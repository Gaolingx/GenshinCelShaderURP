#ifndef CUSTOM_AVATAR_GENSHIN_PASS_INCLUDED
#define CUSTOM_AVATAR_GENSHIN_PASS_INCLUDED

#include "../ShaderLibrary/AvatarGenshinInput.hlsl"
#include "../ShaderLibrary/AvatarSpecularHelper.hlsl"
#include "../ShaderLibrary/AvatarShaderUtils.hlsl"

struct Attributes
{
    float4 positionOS  : POSITION;
    float3 normalOS    : NORMAL;
    float4 tangentOS   : TANGENT;
    float4 vertexColor : COLOR;
    float2 uv1         : TEXCOORD0;
    float2 uv2         : TEXCOORD1;
};

struct Varyings
{
    float4 positionCS  : SV_POSITION;
    float3 positionWS  : TEXCOORD0;
    float3 normalWS    : TEXCOORD1;
    float4 uv          : TEXCOORD2;
    float3 bitangentWS : TEXCOORD3;
    float3 tangentWS   : TEXCOORD4;
    float3 SH          : TEXCOORD5;
    real   fogFactor   : TEXCOORD6;
    float4 vertexColor : COLOR;
};

Varyings GenshinStyleVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    VertexPositionInputs vertexPositionInputs = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs vertexNormalInputs = GetVertexNormalInputs(input.normalOS.xyz, input.tangentOS);

    // 世界空间
    output.positionWS = vertexPositionInputs.positionWS;
    output.positionCS = vertexPositionInputs.positionCS;
    output.tangentWS = vertexNormalInputs.tangentWS;
    output.bitangentWS = vertexNormalInputs.bitangentWS;
    output.normalWS = vertexNormalInputs.normalWS;
    output.uv = CombineAndTransformDualFaceUV(input.uv1, input.uv2, 1);
    output.vertexColor = input.vertexColor;

    // 间接光 with 球谐函数
    output.SH = SampleSH(lerp(vertexNormalInputs.normalWS, float3(0, 0, 0), _IndirectLightFlattenNormal));

    output.fogFactor = ComputeFogFactor(vertexPositionInputs.positionCS.z);

    return output;
}

half4 GenshinStyleFragment(Varyings input, FRONT_FACE_TYPE isFrontFace : FRONT_FACE_SEMANTIC) : SV_Target
{
    SetupDualFaceRendering(input.normalWS, input.uv, isFrontFace);

    half4 mainTexCol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy);
    //给背面填充颜色，对眼睛，丝袜很有用
    mainTexCol.rgb *= IS_FRONT_VFACE(isFrontFace, _FrontFaceTintColor.rgb, _BackFaceTintColor.rgb);

    half4 ilmTexCol = SAMPLE_TEXTURE2D(_ilmTex, sampler_ilmTex, input.uv.xy);

    //阴影坐标
    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    Light mainLight = GetCharacterMainLightStruct(shadowCoord, input.positionWS);
    //获取主光源颜色
    float4 LightColor = float4(mainLight.color.rgb, 1);
    //获取灯光阴影
    #if _MAINLIGHT_SHADOWATTENUATION_ON
        float shadowAttenuation = mainLight.shadowAttenuation;
    #else
        float shadowAttenuation = 1;
    #endif
    //获取主光源方向
    float3 lightDirectionWS = normalize(mainLight.direction);
    //间接光
    float3 indirectLightColor = CalculateGI(mainTexCol.rgb, ilmTexCol.g, input.SH.rgb, _IndirectLightIntensity, _IndirectLightUsage);
    //视线方向
    float3 viewDirectionWS = normalize(GetWorldSpaceViewDir(input.positionWS));
    // material index
    float material_id = materialID(ilmTexCol.w);

    //获取世界空间法线，如果要采样NormalMap，要使用TBN矩阵变换
    #if _NORMAL_MAP_ON
        float3x3 tangentToWorld = float3x3(input.tangentWS, input.bitangentWS, input.normalWS);
        float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv.xy));
        float3 normalFactor = float3(_BumpFactor, _BumpFactor, 1);
        float3 normal = normalize(normalTS * normalFactor);
        float3 normalWS = TransformTangentToWorld(normal, tangentToWorld, true);
        input.normalWS = normalWS;
    #else
        float3 normalWS = normalize(input.normalWS);
    #endif

    float NoV = dot(normalize(normalWS), normalize(GetWorldSpaceViewDir(input.positionWS)));

    half aoFactor = ilmTexCol.g * input.vertexColor.r;
    float shadow = GetShadow(normalWS, lightDirectionWS, aoFactor, shadowAttenuation);

    float emissionFactor = 1;
    //判断emission是否开启
    #if _EMISSION_ON
        #if defined(_MAINTEXALPHAUSE_EMISSION)
            emissionFactor = _EmissionScaler * mainTexCol.a;
        #elif defined(_MAINTEXALPHAUSE_FLICKER)
            emissionFactor = _EmissionScaler * mainTexCol.a * (0.5 * sin(_Time.y) + 0.5);
        #elif defined(_MAINTEXALPHAUSE_ALPHATEST)
            DoClipTestToTargetAlphaValue(mainTexCol.a, _MainTexCutOff);
            emissionFactor = 0;
        #else
            emissionFactor = 0;
        #endif
    #else
        emissionFactor = 0;
    #endif

