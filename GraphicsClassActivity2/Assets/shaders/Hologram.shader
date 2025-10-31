Shader "Custom/Hologram"
{
    Properties
    {
        _MainTex("Main Texture",2D) = "white"{}
        _LineColor("Line Color",Color) = (0,1,1,1)//scan line colors
        _FresnelColor("Fresnel Color", Color) = (0,0.8,1,1) // color of rim lighting
        _RimIntensity("Rim Intensity", Float) = 1.5//Strength of the rim lighting
        _FresnelPower("Fresnel Power", Range(1,5)) = 2.0 //fresnel effect Power
        _LineSpeed ("Line Speed",Float) = 1.0 //Speed of scanning lines
        _LineFrequency("Line Frequency",Float) = 10.0 //Frequency of scan lines
        _Transparency("Transparency",Range(0,1)) = 0.5 //transparency coontrol

    }

    SubShader
    {
         Tags { "RenderPipeline" = "UniversalRenderPipeline" "Queue" = "Transparent" "RenderType" = "Transparent" }

        // Transparency blending
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD1;
                float3 viewDirWS : TEXCOORD2;
                float2 uv : TEXCOORD0;
            };

             // Material properties
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _LineColor;
            float4 _FresnelColor;
            float _RimIntensity;
            float _FresnelPower;
            float _LineSpeed;
            float _LineFrequency;
            float _Transparency;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                // Transform object space position to clip space
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                
                // Transform normal to world space
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));

                // Calculate view direction in world space
                OUT.viewDirWS = normalize(GetWorldSpaceViewDir(IN.positionOS.xyz));

                // Pass through the UV coordinates
                OUT.uv = IN.uv;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);

                //fresnel effect
                half3 normalWS = normalize(IN.normalWS);
                half3 viewDirWS = normalize(IN.viewDirWS);
                half fresnel = pow(1.0 - saturate(dot(viewDirWS, normalWS)), _FresnelPower);
                half3 fresnelColor = _FresnelColor.rgb*fresnel*_RimIntensity;

                 // Scrolling lines effect
                float lineValue = sin(IN.uv.y * _LineFrequency + _Time.y * _LineSpeed);
                half3 lineColor = _LineColor.rgb * step(0.5, lineValue);  // Creates sharp scan lines

                // Combine the texture color, fresnel rim, and scan lines
                half3 finalColor = texColor.rgb + fresnelColor + lineColor;

                // Apply transparency
                return half4(finalColor, _Transparency);
            }
            ENDHLSL
        }
    }
}
