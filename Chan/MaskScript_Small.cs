using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaskScript_Small : MonoBehaviour
{
    public GameObject FoveaRegionMesh;

    void Start()
    {
            FoveaRegionMesh.GetComponent<MeshRenderer>().material.renderQueue = 3004;
    }
}
