#ifndef CUSTOM_AVATAR_GENSHIN_PASS_INCLUDED
#define CUSTOM_AVATAR_GENSHIN_PASS_INCLUDED

#include "../ShaderLibrary/AvatarGenshinInput.hlsl"
#include "../ShaderLibrary/AvatarLighting.hlsl"

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
    float3 positionWS : VAR_POSITION_WS;
    float3 normalWS : VAR_NORMAL_WS;
    float2 uv : VAR_BASE_UV;
    float4 positionWSAndFogFactor : TEXCOORD1;
    float4 vertexColor : COLOR;
};

Varyings GenshinStyleVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    VertexPositionInputs vertexPositionInputs = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs vertexNormalInputs = GetVertexNormalInputs(input.normalOS.xyz, input.tangentOS);
    // 世界空间
    output.positionWSAndFogFactor = float4(vertexPositionInputs.positionWS, ComputeFogFactor(vertexPositionInputs.positionCS.z));
    output.positionCS = vertexPositionInputs.positionCS;
    output.positionWS = vertexPositionInputs.positionWS;
    output.normalWS = vertexNormalInputs.normalWS;
    output.uv = input.uv;
    output.vertexColor = input.vertexColor;
    return output;
}

half4 GenshinStyleFragment(Varyings input) : SV_Target
{
    half4 mainTexCol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) * _MainTexColoring;
    
    Light mainLight = GetMainLight();
    //获取主光源颜色
    float4 LightColor = float4(mainLight.color.rgb, 1);
    float3 mainLightDirection = normalize(mainLight.direction);
    //获取世界空间法线，如果要采样NormalMap，要使用TBN矩阵变换
    float3 normalWS = normalize(input.normalWS);

