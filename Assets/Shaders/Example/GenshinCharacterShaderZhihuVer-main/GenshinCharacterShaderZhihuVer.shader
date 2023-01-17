Shader "GenshinCharacterShaderZhihuVer"
{
    Properties
    {
        [Header(Main Texture Setting)]
        [Space(5)]
        [MainTexture]_BaseMap ("_BaseMap (Albedo)", 2D) = "black" { }
        [HDR][MainColor]_BaseColor ("_BaseColor", Color) = (1, 1, 1, 1)
        _WorldLightInfluence ("World Light Influence", range(0.0, 1.0)) = 0.1
        [Toggle(ENABLE_AUTOCOLOR)] _EnableAutoColor ("Enable AutoColor", float) = 0.0
        [Space(30)]

        [Header(Bloom)]
        [Space(5)]
        [Toggle(ENABLE_BLOOM_MASK)]_EnableBloomMask ("Enable Bloom", float) = 0.0
        [NoScaleOffset]_BloomMap ("Bloom/Emission Map", 2D) = "black" { }
        _BloomFactor ("Common Bloom Factor", range(0.0, 1.0)) = 1.0

        [Header(Emission)]
        [Toggle]_EnableEmission ("Enable Emission", Float) = 0
        _Emission ("Emission", range(0.0, 20.0)) = 1.0
        [HDR]_EmissionColor ("Emission Color", color) = (0, 0, 0, 0)
        _EmissionBloomFactor ("Emission Bloom Factor", range(0.0, 10.0)) = 1.0
        [HideInInspector]_EmissionMapChannelMask ("_EmissionMapChannelMask", Vector) = (1, 1, 1, 0)
        [Space(30)]

        [Header(Shadow Setting)]
        [Space(5)]
        _LightMap ("LightMap", 2D) = "grey" { }
        _ShadowMultColor ("Shadow Color", color) = (1.0, 1.0, 1.0, 1.0)
        _ShadowArea ("Shadow Area", range(0.0, 1.0)) = 0.5
        _ShadowSmooth ("Shadow Smooth", range(0.0, 1.0)) = 0.05
        _DarkShadowMultColor ("Dark Shadow Color", color) = (0.5, 0.5, 0.5, 1)
        _DarkShadowArea ("Dark Shadow Area", range(0.0, 1.0)) = 0.5
        _DarkShadowSmooth ("Shadow Smooth", range(0.0, 1.0)) = 0.05
        [Toggle]_FixDarkShadow ("Fix Dark Shadow", float) = 1
        [Toggle]_IgnoreLightY ("Ignore Light y", float) = 0
        _FixLightY ("Fix Light y", range(-10.0, 10.0)) = 0.0

        [Toggle(ENABLE_FACE_SHADOW_MAP)]_EnableFaceShadowMap ("Enable Face Shadow Map", float) = 0
        _FaceShadowMap ("Face Shadow Map", 2D) = "white" { }
        _FaceShadowMapPow ("Face Shadow Map Pow", range(0.001, 1.0)) = 0.2
        _FaceShadowOffset ("Face Shadow Offset", range(-1.0, 1.0)) = 0.0

        [Header(Shadow Ramp)]
        [Space(5)]
        [Toggle(ENABLE_RAMP_SHADOW)] _EnableRampShadow ("Enable Ramp Shadow", float) = 1
        _RampMap ("Shadow Ramp Texture", 2D) = "white" { }
        [Header(Ramp Area LightMapAlpha RampLine)]
        _RampArea12 ("Ramp Area 1/2", Vector) = (-50, 1, -50, 4)
        _RampArea34 ("Ramp Area 3/4", Vector) = (-50, 0, -50, 2)
        _RampArea5 ("Ramp Area 5", Vector) = (-50, 3, -50, 0)
        _RampShadowRange ("Ramp Shadow Range", range(0.0, 1.0)) = 0.8
        [Space(30)]

        [Header(Specular Setting)]
        [Space(5)]
        [Toggle]_EnableSpecular ("Enable Specular", float) = 1
        [HDR]_LightSpecColor ("Specular Color", color) = (0.8, 0.8, 0.8, 1)
        _Shininess ("Shininess", range(0.1, 20.0)) = 10.0
        _SpecMulti ("Multiple Factor", range(0.1, 1.0)) = 1
        [Space(30)]
        [Toggle(ENABLE_METAL_SPECULAR)] _EnableMetalSpecular ("Enable Metal Specular", float) = 1
        _MetalMap ("Metal Map", 2D) = "white" { }

        [Header(RimLight Setting)]
        [Space(5)]
        [Toggle]_EnableLambert ("Enable Lambert", float) = 1
        [Toggle]_EnableRim ("Enable Rim", float) = 1
        [HDR]_RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimSmooth ("Rim Smooth", Range(0.001, 1.0)) = 0.01
        _RimPow ("Rim Pow", Range(0.0, 10.0)) = 1.0
        [Space(5)]
        [Toggle]_EnableRimDS ("Enable Dark Side Rim", int) = 1
        [HDR]_DarkSideRimColor ("DarkSide Rim Color", Color) = (1, 1, 1, 1)
        _DarkSideRimSmooth ("DarkSide Rim Smooth", Range(0.001, 1.0)) = 0.01
        _DarkSideRimPow ("DarkSide Rim Pow", Range(0.0, 10.0)) = 1.0
        [HideInInspector][Toggle]_EnableRimOther ("Enable Other Rim", int) = 0
        [HideInInspector][HDR]_OtherRimColor ("Other Rim Color", Color) = (1, 1, 1, 1)
        [HideInInspector]_OtherRimSmooth ("Other Rim Smooth", Range(0.001, 1.0)) = 0.01
        [HideInInspector]_OtherRimPow ("Other Rim Pow", Range(0.001, 50.0)) = 10.0
        [Space(30)]

        [HideInInspector][Header(Shadow mapping)]
        [HideInInspector]_ReceiveShadowMappingAmount ("_ReceiveShadowMappingAmount", Range(0, 1)) = 0.75
        [HideInInspector]_ReceiveShadowMappingPosOffset ("_ReceiveShadowMappingPosOffset (increase it if is face!)", Float) = 0

        [Header(Outline Setting)]
        [Space(5)]
        _OutlineWidth ("_OutlineWidth (World Space)", Range(0, 4)) = 1
        _OutlineColor ("Outline Color", color) = (0.5, 0.5, 0.5, 1)
        [HideInInspector]_OutlineZOffset ("_OutlineZOffset (View Space) (increase it if is face!)", Range(0, 1)) = 0.0001

        [Header(Alpha)]
        [Toggle(ENABLE_ALPHA_CLIPPING)]_EnableAlphaClipping ("_EnableAlphaClipping", Float) = 0
        _Cutoff ("_Cutoff (Alpha Cutoff)", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "UniversalMaterialType" = "Lit" "Queue" = "Geometry" }

        HLSLINCLUDE

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        TEXTURE2D(_BaseMap);        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_EmissionMap);    SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_LightMap);       SAMPLER(sampler_LightMap);
        TEXTURE2D(_FaceShadowMap);  SAMPLER(sampler_FaceShadowMap);
        TEXTURE2D(_RampMap);        SAMPLER(sampler_RampMap);
        TEXTURE2D(_BloomMap);       SAMPLER(sampler_BloomMap);
        TEXTURE2D(_MetalMap);       SAMPLER(sampler_MetalMap);

        CBUFFER_START(UnityPerMaterial)

        float4 _BaseMap_ST;
        float4 _BaseColor;
        half _WorldLightInfluence;

        float4 _LightMap_ST;
        float4 _FaceShadowMap_ST;
        float _FaceShadowMapPow;
        float _FaceShadowOffset;

        float3 _ShadowMultColor;
        float _ShadowArea;
        half _ShadowSmooth;
        float _DarkShadowArea;
        float3 _DarkShadowMultColor;
        half _DarkShadowSmooth;

        half4 _RampArea12;
        half4 _RampArea34;
        half2 _RampArea5;
        float _RampShadowRange;

        float _EnableSpecular;
        float4 _LightSpecColor;
        float _Shininess;
        float _SpecMulti;
        float _FixDarkShadow;
        float _IgnoreLightY;
        float _FixLightY;

        float _EnableLambert;
        float _EnableRim;
        half4 _RimColor;
        float _RimSmooth;
        float _RimPow;
        float _EnableRimDS;
        half4 _DarkSideRimColor;
        float _DarkSideRimSmooth;
        float _DarkSideRimPow;
        float _EnableRimOther;
        half4 _OtherRimColor;
        float _OtherRimSmooth;
        float _OtherRimPow;

        float4 _BloomMap_ST;
        float _BloomFactor;
        float _EnableEmission;
        half3 _EmissionColor;
        float _Emission;
        float _EmissionBloomFactor;
        half _EmissionMulByBaseColor;
        half3 _EmissionMapChannelMask;

        half _ReceiveShadowMappingAmount;
        float _ReceiveShadowMappingPosOffset;

        float _OutlineWidth;
        half4 _OutlineColor;
        float _OutlineZOffset;

        half _Cutoff;
        CBUFFER_END

        struct Attributes
        {
            float3 positionOS: POSITION;
            half4 color: COLOR0;
            half3 normalOS: NORMAL;
            half4 tangentOS: TANGENT;
            float2 texcoord: TEXCOORD0;
        };

        struct Varyings
        {
            float4 positionCS: POSITION;
            float4 color: COLOR0;
            float4 uv: TEXCOORD0;
            float3 positionWS: TEXCOORD1;
            float3 positionVS: TEXCOORD2;
            float3 normalWS: TEXCOORD3;
            float lambert: TEXCOORD4;
            float4 shadowCoord: TEXCOORD5;
        };

        float GetCameraFOV()
        {
            float t = unity_CameraProjection._m11;
            float Rad2Deg = 180 / 3.1415;
            float fov = atan(1.0f / t) * 2.0 * Rad2Deg;
            return fov;
        }
        float ApplyOutlineDistanceFadeOut(float inputMulFix)
        {
            return saturate(inputMulFix);
        }
        float GetOutlineCameraFovAndDistanceFixMultiplier(float positionVS_Z)
        {
            float cameraMulFix;
            if (unity_OrthoParams.w == 0)
            {
                cameraMulFix = abs(positionVS_Z);
                cameraMulFix = ApplyOutlineDistanceFadeOut(cameraMulFix);
                cameraMulFix *= GetCameraFOV();
            }
            else
            {
                float orthoSize = abs(unity_OrthoParams.y);
                orthoSize = ApplyOutlineDistanceFadeOut(orthoSize);
                cameraMulFix = orthoSize * 50;
            }

            return cameraMulFix * 0.0001;
        }

        float3 TransformPositionWSToOutlinePositionWS(half vertexColorAlpha, float3 positionWS, float positionVS_Z, float3 normalWS)
        {
            float outlineExpandAmount = vertexColorAlpha * _OutlineWidth * GetOutlineCameraFovAndDistanceFixMultiplier(positionVS_Z);
            return positionWS + normalWS * outlineExpandAmount;
        }


        Varyings OutlinePassVertex(Attributes input)
        {
            Varyings output = (Varyings)0;
            output.color = input.color;

            VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
            output.normalWS = vertexNormalInput.normalWS;

            output.positionWS = TransformObjectToWorld(input.positionOS);
            output.positionVS = TransformWorldToView(output.positionWS);
            output.positionCS = TransformWorldToHClip(output.positionWS);

            // #ifdef ToonShaderIsOutline
            output.positionWS = TransformPositionWSToOutlinePositionWS(input.color.a, output.positionWS, output.positionVS.z, output.normalWS);
            // #endif
            output.positionCS = TransformWorldToHClip(output.positionWS);
            
            float3 lightDirWS = normalize(_MainLightPosition.xyz);
            float3 fixedlightDirWS = normalize(float3(lightDirWS.x, _FixLightY, lightDirWS.z));
            lightDirWS = _IgnoreLightY ? fixedlightDirWS: lightDirWS;

            float lambert = dot(output.normalWS, lightDirWS);
            output.lambert = lambert * 0.5f + 0.5f;

            output.uv.xy = TRANSFORM_TEX(input.texcoord, _BaseMap);
            output.uv.zw = TRANSFORM_TEX(input.texcoord, _BloomMap);

            output.shadowCoord = TransformWorldToShadowCoord(output.positionWS);
            return output;
        }

        Varyings ToonPassVertex(Attributes input)
        {
            Varyings output = (Varyings)0;
            output.color = input.color;

            VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
            output.normalWS = vertexNormalInput.normalWS;

            output.positionWS = TransformObjectToWorld(input.positionOS);
            output.positionVS = TransformWorldToView(output.positionWS);
            output.positionCS = TransformWorldToHClip(output.positionWS);
            
            float3 lightDirWS = normalize(_MainLightPosition.xyz);
            float3 fixedlightDirWS = normalize(float3(lightDirWS.x, _FixLightY, lightDirWS.z));
            lightDirWS = _IgnoreLightY ? fixedlightDirWS: lightDirWS;

            float lambert = dot(output.normalWS, lightDirWS);
            output.lambert = lambert * 0.5f + 0.5f;

            output.uv.xy = TRANSFORM_TEX(input.texcoord, _BaseMap);
            output.uv.zw = TRANSFORM_TEX(input.texcoord, _BloomMap);

            output.shadowCoord = TransformWorldToShadowCoord(output.positionWS);
            return output;
        }

        half4 FragmentAlphaClip(Varyings input): SV_TARGET
        {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
            #if ENABLE_ALPHA_CLIPPING
                clip(SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).b - _Cutoff);
            #endif
            return 0;
        }
        ENDHLSL

        Pass
        {
            NAME "CHARACTER_BASE"

            Tags { "LightMode" = "UniversalForward" }

            Cull Back
            ZTest LEqual
            ZWrite On
            Blend One Zero

            HLSLPROGRAM

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fog
            
            // #pragma shader_feature_local ENABLE_AUTOCOLOR
            #pragma shader_feature_local_fragment ENABLE_ALPHA_CLIPPING
            #pragma shader_feature_local_fragment ENABLE_BLOOM_MASK
            #pragma shader_feature_local_fragment ENABLE_FACE_SHADOW_MAP
            #pragma shader_feature_local_fragment ENABLE_RAMP_SHADOW
            #pragma vertex ToonPassVertex
            #pragma fragment ToonPassFragment

            half4 ToonPassFragment(Varyings input): COLOR
            {

                half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy);
                #if ENABLE_ALPHA_CLIPPING
                    clip(baseColor.a - _Cutoff);
                #endif

                #if ENABLE_BLOOM_MASK
                    baseColor.a = SAMPLE_TEXTURE2D(_BloomMap, sampler_BloomMap, input.uv.zw).a * baseColor.a;
                #endif

                if (!_EnableEmission)
                {
                    baseColor.a = 0;
                }

                Light mainLight = GetMainLight();

                float3 shadowTestPosWS = input.positionWS + mainLight.direction * _ReceiveShadowMappingPosOffset;
                #ifdef _MAIN_LIGHT_SHADOWS
                    float4 shadowCoord = TransformWorldToShadowCoord(shadowTestPosWS);
                    mainLight.shadowAttenuation = MainLightRealtimeShadow(shadowCoord);
                #endif

                half4 LightMapColor = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, input.uv.xy);
                half3 ShadowColor = baseColor.rgb * _ShadowMultColor.rgb;
                half3 DarkShadowColor = baseColor.rgb * _DarkShadowMultColor.rgb;

                // Ramp阴影
                #if ENABLE_RAMP_SHADOW
                    //使用halflambert采样，由于采样至Ramp边缘会出现黑线，因此_RampShadowRange-0.003避免这种情况
                    float rampValue = input.lambert * (1.0 / _RampShadowRange - 0.003);
                    half3 ShadowRamp1 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, 0.95)).rgb;
                    half3 ShadowRamp2 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, 0.85)).rgb;
                    half3 ShadowRamp3 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, 0.75)).rgb;
                    half3 ShadowRamp4 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, 0.65)).rgb;
                    half3 ShadowRamp5 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, 0.55)).rgb;
                    half3 CoolShadowRamp1 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, 0.45)).rgb;
                    half3 CoolShadowRamp2 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, 0.35)).rgb;
                    half3 CoolShadowRamp3 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, 0.25)).rgb;
                    half3 CoolShadowRamp4 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, 0.15)).rgb;
                    half3 CoolShadowRamp5 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, 0.05)).rgb;
                    // 0    hard/emission/specular/silk
                    // 77   soft/common
                    // 128  metal
                    // 179  tights
                    // 255  skin
                    half3 AllRamps[10] = {
                        ShadowRamp1, ShadowRamp2, ShadowRamp3, ShadowRamp4, ShadowRamp5, CoolShadowRamp1, CoolShadowRamp2, CoolShadowRamp3, CoolShadowRamp4, CoolShadowRamp5
                    };
                    
                    half3 skinRamp = step(abs(LightMapColor.a * 255 - _RampArea12.x), 10) * AllRamps[_RampArea12.y]; // CoolShadowRamp2
                    half3 tightsRamp = step(abs(LightMapColor.a * 255 - _RampArea12.z), 10) * AllRamps[_RampArea12.w]; // CoolShadowRamp5
                    half3 softCommonRamp = step(abs(LightMapColor.a * 255 - _RampArea34.x), 10) * AllRamps[_RampArea34.y]; // CoolShadowRamp1
                    half3 hardSilkRamp = step(abs(LightMapColor.a * 255 - _RampArea34.z), 10) * AllRamps[_RampArea34.w]; // CoolShadowRamp3
                    half3 metalRamp = step(abs(LightMapColor.a * 255 - _RampArea5.x), 10) * AllRamps[_RampArea5.y]; // CoolShadowRamp4

                    // 组合5个Ramp，得到最终的Ramp阴影，并根据rampValue与BaseColor结合。
                    half3 finalRamp = skinRamp + tightsRamp + metalRamp + softCommonRamp + hardSilkRamp;

                    rampValue = step(_RampShadowRange, input.lambert);
                    half3 RampShadowColor = rampValue * baseColor.rgb + (1 - rampValue) * finalRamp * baseColor.rgb;

                    ShadowColor = RampShadowColor;
                    DarkShadowColor = RampShadowColor;

                    // #if ENABLE_FACE_SHADOW_MAP
                    //     ShadowColor = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.1, 0.85)).rgb;
                    // #endif
                #endif

                // SWeight：决定阴影范围
                float SWeight = (LightMapColor.g * input.color.r + input.lambert) * 0.5 + 1.125;

                //崩坏3原始算法
                // float SFactor = 1.0f - step(0.5f, SWeight);
                // float2 halfFactor = SWeight * float2(1.2f, 1.25f) + float2(-0.1f, -0.125f);
                // SWeight = SFactor * halfFactor.x + (1.0f - SFactor) * halfFactor.y;
                // SWeight = floor((SWeight + input.lambert) * 0.5 + 1.05 - _ShadowArea);
                // SFactor = step(SWeight, 0);
                //ShadowColor.rgb = SFactor * baseColor.rgb + (1 - SFactor) * ShadowColor.rgb;

                //如果SFactor = 0,ShallowShadowColor为一级阴影色,否则为BaseColor。
                // float SWeight = (LightMapColor.g * input.color.r + input.lambert) * 0.5 + 1.125;
                float SFactor = floor(SWeight - _ShadowArea);
                half3 ShallowShadowColor = SFactor * baseColor.rgb + (1 - SFactor) * ShadowColor.rgb;

                //如果SFactor = 0,DarkShadowColor为二级阴影色,否则为一级阴影色。
                SFactor = floor(SWeight - _DarkShadowArea);
                DarkShadowColor = SFactor * (_FixDarkShadow * ShadowColor + (1 - _FixDarkShadow) * ShallowShadowColor) + (1 - SFactor) * DarkShadowColor;

                // 平滑阴影边缘
                half rampS = smoothstep(0, _ShadowSmooth, input.lambert - _ShadowArea);
                half rampDS = smoothstep(0, _DarkShadowSmooth, input.lambert - _DarkShadowArea);
                ShallowShadowColor.rgb = lerp(ShadowColor, baseColor.rgb, rampS);
                DarkShadowColor.rgb = lerp(DarkShadowColor.rgb, ShadowColor, rampDS);

                //如果SFactor = 0,FinalColor为二级阴影，否则为一级阴影。
                SFactor = floor(LightMapColor.g * input.color.r + 0.9f);
                half4 FinalColor;
                FinalColor.rgb = SFactor * ShallowShadowColor + (1 - SFactor) * DarkShadowColor;

                //根据KEYWORD决定是否使用Ramp阴影
                #if ENABLE_RAMP_SHADOW
                    FinalColor.rgb = RampShadowColor;
                #endif

                // FaceLightMap
                #if ENABLE_FACE_SHADOW_MAP

                    // 计算光照旋转偏移
                    float sinx = sin(_FaceShadowOffset);
                    float cosx = cos(_FaceShadowOffset);
                    float2x2 rotationOffset = float2x2(cosx, -sinx, sinx, cosx);
                    
                    float3 Front = unity_ObjectToWorld._12_22_32;
                    float3 Right = unity_ObjectToWorld._13_23_33;
                    float2 lightDir = mul(rotationOffset, mainLight.direction.xz);

                    //计算xz平面下的光照角度
                    float FrontL = dot(normalize(Front.xz), normalize(lightDir));
                    float RightL = dot(normalize(Right.xz), normalize(lightDir));
                    RightL = - (acos(RightL) / PI - 0.5) * 2;

                    //左右各采样一次FaceLightMap的阴影数据存于lightData
                    float2 lightData = float2(SAMPLE_TEXTURE2D(_FaceShadowMap, sampler_FaceShadowMap, float2(input.uv.x, input.uv.y)).r,
                    SAMPLE_TEXTURE2D(_FaceShadowMap, sampler_FaceShadowMap, float2(-input.uv.x, input.uv.y)).r);

                    //修改lightData的变化曲线，使中间大部分变化速度趋于平缓。
                    lightData = pow(abs(lightData), _FaceShadowMapPow);

                    //根据光照角度判断是否处于背光，使用正向还是反向的lightData。
                    float lightAttenuation = step(0, FrontL) * min(step(RightL, lightData.x), step(-RightL, lightData.y));
                    
                    half3 FaceColor = lerp(ShadowColor.rgb, baseColor.rgb, lightAttenuation);
                    FinalColor.rgb = FaceColor;
                #endif

                // Blinn-Phong
                half3 viewDirWS = normalize(_WorldSpaceCameraPos.xyz - input.positionWS.xyz);
                half3 halfViewLightWS = normalize(viewDirWS + mainLight.direction.xyz);

                half spec = pow(saturate(dot(input.normalWS, halfViewLightWS)), _Shininess);
                spec = step(1.0f - LightMapColor.b, spec);
                half4 specularColor = _EnableSpecular * _LightSpecColor * _SpecMulti * LightMapColor.r * spec;

                half4 SpecDiffuse;
                SpecDiffuse.rgb = specularColor.rgb + FinalColor.rgb;
                SpecDiffuse.rgb *= _BaseColor.rgb;
                SpecDiffuse.a = specularColor.a * _BloomFactor * 10;

                // Rim Light
                float lambertF = dot(mainLight.direction, input.normalWS);
                float lambertD = max(0, -lambertF);
                lambertF = max(0, lambertF);
                float rim = 1 - saturate(dot(viewDirWS, input.normalWS));

                float rimDot = pow(rim, _RimPow);
                rimDot = _EnableLambert * lambertF * rimDot + (1 - _EnableLambert) * rimDot;
                float rimIntensity = smoothstep(0, _RimSmooth, rimDot);
                half4 Rim = _EnableRim * pow(rimIntensity, 5) * _RimColor * baseColor;
                Rim.a = _EnableRim * rimIntensity * _BloomFactor;

                rimDot = pow(rim, _DarkSideRimPow);
                rimDot = _EnableLambert * lambertD * rimDot + (1 - _EnableLambert) * rimDot;
                rimIntensity = smoothstep(0, _DarkSideRimSmooth, rimDot);
                half4 RimDS = _EnableRimDS * pow(rimIntensity, 5) * _DarkSideRimColor * baseColor;
                RimDS.a = _EnableRimDS * rimIntensity * _BloomFactor;

                // Emission & Bloom
                half4 Emission;
                Emission.rgb = _Emission * DarkShadowColor.rgb * _EmissionColor.rgb - SpecDiffuse.rgb;
                Emission.a = _EmissionBloomFactor * baseColor.a;

                half4 SpecRimEmission;
                SpecRimEmission.rgb = pow(DarkShadowColor, 1) * _Emission;
                SpecRimEmission.a = (SpecDiffuse.a + Rim.a + RimDS.a);

                FinalColor = SpecDiffuse + Rim + RimDS + Emission.a * Emission + SpecRimEmission.a * SpecRimEmission;

                FinalColor = (_WorldLightInfluence * _MainLightColor * FinalColor + (1 - _WorldLightInfluence) * FinalColor);

                return FinalColor;
            }
            ENDHLSL

        }
        Pass
        {
            Name "CHARACTER_OUTLINE"
            Tags {  }
            Cull Front
            HLSLPROGRAM

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            // #pragma shader_feature_local ENABLE_AUTOCOLOR
            #pragma shader_feature_local_fragment ENABLE_ALPHA_CLIPPING

            #pragma vertex OutlinePassVertex
            #pragma fragment OutlinePassFragment

            float4 OutlinePassFragment(Varyings input): COLOR
            {
                half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy);
                half4 FinalColor = _OutlineColor * baseColor;

                return FinalColor;
            }

            ENDHLSL

        }
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Off

            HLSLPROGRAM

            #pragma vertex OutlinePassVertex
            #pragma fragment FragmentAlphaClip

            ENDHLSL

        }
        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Off

            HLSLPROGRAM

            #pragma vertex OutlinePassVertex
            #pragma fragment FragmentAlphaClip
            
            ENDHLSL

        }
    }
}
