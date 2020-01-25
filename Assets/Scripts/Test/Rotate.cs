using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    [Range(0.0f,90.0f)]
    public float rotateAngle=30.0f;
    [Range(0.0f,100.0f)]
    public float speed = 15.0f;
    private float currentAngle;
    private bool add;
    private void Awake() {
        add= true;
        currentAngle = 0.0f;
        this.transform.rotation = Quaternion.Euler(0.0f,0.0f,0.0f);
    }
    private void Update() {

        if(add){
            currentAngle += Time.deltaTime * speed;
        }
        else{
            currentAngle -= Time.deltaTime * speed;
        }

        if(currentAngle <= -rotateAngle){
            add = true;
        }
        else if ( currentAngle >= rotateAngle)
        {
            add = false;
        }
        this.transform.rotation = Quaternion.Euler(0.0f,currentAngle,0.0f);

    }
}
