#ifndef CUSTOM_AVARTAR_LIGHTING_INCLUDED
#define CUSTOM_AVARTAR_LIGHTING_INCLUDED

///////////////////////////////////////////////////////////////////////////////
//                      Lighting Functions                                   //
///////////////////////////////////////////////////////////////////////////////

float GetLinearEyeDepthAnyProjection(float depth)
{
    if (IsPerspectiveProjection())
    {
        return LinearEyeDepth(depth, _ZBufferParams);
    }

    return LinearDepthToEyeDepth(depth);
}

// works only in fragment shader
float GetLinearEyeDepthAnyProjection(float4 svPosition)
{
    // 透视投影时，Scene View 里直接返回 svPosition.w 会出问题，Game View 里没事

    return GetLinearEyeDepthAnyProjection(svPosition.z);
}

struct RimLightMaskData
{
    float3 color;
    float width;
    float edgeSoftness;
    float modelScale;
    float ditherAlpha;
};

float3 GetRimLightMask(
    RimLightMaskData rlmData,
    float3 normalWS,
    float3 viewDirWS,
    float NoV,
    float4 svPosition,
    float4 lightMap)
{
    float invModelScale = rcp(rlmData.modelScale);
    float rimWidth = rlmData.width / 2000.0; // rimWidth 表示的是屏幕上像素的偏移量，和 modelScale 无关

    rimWidth *= lightMap.r; // 有些地方不要边缘光
    rimWidth *= _ScaledScreenParams.y; // 在不同分辨率下看起来等宽

    if (IsPerspectiveProjection())
    {
        // unity_CameraProjection._m11: cot(FOV / 2)
        // 2.414 是 FOV 为 45 度时的值
        rimWidth *= unity_CameraProjection._m11 / 2.414; // FOV 越小，角色越大，边缘光越宽
    }
    else
    {
        // unity_CameraProjection._m11: (1 / Size)
        // 1.5996 纯 Magic Number
        rimWidth *= unity_CameraProjection._m11 / 1.5996; // Size 越小，角色越大，边缘光越宽
    }

    float depth = GetLinearEyeDepthAnyProjection(svPosition);
    rimWidth *= 10.0 * rsqrt(depth * invModelScale); // 近大远小

    float indexOffsetX = -sign(cross(viewDirWS, normalWS).y) * rimWidth;
    uint2 index = clamp(svPosition.xy - 0.5 + float2(indexOffsetX, 0), 0, _ScaledScreenParams.xy - 1); // 避免出界
    float offsetDepth = GetLinearEyeDepthAnyProjection(LoadSceneDepth(index));

    // 只有 depth 小于 offsetDepth 的时候再画
    float intensity = smoothstep(0.12, 0.18, (offsetDepth - depth) * invModelScale);

    // 用于柔化边缘光，edgeSoftness 越大，越柔和
    float fresnel = pow(max(1 - NoV, 0.01), max(rlmData.edgeSoftness, 0.01));

    // Dither Alpha 效果会扣掉角色的一部分像素，导致角色身上出现不该有的边缘光
    // 所以这里在 ditherAlpha 较强时隐去边缘光
    float ditherAlphaFadeOut = smoothstep(0.9, 1, rlmData.ditherAlpha);

    return rlmData.color * saturate(intensity * fresnel * ditherAlphaFadeOut);
}

struct RimLightData
{
    float darkenValue;
    float intensityFrontFace;
    float intensityBackFace;
};

float3 GetRimLight(RimLightData rimData, float3 rimMask, float NoL, Light light, bool isFrontFace)
{
    float attenuation = saturate(NoL * light.shadowAttenuation * light.distanceAttenuation);
    float intensity = lerp(rimData.intensityBackFace, rimData.intensityFrontFace, isFrontFace);
    return rimMask * (lerp(rimData.darkenValue, 1, attenuation) * max(0, intensity));
}

#endif