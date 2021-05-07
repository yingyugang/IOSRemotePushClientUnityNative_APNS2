#import "PushNotificationController.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "UserNotifications/UserNotifications.h"
#import "PushNotificationManager.h"

@implementation UnityAppController (PushNotificationController)

CallBack notificationCallBack;
CallBack deviceTokenCallBack;
id thisClass;
const char* launchNotification;
int length;

void Enroll(CallBack deviceTokenCB,CallBack notificationCB)
{
    deviceTokenCallBack = deviceTokenCB;
    notificationCallBack = notificationCB;
    [thisClass registerRemoteNotifications];
}

/*
 Called when the category is loaded.  This is where the methods are swizzled
 out.
 */
+ (void)load {
  Method original;
  Method swizzled;

  original = class_getInstanceMethod(
      self, @selector(application:didFinishLaunchingWithOptions:));
  swizzled = class_getInstanceMethod(
      self,
      @selector(WechatSignInAppController:didFinishLaunchingWithOptions:));
  method_exchangeImplementations(original, swizzled);
}

- (BOOL)WechatSignInAppController:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"当程序载入后执行");
    thisClass = self;

    return  [self WechatSignInAppController:application
            didFinishLaunchingWithOptions:launchOptions];
}

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString* token = [self fetchDeviceToken:deviceToken];
    NSLog(@"%@",token);
    deviceTokenCallBack([token UTF8String]);
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)app
        didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    // The token is not currently available.
    NSLog(@"Remote notification support is unavailable due to error: %@", err);  
}

/*
 * Tokenを解析
 */
- (NSString *)fetchDeviceToken:(NSData *)deviceToken {
    NSUInteger len = deviceToken.length;
    if (len == 0) {
        return nil;
    }
    const unsigned char *buffer = deviceToken.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(len * 2)];
    for (int i = 0; i < len; ++i) {
        [hexString appendFormat:@"%02x", buffer[i]];
    }
    return [hexString copy];
}

/*
 * リモートプッシューを登録
 */
- (void)registerRemoteNotifications {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = [PushNotificationManager sharedInstance];
    [PushNotificationManager sharedInstance].callBack = notificationCallBack;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted,NSError * _Nullable error){
        if(!error){
            NSLog(@"OK");
            dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
        }
    }];
}
@end
