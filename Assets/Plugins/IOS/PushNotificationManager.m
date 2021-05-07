#import "UserNotifications/UserNotifications.h"
#import <PushNotificationManager.h>

@implementation PushNotificationManager

typedef void(*CallBack)(const char* p);

+ (instancetype)sharedInstance
{
    static PushNotificationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PushNotificationManager alloc] init];
    });
    return sharedInstance;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog( @"willPresentNotification" );
    NSLog(@"%@", notification.request.content.userInfo);
    NSData *infoData = [NSJSONSerialization dataWithJSONObject:notification.request.content.userInfo options:0 error:nil];
    NSString *info = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding];
    self.callBack([info UTF8String]);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler
{
    NSLog( @"didReceiveNotificationResponse" );
    NSLog(@"%@", response.notification.request.content.userInfo);
    NSData *infoData = [NSJSONSerialization dataWithJSONObject:response.notification.request.content.userInfo options:0 error:nil];
    NSString *info = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding];
    self.callBack([info UTF8String]);
}
@end