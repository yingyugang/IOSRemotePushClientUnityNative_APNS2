using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TestInput : MonoBehaviour
{
    public RectTransform whoopPatternRoot;
    public RectTransform canvasScaler;

    public InputField inputField;
    public Button button;
    // TouchScreenKeyboard touchScreenKeyboard;

    // Start is called before the first frame update
    void Start()
    {
        //TouchScreenKeyboard.hideInput = true;
        //touchScreenKeyboard = TouchScreenKeyboard.Open("",TouchScreenKeyboardType.Default,false);

        button.onClick.AddListener(() =>
        {
            inputField.Select();
        });

    }

    private void Update()
    {
        // inputField.text = touchScreenKeyboard.text;
        var ratio = (float)TouchScreenKeyboard.area.height / Screen.height;
        whoopPatternRoot.anchoredPosition = new Vector3(whoopPatternRoot.anchoredPosition.x, canvasScaler.sizeDelta.y * ratio, 0);
        inputField.Select();
        inputField.ActivateInputField();
    }
}
