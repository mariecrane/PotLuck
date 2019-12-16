# PotLuck

PotLuck is a cross-platform flutter application that helps people find recipes based on the ingredients
that they already have. We believe in reducing food waste by using every ingredient in your pantry.
You can do this by cooking alone or by cooking with friends, pooling together your available ingredients.
PotLuck facilitates this process and makes it easy to decide what to cook.

## Flutter and Project Setup

1. Download and install the Flutter SDK for your operating system through the instructions found
[here](https://flutter.dev/docs/get-started/install).

 - Unless you want to add Flutter to your PATH environment variable every time you want to use it,
   pay close attention to the section on updating your path permanently.

 - You must follow at least one (or both) of the platform-specific (iOS/Android) sets of instructions
   to be able to build the app, including instructions for setting up an emulator if you do not have
   a physical device to install the app to.
 
 - If installing Flutter on iOS, make sure to follow the steps to install and set up CocoaPods. 

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

    2. Near the run and stop buttons at the top of the window, select which device to run the app on. You can choose a connected iOS device or an iOS simulator. To run on your own device, you need to [set up a signing configuration and trust yourself as the developer on your device](https://medium.com/front-end-weekly/how-to-test-your-flutter-ios-app-on-your-ios-device-75924bfd75a8).

    3. Press the white Run button in the top left corner of XCode. (Looks like a play button, a triangle pointing to the right.)

 - For running on Android devices:

    1. Open the project in Android Studio, if not already opened.

    2. Near the top of the window, select the device you want to run the app on. If nothing is selected, the dropdown will read "no devices". If no devices are available from the dropdown, you need to [connect a physical Android device](https://developer.android.com/studio/run/device) or [create a virtual device](https://developer.android.com/studio/run/managing-avds#createavd).

    3. Press the green Run button toward the top right of the window. (Looks like a play button, a triangle pointing to the right.)


### Frequently Asked Question

1. How do I add/remove friends?

-To Add: On the Search Page, at the lower right of the page, there is a floating orange button with an add friends icon. After pressing the button, the Friends Page will show. You must know your friend's email address beforehand through off-App communications so that you are able to enter their email in the prompted section. After typing, press the orange Add button. This will send a friend request to that account. Friend Requests show underneath the Friend Requests section on the same page. It is empty if there are none. When you get a request, the friend's image and email will be displayed along with a green add icon. Pressing the icon will add them into your friend list.

-To Remove: Route to the Friends Page *note above's instructions*. Your friends are listed on this page. Following their email, there is a red icon. When that icon is pressed, an alert will prompt you to continue or cancel your unfriending request. If confirmed, that account will be taken off you friend's list.

2.What is the Pantry?

-The Pantry is where you store information about the ingredients you have. It mimics a real pantry, cupboard, refrigerator that contains ingredients for usage. These ingredients in the Pantry can be realistic or to the will of the user. Ingredients can be added and removed at any time. When added to the Pantry, it will also show on the Search page to allow an easier selection of ingredients for the recipe search.

3. How do I change my profile picture?

-On the Profile Page, the default image is a User with an orange background. When this circle image is pressed, it will prompt the user to change their image to an existing image on their device. There are editing features available.

4. Can I change my email/password?

-To change your email and/or password, there is an Edit Profile button located on the Profile Page. When pressed, another page will show. In order to change for any option, THE CURRENT PASSWORD MUST BE ENTERED FIRST into the prompted box. Enter the desired new email and/or password into the prompted areas and press the following button to change.

5. How do I add ingredients that are not in a Pantry to my Search?

-Some users may wish to add additional ingredients that realistically may not be in their possession. Most common cases are for hypothetical searches. On the Search Page, there is a prompted search bar at the top of the page. This can be used to search for an ingredient that may reside in any of the User or Friends' pantries, or it can be used to add ingredients to an others catagory. When an ingredient is typed in, if it does not exist in any pantries, it will prompt to add to the Others section. Press this option and a new drop down will be created, similar to your friends' pantries, where ingredients can be deselected from the search.