//区分面部和身体的渲染
#if defined(_RENDERTYPE_BODY)

    //Diffuse
    half3 diffuseColor = 0;
    half3 rampTexCol = GetShadowRampColor(shadow, ilmTexCol);
    half3 brightAreaColor = rampTexCol * _LightAreaColorTint.rgb;
    //以上获取的Shadow Color颜色对固有阴影的颜色处理不够深，所以通过ShadowColor进一步调色
    half3 darkShadowColor = rampTexCol * lerp(_DarkShadowColor.rgb, _CoolDarkShadowColor.rgb, _UseCoolShadowColorOrTex);
    half3 ShadowColorTint = lerp(darkShadowColor.rgb, brightAreaColor, _BrightAreaShadowFac);

    half3 specular = (float3)0.0f;
    #if _SPECULAR_ON
        float3 half_vector = normalize(viewDirectionWS + mainLight.direction);
        float ndoth = dot(normalWS, half_vector);
        // SPECULAR :
        if(_SpecularHighlights) specular_color(ndoth, ShadowColorTint, ilmTexCol.x, ilmTexCol.z, material_id, specular);
        if(ilmTexCol.x > 0.90f) specular = 0.0f; // making sure the specular doesnt bleed into the metal area
        // METALIC :
        if(_MetalMaterial) metalics(ShadowColorTint, normalWS, ndoth, ilmTexCol.x, mainTexCol.xyz);
    #endif

    diffuseColor = ShadowColorTint * mainTexCol.rgb;

    //边缘光部分
    half3 rimLightColor = 0;
    #if _RIM_LIGHTING_ON
        rimLightColor = GetRimLight(input.positionCS, normalWS, LightColor.rgb, material_id);
    #endif

    half3 emissionColor = lerp(_EmissionTintColor.rgb, mainTexCol.rgb, _EmissionMixBaseColorFac) * emissionFactor;

    //最终的合成
    float3 FinalDiffuse = 0;
    FinalDiffuse += indirectLightColor;
    FinalDiffuse += diffuseColor;
    FinalDiffuse += specular;
    FinalDiffuse += rimLightColor;
    FinalDiffuse += emissionColor;

    float alpha = _Alpha;

    float4 FinalColor = float4(FinalDiffuse, alpha);
    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaClip);

    // Mix Fog
    real fogFactor = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);
    FinalColor.rgb = MixFog(FinalColor.rgb, fogFactor);

    return FinalColor;

