package com.gijoehosaphat;

import com.facebook.react.bridge.Promise;

public interface AsyncResponse {
  void onProcessFinish(RegistrationResult result, Promise promise);
}
