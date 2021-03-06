#   AutoVersion for Xcode, for ObjC
#   Copyright 2015 Malcolm Teas, see https://github.com/malcolmteas/AutoVersionXcode

#   This uses the Version (CFBundleShortVersionString), Build (CFBundleVersion), and Bundle
#   Identifier fields in your project's General tab (or in the Info.plist file).

#   The copyright info comes from a Copyright.xcconfig file that's added into the
#   project's configurations.  The COPYRIGHT_NAME and COPYRIGHT_YEAR values could be added in
#   any other config file.  Alternately, you could add a user-defined build setting too.

#   The version is a three digit version like 1.2.3 as in http://semver.org followed by d for
#   development, a for alpha, or b for beta.  Release has no letter.  When you submit to the
#   app store it will need to be as a release, no trailing letters and in Release
#   configuration. Multiple betas, for example, can be done as 1.2.3b3 for beta 3.  This works
#   for development or alpha versions if you use those.  Development means "not at all feature
#   complete". Alpha is "mostly feature complete".  Beta is "feature complete, but buggy".
#   Some groups use a "Final" which is for testing just pre-release.  Using development,
#   alpha, beta, or final is completely optional.

#   All values are created in version.h to be used at runtime.  Some data is printed
#   in the build log for reference as well.  Good practice is to let version.h be
#   regenerated each build and to avoid storing it in your source code repository.

#   Get the version, and extract the parts of it
version=`/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${INFOPLIST_FILE}" `
phaseLetter=${version//[^a-z]/}
phaseLetter=`echo $phaseLetter | tr "[:lower:]" "[:upper:]"`
phaseNumber=${version##*[a-z]}
simpleVersion=${version%%[a-z]*}

#   Get the git commit hash short version so we can track builds in the repo
buildHash=`git rev-parse --short=5  HEAD | tr "[:lower:]" "[:upper:]"`
if ! git diff --quiet
then
    buildHash="${buildHash}-dirty"      # Has un-committed changes.
fi

#   The build number needs to increment for each app store submission. Here it's
#   automatically updated for each release build, in hex format for compactness.
buildNumber=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${INFOPLIST_FILE}" `
if [ "$CONFIGURATION" = "Release" ]
then
    buildNumber=$(($buildNumber + 1))
    buildNumber=$(printf "%X" $buildNumber)
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${INFOPLIST_FILE}"
fi
buildCode="${buildNumber}-${buildHash}"

#   Put it all together
fullversion="${version}-${buildCode}"

#   Get app id
appID=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "${INFOPLIST_FILE}" `

#  Write out the version to the console
echo "${PRODUCT_NAME} ${fullversion} built in ${CONFIGURATION} configuration"
echo "Build with ${SDK_NAME} with Xcode ${XCODE_VERSION_ACTUAL}. (See version.h.)"

#  Write out the version.h file
echo "//  Application version information automatically generated at build time." > version.h
echo "//  Do not commit this file to your code repository." >> version.h
echo "//  This is generated by a script in Run Script build phase." >> version.h
echo "//  See script for details on updating version and copyright." >> version.h

echo >> version.h
echo "//  Application information" >> version.h
echo "#define ApplicationName @\"${PRODUCT_NAME}\"" >> version.h
echo "#define BundleID @\"${appID}\""  >> version.h
echo "#define Configuration @\"${CONFIGURATION}\"    // Configuration: Debug, Release, etc" >> version.h
echo "#define CopyrightName @\"${COPYRIGHT_NAME}\"" >> version.h
echo "#define CopyrightYear @\"${COPYRIGHT_YEAR}\"" >> version.h
echo "#define Copyright = \"Copyright ${COPYRIGHT_YEAR} by ${COPYRIGHT_NAME}. All rights reserved.\"" >> version.h

echo >> version.h
echo "//  Version information" >> version.h
echo "#define FullVersion @\"${fullversion}\"" >> version.h
echo "#define Version @\"${version}\"    // From General tab or short bundle string in plist file" >> version.h
echo "#define SimpleVersion @\"${simpleVersion}\"" >> version.h

echo >> version.h
echo "//  Information about this build" >> version.h
echo "#define BuildNumber ${buildNumber}    // Increment this by changing CFBundleVersion in app plist." >> version.h
echo "#define BuildHash @\"${buildHash}\"    // git commit hash" >> version.h
echo "#define BuildCode @\"${buildCode}\"" >> version.h

echo >> version.h
echo "//  Environment version" >> version.h
echo "#define XCODE_VERSION @\"${XCODE_VERSION_ACTUAL}\"" >> version.h
echo "#define SDK_NAME @\"${SDK_NAME}\"" >> version.h
echo "#define DEPLOYMENT_TARGET = \"${IPHONEOS_DEPLOYMENT_TARGET}\"" >> version.h

echo >> version.h
echo "//  Development phase" >> version.h
if [[ "${phaseLetter}" == "dD" ]]
then
    echo "#define ReleasePhase @\"dev\"" >> version.h
    echo "#define Dev" >> version.h
    echo "#define PhaseNumber ${phaseNumber}" >> version.h
fi
if [[ "$phaseLetter" == "A" ]]
then
    echo "#define ReleasePhase @\"alpha\"" >> version.h
    echo "#define Alpha" >> version.h
    echo "#define PhaseNumber ${phaseNumber}" >> version.h
fi
if [[ "$phaseLetter" == "B" ]]
then
    echo "#define ReleasePhase @\"beta\"" >> version.h
    echo "#define Beta" >> version.h
    echo "#define PhaseNumber ${phaseNumber}" >> version.h
fi
if [[ "$phaseLetter" == "F" ]]
then
    echo "#define ReleasePhase @\"final\"" >> version.h
    echo "#define Final" >> version.h
    echo "#define PhaseNumber ${phaseNumber}" >> version.h
fi
if  [[ "$phaseLetter" == "" ]]
then
    echo "#define ReleasePhase @\"release\"" >> version.h
    echo "#define Release" >> version.h
    echo "#define PhaseNumber 0" >> version.h
fi
