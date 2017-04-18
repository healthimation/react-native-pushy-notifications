package com.gijoehosaphat;

import android.os.Bundle;
import android.os.Build;
import android.app.PendingIntent;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.content.Context;
import android.media.RingtoneManager;
import android.app.NotificationManager;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import static com.gijoehosaphat.RNPushyNotificationsModule.TAG;
import static com.gijoehosaphat.RNPushyNotificationsModule.NOTIFICATION_ACTION;

import java.util.Locale;

public class RNPushyNotification {
  private Intent intent;
  private Context context;

  public RNPushyNotification(Context context, Intent intent) {
    this.context = context;
    this.intent = intent;
  }

  public void sendNotification() {

    Resources res = this.context.getResources();
    String packageName = this.context.getPackageName();

    // Default notification title
    //Small default Icon
    int defaultTitleResId = res.getIdentifier("default_notiication_title", "string", packageName);
    String title = this.context.getString(defaultTitleResId);
    String message = null;

    // Attempt to extract the incoming title/text properties...
    if (this.intent.getStringExtra("title") != null) {
      title = this.intent.getStringExtra("title");
    }
    if (this.intent.getStringExtra("message") != null) {
      message = this.intent.getStringExtra("message");
    }

    //Attempt to load translations using a `translation_key` from the JSON data.
    //This allows us to send the key, and load the appropriate language if
    //available. We fallback to strings defined in in english, or the original
    //title/text in the notification itself.
    try {
      Locale currentLocale = res.getConfiguration().locale;
      String language = currentLocale.getLanguage();
      Log.d(TAG, language);
      String translationKey = this.intent.getStringExtra("translation_key");
      Log.d(TAG, translationKey);
      int translationResId = res.getIdentifier(translationKey, "array", packageName);
      Log.d(TAG, Integer.toString(translationResId));
      String[] translations = res.getStringArray(translationResId);
      //We group these into `string-array`s 0 == title, 1 == message
      if (translations != null && translations.length == 2) {
        title = translations[0];
        message = translations[1];
      }
    } catch (Exception ex) {
      Log.e(TAG, ex.getMessage());
    }

    //Create our pendingIntent used to pass data to the app from clicking on the notification.
    Class intentClass = getMainActivityClass(this.context);
    Intent contentIntent = new Intent(context, intentClass);
    Bundle extrasBundle = this.intent.getExtras();
    contentIntent.putExtras(extrasBundle);
    contentIntent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
    contentIntent.setAction(NOTIFICATION_ACTION);
    PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, contentIntent, PendingIntent.FLAG_UPDATE_CURRENT);

    // Prepare a notification with vibration, sound and lights
    //TODO: Optionally parse notification parameters to set some of these values...
    NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(context)
        .setContentTitle(title)
        .setContentText(message)
        .setLights(Color.BLUE, 1000, 1000)
        .setVibrate(new long[]{ 0, 400, 250, 400 })
        .setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION))
        .setAutoCancel(true)
        .setContentIntent(pendingIntent);

    //Small default Icon
    int smallIconResId = res.getIdentifier("ic_notifications", "drawable", packageName);
    mBuilder.setSmallIcon(smallIconResId);

    // Accent Color
    int accentColorResId = res.getIdentifier("colorAccent", "color", packageName);
    mBuilder.setColor(res.getColor(res.getIdentifier("colorAccent", "color", packageName)));

    //Large icon
    // int largeIconResId = res.getIdentifier("ic_launcher", "mipmap", packageName);
    // Bitmap largeIconBitmap = BitmapFactory.decodeResource(res, largeIconResId);
    // if (largeIconResId != 0 && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
    //     mBuilder.setLargeIcon(largeIconBitmap);
    // }

    // Get an instance of the NotificationManager service
    NotificationManager mNotifyMgr = (NotificationManager) context.getSystemService(context.NOTIFICATION_SERVICE);

    // Build the notification and display it
    mNotifyMgr.notify(1, mBuilder.build());

  }

  private Class getMainActivityClass(Context context) {
    String packageName = context.getPackageName();
    Intent launchIntent = context.getPackageManager().getLaunchIntentForPackage(packageName);
    String className = launchIntent.getComponent().getClassName();
    try {
      return Class.forName(className);
    } catch (ClassNotFoundException e) {
      e.printStackTrace();
      return null;
    }
  }

}
