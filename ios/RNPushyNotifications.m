
#import "RNPushyNotifications.h"
#import "PushySDK-Swift.h"
#import <React/RCTEventDispatcher.h>

@import UserNotifications;

@implementation RNPushyNotifications

NSString *NOTIFICATION_EVENT = @"NotificationReceived";
NSString *USER_INTERACTION = @"userInteraction";

Pushy *pushy;

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE();

// + (void) didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull RCTRemoteNotificationCallback)completionHandler {
//   NSMutableDictionary* data = [[NSMutableDictionary alloc] initWithDictionary: userInfo];
//   [data setValue:@(RCTSharedApplication().applicationState == UIApplicationStateInactive) forKey:USER_INTERACTION];
//   [[NSNotificationCenter defaultCenter] postNotificationName:FCMNotificationReceived object:self userInfo:@{@"data": data, @"completionHandler": completionHandler}];
// }
//
// + (void)didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(nonnull RCTNotificationResponseCallback)completionHandler {
//   NSMutableDictionary* data = [[NSMutableDictionary alloc] initWithDictionary: response.notification.request.content.userInfo];
//   [data setValue:@YES forKey:USER_INTERACTION];
//   [[NSNotificationCenter defaultCenter] postNotificationName:FCMNotificationReceived object:self userInfo:@{@"data": data, @"completionHandler": completionHandler}];
// }
//
// + (void)willPresentNotification:(UNNotification *)notification withCompletionHandler:(nonnull RCTWillPresentNotificationCallback)completionHandler {
//   NSMutableDictionary* data = [[NSMutableDictionary alloc] initWithDictionary: notification.request.content.userInfo];
//   [[NSNotificationCenter defaultCenter] postNotificationName:FCMNotificationReceived object:self userInfo:@{@"data": data, @"completionHandler": completionHandler}];
// }

//Is this even needed?
// - (void)setBridge:(RCTBridge *)bridge {
//   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotificationReceived:) name:NOTIFICATION_EVENT object:nil];
// }

//Is this even needed?
// - (void)handleNotificationReceived:(NSNotification *)notification {
//   id completionHandler = notification.userInfo[@"completionHandler"];
//   NSMutableDictionary* data = notification.userInfo[@"data"];
//   if(completionHandler != nil){
//     NSString *completionHandlerId = [[NSUUID UUID] UUIDString];
//     if (!self.notificationCallbacks) {
//       // Lazy initialization
//       self.notificationCallbacks = [NSMutableDictionary dictionary];
//     }
//     self.notificationCallbacks[completionHandlerId] = completionHandler;
//     data[@"_completionHandlerId"] = completionHandlerId;
//   }
//
//   [self.bridge.eventDispatcher sendDeviceEventWithName:FCMNotificationReceived body:data];
// }

//Configure: Listen and register device w/ Pushy
RCT_EXPORT_METHOD(configure:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  @try {
    pushy = [[Pushy alloc]init:[UIApplication sharedApplication]];

    [pushy register:^(NSError *error, NSString* deviceToken) {
      if (error != nil) { // Handle registration errors
        NSLog (@"Registration failed: %@", error);
        reject(@"registration_failed", @"Registration failed: ", error);
        return ;
      }

      // Print device token to console
      NSLog(@"Pushy device token: %@", deviceToken);

      [pushy setNotificationHandler:^(NSDictionary *data, void (^completionHandler)(UIBackgroundFetchResult)) {
        // Print notification payload data
        NSLog(@"Received notification: %@", data);

        NSString* messageValue = [data objectForKey:@"message"];

        [data setValue:@YES forKey:USER_INTERACTION]; //Is this the case? Do we know this yet?

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

        [self sendEvent:data];

        // You must call this completion handler when you finish processing
        // the notification (after fetching background data, if applicable)
        completionHandler(UIBackgroundFetchResultNewData);
      }];

      resolve(deviceToken);
    }];
  } @catch (NSException *exception) {
    reject(@"configure_failed", @"Configure failed: ", exception);
  }
}

//Subscribe to a Pushy topic...
RCT_EXPORT_METHOD(subscribe:(NSString *)topic resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  @try {
    [pushy subscribeWithTopic:topic handler:^(NSError *error) {
        if (error != nil) { // Handle errors
          NSLog(@"Subscribe failed: %@", error);
          reject(@"subscribe_failed", @"Subscribe failed: ", error);
          return;
        }
        // Otherwise, subscribe successful
        resolve(@YES);
        NSLog(@"Subscribed to topic successfully");
    }];
  } @catch (NSException *exception) {
    reject(@"subsctibe_failed", @"Subscribe failed: ", exception);
  }
}

//Unsubscribe to a Pushy topic...
RCT_EXPORT_METHOD(unsubscribe:(NSString *)topic resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  @try {
    [pushy unsubscribeWithTopic:@"news" handler:^(NSError *error) {
      if (error != nil) { // Handle unsubscribe errors
        NSLog(@"Unsubscribe failed: %@", error);
        reject(@"unsubscribe_failed", @"Unsubscribe failed: ", error);
        return;
      }
      // Otherwise, unsubscribe successful
      resolve(@YES);
      NSLog(@"Unsubscribed from topic successfully");
    }];
  } @catch (NSException *exception) {
    reject(@"unsubscribe_failed", @"Unsubscribe failed: ", exception);
  }
}

- (void) sendEvent:(NSDictionary *)params {
  [self.bridge.eventDispatcher sendDeviceEventWithName:NOTIFICATION_EVENT body:params];
}

@end
