#import "PushNotificationController.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "UserNotifications/UserNotifications.h"
#import "PushNotificationManager.h"

@implementation UnityAppController (PushNotificationController)

CallBack notificationCallBack;
CallBack deviceTokenCallBack;
id thisClass;

void enroll(CallBack deviceTokenCB,CallBack notificationCB)
{
    deviceTokenCallBack = deviceTokenCB;
    notificationCallBack = notificationCB;
    [thisClass registerRemoteNotifications];
}

const char* getLastNotification(){
    NSString *lastNotification = [PushNotificationManager sharedInstance].lastNotification;
    if(lastNotification!=nil){
        return [lastNotification UTF8String];
    }else{
        const char *str = "";
        return str;
    }
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
      @selector(PushNotificationController:didFinishLaunchingWithOptions:));
  method_exchangeImplementations(original, swizzled);
}
UNUserNotificationCenter *center;
- (BOOL)PushNotificationController:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"当程序载入后执行");
    thisClass = self;
    center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = [PushNotificationManager sharedInstance];
    return  [self PushNotificationController:application
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
    PushNotificationManager *pushNotificationManager = [PushNotificationManager sharedInstance];
    
    pushNotificationManager.callBack = notificationCallBack;
    
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
