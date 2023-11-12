using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class RayCastToGazeTarget : MonoBehaviour
{
    public GameObject GazeTarget;
    RaycastHit hit;
    public Vector3 GazeTargetPosForShader;

    void Update()
    {
        transform.LookAt(GazeTarget.transform);
        
        if(Physics.Raycast(transform.position,transform.forward,out hit))
        {
            Vector3 hitPoint = hit.point;
            GazeTargetPosForShader = hitPoint + transform.forward * 100f;
        }
    }
}
