Shader "AVProVideo/VR/InsideSphere Unlit (stereo+fog)"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "black" {}
		_ChromaTex("Chroma", 2D) = "white" {}
		_HueShiftTex ("Hue Shift Texture", 2D) = "WHite" {}
		_HueShift ("Hue Shift", Range(0,10)) = 0
		_Saturation ("Saturation", Range(0,5)) = 0
		_Brightness ("Brightness", Range(-1,1)) = 0

        _GazePoint ("Gaze Point", Vector) = (0,0,0,0)
        _GazeRadius ("Gaze Radius", Float) = 25.0
		_GazeRadius_Color ("Gaze Radius for Color", FLoat) = 0

		[KeywordEnum(None, Top_Bottom, Left_Right, Custom_UV)] Stereo ("Stereo Mode", Float) = 0
		[KeywordEnum(None, Left, Right)] ForceEye ("Force Eye Mode", Float) = 0
		[Toggle(STEREO_DEBUG)] _StereoDebug ("Stereo Debug Tinting", Float) = 0
		[KeywordEnum(None, EquiRect180)] Layout("Layout", Float) = 0
		[Toggle(HIGH_QUALITY)] _HighQuality ("High Quality", Float) = 0
		[Toggle(APPLY_GAMMA)] _ApplyGamma("Apply Gamma", Float) = 0
		[Toggle(USE_YPCBCR)] _UseYpCbCr("Use YpCbCr", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "IgnoreProjector" = "True" "Queue" = "Background" }
		ZWrite On
		//ZTest Always
		Cull Front
		Lighting Off

		Pass
		{
			CGPROGRAM
			#include "UnityCG.cginc"
			#include "AVProVideo.cginc"
#if HIGH_QUALITY || APPLY_GAMMA
			#pragma target 3.0
#endif
			#pragma vertex vert
			#pragma fragment frag

			//#define STEREO_DEBUG 1
			//#define HIGH_QUALITY 1

			#pragma multi_compile_fog
			// TODO: replace use multi_compile_local instead (Unity 2019.1 feature)
			#pragma multi_compile MONOSCOPIC STEREO_TOP_BOTTOM STEREO_LEFT_RIGHT STEREO_CUSTOM_UV
			#pragma multi_compile FORCEEYE_NONE FORCEEYE_LEFT FORCEEYE_RIGHT
			#pragma multi_compile __ STEREO_DEBUG
			#pragma multi_compile __ HIGH_QUALITY
			#pragma multi_compile __ APPLY_GAMMA
			#pragma multi_compile __ USE_YPCBCR
			#pragma multi_compile __ LAYOUT_EQUIRECT180

			struct appdata
			{
				float4 vertex : POSITION; // vertex position
#if HIGH_QUALITY
				float3 normal : NORMAL;
#else
				float2 uv : TEXCOORD0; // texture coordinate			
#if STEREO_CUSTOM_UV
				float2 uv2 : TEXCOORD1;	// Custom uv set for right eye (left eye is in TEXCOORD0)
#endif
#endif

#ifdef UNITY_STEREO_INSTANCING_ENABLED
				UNITY_VERTEX_INPUT_INSTANCE_ID
#endif
			};

			struct v2f
			{
				float4 vertex : SV_POSITION; // clip space position
				float3 worldPos : TEXCOORD1;
#if HIGH_QUALITY
				float3 normal : TEXCOORD0;
				
#if STEREO_TOP_BOTTOM | STEREO_LEFT_RIGHT
				float4 scaleOffset : TEXCOORD1; // texture coordinate
				UNITY_FOG_COORDS(2)
#else
				UNITY_FOG_COORDS(1)
#endif
#else
				float2 uv : TEXCOORD0; // texture coordinate
				UNITY_FOG_COORDS(1)
#endif

#if STEREO_DEBUG
				float4 tint : COLOR;
#endif

#ifdef UNITY_STEREO_INSTANCING_ENABLED
				UNITY_VERTEX_OUTPUT_STEREO
#endif
			};

			uniform sampler2D _MainTex;
#if USE_YPCBCR
			uniform sampler2D _ChromaTex;
			uniform float4x4 _YpCbCrTransform;
#endif
			uniform float4 _MainTex_ST;

			float _HueShift;
			float _Saturation;
			float _Brightness;

			float4 _GazePoint;
			float _GazeRadius;
			float _GazeRadius_Color;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

#ifdef UNITY_STEREO_INSTANCING_ENABLED
				UNITY_SETUP_INSTANCE_ID(v);						// calculates and sets the built-n unity_StereoEyeIndex and unity_InstanceID Unity shader variables to the correct values based on which eye the GPU is currently rendering
				UNITY_INITIALIZE_OUTPUT(v2f, o);				// initializes all v2f values to 0
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);		// tells the GPU which eye in the texture array it should render to
#endif


				o.vertex = XFormObjectToClip(v.vertex);

