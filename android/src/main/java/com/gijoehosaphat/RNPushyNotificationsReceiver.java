package com.gijoehosaphat;

import android.content.Intent;
import android.content.Context;
import android.content.BroadcastReceiver;
import android.util.Log;

import com.gijoehosaphat.InactiveNotificationHandlerTaskService;

import static com.gijoehosaphat.RNPushyNotificationsModule.TAG;
import static com.gijoehosaphat.RNPushyNotificationsModule.INITIAL_NOTIFICATION;
import static com.gijoehosaphat.RNPushyNotificationsModule.USER_INTERACTION;

public class RNPushyNotificationsReceiver extends BroadcastReceiver {

  @Override
  public void onReceive(Context context, Intent intent) {
    if (RNPushyNotificationsModule.isActive == true) { //Send event to app...
      intent.putExtra(USER_INTERACTION, false);
      intent.putExtra(INITIAL_NOTIFICATION, false);
      RNPushyNotificationsModule.sendEvent(intent);
      Log.d(TAG, "onReceive: App is Active");
    } else { //Create tray notification...
      Intent i= new Intent(context, InactiveNotificationHandlerTaskService.class);
      i.putExtra("foo", "bar");
      context.startService(i);

      new RNPushyNotification(context, intent).sendNotification();
      Log.d(TAG, "onReceive: App is Inactive");
    }
  }

}