#elif defined(_RENDERTYPE_FACE)

    // 游戏模型的头骨骼是旋转过的
    float3 headDirWSUp = normalize(-UNITY_MATRIX_M._m00_m10_m20);
    float3 headDirWSRight = normalize(-UNITY_MATRIX_M._m02_m12_m22);
    float3 headDirWSForward = normalize(UNITY_MATRIX_M._m01_m11_m21);

    float3 lightDirProj = normalize(lightDirectionWS - dot(lightDirectionWS, headDirWSUp) * headDirWSUp); // 做一次投影
    //光照在左脸的时候。左脸的uv采样左脸，右脸的uv采样右脸，而光照在右脸的时候，左脸的uv采样右脸，右脸的uv采样左脸，因为SDF贴图明暗变化在右脸
    bool isRight = dot(lightDirProj, headDirWSRight) > 0;
    //相当于float sdfUVx=isRight?1-input.uv.x:input.uv.x;
    //即打在右脸的时候，反转uv的u坐标
    float sdfUVx = lerp(input.uv.x, 1 - input.uv.x, isRight);
    float2 sdfUV = float2(sdfUVx, input.uv.y);
    //使用uv采样面部贴图的a通道
    float sdfValue = 0;
    #if defined(_USEFACELIGHTMAPCHANNEL_R)
        sdfValue = SAMPLE_TEXTURE2D(_FaceShadowMap, sampler_FaceShadowMap, sdfUV).r;
    #else
        sdfValue = SAMPLE_TEXTURE2D(_FaceShadowMap, sampler_FaceShadowMap, sdfUV).a;
    #endif
    sdfValue += _FaceShadowOffset;
    //dot(lightDir,headForward)的范围是[1,-1]映射到[0,1]
    float FoL01 = (dot(headDirWSForward, lightDirProj) * 0.5 + 0.5);
    //采样结果大于点乘结果，不在阴影，小于则处于阴影
    float sdfShadow = smoothstep(FoL01 - _FaceShadowTransitionSoftness, FoL01 + _FaceShadowTransitionSoftness, 1 - sdfValue);
    float brightAreaMask = (1 - sdfShadow) * shadowAttenuation;

    half3 rampTexCol = GetShadowRampColor(shadow, ilmTexCol);
    //half3 rampTexCol = mainTexCol.rgb;

    half3 diffuseColor = 0;
    half3 brightAreaColor = rampTexCol * _LightAreaColorTint.rgb;
    half3 darkShadowColor = rampTexCol * lerp(_DarkShadowColor.rgb, _CoolDarkShadowColor.rgb, _UseCoolShadowColorOrTex);
    half3 ShadowColorTint = lerp(darkShadowColor, brightAreaColor, brightAreaMask);

    diffuseColor = ShadowColorTint * mainTexCol.rgb;
    //遮罩贴图的rg通道区分受光照影响的区域和不受影响的区域
    half3 faceDiffuseColor = lerp(mainTexCol.rgb, diffuseColor, ilmTexCol.r);

    //边缘光部分
    half3 rimLightColor = 0;
    #if _RIM_LIGHTING_ON
        rimLightColor = GetRimLight(input.positionCS, normalWS, LightColor.rgb, material_id);
    #endif

    half3 emissionColor = lerp(_EmissionTintColor.rgb, mainTexCol.rgb, _EmissionMixBaseColorFac) * emissionFactor;

    float3 FinalDiffuse = 0;
    FinalDiffuse += indirectLightColor;
    FinalDiffuse += faceDiffuseColor;
    FinalDiffuse += rimLightColor;
    FinalDiffuse += emissionColor;

    float alpha = _Alpha;

    float4 FinalColor = float4(FinalDiffuse, alpha);
    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaClip);

    // Mix Fog
    real fogFactor = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);
    FinalColor.rgb = MixFog(FinalColor.rgb, fogFactor);

    return FinalColor;

#endif

    return float4(1.0, 1.0, 1.0, 1.0);
}

#endif
