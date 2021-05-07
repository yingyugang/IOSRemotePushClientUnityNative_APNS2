#import "UserNotifications/UserNotifications.h"
#import "PushNotificationController.h"

@interface PushNotificationManager : NSObject<UNUserNotificationCenterDelegate>
+ (instancetype)sharedInstance;
@property CallBack callBack;
@end
