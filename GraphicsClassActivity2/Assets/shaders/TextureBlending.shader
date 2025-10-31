Shader "Custom/TextureBlending"
{
    Properties
    {
        _MainTex("Texture",2D) = "white"{}
        _BaseColor("Base Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" "Queue" = "Transparent" "RenderType" = "Transparent" }
        // Uncomment the blending mode you want to use:
        // Alpha blending (default):
        //Blend SrcAlpha OneMinusSrcAlpha
        // Additive blending:
         //Blend One One
        // Multiplicative blending:
         //Blend DstColor Zero
  // Reverse multiplicative blending: makes black parts transparent
        Blend OneMinusDstColor One
        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;  // Clip-space position
                float2 uv : TEXCOORD0;             // UV coordinates passed to the fragment shader
            };

            // Declare the texture and base color properties
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _BaseColor;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);  // Transform to clip space
                OUT.uv = IN.uv;  // Pass UVs to fragment shader
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
               // Sample the texture using UV coordinates
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                // Combine the texture color and the base color
                half4 finalColor = texColor * _BaseColor;
                return finalColor;  // Return the final color with blending
            }
            ENDHLSL
        }
    }
}
