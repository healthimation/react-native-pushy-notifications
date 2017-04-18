
#import "RNPushyNotifications.h"
#import <PushySDK/PushySDK-Swift.h>

@implementation RNPushyNotifications

NSString *NOTIFICATION_EVENT = @"NotificationReceived";

Pushy *pushy;

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE();

//Configure: Listen and register device w/ Pushy
RCT_EXPORT_METHOD(configure:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  @try {
    pushy = [[Pushy alloc]init:[UIApplication sharedApplication]];

    [pushy register:^(NSError *error, NSString* deviceToken) {
      if (error != nil) { // Handle registration errors
        NSLog (@"Registration failed: %@", error);
        reject(error);
        return ;
      }

      // Print device token to console
      NSLog(@"Pushy device token: %@", deviceToken);

      [pushy setNotificationHandler:^(NSDictionary *data, void (^completionHandler)(UIBackgroundFetchResult)) {
        // Print notification payload data
        NSLog(@"Received notification: %@", data);

        NSString* messageValue = [data objectForKey:@"message"];

        // // Fallback message containing data payload
        // NSString *message = [NSString stringWithFormat:@"%@", data];
        //
        // // Attempt to extract "message" key from APNs payload
        // if (data[@"aps"]) {
        //   NSDictionary *aps = [data objectForKey:@"aps"];
        //
        //   if (aps[@"alert"]) {
        //     message = [aps valueForKey:@"alert"];
        //   }
        // }
        //
        // NSLocalizedString("window.greeting", value:"Hello, world!", comment:"Window title");
        // // Display the notification as an alert
        // UIAlertController * alert = [UIAlertController
        //                                 alertControllerWithTitle:@"Incoming Notification"
        //                                 message:message
        //                                 preferredStyle:UIAlertControllerStyleAlert];

        // // Add an action button
        // [alert addAction:[UIAlertAction
        //                     actionWithTitle:@"OK"
        //                     style:UIAlertActionStyleDefault
        //                     handler:nil]];

        // // Show the alert dialog
        // [self.window.rootViewController presentViewController:alert animated:YES completion:nil];

        // You must call this completion handler when you finish processing
        // the notification (after fetching background data, if applicable)
        completionHandler(UIBackgroundFetchResultNewData);
      }];

      resolve(deviceToken);
    }];
  } @catch (NSException *exception) {
    reject(exception);
  }
}

//Subscribe to a Pushy topic...
RCT_EXPORT_METHOD(subscribe:(NSString *)topic resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  @try {
    [pushy subscribeWithTopic:topic handler:^(NSError *error) {
        if (error != nil) { // Handle errors
          NSLog(@"Subscribe failed: %@", error);
          reject(error);
          return;
        }
        // Otherwise, subscribe successful
        resolve(@YES);
        NSLog(@"Subscribed to topic successfully");
    }];
  } @catch (NSException *exception) {
    reject(exception);
  }
}

//Unsubscribe to a Pushy topic...
RCT_EXPORT_METHOD(unsubscribe:(NSString *)topic resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  @try {
    [pushy unsubscribeWithTopic:@"news" handler:^(NSError *error) {
      if (error != nil) { // Handle unsubscribe errors
        NSLog(@"Unsubscribe failed: %@", error);
        reject(error);
        return;
      }
      // Otherwise, unsubscribe successful
      resolve(@YES);
      NSLog(@"Unsubscribed from topic successfully");
    }];
  } @catch (NSException *exception) {
    reject(exception);
  }
}

- (void) sendEvent:(NSDictionary *)params {
  [self.bridge.eventDispatcher sendDeviceEventWithName:NOTIFICATION_EVENT body:params];
}

@end
