Shader "Despeckle Shader 4x"
{
    Properties
    {
        _ReflTex("Texture", 2D) = "white" {}
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

            sampler2D _ReflTex;
            float4 _ReflTex_TexelSize;

            // Makes pixel average color of 4 pixels around it
            fixed4 despeckle(v2f i)
            {
                fixed4 color = fixed4(0.0f, 0.0f, 0.0f, 0.0f);
                float off = _ReflTex_TexelSize.x;

                // top row
                color += tex2D(_ReflTex, float2(i.uv.x, i.uv.y + off)) * 0.2f;

                // middle row
                color += tex2D(_ReflTex, float2(i.uv.x + off, i.uv.y)) * 0.2f;
                color += tex2D(_ReflTex, float2(i.uv.x, i.uv.y)) * 0.2f;
                color += tex2D(_ReflTex, float2(i.uv.x - off, i.uv.y)) * 0.2f;
                
                // bottom
                color += tex2D(_ReflTex, float2(i.uv.x, i.uv.y - off)) * 0.2f;

                return color;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = despeckle(i);

                return fixed4(col.xyz, 1.0f);
            }

        ENDCG
    }
    }
}
