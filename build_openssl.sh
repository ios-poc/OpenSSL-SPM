#!/bin/bash
set -e

OPENSSL_VERSION="3.3.2"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="${SCRIPT_DIR}/build"
OPENSSL_DIR="${BUILD_DIR}/openssl-${OPENSSL_VERSION}"

# Check for spaces in path
if [[ "$SCRIPT_DIR" == *" "* ]]; then
    echo "Warning: Script directory contains spaces: $SCRIPT_DIR"
    echo "This may cause build issues. Consider moving to a path without spaces."
fi

# Clean previous builds
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Download OpenSSL
cd "${BUILD_DIR}"
echo "Downloading OpenSSL ${OPENSSL_VERSION}..."
curl -L -O "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"

# Verify download
if [ ! -f "openssl-${OPENSSL_VERSION}.tar.gz" ]; then
    echo "Error: Download failed"
    exit 1
fi

# Check file size (should be several MB, not bytes)
file_size=$(stat -f%z "openssl-${OPENSSL_VERSION}.tar.gz" 2>/dev/null || stat -c%s "openssl-${OPENSSL_VERSION}.tar.gz" 2>/dev/null)
if [ "$file_size" -lt 1000000 ]; then
    echo "Error: Downloaded file is too small ($file_size bytes), probably not a valid archive"
    echo "File contents:"
    head -20 "openssl-${OPENSSL_VERSION}.tar.gz"
    exit 1
fi

echo "Extracting OpenSSL..."
tar -xzf "openssl-${OPENSSL_VERSION}.tar.gz"

# Get SDK paths
IPHONE_SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)
SIMULATOR_SDK_PATH=$(xcrun --sdk iphonesimulator --show-sdk-path)

# Verify SDK paths
if [ ! -d "$IPHONE_SDK_PATH" ] || [ ! -d "$SIMULATOR_SDK_PATH" ]; then
    echo "Error: Could not find iOS SDKs"
    echo "iPhone SDK: $IPHONE_SDK_PATH"
    echo "Simulator SDK: $SIMULATOR_SDK_PATH"
    exit 1
fi

# Build for iOS Device (arm64)
cd "${OPENSSL_DIR}"
echo "Building for iOS Device (arm64)..."
echo "Using iPhone SDK: ${IPHONE_SDK_PATH}"

# Configure for iOS device build
./Configure ios64-xcrun \
    --prefix="${BUILD_DIR}/ios-arm64" \
    -isysroot "${IPHONE_SDK_PATH}" \
    -miphoneos-version-min=12.0 \
    no-shared no-dso no-hw no-engine no-async no-tests

make clean
make -j$(sysctl -n hw.ncpu)
make install_sw

# Build for iOS Simulator (arm64 only - universal builds are complex)
echo "Building for iOS Simulator (arm64)..."
echo "Using Simulator SDK: ${SIMULATOR_SDK_PATH}"

make clean
./Configure iossimulator-xcrun \
    --prefix="${BUILD_DIR}/ios-simulator" \
    -isysroot "${SIMULATOR_SDK_PATH}" \
    -mios-simulator-version-min=12.0 \
    no-shared no-dso no-hw no-engine no-async no-tests

make -j$(sysctl -n hw.ncpu)
make install_sw

# Verify libraries were created
cd "${BUILD_DIR}"
echo "Verifying build outputs..."

if [ ! -f "ios-arm64/lib/libssl.a" ] || [ ! -f "ios-arm64/lib/libcrypto.a" ]; then
    echo "Error: iOS arm64 libraries not found"
    ls -la ios-arm64/lib/ || echo "ios-arm64/lib/ directory not found"
    exit 1
fi

if [ ! -f "ios-simulator/lib/libssl.a" ] || [ ! -f "ios-simulator/lib/libcrypto.a" ]; then
    echo "Error: iOS simulator libraries not found"
    ls -la ios-simulator/lib/ || echo "ios-simulator/lib/ directory not found"
    exit 1
fi

# Check library architectures
echo "Checking library architectures..."
echo "iOS Device libssl.a:"
lipo -info ios-arm64/lib/libssl.a
echo "iOS Simulator libssl.a:"
lipo -info ios-simulator/lib/libssl.a

# Create XCFrameworks
echo "Creating SSL XCFramework..."
xcodebuild -create-xcframework \
    -library "ios-arm64/lib/libssl.a" \
    -headers "ios-arm64/include" \
    -library "ios-simulator/lib/libssl.a" \
    -headers "ios-simulator/include" \
    -output "OpenSSL_SSL.xcframework"

echo "Creating Crypto XCFramework..."
xcodebuild -create-xcframework \
    -library "ios-arm64/lib/libcrypto.a" \
    -headers "ios-arm64/include" \
    -library "ios-simulator/lib/libcrypto.a" \
    -headers "ios-simulator/include" \
    -output "OpenSSL_Crypto.xcframework"

# Final verification
echo ""
echo "Build completed successfully!"
echo "Created XCFrameworks:"
echo "  SSL Framework: ${BUILD_DIR}/OpenSSL_SSL.xcframework"
echo "  Crypto Framework: ${BUILD_DIR}/OpenSSL_Crypto.xcframework"
echo ""
echo "XCFramework info:"
xcodebuild -xcframework -info OpenSSL_SSL.xcframework
echo ""
echo "You can now drag these XCFrameworks into your Xcode project."