#if !HIGH_QUALITY
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				#if LAYOUT_EQUIRECT180
				o.uv.x = ((o.uv.x - 0.5) * 2.0) + 0.5;
				#endif
				o.uv.xy = float2(1.0-o.uv.x, o.uv.y);
#endif

#if STEREO_TOP_BOTTOM | STEREO_LEFT_RIGHT
				float4 scaleOffset = GetStereoScaleOffset(IsStereoEyeLeft(), _MainTex_ST.y < 0.0);

				#if !HIGH_QUALITY
				o.uv.xy *= scaleOffset.xy;
				o.uv.xy += scaleOffset.zw;
				#else
				o.scaleOffset = scaleOffset;
				#endif
#elif STEREO_CUSTOM_UV && !HIGH_QUALITY
				if (!IsStereoEyeLeft())
				{
					o.uv.xy = TRANSFORM_TEX(v.uv2, _MainTex);
					o.uv.xy = float2(1.0 - o.uv.x, o.uv.y);
				}
#endif

#if HIGH_QUALITY
				o.normal = v.normal;
#endif

				#if STEREO_DEBUG
				o.tint = GetStereoDebugTint(IsStereoEyeLeft());
				#endif

				UNITY_TRANSFER_FOG(o, o.vertex);

	
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	
				return o;
			}

			float3 HueShift(float3 color)
			{
				float3x3 RGB_YIQ = 
					float3x3 (0.299, 0.587, 0.114,
							  0.5959, -0.275, -0.3213,
							  0.2115, -0.5227, 0.3112);
				
				float3x3 YIQ_RGB = 
					float3x3 (1, 0.956, 0.619,
							  1, -0.272, -0.647,
							  1, -1.106, 1.702);

				float3 YIQ = mul(RGB_YIQ, color);
				float hue = atan2(YIQ.z,YIQ.y) + _HueShift;
				float chroma = length(float2(YIQ.y,YIQ.z)) * _Saturation;

				float Y = YIQ.x + _Brightness;
				float I = chroma * cos(hue);
				float Q = chroma * sin(hue);

				float3 shiftYIQ = float3(Y,I,Q);
				float3 newRGB = mul(YIQ_RGB,shiftYIQ);
				return newRGB;
			}

			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv;
	
				// Calculate the distance in world space
				float distancebet = distance(i.worldPos, _GazePoint.xyz);
                // Brightness calculation based on distance
				float brightness = 1.0;
				if (distancebet > _GazeRadius)
					{
						brightness -= (distancebet - _GazeRadius) * 0.01;
						brightness = max(brightness, 0);
					}

				if(distancebet > _GazeRadius_Color)
				{
					brightness -= (distancebet - _GazeRadius_Color) * 0.01;
					brightness = max(brightness, 0);
				}

				float4 color = tex2D(_MainTex, i.uv)*brightness;
				//return color * brightness;

#if HIGH_QUALITY
				float3 n = normalize(i.normal);

				float M_1_PI = 1.0 / 3.1415926535897932384626433832795;
				float M_1_2PI = 1.0 / 6.283185307179586476925286766559;
				uv.x = 0.5 - atan2(n.z, n.x) * M_1_2PI;
				uv.y = 0.5 - asin(-n.y) * M_1_PI;
				uv.x += 0.75;
				uv.x = fmod(uv.x, 1.0);
				//uv.x = uv.x % 1.0;
				uv.xy = TRANSFORM_TEX(uv, _MainTex);
				#if LAYOUT_EQUIRECT180
				uv.x = ((uv.x - 0.5) * 2.0) + 0.5;
				#endif
				#if STEREO_TOP_BOTTOM | STEREO_LEFT_RIGHT
				uv.xy *= i.scaleOffset.xy;
				uv.xy += i.scaleOffset.zw;
				#endif
#else
				uv = i.uv;
#endif
				fixed4 col;
#if USE_YPCBCR
				col = SampleYpCbCr(_MainTex, _ChromaTex, uv, _YpCbCrTransform);
#else
				col = SampleRGBA(_MainTex, uv);
#endif

#if STEREO_DEBUG
				col *= i.tint;
#endif
				color.rgb = HueShift(color.rgb);

				UNITY_APPLY_FOG(i.fogCoord, col);
				return fixed4(color.rgb, 1.0);
			}
			ENDCG
		}
	}
}
