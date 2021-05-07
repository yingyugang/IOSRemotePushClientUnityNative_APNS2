#import <UnityAppController.h>
typedef void(*CallBack)(const char* p);
// to handle these messages also.
@interface UnityAppController(PushNotificationController)


// These are the implementations for GSI.  The signatures match the
// AppController methods.
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end
