#ifndef CUSTOM_AVARTAR_SHADERUTILS_INCLUDED
#define CUSTOM_AVARTAR_SHADERUTILS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

float get_index(float material_id)
{
    // prevents a returned negative index on certain GPUs
    return max(0, material_id - 1);
}

float4 CombineAndTransformDualFaceUV(float2 uv1, float2 uv2, float4 mapST)
{
    return float4(uv1, uv2) * mapST.xyxy + mapST.zwzw;
}

void SetupDualFaceRendering(inout float3 normalWS, inout float4 uv, FRONT_FACE_TYPE isFrontFace)
{
    #if defined(_MODEL_GAME)
        if (IS_FRONT_VFACE(isFrontFace, 1, 0))
            return;

        // 游戏内的部分模型用了双面渲染
        // 渲染背面的时候需要调整一些值，这样就不需要修改之后的计算了

        // 反向法线
        normalWS *= -1;

        // 交换 uv1 和 uv2
        #if defined(_BACKFACEUV2_ON)
            uv.xyzw = uv.zwxy;
        #endif
    #endif
}

float3 desaturation(float3 color)
{
    float3 grayXfer = float3(0.3, 0.59, 0.11);
    float grayf = dot(color, grayXfer);
    return float3(grayf, grayf, grayf);
}

float3 CalculateGI(float3 baseColor, float diffuseThreshold, float3 sh, float intensity, float mainColorLerp)
{
    return intensity * lerp(float3(1, 1, 1), baseColor, mainColorLerp) * lerp(desaturation(sh), sh, mainColorLerp) * diffuseThreshold;
}

Light GetCharacterMainLightStruct(float4 shadowCoord, float3 positionWS)
{
    Light light = GetMainLight();

    #if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        ShadowSamplingData shadowSamplingData = GetMainLightShadowSamplingData();
        half4 shadowParams = GetMainLightShadowParams();

        // 我自己试下来，在角色身上 LowQuality 比 Medium 和 High 好
        // Medium 和 High 采样数多，过渡的区间大，在角色身上更容易出现 Perspective aliasing
        shadowSamplingData.softShadowQuality = SOFT_SHADOW_QUALITY_LOW;
        light.shadowAttenuation = SampleShadowmap(TEXTURE2D_ARGS(_MainLightShadowmapTexture, sampler_LinearClampCompare), shadowCoord, shadowSamplingData, shadowParams, false);
        light.shadowAttenuation = lerp(light.shadowAttenuation, 1, GetMainLightShadowFade(positionWS));
    #endif

    #ifdef _LIGHT_LAYERS
        if (!IsMatchingLightLayer(light.layerMask, GetMeshRenderingLayer()))
        {
            // 偷个懒，直接把强度改成 0
            light.distanceAttenuation = 0;
            light.shadowAttenuation = 0;
        }
    #endif

    return light;
}

half GetShadow(float3 normalWS, half3 lightDirection, half aoFactor, float shadowAttenuation)
{
    half NDotL = dot(normalWS, lightDirection);
    half halfLambert = smoothstep(0.0, _GreyFac, NDotL + _DarkFac);
    half shadow = saturate(2.0 * halfLambert * aoFactor) * shadowAttenuation;
    return lerp(shadow, 1.0, step(0.9, aoFactor));
}

float3 GetShadowRampColor(float halfLambert, float4 lightmap)
{
    float brightMask = step(_BrightFac, halfLambert);  //亮面
    //判断白天与夜晚
    float rampSampling = 0.0;
    if(_UseCoolShadowColorOrTex == 1){rampSampling = 0.5;}
    //计算ramp采样条数
    float ramp0 = _RampIndex0 * -0.1 + 1.05 - rampSampling;  //0.95
    float ramp1 = _RampIndex1 * -0.1 + 1.05 - rampSampling;  //0.65
    float ramp2 = _RampIndex2 * -0.1 + 1.05 - rampSampling;  //0.75
    float ramp3 = _RampIndex3 * -0.1 + 1.05 - rampSampling;  //0.55
    float ramp4 = _RampIndex4 * -0.1 + 1.05 - rampSampling;  //0.85
    //分离lightmap.a各材质
    float lightmapA1 = step(0.0, lightmap.a);  //0.0
    float lightmapA2 = step(0.25, lightmap.a);  //0.3
    float lightmapA3 = step(0.45, lightmap.a);  //0.5
    float lightmapA4 = step(0.65, lightmap.a);  //0.7
    float lightmapA5 = step(0.95, lightmap.a);  //1.0
    //重组lightmap.a
    float rampV = 0;
    rampV = lerp(rampV, ramp0, lightmapA1);  //0.0
    rampV = lerp(rampV, ramp1, lightmapA2);  //0.3
    rampV = lerp(rampV, ramp2, lightmapA3);  //0.5
    rampV = lerp(rampV, ramp3, lightmapA4);  //0.7
    rampV = lerp(rampV, ramp4, lightmapA5);  //1.0
    //采样ramp
    float3 rampCol = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, rampV)).rgb;
    float3 shadowRamp = lerp(rampCol, halfLambert, brightMask);  //遮罩亮面
    return shadowRamp;
}

float3 GetRimLight(float4 positionCS, float3 normalWS, float3 LightColor, float material_id)
{

    //获取当前片元的深度
    float linearEyeDepth = LinearEyeDepth(positionCS.z, _ZBufferParams);
    //根据视线空间的法线采样左边或者右边的深度图
    float3 normalVS = mul((float3x3)UNITY_MATRIX_V, normalWS);
    //根据视线空间的法线采样左边或者右边的深度图，根据深度缩放，实现近大远小的效果
    float2 uvOffset = float2(sign(normalVS.x), 0) * _RimLightWidth / (1 + linearEyeDepth) / 100;
    int2 loadTexPos = positionCS.xy + uvOffset * _ScaledScreenParams.xy;
    //限制左右，不采样到边界
    loadTexPos = min(max(loadTexPos, 0), _ScaledScreenParams.xy - 1);
    //偏移后的片元深度
    float offsetSceneDepth = LoadSceneDepth(loadTexPos);
    //转换为LinearEyeDepth
    float offsetLinearEyeDepth = LinearEyeDepth(offsetSceneDepth, _ZBufferParams);
    //深度差超过阈值，表示是边界
    float rimLight = saturate(offsetLinearEyeDepth - (linearEyeDepth + _RimLightThreshold)) / _RimLightFadeout;

    float4 rim_colors[5] =
    {
        _RimColor1, _RimColor2, _RimColor3, _RimColor4, _RimColor5
    };

    // get rim light color
    float3 rimLightColor = saturate(rim_colors[get_index(material_id)].rgb * rimLight * _RimLightTintColor);
    rimLightColor *= saturate(LightColor.rgb);
    rimLightColor *= _RimLightBrightness;

    return rimLightColor;
}

float materialID(float alpha)
{
    float region = alpha;

    float material = 1.0f;

    material = ((region >= 0.8f)) ? 2.0f : 1.0f;
    material = ((region >= 0.4f && region <= 0.6f)) ? 3.0f : material;
    material = ((region >= 0.2f && region <= 0.4f)) ? 4.0f : material;
    material = ((region >= 0.6f && region <= 0.8f)) ? 5.0f : material;

    return material;
}

void DoClipTestToTargetAlphaValue(float alpha, float alphaTestThreshold)
{
    clip(alpha - alphaTestThreshold);
}

#endif