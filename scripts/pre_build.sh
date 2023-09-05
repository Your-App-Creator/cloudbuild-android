#!/bin/sh
# pre-build; written 2020-2023 by Martin Zeitler
# https://developer.android.com/studio#command-tools
CLI_TOOLS_VERSION=10406996
CLI_TOOLS_ZIP_FILE=commandlinetools-linux-${CLI_TOOLS_VERSION}_latest.zip

# A) Android command-line tools (has sdkmanager)
# https://developer.android.com/studio#command-tools
wget -q https://dl.google.com/android/repository/${CLI_TOOLS_ZIP_FILE}
unzip -qq ${CLI_TOOLS_ZIP_FILE} -d "${ANDROID_HOME}"
rm ${CLI_TOOLS_ZIP_FILE}

# Android SDK licenses
# https://developer.android.com/studio/command-line/sdkmanager.html
yes | "${ANDROID_HOME}"/tools/bin/sdkmanager --sdk_root="${ANDROID_HOME}" --licenses >/dev/null

# Android Platform Tools
PACKAGES="platform-tools"

# Cloud Build trigger substitution ${_ANDROID_SDK_PACKAGES}
if [ "x$ANDROID_SDK_PACKAGES" = "x" ] ; then
    echo _ANDROID_SDK_PACKAGES not provided by build trigger, installing ${PACKAGES}.
else
    PACKAGES=$ANDROID_SDK_PACKAGES
fi

# Installing all Android SDK Packages at once, in order to query the repository only once.
echo "${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --install ${PACKAGES}"
"${ANDROID_HOME}"/tools/bin/sdkmanager --sdk_root="${ANDROID_HOME}" --install "$PACKAGES"


# B) Change the version in gradle-wrapper.properties
# Cloud Build trigger substitution ${_GRADLE_WRAPPER_VERSION}
if [ "x$GRADLE_WRAPPER_VERSION" = "x" ] ; then
    echo _GRADLE_WRAPPER_VERSION not provided by build trigger, using the default version. ;
else
    if [ "$GRADLE_WRAPPER_VERSION" != "8.2" ] ; then
        WRAPPER_PROPERTIES=/workspace/gradle/wrapper/gradle-wrapper.properties
        sed -i -e "s/8\.2/${GRADLE_WRAPPER_VERSION}/g" ${WRAPPER_PROPERTIES}
    fi
fi
