#import "PushNotificationController.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "UserNotifications/UserNotifications.h"

@implementation UnityAppController (PushNotificationController)

typedef void(*CallBack)(const char* p);
typedef void(*CallBack1)(int p);
CallBack1 notificationCallBack;
CallBack deviceTokenCallBack;
id thisClass;
const char* launchNotification;
int length;

void Enroll(CallBack deviceTokenCB,CallBack1 notificationCB)
{
    deviceTokenCallBack = deviceTokenCB;
    notificationCallBack = notificationCB;
    
    notificationCB(0);
    
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

  original = class_getInstanceMethod(
      self, @selector(application:openURL:sourceApplication:annotation:));
  swizzled = class_getInstanceMethod(
      self, @selector
      (WechatSignInAppController:openURL:sourceApplication:annotation:));
  method_exchangeImplementations(original, swizzled);

  original =
      class_getInstanceMethod(self, @selector(application:openURL:options:));
  swizzled = class_getInstanceMethod(
      self, @selector(WechatSignInAppController:openURL:options:));
  method_exchangeImplementations(original, swizzled);
    
    original =
        class_getInstanceMethod(self, @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:));
    swizzled = class_getInstanceMethod(
        self, @selector(WechatSignInAppController:didRegisterForRemoteNotificationsWithDeviceToken:));
    method_exchangeImplementations(original, swizzled);
   
    
    original =
        class_getInstanceMethod(self, @selector(application:didFailToRegisterForRemoteNotificationsWithError:));
    swizzled = class_getInstanceMethod(
        self, @selector(WechatSignInAppController:didRegisterForRemoteNotificationsWithDeviceToken:));
    method_exchangeImplementations(original, swizzled);
}

- (BOOL)WechatSignInAppController:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"当程序载入后执行");
    thisClass = self;
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted,NSError * _Nullable error){
        if(!error){
            NSLog(@"OK");
            dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
        }
    }];
    return  [self WechatSignInAppController:application
            didFinishLaunchingWithOptions:launchOptions];
}




/**
 * Handle the auth URL
 */
- (BOOL)WechatSignInAppController:(UIApplication *)application
                          openURL:(NSURL *)url
                sourceApplication:(NSString *)sourceApplication
                       annotation:(id)annotation {
    BOOL handled = [self WechatSignInAppController:application
                                           openURL:url
                                 sourceApplication:sourceApplication
                                        annotation:annotation];
  return handled;
}

/**
 * Handle the auth URL.
 */
- (BOOL)WechatSignInAppController:(UIApplication *)app
                          openURL:(NSURL *)url
                          options:(NSDictionary *)options {
    BOOL handled =
        [self WechatSignInAppController:app openURL:url options:options];
    return handled;
}

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString* str = [self fetchDeviceToken:deviceToken];
    NSLog(@"%@",str);
    NSString *token = [[[deviceToken description]
                           stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                           stringByReplacingOccurrencesOfString:@" "
                           withString:@""];
       NSLog(@"DeviceToken string, %@", token);
       deviceTokenCallBack([token UTF8String]);
       [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)app
        didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    // The token is not currently available.
    NSLog(@"Remote notification support is unavailable due to error: %@", err);  
}

- (void)application:(UIApplication *)application 
        didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo 
        fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
   
    NSData *infoData = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:nil];
    NSString *info = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",info);
    launchNotification = [info UTF8String];
    length = info.length;
    notificationCallBack(length);
    /*
    if(notificationCallBack==NULL){
        launchNotification = [info UTF8String];
        length = info.length;
    }else{
        //notificationCallBack([info UTF8String]);
        length = info.length;
        char charValue = length+'0';
        char *pChar = &charValue;
        notificationCallBack(pChar);
        
        
       // notificationCallBack([info UTF8String]);
    }*/
    // 这里将角标数量减一，注意系统不会帮助我们处理角标数量
    application.applicationIconBadgeNumber = application.applicationIconBadgeNumber - 1;
}

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

- (void)registerRemoteNotifications {
    // 区分是否是 iOS8 or later
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        // 这里 types 可以自定义，如果 types 为 0，那么所有的用户通知均会静默的接收，系统不会给用户任何提示(当然，App 可以自己处理并给出提示)
        UIUserNotificationType types = (UIUserNotificationType) (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
        // 这里 categories 可暂不深入，本文后面会详细讲解。
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        // 当应用安装后第一次调用该方法时，系统会弹窗提示用户是否允许接收通知
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    } else {
        UIRemoteNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
}
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(nonnull UIUserNotificationSettings *)notificationSettings {
    // Register for remote notifications.
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}
@end
