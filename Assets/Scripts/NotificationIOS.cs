using System;
using System.Runtime.InteropServices;

public class NotificationIOS 
{
    delegate void CallBack(IntPtr param);

    [DllImport("__Internal")]
    private static extern void Enroll();

    public static void Register()
    {
        Enroll();
    }
}
