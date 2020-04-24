Shader "Raytrace Reflection"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_SpecTex("Specular map", 2D) = "white" {}
		_ReflTex("Reflection", 2D) = "white" {}
		//_SkyCube("Skybox", Cube) = "white"{}
	}
	
	SubShader
	{
		// No culling or depth
		//Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			sampler2D _MainTex;
			sampler2D _SpecTex;
			sampler2D _ReflTex;
			float4 _ReflTex_TexelSize;
			//sampler3D _SkyCube;

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 diffuse = tex2D(_MainTex, i.uv);
				fixed4 specular = tex2D(_SpecTex, i.uv);
				fixed4 reflection = tex2D(_ReflTex, i.uv);

				fixed4 col = lerp(diffuse, reflection, specular);

				return fixed4(col.xyz,1.0f);
			}

			ENDCG
		}
	}
}
