using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaskShaderController : MonoBehaviour
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

        if (Input.GetKeyDown(KeyCode.K))
            MS_Brightness -= 0.1f;

        if (Input.GetKeyDown(KeyCode.J))
            MS_Brightness += 0.1f;

        if (Input.GetKeyDown(KeyCode.S))
            MS_Saturation -= 0.1f;

        if (Input.GetKeyDown(KeyCode.A))
            MS_Saturation += 0.1f;
    }
}
