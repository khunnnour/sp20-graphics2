Shader "Hidden/DespeckleMedian1px"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        // Cull Off ZWrite Off ZTest Always

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

            sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			// holder for color channel values
			float4 vals[9];
			float avgs[9];
			float4 color = float4(0.0f, 0.0f, 0.0f, 0.0f);


			// Get vals of pixels
			void getValues(v2f i)
			{			
				float off = _MainTex_TexelSize.x;
				// top row
				vals[0] = tex2D(_MainTex, float2(i.uv.x - off, i.uv.y + off));
				vals[1] = tex2D(_MainTex, float2(i.uv.x, i.uv.y + off));
				vals[2] = tex2D(_MainTex, float2(i.uv.x + off, i.uv.y + off));
				
				// middle row
				vals[3] = tex2D(_MainTex, float2(i.uv.x + off, i.uv.y));
				vals[4] = tex2D(_MainTex, float2(i.uv.x, i.uv.y));
				vals[5] = tex2D(_MainTex, float2(i.uv.x - off, i.uv.y));
				
				// bottom
				vals[6] = tex2D(_MainTex, float2(i.uv.x - off, i.uv.y - off));
				vals[7] = tex2D(_MainTex, float2(i.uv.x, i.uv.y - off));
				vals[8] = tex2D(_MainTex, float2(i.uv.x + off, i.uv.y - off));
				
				//// top row
				//color += tex2D(_MainTex, float2(i.uv.x - off, i.uv.y + off));
				//color += tex2D(_MainTex, float2(i.uv.x, i.uv.y + off));
				//color += tex2D(_MainTex, float2(i.uv.x + off, i.uv.y + off));
				//
				//// middle row
				//color += tex2D(_MainTex, float2(i.uv.x + off, i.uv.y));
				//color += tex2D(_MainTex, float2(i.uv.x, i.uv.y));
				//color += tex2D(_MainTex, float2(i.uv.x - off, i.uv.y));
				//
				//// bottom
				//color += tex2D(_MainTex, float2(i.uv.x - off, i.uv.y - off));
				//color += tex2D(_MainTex, float2(i.uv.x, i.uv.y - off));
				//color += tex2D(_MainTex, float2(i.uv.x + off, i.uv.y - off));
				//
				//color *= 0.111f;
			}

			// sort color's channels
			// - - - - - - - - - - - - - - - - - - - - - - - - - - //
			// Original code for sorting: jozxyqk on stackoverflow //
			// https://stackoverflow.com/a/28856413				   //
			// - - - - - - - - - - - - - - - - - - - - - - - - - - //
			//
			//float tmp;
			//// Compare macro
			//#define CMP(a, b) a < b
			//// Swap macro
			//#define SWAP(a, b) tmp = a; a = b; b = tmp;
			//// Compare/Swap macro
			//#define CSWAP(a, b) if (CMP(a, b)) {SWAP(a, b);}
			//
			//void SortValues()
			//{
			//	// sort r values
			//	CSWAP(vals[0].r, vals[1].r);
			//	CSWAP(vals[2].r, vals[3].r);
			//	CSWAP(vals[4].r, vals[5].r);
			//	CSWAP(vals[7].r, vals[8].r);
			//
			//	CSWAP(vals[0].r, vals[2].r);
			//	CSWAP(vals[1].r, vals[3].r);
			//	CSWAP(vals[6].r, vals[8].r);
			//	
			//	CSWAP(vals[1].r, vals[2].r);
			//	CSWAP(vals[6].r, vals[7].r);
			//	CSWAP(vals[5].r, vals[8].r);
			//	
			//	CSWAP(vals[4].r, vals[7].r);
			//	CSWAP(vals[3].r, vals[8].r);
			//
			//	CSWAP(vals[4].r, vals[6].r);
			//	CSWAP(vals[5].r, vals[7].r);
			//
			//	CSWAP(vals[5].r, vals[6].r);
			//	CSWAP(vals[2].r, vals[7].r);
			//
			//	CSWAP(vals[0].r, vals[5].r);
			//	CSWAP(vals[1].r, vals[6].r);
			//	CSWAP(vals[3].r, vals[7].r);
			//
			//	CSWAP(vals[0].r, vals[4].r);
			//	CSWAP(vals[1].r, vals[5].r);
			//	CSWAP(vals[3].r, vals[6].r);
			//
			//	CSWAP(vals[1].r, vals[4].r);
			//	CSWAP(vals[2].r, vals[5].r);
			//
			//	CSWAP(vals[2].r, vals[4].r);
			//	CSWAP(vals[3].r, vals[5].r);
			//
			//	CSWAP(vals[3].r, vals[4].r);
			//}
			void bubbleSort()
			{
				float tmp;
				//bool swapped = true;
				//int j = 0;
				//
				//for (int c = 0; c < 3; c--)
				//{
				//	if (!swapped)
				//		break;
				//	swapped = false;
				//	j++;
				//	for (int i = 0; i < 3; i++)
				//	{
				//		if (i >= 3 - j)
				//			break;
				//		if (vals[i].r > vals[i + 1].r)
				//		{
				//			tmp = vals[i].r;
				//			vals[i].r = vals[i + 1].r;
				//			vals[i + 1].r = tmp;
				//			swapped = true;
				//		}
				//		if (vals[i].g > vals[i + 1].g)
				//		{
				//			tmp = vals[i].g;
				//			vals[i].g = vals[i + 1].g;
				//			vals[i + 1].g = tmp;
				//			swapped = true;
				//		}
				//		if (vals[i].b > vals[i + 1].b)
				//		{
				//			tmp = vals[i].b;
				//			vals[i].b = vals[i + 1].b;
				//			vals[i + 1].b = tmp;
				//			swapped = true;
				//		}
				//	}
				//}
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
