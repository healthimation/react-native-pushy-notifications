
#import "RNPushyNotifications.h"
#import "PushySDK-Swift.h"

#import <React/RCTEventDispatcher.h>
#import <React/RCTUtils.h>

@import UserNotifications;

@implementation RNPushyNotifications

NSString *NOTIFICATION_EVENT = @"NotificationReceived";
NSString *USER_INTERACTION = @"userInteraction";
NSString *INITIAL_NOTIFICATION = @"initialNotification";

Pushy *pushy;
NSDictionary *initialNotification;

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE();

- (void) setBridge:(RCTBridge *)bridge {
  _bridge = bridge;
}

//Get our initialNotifications from launchOptions
+ (void) getInitialNotificationFromOptions:(NSDictionary *)launchOptions {
  NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
  if (notification) {
    initialNotification = notification;
    NSLog(@"app recieved notification from remote%@", notification);
  } else {
    NSLog(@"app did not recieve notification");
  }
}

//Configure: Listen and register device w/ Pushy
RCT_EXPORT_METHOD(configure:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  @try {
    pushy = [[Pushy alloc]init:RCTSharedApplication()];

    [pushy setNotificationHandler:^(NSDictionary *data, void (^completionHandler)(UIBackgroundFetchResult)) {
      NSMutableDictionary *notification = [data mutableCopy];

      // Print notification payload data
      NSLog(@"Received notification: %@", notification);

      if (RCTSharedApplication().applicationState == UIApplicationStateActive) {
        [notification setObject:@NO forKey:USER_INTERACTION];
      } else {
        [notification setObject:@YES forKey:USER_INTERACTION];
      }

      [notification setObject:@NO forKey:INITIAL_NOTIFICATION];

      [self sendEvent:notification];

      // You must call this completion handler when you finish processing
      // the notification (after fetching background data, if applicable)
      completionHandler(UIBackgroundFetchResultNewData);
    }];

    [pushy register:^(NSError *error, NSString* deviceToken) {
      if (error != nil) { // Handle registration errors
        NSLog (@"Registration failed: %@", error);
        reject(@"registration_failed", @"Registration failed: ", error);
        return ;
      }

      // Print device token to console
      NSLog(@"Pushy device token: %@", deviceToken);

      resolve(deviceToken);
    }];

    //This may have been set by a call you put in AppDelegate...
    if (initialNotification) {
      NSLog(@"initialNotification: %@", initialNotification);
      NSMutableDictionary *notification = [initialNotification mutableCopy];
      [notification setObject:@YES forKey:USER_INTERACTION];
      [notification setObject:@YES forKey:INITIAL_NOTIFICATION];
      [self sendEvent:notification];
    }
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
