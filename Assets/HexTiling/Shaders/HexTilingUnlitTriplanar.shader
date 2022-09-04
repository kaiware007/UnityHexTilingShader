Shader "HexTiling/Unlit Triplanar"
{
    // Hex-Tiling Unlit Tri-planar Shader
    // Reference : https://github.com/mmikk/hextile-demo
    //             https://github.com/keijiro/HexTileTest
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RotStrength("Rotate Strength", float) = 0
        _Contrast("Contrast", Range(0,1)) = 0.5
        _DetailTileRate("Tile Rate",float) = 1
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD2;
                float3 worldNormal : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _RotStrength;
            float _Contrast;
            float _DetailTileRate;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col;
                float3 weights;
                CommonTriplanarColor(col, weights, _MainTex, i.worldPos,
                    i.worldNormal, _RotStrength, _Contrast, _DetailTileRate);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
