using UnityEngine.UI;
using UnityEngine;
using UnityEngine.Networking;
using System.Collections;

public class Test : MonoBehaviour
{
    public Button enrollButton;
    public Text tokenTxt;
    public Text notificationTxt;
    public Button enrollButton1;
    string token = "ddddd";
    private void Awake()
    {
        enrollButton1.onClick.AddListener(() => {
            StartCoroutine(SendToken(token));
        });
        enrollButton.onClick.AddListener(() =>
        {
            NotificationIOS.Register((token) =>
            {
                tokenTxt.text = token;
                
                this.token = token;
            }, (notification) =>
            {
                notificationTxt.text = notification;

            });
        });
        notificationTxt.text = NotificationIOS.GetLastNotification();
    }

    IEnumerator SendToken(string token)
    {
        Debug.Log("Send");
        UnityWebRequest unityWebRequest = UnityWebRequest.Get("http://192.168.11.3:8080/getDeviceToken?deviceToken=" + token);//  new UnityWebRequest("192.168.11.3:8080/getDeviceToken?deviceToken=" + token);
        yield return unityWebRequest.SendWebRequest();
        if (unityWebRequest.result != UnityWebRequest.Result.Success)
        {
            notificationTxt.text = unityWebRequest.error;
        }
    }
}
