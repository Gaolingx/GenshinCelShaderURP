Shader "URPGenshinPostProcess"
{
    HLSLINCLUDE

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

        #pragma multi_compile_local_fragment _ _BLOOM_COLOR _BLOOM_BRIGHTNESS
        #pragma multi_compile_local_fragment _ _TONEMAPPING

        float2 _BlitTexture_TexelSize;
        half _BloomThreshold;
        half _BloomIntensity;
        half4 _BloomWeights;
        half4 _BloomColor;
        half _BlurRadius;
        half _Exposure;
        half _Contrast;
        half _Saturation;

        TEXTURE2D(_BloomTextureA);
        TEXTURE2D(_BloomTextureB);
        TEXTURE2D(_BloomTextureC);
        TEXTURE2D(_BloomTextureD);

        const static int kernelSize = 9;
        const static float kernelOffsets[9] = {
            -4.0,
            -3.0,
            -2.0,
            -1.0,
            0.0,
            1.0,
            2.0,
            3.0,
            4.0,
        };
        const static float kernel[9] = {
            0.01621622,
            0.05405405,
            0.12162162,
            0.19459459,
            0.22702703,
            0.19459459,
            0.12162162,
            0.05405405,
            0.01621622
        };

        half4 Prefilter(Varyings input) : SV_TARGET
        {
            float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord);
            half4 color = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv);

#if _BLOOM_BRIGHTNESS
            half brightness = max(max(color.r, color.g), color.b);
            color.rgb *= saturate(brightness - _BloomThreshold);
#else
            color.rgb = max(color.rgb - _BloomThreshold, 0.0);
#endif

            return color;
        }

        half4 GaussianBlur(float2 uv, float2 direction)
        {
            float2 offset = _BlurRadius * _BlitTexture_TexelSize * direction; 
            half4 color = 0.0;

            UNITY_UNROLL
            for (int i = 0; i < kernelSize; i++)
            {
                float2 sampleUV = uv + kernelOffsets[i] * offset;
                color += kernel[i] * SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, sampleUV);
            }

            return color;
        }

        half4 HorizontalBlur1x(Varyings input) : SV_TARGET
        {
            float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord);
            return GaussianBlur(uv, float2(1.0, 0.0));
        }

        half4 HorizontalBlur2x(Varyings input) : SV_TARGET
        {
            float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord);
            return GaussianBlur(uv, float2(2.0, 0.0));
        }

        half4 VerticalBlur1x(Varyings input) : SV_TARGET
        {
            float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord);
            return GaussianBlur(uv, float2(0.0, 1.0));
        }

        half4 VerticalBlur2x(Varyings input) : SV_TARGET
        {
            float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord);
            return GaussianBlur(uv, float2(0.0, 2.0));
        }

        half4 Upsample(Varyings input) : SV_TARGET
        {
            float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord);
            half4 color = 0.0;
            half4 weights = _BloomWeights;

            color += SAMPLE_TEXTURE2D_X(_BloomTextureA, sampler_LinearClamp, uv) * weights.x;
            color += SAMPLE_TEXTURE2D_X(_BloomTextureB, sampler_LinearClamp, uv) * weights.y;
            color += SAMPLE_TEXTURE2D_X(_BloomTextureC, sampler_LinearClamp, uv) * weights.z;
            color += SAMPLE_TEXTURE2D_X(_BloomTextureD, sampler_LinearClamp, uv) * weights.w;

            return color;
        }

        half3 Tonemap(half3 color)
        {
            half3 c0 = (1.36 * color + 0.047) * color;
            half3 c1 = (0.93 * color + 0.56) * color + 0.14;
            return saturate(c0 / c1);
        }

        half4 ColorGrading(Varyings input) : SV_TARGET
        {
            float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord);
            half4 baseMap = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv);
            half3 color = baseMap.rgb;
            half alpha = baseMap.a;

#if _BLOOM_COLOR || _BLOOM_BRIGHTNESS
            // Bloom
            half3 bloom = SAMPLE_TEXTURE2D_X(_BloomTextureA, sampler_LinearClamp, uv).rgb;
            bloom *= _BloomIntensity * _BloomColor.rgb;
            color += bloom;
#endif

            // Exposure
            color *= _Exposure;

#if _TONEMAPPING
            // Tonemapping
            color = Tonemap(color);
#endif

            // Contrast
            half3 colorLog = LinearToLogC(color);
            colorLog = lerp(ACEScc_MIDGRAY, colorLog, _Contrast);
            color = LogCToLinear(colorLog);

            // Saturation
            half luma = dot(color, half3(0.2126, 0.7152, 0.0722));
            color = lerp(luma, color, _Saturation);

            return float4(color, alpha);
        }

    ENDHLSL

    Subshader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        ZWrite Off ZTest Always Blend Off Cull Off

        Pass
        {
            Name "Blit"
            
            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment FragBilinear

            ENDHLSL
        }

        Pass
        {
            Name "BloomPrefilter"

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Prefilter

            ENDHLSL
        }

        Pass
        {
            Name "BloomHorizontalBlur1x"

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment HorizontalBlur1x

            ENDHLSL
        }

        Pass
        {
            Name "BloomHorizontalBlur2x"

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment HorizontalBlur2x

            ENDHLSL
        }

        Pass
        {
            Name "BloomVerticalBlur1x"

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment VerticalBlur1x

            ENDHLSL
        }

        Pass
        {
            Name "BloomVerticalBlur2x"

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment VerticalBlur2x

            ENDHLSL
        }

        Pass
        {
            Name "BloomUpsample"

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Upsample

            ENDHLSL
        }

        Pass
        {
            Name "ColorGrading"

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment ColorGrading

            ENDHLSL
        }
    }
}
