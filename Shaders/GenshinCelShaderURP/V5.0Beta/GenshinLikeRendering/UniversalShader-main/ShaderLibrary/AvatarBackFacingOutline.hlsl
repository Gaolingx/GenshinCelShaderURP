#ifndef CUSTOM_AVATAR_BACK_FACING_OUTLINE_INCLUDED
#define CUSTOM_AVATAR_BACK_FACING_OUTLINE_INCLUDED

//使用宏 _USESMOOTHNORMAL_NULL、_USESMOOTHNORMAL_VERTEXCOLOR、_USESMOOTHNORMAL_NORMALTEXTURE
//【1】_USESMOOTHNORMAL_NULL:不使用额外的平滑法线，直接使用模型原本的法线信息
//【2】_USESMOOTHNORMAL_VERTEXCOLOR:使用顶点色RG通道存储平滑法线信息
//【3】_USESMOOTHNORMAL_NORMALTEXTURE:使用贴图RG通道存储切线空间平滑法线信息

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core//ShaderLibrary/SpaceTransforms.hlsl"

struct OutlineData
{
    float outlineWidth;
    float3 positionOS;
    float3 normalOS;
    float positionVS_Z;
    //如果使用贴图或顶点色中的平滑法线信息
    #if defined(_USESMOOTHNORMAL_VERTEXCOLOR) || defined(_USESMOOTHNORMAL_NORMALTEXTURE)
    float4 tangentOS;
    float3 smoothNormalTS;
    #endif
};

#if defined(_USESMOOTHNORMAL_VERTEXCOLOR) || defined(_USESMOOTHNORMAL_NORMALTEXTURE)
OutlineData GetOutlineData(float outlineWidth, float3 positionOS, float3 normalOS, float positionVS_Z, float4 tangentOS, float3 smoothNormalTS)
{
    OutlineData data;
    data.positionOS = positionOS;
    data.outlineWidth = outlineWidth;
    data.normalOS = normalOS;
    data.tangentOS = tangentOS;
    data.positionVS_Z = positionVS_Z;
    data.smoothNormalTS = smoothNormalTS;
    return data;
}
#else
OutlineData GetOutlineData(float outlineWidth, float3 positionOS, float3 normalOS, float positionVS_Z)
{
    OutlineData data;
    data.positionOS = positionOS;
    data.outlineWidth = outlineWidth;
    data.normalOS = normalOS;
    data.positionVS_Z = positionVS_Z;
    return data;
}
#endif


float GetCameraFOV()
{
    //Shader中获取相机FOV
    //https://answers.unity.com/questions/770838/how-can-i-extract-the-fov-information-from-the-pro.html
    float t = unity_CameraProjection._m11;
    float Rad2Deg = 180 / 3.1415;
    float fov = atan(1.0f / t) * 2.0 * Rad2Deg;
    return fov;
}

float ApplyOutlineDistanceFadeOut(float distanceVS)
{
    //深度在ViewSpace中0-10范围内进行描边粗细的缩放
    #if UNITY_REVERSED_Z
        //DX平台
        return max(0.0, (50.0 - distanceVS) * 0.1);
    #else
        //OpenGL平台（还未做测试）
        return min(10.0, distanceVS) * 0.1;
    #endif
}
//距离控制描边粗细，改编自Nilon老师的函数
float GetOutlineCameraFOVAndDistanceFixMultiplier(float positionVS_Z)
{
    float distanceFix;
    if(unity_OrthoParams.w == 0)
    {
        //透视相机
        float distance = abs(positionVS_Z);
        distanceFix = ApplyOutlineDistanceFadeOut(distance);
        distanceFix *= GetCameraFOV();
    }
    else
    {
        //正交相机
        float distance = abs(unity_OrthoParams.z);
        distanceFix = ApplyOutlineDistanceFadeOut(distance) * 50; //参考Nilon老师的数值
    }

    return distanceFix;
}

float2 GetOutlinedOffsetHClip(OutlineData data)
{
    //描边法线处理
#if defined(_USESMOOTHNORMAL_VERTEXCOLOR) || defined(_USESMOOTHNORMAL_NORMALTEXTURE)
    VertexNormalInputs vertexNormalInputs = GetVertexNormalInputs(data.normalOS, data.tangentOS);
    float3x3 tangentToWorld = CreateTangentToWorld(vertexNormalInputs.normalWS, vertexNormalInputs.tangentWS, data.tangentOS.w);
    float3 outlineNormalWS = normalize(TransformTangentToWorld(data.smoothNormalTS, tangentToWorld));
    // float3x3 TBN_T = GetTBNMatrix(data.normalOS, data.tangentOS);
    // float3 outlineNormalWS = TransformTangentToWorld(data.smoothNormalTS, TBN_T);
#else
    float3 outlineNormalWS = TransformObjectToWorldNormal(data.normalOS, true);
#endif
    
    //获得裁剪空间下模型外扩的法线方向
    float3 outlineNormalCS = TransformWorldToHClipDir(outlineNormalWS, true);
    
    //CS下偏移模型
    float2 offset = data.outlineWidth * outlineNormalCS.xy;//基础的沿法线偏移

    //调整offset
    float4 screenParam = GetScaledScreenParams();
    float HdW = screenParam.y / screenParam.x;
    offset *= float2(HdW, 1.0);//offset偏移值适应屏幕纵横比
    float distanceVS = abs(data.positionVS_Z);
    offset *= GetOutlineCameraFOVAndDistanceFixMultiplier(distanceVS);//offset偏移值适应相机距离和FOV
    
    return offset;
}

#endif