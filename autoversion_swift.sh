#   Copyright 2015-2023 Malcolm Teas.  See https://github.com/malcolmteas/AutoVersionXcode

#   This uses the Version (CFBundleShortVersionString), Build (CFBundleVersion), and
#   Bundle Identifier fields in your project's General tab (also found in the Info.plist 
#   file) to determine the version and build number and app id.

#   The copyright info comes from user-defined settings in the Build Settings (these can
#   in an also be in an .xcconfig file as well). The COPYRIGHT_NAME is used for the
#   copyright owner and COPYRIGHT_YEAR is the year of copyright. If the below CopyrightUpdating variable is defined, then COPYRIGHT_YEAR is the start year of 
#   copyright and is automatically update to the current year such as 2008-2021.

#   The version is a three digit version like 1.2.3 as in http://semver.org. You can 
#   optionally add a RELEASE_TAG user-defind build value (same as for copyright) that
#   is made to be part of the version such as "beta 1". This is used to avoid confusing
#   the bare version for the App store and TestFlight beta releases.

#   All values are created in the file version.swift to be used at runtime.  Some data is
#   printed in the build log for reference as well.  Do not commit version.swift to your
#   git code repository as it's regenerated with each new build.

#   Define this to enable automatic copyright year updating, comment it out to disable.
CopyrightUpdating=1

#   Get the git commit hash short version so we can track builds in the repo
buildHash=`git rev-parse --short=5  HEAD | tr "[:lower:]" "[:upper:]"`
if ! git diff --quiet
then
    buildHash="${buildHash}(dirty)"      # Has un-committed changes.
fi

if ${Stage}
then
    Stage = "${Stage}-${StageNumber}"
else
    Stage = ""
fi

#   Assemble version information
if [ -z "${RELEASE_TAG}" ]
then
    releaseTag=""
else
    releaseTag="${RELEASE_TAG}"
fi
buildNumber=${CURRENT_PROJECT_VERSION}
simpleVersion="${MARKETING_VERSION} ${releaseTag}"
version="${MARKETING_VERSION} (${buildNumber}) ${releaseTag}"
fullVersion="${MARKETING_VERSION} (${buildNumber}) ${releaseTag} ${buildHash}"

if [ ! -z $CopyrightUpdating ]
then
    year=`date "+%Y"`
    if [ "${year}" != "${COPYRIGHT_YEAR}" ]
    then
        COPYRIGHT_YEAR="${COPYRIGHT_YEAR}-${year}"
    fi
fi

#  Write out the version to the console
echo "> ${PRODUCT_NAME} ${fullVersion}, Copyright by ${COPYRIGHT_NAME} ${COPYRIGHT_YEAR}"
echo "> Built in ${CONFIGURATION} configuration by Xcode ${XCODE_VERSION_ACTUAL} for ${SDK_NAME} and compatible with ${IPHONEOS_DEPLOYMENT_TARGET}."

#  Write out the version.swift file
echo "//  Application version information automatically generated at build time." > ${PROJECT}/version.swift
echo "//  Do not edit this file." >> ${PROJECT}/version.swift
echo "//  Do not commit this file to your code repository." >> ${PROJECT}/version.swift
echo "//  This is generated by a script in Run Script build phase. See script for" >> ${PROJECT}/version.swift
echo "//  details on updating version, release tag (such as beta) and copyright." >> ${PROJECT}/version.swift

echo >> ${PROJECT}/version.swift
echo "//  Application information" >> ${PROJECT}/version.swift
echo "let ApplicationName = \"${PRODUCT_NAME}\"" >> ${PROJECT}/version.swift
echo "let Configuration = \"${CONFIGURATION}\"    // Configuration: Debug, Release, etc" >> ${PROJECT}/version.swift
echo "let CopyrightName = \"${COPYRIGHT_NAME}\"" >> ${PROJECT}/version.swift
echo "let CopyrightYear = \"${COPYRIGHT_YEAR}\"" >> ${PROJECT}/version.swift
echo "let Copyright = \"Copyright \\(CopyrightYear) by \\(CopyrightName). All rights reserved.\"" >> ${PROJECT}/version.swift

echo >> ${PROJECT}/version.swift
echo "//  Version information" >> ${PROJECT}/version.swift
echo "let SimpleVersion = \"${simpleVersion}\"" >> ${PROJECT}/version.swift
echo "let Version = \"${version}\"    // From General tab or short bundle string in plist" >> ${PROJECT}/version.swift
echo "let FullVersion = \"${fullVersion}\"" >> ${PROJECT}/version.swift

echo >> ${PROJECT}/version.swift
echo "//  Information about this build" >> ${PROJECT}/version.swift
echo "let BuildNumber = \"${buildNumber}\"    // Increment this by changing CFBundleVersion in app plist." >> ${PROJECT}/version.swift
echo "let BuildHash = \"${buildHash}\"        // git commit hash (dirty if not checked in)" >> ${PROJECT}/version.swift
echo "let BuildDate = \"`date -u`\"" >> ${PROJECT}/version.swift

echo >> ${PROJECT}/version.swift
echo "//  Environment version" >> ${PROJECT}/version.swift
echo "let XCODE_VERSION = \"${XCODE_VERSION_ACTUAL}\"" >> ${PROJECT}/version.swift
echo "let SDK_NAME = \"${SDK_NAME}\"" >> ${PROJECT}/version.swift
echo "let DEPLOYMENT_TARGET = \"${IPHONEOS_DEPLOYMENT_TARGET}\"" >> ${PROJECT}/version.swift
