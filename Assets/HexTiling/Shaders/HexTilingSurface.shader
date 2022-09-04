Shader "HexTiling/Surface"
{
    // Hex-Tiling Surface Shader
    // Reference : https://github.com/mmikk/hextile-demo
    //             https://github.com/keijiro/HexTileTest
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [NoScaleOffset]_BumpMap ("Bump Map", 2D) = "bump" {}
        _BumpIntensity("Bump Intensity", Range(0,1)) = 1
        [NoScaleOffset]_OcclusionMap ("Occlusion Map", 2D) = "white" {}
        
        [Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        [NoScaleOffset]_MetallicGlossMap ("Metallic Gloss Map", 2D) = "black" {}
        
        _RotStrength("Rotate Strength", float) = 0
        _Contrast("Contrast", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows
        #pragma shader_feature _METALLICGLOSSMAP
        
        #include "HexTiling.cginc"

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        
        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _OcclusionMap;
        sampler2D _MetallicGlossMap;
        
        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;
        float _BumpIntensity;
        float _RotStrength;
        float _Contrast;
        float _Metallic;
        
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c;
            float3 weights;
            hex2colTex(c, weights, _MainTex, IN.uv_MainTex.xy, _RotStrength, _Contrast);

            c *= _Color;

            float3 normal;
            bumphex2derivNMap(normal, weights, _BumpMap, IN.uv_MainTex.xy, _RotStrength, _Contrast, _BumpIntensity);

            float4 occlusion;
            hex2colTex(occlusion, weights, _OcclusionMap, IN.uv_MainTex.xy, _RotStrength, _Contrast);

            float4 roughness;
            hex2colTex(roughness, weights, _MetallicGlossMap, IN.uv_MainTex.xy, _RotStrength, _Contrast);
            
            o.Albedo = c.rgb;
            o.Normal = normal;
            o.Metallic = roughness.rgb;
            // o.Metallic = 0.1;
            o.Smoothness = roughness.a * _Metallic;
            o.Occlusion = occlusion.r;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
