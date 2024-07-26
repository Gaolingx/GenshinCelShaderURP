#ifndef CUSTOM_AVATAR_GENSHIN_PASS_INCLUDED
#define CUSTOM_AVATAR_GENSHIN_PASS_INCLUDED

#include "../ShaderLibrary/AvatarGenshinInput.hlsl"
#include "../ShaderLibrary/AvatarRimLightHelper.hlsl"
#include "../ShaderLibrary/AvatarSpecularHelper.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float4 vertexColor : COLOR;
    float2 uv1 : TEXCOORD0;
    float2 uv2 : TEXCOORD1;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : VAR_POSITION_WS;
    float3 normalWS : VAR_NORMAL_WS;
    float4 uv : VAR_BASE_UV;
    float4 positionWSAndFogFactor : TEXCOORD1;
    float3 bitangentWS : TEXCOORD2;
    float3 tangentWS : TEXCOORD3;
    float3 SH : TEXCOORD4;
    float4 ss_pos : TEXCOORD5;
    float4 vertexColor : COLOR;
};

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

float3 GetShadowRampColor(float4 lightmap, float NdotL, float shadowAttenuation)
{
    lightmap.g = lerp(1, smoothstep(0.2, 0.3, lightmap.g), _RampAOLerp);  //lightmap.g
    float halfLambert = smoothstep(0.0, _GreyFac, NdotL + _DarkFac) * lightmap.g * shadowAttenuation;  //半Lambert
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

Varyings GenshinStyleVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    VertexPositionInputs vertexPositionInputs = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs vertexNormalInputs = GetVertexNormalInputs(input.normalOS.xyz, input.tangentOS);
    
    // 世界空间
    output.positionWSAndFogFactor = float4(vertexPositionInputs.positionWS, ComputeFogFactor(vertexPositionInputs.positionCS.z));
    output.positionCS = vertexPositionInputs.positionCS;
    output.positionWS = vertexPositionInputs.positionWS;
    output.tangentWS = vertexNormalInputs.tangentWS;
    output.bitangentWS = vertexNormalInputs.bitangentWS;
    output.normalWS = vertexNormalInputs.normalWS;
    output.uv = CombineAndTransformDualFaceUV(input.uv1, input.uv2, 1);
    output.vertexColor = input.vertexColor;

    // 间接光 with 球谐函数
    output.SH = SampleSH(lerp(vertexNormalInputs.normalWS, float3(0, 0, 0), _IndirectLightFlattenNormal));

    output.ss_pos = ComputeScreenPos(output.positionCS);

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
    float NoL = dot(normalize(normalWS), normalize(mainLight.direction));

    float emissionFactor = 1.0;
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

//区分面部和身体的渲染    
#if defined(_RENDERTYPE_BODY)

    float remappedNoL = NoL + input.vertexColor.g;

    //Diffuse
    half3 diffuseColor = 0;
    half3 rampTexCol = GetShadowRampColor(ilmTexCol, remappedNoL, shadowAttenuation);
    half3 brightAreaColor = rampTexCol * _LightAreaColorTint.rgb;
    //以上获取的Shadow Color颜色对固有阴影的颜色处理不够深，所以通过ShadowColor进一步调色
    half3 darkShadowColor = rampTexCol * lerp(_DarkShadowColor.rgb, _CoolDarkShadowColor.rgb, _UseCoolShadowColorOrTex);

    half3 ShadowColorTint = lerp(darkShadowColor.rgb, brightAreaColor, _BrightAreaShadowFac);
    diffuseColor = ShadowColorTint * mainTexCol.rgb;

    float material_id = materialID(ilmTexCol.w);
    half3 FinalSpecCol = 0;
    #if _SPECULAR_ON
        float3 half_vector = normalize(viewDirectionWS + mainLight.direction);
        float ndoth = dot(normalWS, half_vector);
        // SPECULAR : 
        float3 specular = (float3)0.0f;
        if(_SpecularHighlights) specular_color(ndoth, ShadowColorTint, ilmTexCol.x, ilmTexCol.z, material_id, specular);
        if(ilmTexCol.x > 0.90f) specular = 0.0f; // making sure the specular doesnt bleed into the metal area
        // METALIC :
        float frontFace = 1;
        if (IS_FRONT_VFACE(isFrontFace, 1, 0))
        {
            frontFace = 0;
        }
        else
        {
            frontFace = 1;
        }
        if(_MetalMaterial) metalics(ShadowColorTint, normalWS, ndoth, ilmTexCol.x, frontFace, diffuseColor.xyz);

        FinalSpecCol = specular;
    #else
        FinalSpecCol = 0;
    #endif
    
    //边缘光部分
    half3 rimLightColor;
    #if _RIM_LIGHTING_ON
        rimLightColor = GetRimLight(input.ss_pos, normalWS, input.positionCS, LightColor.rgb, material_id, diffuseColor, viewDirectionWS);
    #else
        rimLightColor = 0;
    #endif

    //判断emission是否开启
    #if _EMISSION_ON != 1
        emissionFactor = 0;
    #endif
    half3 emissionColor = lerp(_EmissionTintColor.rgb, mainTexCol.rgb, _EmissionMixBaseColorFac) * emissionFactor;

    //最终的合成
    float3 FinalDiffuse = 0;
    FinalDiffuse += indirectLightColor;
    FinalDiffuse += diffuseColor;
    FinalDiffuse += FinalSpecCol;
    FinalDiffuse += ApplySpecularOpacity(FinalDiffuse, FinalSpecCol, ilmTexCol.a);
    FinalDiffuse += rimLightColor;
    FinalDiffuse += emissionColor;

    float alpha = _Alpha;

    float4 FinalColor = float4(FinalDiffuse, alpha);
    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaClip);
    FinalColor.rgb = MixFog(FinalColor.rgb, input.positionWSAndFogFactor.w);

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

    float remappedNoL = NoL;
    half3 rampTexCol = GetShadowRampColor(ilmTexCol, remappedNoL, 1);
    //half3 rampTexCol = mainTexCol.rgb;

    half3 diffuseColor = 0;
    half3 brightAreaColor = rampTexCol.rgb * _LightAreaColorTint.rgb;
    half3 shadowAreaColor = rampTexCol.rgb * lerp(_DarkShadowColor.rgb, _CoolDarkShadowColor.rgb, _UseCoolShadowColorOrTex);

    half3 ShadowColorTint = lerp(shadowAreaColor, brightAreaColor, brightAreaMask);
    diffuseColor = ShadowColorTint * mainTexCol.rgb;
    //遮罩贴图的rg通道区分受光照影响的区域和不受影响的区域
    half3 faceDiffuseColor = lerp(mainTexCol.rgb, diffuseColor, ilmTexCol.r);

    float material_id = materialID(ilmTexCol.w);

    //边缘光部分
    half3 rimLightColor;
    #if _RIM_LIGHTING_ON
        rimLightColor = GetRimLight(input.ss_pos, normalWS, input.positionCS, LightColor.rgb, material_id, diffuseColor, viewDirectionWS);
    #else
        rimLightColor = 0;
    #endif

    //判断emission是否开启
    #if _EMISSION_ON != 1
        emissionFactor = 0;
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
    FinalColor.rgb = MixFog(FinalColor.rgb, input.positionWSAndFogFactor.w);

    return FinalColor;

#endif

    return float4(1.0, 1.0, 1.0, 1.0);
}

#endif
