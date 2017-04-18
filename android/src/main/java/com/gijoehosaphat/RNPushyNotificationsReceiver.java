package com.gijoehosaphat;

import android.content.Intent;
import android.content.Context;
import android.content.BroadcastReceiver;
import android.util.Log;

import static com.gijoehosaphat.RNPushyNotificationsModule.TAG;
import static com.gijoehosaphat.RNPushyNotificationsModule.USER_INTERACTION;

public class RNPushyNotificationsReceiver extends BroadcastReceiver {

  @Override
  public void onReceive(Context context, Intent intent) {
    if (RNPushyNotificationsModule.isActive == true) { //Send event to app...
      intent.putExtra(USER_INTERACTION, false);
      RNPushyNotificationsModule.sendEvent(intent);
      Log.d(TAG, "onReceive: App is Active");
    } else { //Create tray notification...
      new RNPushyNotification(context, intent).sendNotification();
      Log.d(TAG, "onReceive: App is Inactive");
    }
  }

}
