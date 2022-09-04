Shader "HexTiling/Unlit"
{
    // Practical Real-Time Hex-Tiling Unlit Shader
    // Reference : https://github.com/mmikk/hextile-demo
    //             https://github.com/keijiro/HexTileTest
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RotStrength("Rotate Strength", float) = 0
        _Contrast("Contrast", Range(0,1)) = 0.5
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
            #include "HexTiling.cginc"
            
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
            float _RotStrength;
            float _Contrast;
            
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
                fixed4 color;
                float3 weights;
                hex2colTex(color, weights, _MainTex, i.uv, _RotStrength, _Contrast);

                // color.rgb = UnpackNormal(color);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, color);
                return color;
            }
            ENDCG
        }
    }
}
