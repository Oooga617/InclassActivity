Shader "Custom/StencilFront"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white"{}
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" "Queue" = "Geometry" }

        //Disable color output (so the object doesn't appear visually)')
        ColorMask 0 
        ZWrite Off

        //Stencil operations
        Stencil
        {
            Ref 1 //set stencil reference value
            Comp Always //always pass stencil test
            Pass Replace //replace stencil buffer value with reference value
        }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
               float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                return half4(0, 0, 0, 1);  // Black color (will not be visible due to ColorMask 0)
            }
            ENDHLSL
        }
    }
}
