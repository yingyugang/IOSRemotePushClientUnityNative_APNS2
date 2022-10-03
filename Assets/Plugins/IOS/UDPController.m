//
//  UnityFramework
//
//  Created by 应彧刚 on 2022/10/3.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>
#import <UDPController.h>

/** 这个端口可以随便设置*/
#define TEST_IP_PROT 9091
/** 替换成你需要连接服务器绑定的IP地址，不能随便输*/
#define TEST_IP_ADDR "192.168.103.244"

@implementation UDPController

typedef void(*CallBack)(const char* p);
CallBack receiveMsgCallback;
id thisClass;
void initUDP(CallBack deviceTokenCB)
{
    receiveMsgCallback = deviceTokenCB;
    [thisClass  connectServer: thisClass];
}

- (BOOL)UDPController:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"当程序载入后执行");
    thisClass = self;
    return  [self UDPController:application
            didFinishLaunchingWithOptions:launchOptions];
}

bool _socketRef;

- (IBAction)connectServer:(id)sender {
    
    if (!_socketRef) {
        
        // 创建socket关联的上下文信息
        
        /*
         typedef struct {
         CFIndex    version; 版本号, 必须为0
         void *    info; 一个指向任意程序定义数据的指针，可以在CFSocket对象刚创建的时候与之关联，被传递给所有在上下文中回调
         const void *(*retain)(const void *info); info 指针中的retain回调，可以为NULL
         void    (*release)(const void *info); info指针中的release回调，可以为NULL
         CFStringRef    (*copyDescription)(const void *info); 回调描述，可以n为NULL
         } CFSocketContext;
         
         */
        
        CFSocketContext sockContext = {0, (__bridge void *)(self), NULL, NULL, NULL};
        
        //创建一个socket
        _socketRef = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_DGRAM, IPPROTO_TCF, kCFSocketConnectCallBack, NULL, &sockContext);
        
        //创建sockadd_in的结构体，改结构体作为socket的地址，IPV6需要改参数
        
        //sockaddr_in
        // sin_len;  长度
        //sin_family;协议簇， 用AF_INET -> 互联网络， TCP，UDP 等等
        //sin_port; 端口号（使用网络字节顺序）htons:将主机的无符号短整形数转成网络字节顺序
        //in_addr sin_addr; 存储IP地址， inet_addr()的功能是将一个点分十进制的IP转换成一个长整型数(u_long类型)，若字符串有效则将字符串转换为32位二进制网络字节序的IPV4地址， 否则为IMADDR_NONE
        //sin_zero[8]; 让sockaddr与sockaddr_in 两个数据结构保持大小相同而保留的空字节，无需处理
        
        struct sockaddr_in Socketaddr;
        //memset： 将addr中所有字节用0替代并返回addr，作用是一段内存块中填充某个给定的值，它是对较大的结构体或数组进行清零操作的一种最快方法
        memset(&Socketaddr, 0, sizeof(Socketaddr));
        Socketaddr.sin_len = sizeof(Socketaddr);
        Socketaddr.sin_family = AF_INET;
        Socketaddr.sin_port = htons(TEST_IP_PROT);
        Socketaddr.sin_addr.s_addr = inet_addr(TEST_IP_ADDR);
        
        //将地址转化为CFDataRef
        CFDataRef dataRef = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&Socketaddr, sizeof(Socketaddr));
        
        //连接
        //CFSocketError    CFSocketConnectToAddress(CFSocketRef s, CFDataRef address, CFTimeInterval timeout);
        //第一个参数  连接的socket
        //第二个参数  连接的socket的包含的地址参数
        //第三个参数 连接超时时间，如果为负，则不尝试连接，而是把连接放在后台进行，如果_socket消息类型为kCFSocketConnectCallBack，将会在连接成功或失败的时候在后台触发回调函数
        CFSocketConnectToAddress(_socketRef, dataRef, -1);
        
        //加入循环中
        //获取当前线程的runLoop
        CFRunLoopRef runloopRef = CFRunLoopGetCurrent();
        //把socket包装成CFRunLoopSource, 最后一个参数是指有多个runloopsource通过一个runloop时候顺序，如果只有一个source 通常为0
        CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socketRef, 0);
        
        //加入运行循环
        //第一个参数：运行循环管
        //第二个参数： 增加的运行循环源, 它会被retain一次
        //第三个参数：用什么模式把source加入到run loop里面,使用kCFRunLoopCommonModes可以监视所有通常模式添加source
        CFRunLoopAddSource(runloopRef, sourceRef, kCFRunLoopCommonModes);
        
        //之前被retain一次，这边要释放掉
        CFRelease(sourceRef);
        
    }
    
}
@end
