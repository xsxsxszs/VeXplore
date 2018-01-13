# !/bin/bash


ANNOTATED_TAG_NAME="baseVersioningTag"
VERSIONING_XCCONFIG_FILE_PATH="${SRCROOT}/Version.xcconfig"

if [ ! -e $VERSIONING_XCCONFIG_FILE_PATH ]; then
    touch $VERSIONING_XCCONFIG_FILE_PATH
fi

pushd "$SRCROOT" >/dev/null
    # Fetch Git Output
    GIT_DESCRIBE_OUTPUT=$(git describe --match $ANNOTATED_TAG_NAME) # e.g., baseVersioningTag-423-g41438bd

    # Use Internal Field Separator to split on "-"
    IFS='-'
    GIT_DESCRIBE_COMPONENTS=($GIT_DESCRIBE_OUTPUT) # baseVersioningTag 423 g41438bd
    unset IFS
    VERSION_NUMBER=${GIT_DESCRIBE_COMPONENTS[1]}

    ## Write Build Configuration Values to Xcode Versioning file
    if [ -z $VERSION_NUMBER ]
    then
        echo "BUILD_NUMBER = 1" > $VERSIONING_XCCONFIG_FILE_PATH # set default value if VERSION_NUMBER is empty
    else
        echo "BUILD_NUMBER = ${VERSION_NUMBER}" > $VERSIONING_XCCONFIG_FILE_PATH
    fi

    # Finish file with a Touch
    touch $VERSIONING_XCCONFIG_FILE_PATH
popd >/dev/null
