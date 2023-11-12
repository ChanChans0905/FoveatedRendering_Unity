using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaskScript_Big : MonoBehaviour
{
    public GameObject MiddleRegionMesh;

    void Start()
    {
        MiddleRegionMesh.GetComponent<MeshRenderer>().material.renderQueue = 3002;
    }
}
