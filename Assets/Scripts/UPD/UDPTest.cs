using System;
using System.Runtime.InteropServices;
using AOT;
using UnityEngine;
using UnityEngine.UI;

public class UDPTest : MonoBehaviour
{
    public Button btnConnet;
    public Text text;

    delegate void CallBack(IntPtr param);
    static Action<string> OnCallback;

    private void Awake()
    {
        btnConnet.onClick.AddListener(()=> {
            connet(DeviceTokenCallBack);
        });
        OnCallback = (str) =>
        {
            text.text = str;
        };
    }

    [DllImport("__Internal")]
    private static extern void connet(CallBack deviceTokenCB);

    [MonoPInvokeCallback(typeof(CallBack))]
    static void DeviceTokenCallBack(IntPtr param)
    {
        string data = Marshal.PtrToStringAuto(param);
        OnCallback?.Invoke(data);
    }
}
