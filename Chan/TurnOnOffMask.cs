using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TurnOnOffMask : MonoBehaviour
{
    public GameObject Mask_Small, Mask_Big;
    public GameObject VideoMeshForMask_Small, VideoMeshForMask_Big;


    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Q))
        {
            VideoMeshForMask_Big.SetActive(true);
            VideoMeshForMask_Small.SetActive(true);
            Mask_Small.SetActive(true);
            Mask_Big.SetActive(true);
        }


        if (Input.GetKeyDown(KeyCode.W))
        {
            VideoMeshForMask_Big.SetActive(false);
            VideoMeshForMask_Small.SetActive(false);
            Mask_Small.SetActive(false);
            Mask_Big.SetActive(false);
        }
    }
}
