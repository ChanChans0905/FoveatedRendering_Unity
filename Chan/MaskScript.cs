using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaskScript : MonoBehaviour
{
    public GameObject[] MaskObject;

    void Start()
    {
        for(int i =0; i<MaskObject.Length; i++)
        {
            MaskObject[i].GetComponent<MeshRenderer>().material.renderQueue = 3002;
        }    
    }
}
