
#import <UIKit/UIKit.h>

#if __has_include(<React/RCTBridgeModule.h>)
  #import <React/RCTBridgeModule.h>
#else
  #import "RCTBridgeModule.h"
#endif

@interface RNPushyNotifications : NSObject <RCTBridgeModule>

  + (void) getInitialNotificationFromOptions:(NSDictionary *)launchOptions;
  - (void) sendEvent:(NSDictionary *)params;

@end
