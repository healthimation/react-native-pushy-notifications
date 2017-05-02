
package com.gijoehosaphat;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.os.AsyncTask;
import android.content.Intent;
import android.content.Context;
import android.content.res.Resources;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import me.pushy.sdk.Pushy;
import me.pushy.sdk.util.exceptions.PushyException;

import java.util.Set;
import java.util.Locale;

public class RNPushyNotificationsModule extends ReactContextBaseJavaModule implements AsyncResponse, LifecycleEventListener {
  public static final String TAG = "RNPushyNotifications";
  public static final String NOTIFICATION_ACTION = "com.gijoehosaphat.pushy.me";
  public static final String INITIAL_NOTIFICATION = "initialNotification";
  public static final String USER_INTERACTION = "userInteraction";
  public static final String NOTIFICATION_EVENT = "NotificationReceived";
  public static boolean isActive = false;

  private static ReactApplicationContext reactContext;

  private boolean isConfigured = false;

  public RNPushyNotificationsModule(ReactApplicationContext reactContext) {
    super(reactContext);
    RNPushyNotificationsModule.reactContext = reactContext;
    RNPushyNotificationsModule.isActive = true;

    this.reactContext.addLifecycleEventListener(this);
  }

  @Override
  public String getName() {
    return "RNPushyNotifications";
  }

  //Configure: Listen and register device w/ Pushy
  @ReactMethod
  public void configure(Promise promise) {
    if (this.isConfigured == false) {
      try {
        Pushy.listen(RNPushyNotificationsModule.reactContext);
        new RegisterAsync(this, promise).execute();
      } catch(Exception ex) {
        Log.e(TAG, "Initialization failed: " + ex.getMessage());
        this.isConfigured = false;
        promise.reject(ex);
      }
    }
  }

  //Subscribe to a Pushy topic...
  @ReactMethod
  public void subscribe(String topic, Promise promise) {
    try {
      Pushy.subscribe(topic, RNPushyNotificationsModule.reactContext);
      promise.resolve(true);
    } catch(PushyException ex) {
      Log.e(TAG, "Subscription failed: " + ex.getMessage());
      promise.reject(ex);
    }
  }

  //Unsubscribe to a Pushy topic...
  @ReactMethod
  public void unsubscribe(String topic, Promise promise) {
    try {
      Pushy.unsubscribe(topic, RNPushyNotificationsModule.reactContext);
      promise.resolve(true);
    } catch(PushyException ex) {
      Log.e(TAG, "Subscription failed: " + ex.getMessage());
      promise.reject(ex);
    }
  }

  //Toggle notifications...
  @ReactMethod
  public void toggleNotifications(boolean enabled, Promise promise) {
    try {
      Pushy.toggleNotifications(enabled, RNPushyNotificationsModule.reactContext);
      promise.resolve(enabled);
    } catch(Exception ex) {
      Log.e(TAG, "Subscription failed: " + ex.getMessage());
      promise.reject(ex);
    }
  }

  @Override
  public void onProcessFinish(RegistrationResult result, Promise promise) {
    if (result.error != null) {
      Log.e(TAG, "Registration failed: " + result.error.getMessage());
      this.isConfigured = false;
      promise.reject(result.error);
    } else {
      Log.d(TAG, "Device token: " + result.deviceToken);
      this.isConfigured = true;

      //Get initial launched notification...
      Activity activity = getCurrentActivity();
      if (activity != null) {
        Intent intent = activity.getIntent();
        intent.putExtra(USER_INTERACTION, true);
        intent.putExtra(INITIAL_NOTIFICATION, true);
        RNPushyNotificationsModule.sendEvent(intent);
        Log.d(TAG, "Initial notification event sent.");
      }
      promise.resolve(result.deviceToken);
    }
  }

  private class RegisterAsync extends AsyncTask<String, Void, RegistrationResult> {
    private Promise promise;
    private AsyncResponse delegate = null;

    public RegisterAsync(AsyncResponse delegate, Promise promise) {
      this.promise = promise;
      this.delegate = delegate;
    }

    @Override
    protected RegistrationResult doInBackground(String... params) {
      RegistrationResult result = new RegistrationResult();
      try {
        result.deviceToken = Pushy.register(RNPushyNotificationsModule.reactContext);
      } catch (PushyException ex) {
        result.error = ex;
      }
      return result;
    }

    @Override
    protected void onPostExecute(RegistrationResult result) {
      delegate.onProcessFinish(result, promise);
    }
  }

  @Override
  public void onHostResume() {
    RNPushyNotificationsModule.isActive = true;
    Log.d(TAG, "isActive set to true.");

    Activity activity = getCurrentActivity();
    if (activity != null) {
      Intent intent = activity.getIntent();
      intent.putExtra(USER_INTERACTION, true);
      intent.putExtra(INITIAL_NOTIFICATION, false);
      RNPushyNotificationsModule.sendEvent(intent);
    }
  }

  @Override
  public void onHostPause() {
    // RNPushyNotificationsModule.isActive = false;
  }

  @Override
  public void onHostDestroy() {
    RNPushyNotificationsModule.isActive = false;
    Log.d(TAG, "isActive set to false.");
  }

  public static void sendEvent(Intent intent) {
    RNPushyNotificationsModule.reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(NOTIFICATION_EVENT, parseIntent(intent));
  }

  private static WritableMap parseIntent(Intent intent) {
    WritableMap params;
    Bundle extras = intent.getExtras();
    if (extras != null) {
      try {
        params = Arguments.fromBundle(extras);
      } catch (Exception e) {
        Log.e(TAG, e.getMessage());
        params = Arguments.createMap();
      }
    } else {
      params = Arguments.createMap();
    }

    try {
      Resources res = reactContext.getResources();
      String packageName = reactContext.getPackageName();
      Locale currentLocale = res.getConfiguration().locale;
      String language = currentLocale.getLanguage();
      Log.d(TAG, language);
      String translationKey = intent.getStringExtra("translation_key");
      Log.d(TAG, translationKey);
      int translationResId = res.getIdentifier(translationKey, "array", packageName);
      Log.d(TAG, Integer.toString(translationResId));
      String[] translations = res.getStringArray(translationResId);
      //We group these into `string-array`s 0 == title, 1 == message
      if (translations != null && translations.length == 2) {
        params.putString("title", translations[0]);
        params.putString("message", translations[1]);
      }
    } catch (Exception ex) {
      Log.e(TAG, ex.getMessage());
    }

    WritableMap wMap = Arguments.createMap();
    wMap.putString("action", intent.getAction());
    params.putMap("intent", wMap);
    return params;
  }
}
