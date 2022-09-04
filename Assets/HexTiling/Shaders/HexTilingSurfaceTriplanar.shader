Shader "HexTiling/Surface Tri-planar"
{
    // Hex-Tiling Surface Tri-planar Shader
    // Reference : https://github.com/mmikk/hextile-demo
    //             https://github.com/keijiro/HexTileTest
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        [NoScaleOffset]_MainTex ("Albedo (RGB)", 2D) = "white" {}
        [NoScaleOffset]_BumpMap ("Bump Map", 2D) = "bump" {}
        _BumpIntensity("Bump Intensity", Range(0,1)) = 1
        [NoScaleOffset]_OcclusionMap ("Occlusion Map", 2D) = "white" {}
        
        [Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        [NoScaleOffset]_MetallicGlossMap ("Metallic Gloss Map", 2D) = "black" {}

        _RotStrength("Rotate Strength", float) = 0
        _Contrast("Contrast", Range(0,1)) = 0.5
        _DetailTileRate("Tile Rate",float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

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
            float3 worldPos;
            float3 worldNormal; INTERNAL_DATA
        };

        fixed4 _Color;
        float _BumpIntensity;
        float _RotStrength;
        float _Contrast;
        float _Metallic;
        float _DetailTileRate;
        
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 col;
            float3 normal;
            float4 occlusion;
            float4 roughness;
            float3 weights;

            float3 worldNormal = WorldNormalVector(IN, float3(0.0, 0.0, 1.0));
            CommonTriplanarColor(col, weights, _MainTex, IN.worldPos,
                    worldNormal, _RotStrength, _Contrast, _DetailTileRate);
            
            CommonTriplanarNormal(normal, weights, _BumpMap, IN.worldPos,
                        worldNormal, _RotStrength, _Contrast, _BumpIntensity, _DetailTileRate);
            
            CommonTriplanarColor(occlusion, weights, _OcclusionMap, IN.worldPos,
                    worldNormal, _RotStrength, _Contrast, _DetailTileRate);

            CommonTriplanarColor(roughness, weights, _MetallicGlossMap, IN.worldPos,
                    worldNormal, _RotStrength, _Contrast, _DetailTileRate);
            
            // Albedo comes from a texture tinted by color
            // o.Albedo = normal;
            o.Albedo = col * _Color;
            o.Normal = normal;
            // Metallic and smoothness come from slider variables
            o.Metallic = roughness.rgb;
            o.Smoothness = roughness.a * _Metallic;
            o.Occlusion = occlusion.r;
            // o.Alpha = col.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
