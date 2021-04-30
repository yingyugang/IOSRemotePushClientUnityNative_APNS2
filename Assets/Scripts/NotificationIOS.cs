using AOT;
using System;
using System.Collections.Specialized;
using System.Runtime.InteropServices;

public class NotificationIOS 
{
    delegate void CallBack(IntPtr param);

    [DllImport("__Internal")]
    private static extern void Enroll(CallBack deviceTokenCB, CallBack notificationCB);

    static Action<string> deviceTokenCB;
    static Action<string> notificationCB;
    public static void Register(Action<string> deviceTokenCB,Action<string> notificationCB)
    {
        NotificationIOS.deviceTokenCB = deviceTokenCB;
        NotificationIOS.notificationCB = notificationCB;
        Enroll(DeviceTokenCallBack, NotificationCallBack);
    }

    [MonoPInvokeCallback(typeof(CallBack))]
    static void DeviceTokenCallBack(IntPtr param)
    {
        string deviceToken = Marshal.PtrToStringAuto(param);
        deviceTokenCB?.Invoke(deviceToken);
    }

    [MonoPInvokeCallback(typeof(CallBack))]
    static void NotificationCallBack(IntPtr param)
    {
        string notification = Marshal.PtrToStringAuto(param);
        notificationCB?.Invoke(notification);
    }
}
