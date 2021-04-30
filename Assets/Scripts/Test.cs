using UnityEngine.UI;
using UnityEngine;

public class Test : MonoBehaviour
{
    public Button enrollButton;

    private void Awake()
    {
        enrollButton.onClick.AddListener(()=> {
            NotificationIOS.Register();
        });
    }
}
