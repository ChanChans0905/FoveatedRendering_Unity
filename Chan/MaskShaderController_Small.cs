using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaskShaderController_Small : MonoBehaviour
{
    public Material MaskShader;
    private Renderer _MaskRenderer;
    public float MS_Brightness;
    public float MS_Saturation = 1;

    void Start()
    {
        _MaskRenderer = GetComponent<Renderer>();
    }

    // Update is called once per frame
    void Update()
    {
        _MaskRenderer.material.SetFloat("_Brightness", MS_Brightness);
        _MaskRenderer.material.SetFloat("_Saturation", MS_Saturation);

        //if (Input.GetKeyDown(KeyCode.C))
        //    MS_Brightness -= 0.01f;

        //if (Input.GetKeyDown(KeyCode.V))
        //    MS_Brightness += 0.01f;

        if (Input.GetKeyDown(KeyCode.C))
            MS_Saturation -= 0.01f;

        if (Input.GetKeyDown(KeyCode.V))
            MS_Saturation += 0.01f;

    }
}
