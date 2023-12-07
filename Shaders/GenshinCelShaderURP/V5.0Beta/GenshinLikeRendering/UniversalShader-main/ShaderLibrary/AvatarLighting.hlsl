#ifndef CUSTOM_AVARTAR_LIGHTING_INCLUDED
#define CUSTOM_AVARTAR_LIGHTING_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "../ShaderLibrary/AvatarGenshinInput.hlsl"

///////////////////////////////////////////////////////////////////////////////
//                      Lighting Functions                                   //
///////////////////////////////////////////////////////////////////////////////

float ApplyRimLightDistanceFadeOut(float distance)
{
    return smoothstep(0.0, 0.05, distance);
}

float GetRimLightDistanceFixMultiplier(float positionVS_Z)
{
    float distanceFix;
    if(unity_OrthoParams.w == 0)
    {
        //透视相机
        distanceFix = ApplyRimLightDistanceFadeOut(positionVS_Z);
    }
    else
    {
        //正交相机
        float distance = abs(unity_OrthoParams.z);
        distanceFix = ApplyRimLightDistanceFadeOut(distance);
    }

    return distanceFix;
}

float GetRimLightDepthDiff(float3 positionCS_XYZ, float2 normalCS_XY, float rimLightWidth, float rimLightCorrection = 0.015)
{
    //获取Fragment原本的深度值
    float2 originPositionSS = positionCS_XYZ.xy / _ScaledScreenParams.xy;
    float originDepth = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, originPositionSS).r;
    originDepth = LinearEyeDepth(originDepth, _ZBufferParams);
    //基于摄像机距离调整外扩距离，进而控制边缘光宽度
    float distanceFixMultiplier = GetRimLightDistanceFixMultiplier(positionCS_XYZ.z);
    //获取Fragment外扩后的深度值
    float2 offsetPositionSS = originPositionSS + normalCS_XY * rimLightWidth * rimLightCorrection * distanceFixMultiplier;
    float offsetDepth = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, offsetPositionSS).r;
    offsetDepth = LinearEyeDepth(offsetDepth, _ZBufferParams);
    float depthDiff = offsetDepth - originDepth;
    return depthDiff;
}

#endif