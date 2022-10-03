using System;
using System.Runtime.InteropServices;
using AOT;
using UnityEngine;
using UnityEngine.UI;

public class UDPTest : MonoBehaviour
{
    public Button btnConnect;
    public Text text;

    delegate void CallBack(IntPtr param);
    static Action<string> OnCallback;

    private void Awake()
    {
        btnConnect.onClick.AddListener(()=> {
            initUDP(DeviceTokenCallBack);
        });
        OnCallback = (str) =>
        {
            text.text = str;
        };
    }

    [DllImport("__Internal")]
    private static extern void initUDP(CallBack deviceTokenCB);

    [MonoPInvokeCallback(typeof(CallBack))]
    static void DeviceTokenCallBack(IntPtr param)
    {
        string data = Marshal.PtrToStringAuto(param);
        OnCallback?.Invoke(data);
    }
}
