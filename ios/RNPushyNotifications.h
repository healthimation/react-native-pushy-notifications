
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

@interface RNPushyNotifications : NSObject <RCTBridgeModule>

  // typedef void (^RCTRemoteNotificationCallback)(UIBackgroundFetchResult result);
  // typedef void (^RCTWillPresentNotificationCallback)(UNNotificationPresentationOptions result);
  // typedef void (^RCTNotificationResponseCallback)();
  //
  // #if !TARGET_OS_TV
  // + (void)didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull RCTRemoteNotificationCallback)completionHandler;
  // + (void)didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response withCompletionHandler:(nonnull RCTNotificationResponseCallback)completionHandler;
  // + (void)willPresentNotification:(nonnull UNNotification *)notification withCompletionHandler:(nonnull RCTWillPresentNotificationCallback)completionHandler;
  // #endif

@end
