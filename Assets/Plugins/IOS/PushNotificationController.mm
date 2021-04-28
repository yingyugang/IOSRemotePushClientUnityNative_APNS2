#include <iostream>
using namespace std;
#import "PushNotificationController.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@implementation UnityAppController (PushNotificationController)

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
}

- (BOOL)WechatSignInAppController:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"当程序载入后执行");
    //BOOL handled = [WXApi registerApp:@"wx7a3c7293fe47ea6a" universalLink:@"applinks:yingyugang.s3-ap-northeast-1.amazonaws.com"];
    //返回True，有用，证明可以
    //BOOL handled =  [WXApi registerApp:@"wxd930ea5d5a258f4f" universalLink:@"https://help.wechat.com/sdksample/"];
    //NSLog(@" %s",handled ? "True" : "False");
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
    if(isAuthorization){
        NSLog(@"%@", url.absoluteString);
        const char *str2=[url.absoluteString UTF8String];
        ct(str2);
        isAuthorization = false;
    }
    return handled;
}
@end
