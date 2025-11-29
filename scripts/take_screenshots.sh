#!/bin/bash

# Screenshot automation script for System26
# Takes screenshots in all supported languages

set -e

PROJECT_DIR="/Users/ccheney/Projects/apple-foundation-models-benchmarking"
OUTPUT_DIR="$PROJECT_DIR/fastlane/screenshots"
SCHEME="System26"
PROJECT="$PROJECT_DIR/System26.xcodeproj"

# Devices
IPHONE_DEVICE="iPhone 17 Pro Max"
IPAD_DEVICE="iPad Pro 13-inch (M4)"

# All supported languages
LANGUAGES=("en" "de" "es" "fr" "it" "ja" "ko" "pt" "vi" "zh-Hans")

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to take screenshots for a device and language
take_screenshots() {
    local device="$1"
    local lang="$2"
    local device_dir

    # Create directory name from device
    device_dir=$(echo "$device" | tr ' ' '_' | tr -d '()')

    echo "📸 Taking screenshots for $device in $lang..."

    # Create output folder
    local out_folder="$OUTPUT_DIR/${lang}/${device_dir}"
    mkdir -p "$out_folder"

    # Find the simulator UDID (filter for iOS 26)
    local udid=$(xcrun simctl list devices available -j | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data['devices'].items():
    if 'iOS-26' in runtime:
        for dev in devices:
            if '$device' in dev['name'] and dev['isAvailable']:
                print(dev['udid'])
                sys.exit(0)
" 2>/dev/null)

    if [ -z "$udid" ]; then
        echo "❌ Could not find simulator: $device"
        return 1
    fi

    echo "   Using simulator UDID: $udid"

    # Boot simulator
    xcrun simctl boot "$udid" 2>/dev/null || true

    # Set language and locale
    local lang_upper=$(echo "$lang" | tr '[:lower:]' '[:upper:]')
    xcrun simctl spawn "$udid" defaults write "Apple Global Domain" AppleLanguages -array "$lang"
    xcrun simctl spawn "$udid" defaults write "Apple Global Domain" AppleLocale -string "${lang}_${lang_upper}"

    # Run UI tests with specific language
    echo "   Running UI tests..."
    xcodebuild test \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,id=$udid" \
        -testLanguage "$lang" \
        -only-testing:System26UITests/ScreenshotTests/testTakeScreenshots \
        -derivedDataPath "$PROJECT_DIR/DerivedData" \
        2>&1 || true

    # Find and copy screenshots from test results
    echo "   Extracting screenshots..."
    local result_bundle=$(find "$PROJECT_DIR/DerivedData/Logs/Test" -name "*.xcresult" -type d -newer "$out_folder" 2>/dev/null | sort | tail -1)

    if [ -n "$result_bundle" ]; then
        echo "   Found result bundle: $result_bundle"

        # Find PNG files in the Data directory by checking file type
        local counter=1
        for data_file in "$result_bundle/Data/"*; do
            if file "$data_file" 2>/dev/null | grep -q "PNG image"; then
                local screenshot_name=$(printf "%02d_Screenshot.png" $counter)
                cp "$data_file" "$out_folder/$screenshot_name"
                echo "   Copied: $screenshot_name"
                ((counter++))
            fi
        done
    fi

    # Shutdown simulator
    xcrun simctl shutdown "$udid" 2>/dev/null || true

    echo "✅ Done with $device in $lang"
    echo "   Screenshots saved to: $out_folder"
}

echo "🚀 Starting screenshot automation..."
echo "   Output: $OUTPUT_DIR"
echo ""

# Take screenshots for each language and device
for lang in "${LANGUAGES[@]}"; do
    take_screenshots "$IPHONE_DEVICE" "$lang"
    take_screenshots "$IPAD_DEVICE" "$lang"
done

# App Store Connect required dimensions (highest resolution)
IPHONE_WIDTH=1284
IPHONE_HEIGHT=2778
IPAD_WIDTH=2064
IPAD_HEIGHT=2752

# Resize screenshots for App Store Connect
resize_screenshots() {
    echo ""
    echo "📐 Resizing screenshots for App Store Connect..."

    for lang in "${LANGUAGES[@]}"; do
        # Resize iPhone screenshots (1284 × 2778)
        local iphone_dir="$OUTPUT_DIR/${lang}/iPhone_17_Pro_Max"
        if [ -d "$iphone_dir" ]; then
            for img in "$iphone_dir"/*.png; do
                if [ -f "$img" ]; then
                    sips -z $IPHONE_HEIGHT $IPHONE_WIDTH "$img" --out "$img" >/dev/null 2>&1
                    echo "   Resized: $img → ${IPHONE_WIDTH}×${IPHONE_HEIGHT}"
                fi
            done
        fi

        # Resize iPad screenshots (2064 × 2752)
        local ipad_dir="$OUTPUT_DIR/${lang}/iPad_Pro_13-inch_M4"
        if [ -d "$ipad_dir" ]; then
            for img in "$ipad_dir"/*.png; do
                if [ -f "$img" ]; then
                    sips -z $IPAD_HEIGHT $IPAD_WIDTH "$img" --out "$img" >/dev/null 2>&1
                    echo "   Resized: $img → ${IPAD_WIDTH}×${IPAD_HEIGHT}"
                fi
            done
        fi
    done

    echo "✅ All screenshots resized for App Store Connect"
}

resize_screenshots

echo ""
echo "🎉 All screenshots complete!"
echo "   Check: $OUTPUT_DIR"
