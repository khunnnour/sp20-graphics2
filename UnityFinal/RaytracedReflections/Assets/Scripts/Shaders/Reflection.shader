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
		Pass
		{
			CGPROGRAM
			// Upgrade NOTE: excluded shader from DX11 because it uses wrong array syntax (type[size] name)
			//#pragma exclude_renderers d3d11
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _ReflTex;
			float4 _MainTex_TexelSize;
			// holder for color channel values
			float4 vals[9];
			float avgs[9];
			float4 color = float4(0.0f, 0.0f, 0.0f, 0.0f);

			// Get vals of pixels
			void getValues(v2f i)
			{
				const float off = _MainTex_TexelSize.x;
				// top row
				vals[0] = tex2D(_ReflTex, float2(i.uv.x - off, i.uv.y + off));
				vals[1] = tex2D(_ReflTex, float2(i.uv.x, i.uv.y + off));
				vals[2] = tex2D(_ReflTex, float2(i.uv.x + off, i.uv.y + off));
				
				// middle row
				vals[3] = tex2D(_ReflTex, float2(i.uv.x + off, i.uv.y));
				vals[4] = tex2D(_ReflTex, float2(i.uv.x, i.uv.y));
				vals[5] = tex2D(_ReflTex, float2(i.uv.x - off, i.uv.y));
				
				// bottom
				vals[6] = tex2D(_ReflTex, float2(i.uv.x - off, i.uv.y - off));
				vals[7] = tex2D(_ReflTex, float2(i.uv.x, i.uv.y - off));
				vals[8] = tex2D(_ReflTex, float2(i.uv.x + off, i.uv.y - off));
			}

			void bubbleSort()
			{
				float tmp;
				bool sorted = false;
				while (!sorted)
				{
					sorted = true;
					for (int i = 1; i < 9; i++)
					{
						if (vals[i - 1].r > vals[i].r)
						{
							tmp = vals[i].r;
							vals[i].r = vals[i - 1].r;
							vals[i - 1].r = tmp;
							sorted = false;
						}
						if (vals[i - 1].g > vals[i].g)
						{
							tmp = vals[i].g;
							vals[i].g = vals[i - 1].g;
							vals[i - 1].g = tmp;
							sorted = false;
						}
						if (vals[i - 1].b > vals[i].b)
						{
							tmp = vals[i].b;
							vals[i].b = vals[i - 1].b;
							vals[i - 1].b = tmp;
							sorted = false;
						}
					}
				}
			}

			fixed4 frag(v2f i) : SV_Target
			{
				getValues(i);

				bubbleSort();

				fixed4 col = vals[3];

				return fixed4(col.xyz, 1.0f);
			}
            ENDCG
		}
	}
}
