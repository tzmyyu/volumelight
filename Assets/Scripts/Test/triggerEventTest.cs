using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Managers;
using Const;

public class triggerEventTest : MonoBehaviour
{
    void Start()
    {
        EventManager.InvokeEvent(EventString.BokehOpen);
        EventManager.InvokeEvent(EventString.VignetteOpen);
    }

    void Update()
    {
        if(Input.GetKey(KeyCode.Keypad1)){
            EventManager.InvokeEvent(EventString.BokehOpen);
        }
        if(Input.GetKey(KeyCode.Keypad2)){
            EventManager.InvokeEvent(EventString.BloomOpen);
        }
        if(Input.GetKey(KeyCode.Keypad3)){
            EventManager.InvokeEvent(EventString.GaussianBlurOpen);
        }
        if(Input.GetKey(KeyCode.Keypad4)){
            EventManager.InvokeEvent(EventString.BSCGammaOpen);
        }
        if(Input.GetKey(KeyCode.Keypad5)){
            EventManager.InvokeEvent(EventString.VignetteOpen);
        }
        if(Input.GetKey(KeyCode.Keypad0)){
            EventManager.InvokeEvent(EventString.BokehClose);
            EventManager.InvokeEvent(EventString.BloomClose);
            EventManager.InvokeEvent(EventString.GaussianBlurClose);
            EventManager.InvokeEvent(EventString.BSCGammaClose);
            EventManager.InvokeEvent(EventString.VignetteClose);
        }
    }
}
