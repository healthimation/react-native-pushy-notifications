
#import <UIKit/UIKit.h>

#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

@interface RNPushyNotifications : NSObject <RCTBridgeModule>

  + (void) getInitialNotificationFromOptions:(NSDictionary *)launchOptions;
  - (void) sendEvent:(NSDictionary *)params
  
@end
