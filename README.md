
# react-native-pushy-notifications

## Getting started

`$ npm install react-native-pushy-notifications --save`

### Mostly automatic installation

`$ react-native link react-native-pushy-notifications`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-pushy-notifications` and add `RNPushyNotifications.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNPushyNotifications.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.gijoehosaphat.RNPushyNotificationsPackage;` to the imports at the top of the file
  - Add `new RNPushyNotificationsPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-pushy-notifications'
  	project(':react-native-pushy-notifications').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-pushy-notifications/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-pushy-notifications')
  	```

### Extra Installation steps

#### Android
  1. AndroidManifest
    ```
    <!-- Pushy Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <!-- End Pushy Permissions -->

    <!-- Pushy Declarations -->
    <!-- Pushy Notification Receiver -->
    <!-- Incoming push notifications will invoke the following BroadcastReceiver -->
    <receiver android:name=".PushReceiver" android:exported="false">
      <intent-filter>
        <!-- Do not modify this -->
        <action android:name="pushy.me" />
      </intent-filter>
    </receiver>

    <!-- Pushy Update Receiver -->
    <!-- Do not modify - internal BroadcastReceiver that restarts the listener service -->
    <receiver android:name="me.pushy.sdk.receivers.PushyUpdateReceiver" android:exported="false">
      <intent-filter>
        <action android:name="android.intent.action.PACKAGE_REPLACED" />
          <data android:scheme="package" />
      </intent-filter>
    </receiver>

    <!-- Pushy Boot Receiver -->
    <!-- Do not modify - internal BroadcastReceiver that restarts the listener service -->
    <receiver android:name="me.pushy.sdk.receivers.PushyBootReceiver" android:exported="false">
      <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
      </intent-filter>
    </receiver>

    <!-- Pushy Socket Service -->
    <!-- Do not modify - internal socket service -->
    <service android:name="me.pushy.sdk.services.PushySocketService"/>
    <!-- End Pushy Declarations -->
    ```
  2. Proguard changes (if you use Proguard)
    ```
      -dontwarn com.fasterxml.**
      -dontwarn org.eclipse.paho.client.mqttv3.**

      -keep class me.pushy.** { *; }
      -keep class com.fasterxml.** { *; }
      -keep class org.eclipse.paho.client.mqttv3.** { *; }
    ```

## Usage
```javascript
import RNPushyNotifications from 'react-native-pushy-notifications'

// TODO: What to do with the module?
RNPushyNotifications
```
