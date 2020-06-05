# tapper

A mobile game built using the Flutter framework. Compatible with Android and iOS

![App Screenshot 1](/screenshots/screenshot_1.png)

![App Screenshot 1](/screenshots/screenshot_2.png)

## About

The game involves tapping on a box to increase the score. Tapping too late or tapping the wrong box will lead to a loss.

The main code game is stored in game.dart where game UI and logic is handled.

## Download Links

https://bit.ly/tapperandroid

https://bit.ly/tapperios

## Getting Started

### Step 1: Clone the repository

`git clone https://github.com/aligorithm/tapper.git`

### Step 2: Pull dependencies (Required)

`flutter pub get`

### Step 3: Change bundle identifiers (Required)

**Android**

- Open the project in Android Studio
- Open the Android Manifest file
- Use the refactor option to change _ng.i.aligorithm.tapper_ to your chosen identifier
- Open the app level build.gradle file and change the bundle identifier there as well

**iOS**

- Run `open ios/Runner.xcworkspace` to to open the project in Xcode
- Select the "Runner" target and change the bundle identifier

### Signing (Required for release build)

Follow the procedures in the below links to configure signing for Android and iOS respectively.

https://flutter.dev/docs/deployment/android

https://flutter.dev/docs/deployment/ios

### Google Play Games and Apple Game Center

You may choose to include or exclude this feature. Game Center is quite straightforward, but Google Play Games is a bit tricky. Use [This link](https://developer.apple.com/library/archive/documentation/LanguagesUtilities/Conceptual/iTunesConnectGameCenter_Guide/Introduction/Introduction.html) to configure iOS and [this link](https://github.com/flame-engine/play_games/blob/master/doc/signin.md) to configure Android.

To configure Play Games and Game Center leaderboard ids, create Constants.dart in lib/ and paste the following code:

`class Constants {
  static const String android_leaderboard_id = "PASTE_ANDROID_LEADERBOARD_ID";
  static const String ios_leaderboard_id = "PASTE_IOS_LEADERBOARD_ID";
}`

### Platform

[Flutter SDK](https://flutter.dev)
