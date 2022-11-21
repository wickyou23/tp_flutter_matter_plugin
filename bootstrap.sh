mkdir -p "unzip" && cd "unzip"

ANDROID_CHIP_LIBRARY_NAME="chip-library-v1.0.0.zip"
IOS_CHIP_LIBRARY_NAME="TPMatter.xcframework.v1.0.0.zip"

curl https://www.dropbox.com/s/qh3m9vj2cdkqnb4/chip-library-v1.0.0.zip -L -o $ANDROID_CHIP_LIBRARY_NAME

unzip $ANDROID_CHIP_LIBRARY_NAME


curl https://www.dropbox.com/s/ppat6qvtet0m4i1/TPMatter.xcframework.v1.0.0.zip -L -o $IOS_CHIP_LIBRARY_NAME

unzip $IOS_CHIP_LIBRARY_NAME

ANDROID_LIB_DIR="../android/libs"
if [ ! -d "$ANDROID_LIB_DIR" ]; then
  mkdir -p $ANDROID_LIB_DIR
fi

IOS_FRAMEWORK_DIR="../ios/Frameworks"
if [ ! -d "$IOS_FRAMEWORK_DIR" ]; then
  mkdir -p $IOS_FRAMEWORK_DIR
fi

cp -R "chip-library-v1.0.0" "../android/libs"
cp -R "TPMatter.xcframework" "../ios/Frameworks"

cd "../" && rm -rf "unzip"