//区分面部和身体的渲染    
#if defined(_RENDERTYPE_BODY)
        float emissionFactor = 1.0;
    #if defined(_MAINTEXALPHAUSE_EMISSION)
        emissionFactor = _EmissionScaler * mainTexCol.a;
    #elif defined(_MAINTEXALPHAUSE_FLICKER)
        emissionFactor = _EmissionScaler * mainTexCol.a * (0.5 * sin(_Time.y) + 0.5);
    #elif defined(_MAINTEXALPHAUSE_ALPHATEST)
        clip(mainTexCol.a - _MainTexCutOff);
        emissionFactor = 0;
    #else
        emissionFactor = 0;
    #endif

    half4 ilmTexCol = SAMPLE_TEXTURE2D(_ilmTex, sampler_ilmTex, input.uv);

    float halfLambert = 0.5 * dot(mainLightDirection, input.normalWS) + 0.5;
    float AOMask = step(0.02, ilmTexCol.g);
    float brightAreaMask = AOMask * halfLambert;

    half3 diffuseColor = 0;
    //Diffuse
    float2 rampUV;
    //对原神Ramp X轴处理：
    //以LightArea作为阈值，通过AO和halfLambert来控制Ramp明亮交界的位置
    rampUV.x = min(0.99, smoothstep(0.001, 1.0 - _LightArea, brightAreaMask));
    //对原神Ramp Y轴处理的全新理解：
    //1.首先，原神的Ramp采样是基于左上角为(0，0)的，原因猜测是网上拿到的Ramp资源是基于PC截帧获取的，DX平台默认的贴图是以左上角为UV空间的原点；
    //而Unity中默认的UV空间原点是左下角，所以需要在Y轴上做翻转
    //2.基于ilm贴图的A通道和Ramp图的适配性，以及结合游戏内的表现，我猜测存在一个_RampCount来对ilm贴图A通道读取Ramp行序号的信息进行缩放
    rampUV.y = 1.0 - saturate(ilmTexCol.a) / _RampCount * 0.5 + _UseCoolShadowColorOrTex * 0.5 - 0.001;
    half3 rampTexCol = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, rampUV).rgb;    
    
    //以上获取的Shadow Color颜色对固有阴影的颜色处理不够深，所以通过ShadowColor进一步调色
    half3 darkShadowColor = lerp(_DarkShadowColor.rgb, _CoolDarkShadowColor.rgb, _UseCoolShadowColorOrTex) * rampTexCol;
    #if !defined(_USERAMPLIGHTAREACOLOR_ON)
        //区分使用Ramp的最右侧作为亮部颜色和使用自定义亮部颜色两种情况，使用自定义时可以获取额外的亮部二分ramp条
        //进一步处理brightAreaMask，来获取亮部区域（非Ramp区）的遮罩，参数_ShadowRampWidth影响最接近亮部的ramp条的宽度
        brightAreaMask = step(1.0 - _LightArea, brightAreaMask + (1.0 - _ShadowRampWidth) * 0.1);
        rampTexCol = lerp(rampTexCol, _LightAreaColorTint, brightAreaMask);
    #endif
    half3 ShadowColorTint = lerp(darkShadowColor.rgb, rampTexCol, AOMask);
    ShadowColorTint = lerp(_NeckColor.rgb, ShadowColorTint, input.vertexColor.b);
    diffuseColor = ShadowColorTint * mainTexCol.rgb;

    half3 FinalSpecCol = 0;
    #if _SPECULAR_ON
        //Specular
        float3 viewDirectionWS = normalize(_WorldSpaceCameraPos.xyz - input.positionWS.xyz);
        float3 halfDirectionWS = normalize(viewDirectionWS + mainLightDirection);
        float hdotl = max(dot(halfDirectionWS, input.normalWS.xyz), 0.0);
        //非金属高光
        float nonMetalSpecular = step(1.0 - 0.5 * _NonMetalSpecArea, pow(hdotl, _Shininess)) * ilmTexCol.r;
        //金属高光
        //ilmTexture中，r通道控制Blinn-Phong高光的系数，b通道控制Metal Specular的范围
        float2 normalCS = TransformWorldToHClipDir(input.normalWS.xyz).xy * 0.5 + float2(0.5, 0.5);
        float metalTexCol = saturate(SAMPLE_TEXTURE2D(_MetalTex, sampler_MetalTex, normalCS)).r * _MTMapBrightness;
        float metalBlinnPhongSpecular = pow(hdotl, _MTShininess) * ilmTexCol.r;
        float metalSpecular = ilmTexCol.b * metalBlinnPhongSpecular * metalTexCol;
        half3 specularColor = (metalSpecular * _MTSpecularScale + nonMetalSpecular) * diffuseColor;
        
        FinalSpecCol = specularColor * _SpecMulti;
    #else
        FinalSpecCol = 0;
    #endif
    
    //边缘光部分
    float3 rimLightColor;
    #if _RIM_LIGHTING_ON
        //获取当前片元的深度
        float linearEyeDepth = LinearEyeDepth(input.positionCS.z, _ZBufferParams);
        //根据视线空间的法线采样左边或者右边的深度图
        float3 normalVS = mul((float3x3)UNITY_MATRIX_V, normalWS);
        //根据视线空间的法线采样左边或者右边的深度图，根据深度缩放，实现近大远小的效果
        float2 uvOffset = float2(sign(normalVS.x), 0) * _RimLightWidth / (1 + linearEyeDepth) / 100;
        int2 loadTexPos = input.positionCS.xy + uvOffset * _ScaledScreenParams.xy;
        //限制左右，不采样到边界
        loadTexPos = min(max(loadTexPos, 0), _ScaledScreenParams.xy - 1);
        //偏移后的片元深度
        float offsetSceneDepth = LoadSceneDepth(loadTexPos);
        //转换为LinearEyeDepth
        float offsetLinearEyeDepth = LinearEyeDepth(offsetSceneDepth, _ZBufferParams);
        //深度差超过阈值，表示是边界
        float rimLight = saturate(offsetLinearEyeDepth - (linearEyeDepth + _RimLightThreshold)) / _RimLightFadeout;
        rimLightColor = rimLight * LightColor.rgb;
        rimLightColor *= _RimLightTintColor;
        rimLightColor *= _RimLightBrightness;
    #else
        rimLightColor = 0;
    #endif

    //最终的合成
    float3 FinalDiffuse = 0;
    FinalDiffuse += diffuseColor;
    FinalDiffuse += FinalSpecCol;
    FinalDiffuse += rimLightColor * lerp(1, FinalDiffuse, _RimLightMixAlbedo);

    //判断emission是否开启
    #if _EMISSION_ON != 1
        emissionFactor = 0;
    #endif
    FinalDiffuse *= 1 + emissionFactor;

    float alpha = _Alpha;

    float4 FinalColor = float4(FinalDiffuse, alpha);
    clip(FinalColor.a - _AlphaClip);
    FinalColor.rgb = MixFog(FinalColor.rgb, input.positionWSAndFogFactor.w);

    return FinalColor;
    
