using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class GazePointCoorToShader : MonoBehaviour
{
    [SerializeField] RayCastToGazeTarget RayCastToGazeTarget;

    // Update is called once per frame
    void Update()
    {
        Vector3 gazePoint = RayCastToGazeTarget.GazeTargetPosForShader;
        Material myMaterial = GetComponent<Renderer>().material;
        myMaterial.SetVector("_GazePoint", new Vector4(gazePoint.x, gazePoint.y, gazePoint.z, 0));
        
        float gazeRadius = 50f;
        if (Input.GetKeyDown(KeyCode.S))
            myMaterial.SetFloat("_GazeRadius", gazeRadius);

    }
}
