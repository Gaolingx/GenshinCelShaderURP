#ifndef CUSTOM_AVATAR_GENSHIN_OUTLINE_PASS_INCLUDED
#define CUSTOM_AVATAR_GENSHIN_OUTLINE_PASS_INCLUDED

#include "../ShaderLibrary/AvatarGenshinInput.hlsl"
#include "../ShaderLibrary/AvatarBackFacingOutline.hlsl"
#include "../ShaderLibrary/NiloZOffset.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float4 vertexColor : COLOR;
    float2 uv : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float fogFactor : TEXCOORD1;
};

void DoClipTestToTargetAlphaValue(float alpha, float alphaTestThreshold) 
{
    clip(alpha - alphaTestThreshold);
}

Varyings BackFaceOutlineVertex(Attributes input)
{
    Varyings output;
    VertexPositionInputs vertexPositionInputs = GetVertexPositionInputs(input.positionOS.xyz);
    
    float outlineWidth = _OutlineWidthAdjustScale * 0.0002;//乘上0.0001使得Inspector面板属性控制器能在0-1之间调整
    
    //获取不同类型的平滑法线信息，进行模型外扩：
    //1.Null:不使用额外的平滑法线，直接使用模型原本的法线信息
    //2.VertexColor:使用顶点色RG通道存储平滑法线信息
    //3.NormalTexture:使用贴图RG通道存储切线空间平滑法线信息
    #if defined(_USESMOOTHNORMAL_VERTEXCOLOR) || defined(_USESMOOTHNORMAL_NORMALTEXTURE)
        #if defined(_USESMOOTHNORMAL_VERTEXCOLOR)
            input.vertexColor.r = input.vertexColor.r * 2.0 - 1.0;
            input.vertexColor.g = input.vertexColor.g * 2.0 - 1.0;
            float3 smoothNormalTS = normalize(float3(input.vertexColor.r, input.vertexColor.g,
                sqrt(1 - dot(float2(input.vertexColor.r, input.vertexColor.g), float2(input.vertexColor.r, input.vertexColor.g)))
                    ));
            OutlineData outlineData = GetOutlineData(outlineWidth * step(0.25, input.vertexColor.a), input.positionOS.xyz, input.normalOS, vertexPositionInputs.positionVS.z, input.tangentOS, smoothNormalTS);
        #else
            float2 smoothNormalTexCol = SAMPLE_TEXTURE2D_LOD(_SmoothNormalTex, sampler_SmoothNormalTex, input.uv, 0);
            float3 smoothNormalTS = normalize(float3(smoothNormalTexCol.r, smoothNormalTexCol.g,
                sqrt(1 - dot(float2(smoothNormalTexCol.r, smoothNormalTexCol.g), float2(smoothNormalTexCol.r, smoothNormalTexCol.g)))
                    ));
            OutlineData outlineData = GetOutlineData(outlineWidth, input.positionOS.xyz, input.normalOS, vertexPositionInputs.positionVS.z, input.tangentOS, smoothNormalTS);
        #endif
    #else
        OutlineData outlineData = GetOutlineData(outlineWidth, input.positionOS.xyz, input.normalOS, vertexPositionInputs.positionVS.z);
    #endif

    //获取并应用HClip Space下的偏移值
    float2 outlinePositionOffsetCS = GetOutlinedOffsetHClip(outlineData);
    output.positionCS = vertexPositionInputs.positionCS;
    output.positionCS.xy += outlinePositionOffsetCS * input.vertexColor.a;

    // Apply ZOffset
    output.positionCS = NiloGetNewClipPosWithZOffset(output.positionCS, _OutlineZOffset + 0.03 * _IsFace);
    
    output.uv = input.uv;

    output.fogFactor = ComputeFogFactor(vertexPositionInputs.positionCS.z);

    return output;
}

half4 BackFaceOutlineFragment(Varyings input) : SV_Target
{
    //根据ilmTexture的五个分组区分出五个不同颜色的描边区域
    half outlineColorMask = SAMPLE_TEXTURE2D(_ilmTex, sampler_ilmTex, input.uv).a;
    half areaMask1 = step(0.003, outlineColorMask) - step(0.35, outlineColorMask);
    half areaMask2 = step(0.35, outlineColorMask) - step(0.55, outlineColorMask);
    half areaMask3 = step(0.55, outlineColorMask) - step(0.75, outlineColorMask);
    half areaMask4 = step(0.75, outlineColorMask) - step(0.95, outlineColorMask);
    half areaMask5 = step(0.95, outlineColorMask);

    #if _OUTLINE_CUSTOM_COLOR_ON
        half3 finalOutlineColor = _CustomOutlineCol.rgb;
    #else
        half3 finalOutlineColor = (1.0 - (areaMask1 + areaMask2 + areaMask3 + areaMask4 + areaMask5)) * _OutlineColor1.rgb + areaMask2 * _OutlineColor2.rgb + areaMask3 * _OutlineColor3.rgb + areaMask4 * _OutlineColor4.rgb + areaMask5 * _OutlineColor5.rgb;
    #endif
    
    float alpha = _Alpha;

    float4 FinalColor = float4(finalOutlineColor, alpha);
    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaClip);
    FinalColor.rgb = MixFog(FinalColor.rgb, input.fogFactor);

    return float4(FinalColor.rgb, 1);
}

#endif