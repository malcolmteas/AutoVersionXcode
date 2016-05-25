#   AutoVersion for Xcode, for Swift
#   Copyright 2015-2016 Malcolm Teas.  See https://github.com/malcolmteas/AutoVersionXcode

#   This uses the Version (CFBundleShortVersionString), Build (CFBundleVersion), and Bundle
#   Identifier fields in your project's General tab (also in the Info.plist file).

#   The copyright info comes from an Copyright.xcconfig file that's added by adding
#   User-Define build settings in the "Build Settings" of the project.  The COPYRIGHT_NAME
#   and COPYRIGHT_YEAR values could be added in any other config file too.

#   The version is a three digit version like 1.2.3 as in http://semver.org followed by d for
#   development, a for alpha, or b for beta.  Release has no letter.  When you submit to the
#   app store it will need to be as a release, no trailing letters and in Release
#   configuration. Multiple betas, for example, can be done as 1.2.3b3 for beta 3.  This works
#   for development or alpha versions if you use those.  Development is "not at all feature
#   complete". Alpha is "mostly feature complete".  Beta is "feature complete, but buggy".  Some
#   groups use a "Final" witch is for testing just pre-release.  Using development, alpha, beta
#   final is completely optional.

#   All values are created in version.swift to be used at runtime.  Some data is printed
#   in the build log for reference as well.

#   Get the version, and extract the parts of it.  Relies on version format as above.
version=`/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${INFOPLIST_FILE}" `
phaseLetter=${version//[^a-z]/}
phaseLetter=`echo $phaseLetter | tr "[:lower:]" "[:upper:]"`
phaseNumber=${version##*[a-z]}
simpleVersion=${version%%[a-z]*}

#   Get the git commit hash short version so we can track builds in the repo
buildHash=`git rev-parse --short=5  HEAD | tr "[:lower:]" "[:upper:]"`
if ! git diff --quiet
then
    buildHash="${buildHash}(dirty)"      # Has un-committed changes.
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
buildCode="(${buildNumber}) ${buildHash}"

#   Put it all together
fullversion="${version} ${buildCode}"

#   Get app id
appID=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "${INFOPLIST_FILE}" `

#  Write out the version to the console
echo "${PRODUCT_NAME} ${fullversion}"
echo "Built in ${CONFIGURATION} configuration with ${SDK_NAME} with Xcode ${XCODE_VERSION_ACTUAL}."

#  Write out the version.swift file
echo "//  Application version information automatically generated at build time." > ${PROJECT}/version.swift
echo "//  Do not commit this file to your code repository." >> ${PROJECT}/version.swift
echo "//  This is generated by a script in Run Script build phase." >> ${PROJECT}/version.swift
echo "//  See script for details on updating version and copyright." >> ${PROJECT}/version.swift

echo >> ${PROJECT}/version.swift
echo "//  Application information" >> ${PROJECT}/version.swift
echo "let ApplicationName = \"${PRODUCT_NAME}\"" >> ${PROJECT}/version.swift
echo "let Configuration = \"${CONFIGURATION}\"    // Configuration: Debug, Release, etc" >> ${PROJECT}/version.swift
echo "let CopyrightName = \"${COPYRIGHT_NAME}\"" >> ${PROJECT}/version.swift
echo "let CopyrightYear = \"${COPYRIGHT_YEAR}\"" >> ${PROJECT}/version.swift
echo "let Copyright = \"Copyright %@ by %@. All rights reserved.\".localizedFormat(CopyrightYear, CopyrightName)" >> ${PROJECT}/version.swift

echo >> ${PROJECT}/version.swift
echo "//  Version information" >> ${PROJECT}/version.swift
echo "let FullVersion = \"${fullversion}\"" >> ${PROJECT}/version.swift
echo "let Version = \"${version}\"    // From Summary tab or short bundle string in plist file" >> ${PROJECT}/version.swift
echo "let SimpleVersion = \"${simpleVersion}\"" >> ${PROJECT}/version.swift

echo >> ${PROJECT}/version.swift
echo "//  Information about this build" >> ${PROJECT}/version.swift
echo "let BuildNumber = \"${buildNumber}\"    // Increment this by changing CFBundleVersion in app plist." >> ${PROJECT}/version.swift
echo "let BuildHash = \"${buildHash}\"        // git commit hash (dirty if not checked in)" >> ${PROJECT}/version.swift
echo "let BuildCode = \"${buildCode}\"" >> ${PROJECT}/version.swift
echo "let BuildDate = \"`date -u`\"" >> ${PROJECT}/version.swift

echo >> ${PROJECT}/version.swift
echo "//  Environment version" >> ${PROJECT}/version.swift
echo "let XCODE_VERSION = \"${XCODE_VERSION_ACTUAL}\"" >> ${PROJECT}/version.swift
echo "let SDK_NAME = \"${SDK_NAME}\"" >> ${PROJECT}/version.swift
echo "let DEPLOYMENT_TARGET = \"${IPHONEOS_DEPLOYMENT_TARGET}\"" >> ${PROJECT}/version.swift

echo >> ${PROJECT}/version.swift
echo "//  Release phase" >> ${PROJECT}/version.swift
echo " enum ReleasePhaseEnum {" >> ${PROJECT}/version.swift
echo "    case Dev, Alpha, Beta, Final, Release" >> ${PROJECT}/version.swift
echo " }" >> ${PROJECT}/version.swift
echo >> ${PROJECT}/version.swift

if [[ "$phaseLetter" == "D" ]]
then
    echo "var ReleasePhase: ReleasePhaseEnum = .Dev" >> ${PROJECT}/version.swift
    echo "let PhaseNumber = ${phaseNumber}" >> ${PROJECT}/version.swift
fi
if [[ "$phaseLetter" == "A" ]]
then
    echo "var ReleasePhase: ReleasePhaseEnum = .Alpha" >> ${PROJECT}/version.swift
    echo "let PhaseNumber = ${phaseNumber}" >> ${PROJECT}/version.swift
fi
if [[ "$phaseLetter" == "B" ]]
then
    echo "var ReleasePhase: ReleasePhaseEnum = .Beta" >> ${PROJECT}/version.swift
    echo "let PhaseNumber = ${phaseNumber}" >> ${PROJECT}/version.swift
fi
if [[ "$phaseLetter" == "F" ]]
then
    echo "var ReleasePhase: ReleasePhaseEnum = .Final" >> ${PROJECT}/version.swift
    echo "let PhaseNumber = ${phaseNumber}" >> ${PROJECT}/version.swift
fi
if  [[ "$phaseLetter" == "" ]]
then
    echo "var ReleasePhase: ReleasePhaseEnum = .Release" >> ${PROJECT}/version.swift
    echo "let PhaseNumber = 0" >> ${PROJECT}/version.swift
fi