#else

    //获取向量信息
    //unity_objectToWorld可以获取世界空间的方向信息，构成如下：
    // unity_ObjectToWorld = ( right, back, left)
    float3 rightDirectionWS = unity_ObjectToWorld._11_21_31;
    float3 backDirectionWS = unity_ObjectToWorld._13_23_33;
    float rdotl = dot(normalize(mainLightDirection.xz), normalize(rightDirectionWS.xz));
    float fdotl = dot(normalize(mainLightDirection.xz), normalize(backDirectionWS.xz));

    //SDF面部阴影
    //将ilmTexture看作光源的数值，那么原UV采样得到的图片是光从角色左侧打过来的效果，且越往中间，所需要的亮度越低。lightThreshold作为点亮区域所需的光源强度
    float2 ilmTextureUV = rdotl < 0.0 ? input.uv : float2(1.0 - input.uv.x, input.uv.y);
    float lightThreshold = 0.5 * (1.0 - fdotl);
    lightThreshold += _FaceShadowOffset;
    
    half4 ilmTexCol = SAMPLE_TEXTURE2D(_ilmTex, sampler_ilmTex, ilmTextureUV);
    half4 metalTexCol = SAMPLE_TEXTURE2D(_MetalTex, sampler_MetalTex, input.uv);

    #if defined(_USEFACELIGHTMAPCHANNEL_R)
        float lightStrength = ilmTexCol.r;
    #else
        float lightStrength = ilmTexCol.a;
    #endif
    
    float brightAreaMask = step(lightThreshold, lightStrength);

    half3 brightAreaColor = mainTexCol.rgb * _LightAreaColorTint.rgb;
    half3 shadowAreaColor = mainTexCol.rgb * lerp(_DarkShadowColor.rgb, _CoolDarkShadowColor.rgb, _UseCoolShadowColorOrTex);

    half3 lightingColor = lerp(shadowAreaColor, brightAreaColor, brightAreaMask) * _MainTexColoring.rgb;

    //边缘光部分
    float3 rimLightColor;
    #if _RIM_LIGHTING_ON
        //获取当前片元的深度
        float linearEyeDepth = LinearEyeDepth(input.positionCS.z, _ZBufferParams);
        //根据视线空间的法线采样左边或者右边的深度图
        float3 normalVS = mul((float3x3)UNITY_MATRIX_V, normalWS);
        //根据视线空间的法线采样左边或者右边的深度图，根据深度缩放，实现近大远小的效果
        float2 uvOffset = float2(sign(normalVS.x), 0) * _RimLightWidth / (1 + linearEyeDepth) / 100;
        int2 loadTexPos = input.positionCS.xy + uvOffset * _ScaledScreenParams.xy;
        //限制左右，不采样到边界
        loadTexPos = min(max(loadTexPos, 0), _ScaledScreenParams.xy - 1);
        //偏移后的片元深度
        float offsetSceneDepth = LoadSceneDepth(loadTexPos);
        //转换为LinearEyeDepth
        float offsetLinearEyeDepth = LinearEyeDepth(offsetSceneDepth, _ZBufferParams);
        //深度差超过阈值，表示是边界
        float rimLight = saturate(offsetLinearEyeDepth - (linearEyeDepth + _RimLightThreshold)) / _RimLightFadeout;
        rimLightColor = rimLight * LightColor.rgb;
        rimLightColor *= _RimLightTintColor;
        rimLightColor *= _RimLightBrightness;
    #else
        rimLightColor = 0;
    #endif

    float3 FinalDiffuse = 0;
    //遮罩贴图的rg通道区分受光照影响的区域和不受影响的区域
    FinalDiffuse = lerp(mainTexCol.rgb, lightingColor, metalTexCol.r);
    FinalDiffuse += rimLightColor * lerp(1, FinalDiffuse, _RimLightMixAlbedo);

    float alpha = _Alpha;

    float4 FinalColor = float4(FinalDiffuse, alpha);
    clip(FinalColor.a - _AlphaClip);
    FinalColor.rgb = MixFog(FinalColor.rgb, input.positionWSAndFogFactor.w);

    return FinalColor;

#endif

    return float4(FinalDiffuse, 1.0);
}

#endif
