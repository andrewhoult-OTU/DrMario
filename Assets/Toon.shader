Shader "Unlit/Toon"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_LUT ("Lut", 2D) = "white" {}
		_LitThreshold("Lit Threshold", Float) = 0.5
		_LitColor ("Lit Color", Color) = (1, 1, 1, 1)
		_ShadowColour ("Ambient Color", Color) = (0, 0, 0, 1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 vertex : SV_POSITION;
			};

			CBUFFER_START(UnityPerMaterial)
				sampler2D _MainTex;
				float4 _MainTex_ST;

				sampler2D _LUT;
				float4 _LUT_ST;

				float _LitThreshold;
				float4 _LitColor;
				float4 _ShadowColour;
			CBUFFER_END

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);

				o.normal = normalize(mul(unity_ObjectToWorld, half4(v.normal, 0)).xyz);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// Hardcoded light dir because otherwise I need to create an entirely new project with 3D URP bases
				fixed3 lightDir = fixed3(2, -1, 1);
				lightDir = normalize(-lightDir);

				// half lambert
				fixed light = dot(lightDir, i.normal) * 0.5 + 0.5;

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				if (light > _LitThreshold)
				{
					col *= _LitColor;
				}
				else
				{
					col *= _ShadowColour;
				}

				col = tex2D(_MainTex, float2(col.r, col.g, 32 * col.b));

				return col;
			}
			ENDHLSL
		}
	}
}
