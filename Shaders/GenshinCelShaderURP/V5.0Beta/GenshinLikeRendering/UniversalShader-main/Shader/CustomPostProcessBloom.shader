Shader "QiuHanMMDRender/CustomPostProcess/Bloom"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _MipBlendTargetTex("Mip Blend Target Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            Name "Pass0:BloomAreaExtractionPass"
            HLSLPROGRAM
            #pragma vertex BloomAreaExtractionVertex
            #pragma fragment BloomAreaExtractionFragment

            #pragma shader_feature_local _ _EXTRACTBYLUMINANCE _EXTRACTBYCOLOR

            #include "../ShaderLibrary/PostProcess/PostProcessBloomAreaExtractionPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Pass1:GaussianBlur_Vertical"
            HLSLPROGRAM
            #pragma vertex GaussianBlurVerticalVertex
            #pragma fragment GaussianBlurFragment

            #include "../ShaderLibrary/PostProcess/PostProcessGaussianBlurPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Pass2:GaussianBlur_Horizontal"
            HLSLPROGRAM
            #pragma vertex GaussianBlurHorizontalVertex
            #pragma fragment GaussianBlurFragment

            #include "../ShaderLibrary/PostProcess/PostProcessGaussianBlurPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Pass3:UpSampleMipsBlend"
            HLSLPROGRAM
            #pragma vertex BloomBlendVertex
            #pragma fragment BloomMipsBlendFragment

            #include "../ShaderLibrary/PostProcess/PostProcessBloomMipBlendPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Pass4:UpSampleFinalBlend"
            HLSLPROGRAM
            #pragma vertex BloomBlendVertex
            #pragma fragment BloomFinalBlendFragment

            #include "../ShaderLibrary/PostProcess/PostProcessBloomMipBlendPass.hlsl"
            ENDHLSL
        }
    }
}