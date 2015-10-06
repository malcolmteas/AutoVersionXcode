# Auto Version Script for Xcode

AutoVersion is a script you put in your Xcode project's "Build Phase" to create a version file for your app.  This file contains code-readable values with your app version, name, copyright, and environmental information such as SDK and Xcode versions.  You can use this for logging or for user display.

There are two versions of this, one for Objective-C and another for Swift.  They generate equivalent output in a file named version.h (for ObjC) or version.swift (Swift).

## Installation

In your Xcode project do the following:

* Select your project's target you want to add the script to, then select the "Build Phases" tab.
* Create a new "Run Script" phase with the "+" sign at the top left of the pane.
* Position your new run script phase immediately after "Target Dependencies" phase.  This script needs to run before the Compile Sources phase.
* Copy and paste the script contents from the Swift or ObjC version as appropriate for your project.
* Change the default shell from "/bin/sh" to "/bin/bash" at the top of the Run Scripts pane.  (This script uses some bash-only matching operations.) 
* Make sure you do not archive the version.h or version.swift file in your git repository as it's generated for you each time you build your application.


## Use

These are some notes on some ways to use the auto version scripts in your project.  I cover the items the script generates and how they can be used.

### Copyright

Most of the script is concerned with the app or build environment versions.  But the script also can help make the copyright available in your code.   The auto version scripts will look for `COPYRIGHT_NAME` and `COPYRIGHT_YEAR` variables in your build environment. These have to be added by you.  These are user-defined build settings in your project file such as:
<pre>
COPYRIGHT_YEAR = 2015
COPYRIGHT_NAME = Malcolm X
</pre>

These are optional.  If you don't use them, then the eqivalent strings in the version file will be empty.  An alternate way to handle copyright that works across multiple languages is to define a string in your strings file instead of using this.

### Versions

This script supports using a git code repository and using [semantic versioning](http://semver.org) version numbering.  More specifically it supports an extension of that version numbering that follows the verison with "d" for development, "a" for alpha, "b" for beta, and "f" for final.  These are all optional.  If they are used, then the script will generate a FullVersion value that looks like: `1.0.0d5-1-0B13E-dirty`.  

In this example the app is 1.0.0 version, development version 5, build 1, with git hash `0B13E` and is dirty, ie there are code changes that are not yet checked into the repository.  This FullVersion is good for logging, but you might not way to expose it to end users in a release version.

So the auto version script breaks down this FullVersion into components with the following names:
* SimpleVersion: `1.0.0`
* Version: `1.0.0d5`
* BuildNumber: `1`
* BuildHash: `0B13E-dirty`
* BuildCode: `1-0B13E-dirty`

### Release Phases

The extension to version numbering I'm using here for the release phases are completely optional.  These are the definitions that that have been useful.

* Development - Not feature complete, code is being built out and is very much a work in progress
* Alpha - Not feature complete but largely so.  The app looks pretty much like it will when done now.  Those features that are compelete are testable.
* Beta - Feature complete, but expected to be buggy and possibly unstable.  Generally serious testing begins now.
* Final - Undergoing final regression testing before release. If it passes, then this is the release software.
* Release - There's no letter here, it's the final GA (Generally Available) product now.

These release phases are separate from the "Release" build configuration that Xcode uses to build the app.  Although, generally the beta through release phases are built for testing and distribution as release builds.  (The app review process will require a release configuration build for submission in any case and if you're using TestFlight for beta, it'll require a release build there too.)

The auto version scripts have values to indicate the release phase of the code.  This can be used to switch on or off debugging and logging code.

The release phase values with our example are:

* ReleasePhase `@dev` or `ReleasePhaseEnum = .Dev`
* PhaseNumber `5`

In the Swift version, the ReleasePhaseEnum is defined.  In the ObjC version the script also creates a #define as "Dev" or "Beta", etc.

### Configuration

The configuration items cover the configuration of the build (Develop or Release), the Xcode and SDK versions, and the minimum deployment target.  These are from environment variables from the build environment.  

It's useful to log these in your app or to report them to help you determine the user base you're on, and where problems many be found.  Perhaps they're specific to a particular SDK or Xcode version?  I would not use these to determine if an API is available or not. This is intended for logging and tracking.
