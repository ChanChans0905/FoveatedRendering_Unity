Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Resolution_X("Resolution_X", Float) = 3840
        _Resolution_Y("Resolution_Y", Float) = 2160
        _DownscaleFactor("Downscale Factor", Range(0,1)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _DownscaleFactor;
            float _Resolution_X;
            float _Resolution_Y;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // DownScale
                float2 gridUV = i.uv * float2(8.0, 8.0);
                float2 gridPosition = floor(gridUV);
                float2 uv = i.uv;

                bool deteriorateQuality = (gridPosition.x < 1.0 || gridPosition.x > 6.0 || gridPosition.y < 1.0 || gridPosition.y > 6.0);
                bool deteriorateQuality2 = (gridPosition.x == 1.0 || gridPosition.x == 6.0 || gridPosition.y == 1.0 || gridPosition.y == 6.0);
   
            if (gridRegion_Inner)
            {

            }
            uv.x *= _Resolution_X * _DownscaleFactor;
            uv.x = floor(uv.x) / _Resolution_X / _DownscaleFactor;
            uv.y *= _Resolution_Y * _DownscaleFactor;
            uv.y = floor(uv.y) / _Resolution_Y / _DownscaleFactor;

            fixed4 col = tex2D(_MainTex, uv);
            return col;

                // // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                // // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col);
                // return col;
            }
            ENDCG
        }
    }
}
