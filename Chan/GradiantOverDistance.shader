Shader "Custom/ColorByDistanceToPoint" {
    SubShader {
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata_t {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _SpecificObjectPosition; // Uniform representing the specific object's coordinates
            half4 _ColorStart; // Uniform representing the starting color (black)
            half4 _ColorEnd; // Uniform representing the ending color (white)

            v2f vert(appdata_t v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                // Convert UV coordinates to world space position
                o.pos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            half4 frag(v2f i) : SV_Target {
                // Get the specific object's coordinates passed as a uniform
                float4 specificObjectPos = _SpecificObjectPosition;

                // Calculate the distance from the world space position to the specific object's coordinates
                half distance = length(i.pos.xyz - specificObjectPos.xyz);

                // Interpolate between _ColorStart and _ColorEnd based on distance
                half4 interpolatedColor = lerp(_ColorStart, _ColorEnd, saturate(distance));

                return interpolatedColor;
            }
            ENDCG
        }
    }
}