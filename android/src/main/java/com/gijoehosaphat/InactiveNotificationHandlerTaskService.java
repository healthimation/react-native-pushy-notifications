package com.gijoehosaphat;

import javax.annotation.Nullable;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.facebook.react.jstasks.HeadlessJsTaskConfig;
import com.facebook.react.HeadlessJsTaskService;
import com.facebook.react.bridge.Arguments;

public class InactiveNotificationHandlerTaskService extends HeadlessJsTaskService {

    @Override
    protected @Nullable HeadlessJsTaskConfig getTaskConfig(Intent intent) {
        Bundle extras = intent.getExtras();
        if (extras != null) {
            return new HeadlessJsTaskConfig(
                    "InactiveNotificationHandler",
                    Arguments.fromBundle(extras),
                    5000);
        }
        return null;
    }
}
