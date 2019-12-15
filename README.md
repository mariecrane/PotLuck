# PotLuck

A Flutter application to help people find recipes based on ingredients they already have.

## Flutter and Project Setup

1. Download and install the Flutter SDK for your operating system through the instructions found
[here](https://flutter.dev/docs/get-started/install).

 - Unless you want to add Flutter to your PATH environment variable every time you want to use it,
   pay close attention to the section on updating your path permanently.

 - You must follow at least one (or both) of the platform-specific (iOS/Android) sets of instructions
   to be able to build the app, including instructions for setting up an emulator if you do not have
   a physical device to install the app to.

2. In a terminal, clone this repo in a directory of your choice.
```shell
$ git clone https://github.com/mariecrane/PotLuck.git
$ cd PotLuck
```

3. Follow the instructions in [SECRETS.md](assets/SECRETS.md) **only through step 2**.

4. Download and install the Google Services config file for your platform.

 - For running on iOS devices:

    1. Download [GoogleService-Info.plist](https://drive.google.com/a/macalester.edu/file/d/1mOMK-JNNkj9TJsLE747CmMYSvjcgy6Zr/view?usp=sharing)

    2. Using XCode, drag the file into the **Runner/Runner/** directory of your Flutter app.
    **It is very important to use XCode to complete this step, as the app will not build properly otherwise!** Check out [this tutorial](https://alligator.io/flutter/firebase-setup/#step-2-download-config-file-1) to see an example of what this should look like.

 - For running on Android devices:

    1. Download [google-services.json](https://drive.google.com/a/macalester.edu/file/d/1joJExrkmtkXLn-wJM6vyGrXR7d14g2rK/view?usp=sharing)

    2. Move the config file into the **android/app/** directory of your Flutter app. Unlike for iOS, you can do this however you wish.

5. In a terminal, get the Flutter plugin dependencies for the project.
   ```shell
   $ cd <path/to/project/root>
   $ flutter pub get
   ```

6. Run the app.

 - For running on iOS devices:

    1. Open the project in XCode, if not already opened.

    2. Near the run and stop buttons at the top of the window, select which device to run the app on. You can choose a connected iOS device or an iOS simulator. To run on your own device, you may need to modify your device management settings to allow PotLuck to build. Go to Settings/General/Profiles & Device Management and tap "Trust Apple Development"

    3. Press the white Run button in the top left corner of XCode. (Looks like a play button, a triangle pointing to the right.)

 - For running on Android devices:

    1. Open the project in Android Studio, if not already opened.

    2. Near the top of the window, select the device you want to run the app on. If nothing is selected, the dropdown will read "no devices". If no devices are available from the dropdown, you need to [connect a physical Android device](https://developer.android.com/studio/run/device) or [create a virtual device](https://developer.android.com/studio/run/managing-avds#createavd).

    3. Press the green Run button toward the top right of the window. (Looks like a play button, a triangle pointing to the right.)
