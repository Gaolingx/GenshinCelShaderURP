Shader "GenshinCelShaderURP/V1.0"
{
    Properties
    {
        [Header(Shader Setting)]
        [Space(5)]
        [KeywordEnum(Base,Hair,Face)] _ShaderEnum("Shader类型",int) = 0
        [Toggle] _IsNight ("In Night", int) = 0
        [Space(5)]

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

        [Header(Shadow Setting 1)]
        [Space(5)]
        _LightMap ("LightMap", 2D) = "grey" { }
        _ShadowMultColor ("Shadow Color", color) = (1.0, 1.0, 1.0, 1.0)
        _ShadowArea ("Shadow Area", range(0.0, 1.0)) = 0.5
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

        [Header(Shadow Setting 2)]
        [Space(5)]
        [Toggle(ENABLE_RAMP_SHADOW)] _EnableRampShadow ("Enable Ramp Shadow", float) = 1
        _RampMap ("RampMap", 2D) = "white" {}
        _ShadowSmooth ("Shadow Smooth", Range(0, 1)) = 0.5
        _RampShadowRange ("Ramp Shadow Range", Range(0.5, 1.0)) = 0.8
        _RangeAO ("AO Range", Range(1, 2)) = 1.5
        _ShadowColor ("Ramp Shadow Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [Space(30)]

        [Header(Specular Setting)]
        [Space(5)]
        [Toggle] _EnableSpecular ("Enable Specular", int) = 1
        [Toggle(ENABLE_METAL_SPECULAR)] _EnableMetalSpecular ("Enable Metal Specular", int) = 1
        _MetalMap ("Metal Map", 2D) = "white" {}
        [HDR] _SpecularColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _BlinnPhongSpecularGloss ("Blinn Phong Specular Gloss", Range(0.01, 10)) = 5
        _BlinnPhongSpecularIntensity ("Blinn Phong Specular Intensity", Range(0, 1)) = 1
        _StepSpecularGloss ("Step Specular Gloss", Range(0, 1)) = 0.5
        _StepSpecularIntensity ("Step Specular Intensity", Range(0, 10)) = 0.5
        _MetalSpecularGloss ("Metal Specular Gloss", Range(0, 1)) = 0.5
        _MetalSpecularIntensity ("Metal Specular Intensity", Range(0, 1)) = 1
        [Space(30)]

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
        [Toggle] _EnableOutline ("Enable Outline", int) = 1
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
        #pragma shader_feature _SHADERENUM_BASE _SHADERENUM_HAIR _SHADERENUM_FACE

        int _IsNight;
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
        int _EnableAutoColor;

        float4 _LightMap_ST;
        float4 _FaceShadowMap_ST;
        float _FaceShadowMapPow;
        float _FaceShadowOffset;

        float4 _RampMap_ST;
        half _EnableRampShadow;
        half _RampShadowRange;
        half4 _ShadowColor;

        float3 _ShadowMultColor;
        float _ShadowArea;
        half _ShadowSmooth;
        float _DarkShadowArea;
        float3 _DarkShadowMultColor;
        half _DarkShadowSmooth;

        int _EnableSpecular;
        int _EnableMetalSpecular;
        float4 _MetalMap_ST;
        half4 _SpecularColor;
        half _BlinnPhongSpecularGloss;
        half _BlinnPhongSpecularIntensity;
        half _StepSpecularGloss;
        half _StepSpecularIntensity;
        half _MetalSpecularGloss;
        half _MetalSpecularIntensity;

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

        int _EnableOutline;
        float _OutlineWidth;
        half4 _OutlineColor;
        float _OutlineZOffset;

        int _EnableAlphaClipping;
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
            return positionWS + normalWS * outlineExpandAmount * _EnableOutline;
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
            
            // #pragma shader_feature_local

            #pragma shader_feature_local_fragment ENABLE_ALPHA_CLIPPING
            #pragma shader_feature_local_fragment ENABLE_BLOOM_MASK
            #pragma shader_feature_local_fragment ENABLE_FACE_SHADOW_MAP
            #pragma shader_feature_local_fragment ENABLE_RAMP_SHADOW
            #pragma shader_feature_local_fragment ENABLE_METAL_SPECULAR
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
                // 计算世界空间中的光照和视角方向
                half3 lightDir = normalize(TransformObjectToWorldDir(mainLight.direction));
                half3 viewDirWS = normalize(_WorldSpaceCameraPos.xyz - input.positionWS.xyz);
                half3 halfViewLightWS = normalize(viewDirWS + mainLight.direction.xyz);
                half3 halfDir = normalize(viewDirWS + lightDir);

                half halfLambert = dot(lightDir, input.normalWS) * 0.5 + 0.5;

                // 依据原来的lambert值，保留0到一定数值的smooth渐变，大于这一数值的全部采样ramp最右边的颜色，从而形成硬边
                halfLambert = smoothstep(0.0, _ShadowSmooth, halfLambert);
                // 常暗阴影
                float ShadowAO = smoothstep(0.1, LightMapColor.g, 0.7);
                // Ramp阴影
                #if ENABLE_RAMP_SHADOW

                //==========================================================================================
                // Base Ramp

                float RampPixelX = 0.00390625;  //0.00390625 = 1/256
                float RampPixelY = 0.03125;     //0.03125 = 1/16/2   尽量采样到ramp条带的正中间，以避免精度误差
                float RampX, RampY;
                // 对X做一步Clamp，防止采样到边界
                RampX = clamp(halfLambert*ShadowAO, RampPixelX, 1-RampPixelX);

                // 灰度0.0-0.2  硬Ramp
                // 灰度0.2-0.4  软Ramp
                // 灰度0.4-0.6  金属层
                // 灰度0.6-0.8  布料层，主要为silk类
                // 灰度0.8-1.0  皮肤/头发层
                // 白天采样上半，晚上采样下半

                //— — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —
                // Base Ramp
                if (_IsNight == 0.0)
                    RampY = RampPixelY * (33 - 2 * (LightMapColor.a * 4 + 1));
                else
                    RampY = RampPixelY * (17 - 2 * (LightMapColor.a * 4 + 1));

                float2 RampUV = float2(RampX, RampY);
                float4 rampColor = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, RampUV);
                half4 FinalRamp = lerp(rampColor * baseColor * _ShadowColor, baseColor, step(_RampShadowRange, halfLambert * ShadowAO));

                //— — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —
                // Hair Ramp
                #if _SHADERENUM_HAIR
                    if (_IsNight == 0.0)
                        RampY = RampPixelY * (33 - 2 * lerp(1, 3, step(0.5, LightMapColor.a)));
                    else
                        RampY = RampPixelY * (17 - 2 * lerp(1, 3, step(0.5, LightMapColor.a)));
                    RampUV = float2(RampX, RampY);
                    rampColor = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, RampUV);
                    FinalRamp = lerp(rampColor * baseColor * _ShadowColor, baseColor, step(_RampShadowRange, halfLambert * ShadowAO));
                #endif

                    half3 RampShadowColor = FinalRamp;

                    ShadowColor = RampShadowColor;

                #endif

                half4 FinalColor;
                FinalColor.rgb = ShadowColor;

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
                    float2 lightDir1 = mul(rotationOffset, mainLight.direction.xz);

                    //计算xz平面下的光照角度
                    float FrontL = dot(normalize(Front.xz), normalize(lightDir1));
                    float RightL = dot(normalize(Right.xz), normalize(lightDir1));
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

                //==========================================================================================
                // 高光
                half4 BlinnPhongSpecular;
                half4 MetalSpecular;
                half4 StepSpecular;
                half4 FinalSpecular;
                // ILM的R通道，灰色为裁边视角高光
                half StepMask = step(0.2, LightMapColor.r) - step(0.8, LightMapColor.r);
                StepSpecular = step(1 - _StepSpecularGloss, saturate(dot(input.normalWS, viewDirWS))) * _StepSpecularIntensity * StepMask;
                // ILM的R通道，白色为 Blinn-Phong + 金属高光
                half MetalMask = step(0.9, LightMapColor.r);
                // Blinn-Phong
                BlinnPhongSpecular = pow(max(0, dot(input.normalWS, halfDir)), _BlinnPhongSpecularGloss) * _BlinnPhongSpecularIntensity * MetalMask;
                // 金属高光
                float2 MetalMapUV = mul((float3x3) UNITY_MATRIX_V, input.normalWS).xy * 0.5 + 0.5;

                float MetalMap = SAMPLE_TEXTURE2D(_MetalMap, sampler_MetalMap, MetalMapUV).r;

                MetalMap = step(_MetalSpecularGloss, MetalMap);

                MetalSpecular = MetalMap * _MetalSpecularIntensity * MetalMask * _EnableMetalSpecular;
                
                FinalSpecular = StepSpecular + BlinnPhongSpecular + MetalSpecular;
                FinalSpecular = lerp(0, baseColor * FinalSpecular * _SpecularColor, LightMapColor.b) ;
                FinalSpecular *= halfLambert * ShadowAO * _EnableSpecular;

                half4 SpecDiffuse;
                SpecDiffuse.rgb = FinalSpecular + FinalColor.rgb;
                SpecDiffuse.rgb *= _BaseColor.rgb;
                SpecDiffuse.a = FinalSpecular.a * _BloomFactor * 10;

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


                // Emission & Bloom
                half4 Emission;
                Emission.rgb = _Emission * ShadowColor.rgb * _EmissionColor.rgb - SpecDiffuse.rgb;
                Emission.a = _EmissionBloomFactor * baseColor.a;

                half4 SpecRimEmission;
                SpecRimEmission.rgb = pow(ShadowColor, 1) * _Emission;
                SpecRimEmission.a = (SpecDiffuse.a + Rim.a);

                FinalColor = SpecDiffuse + Rim + Emission.a * Emission + SpecRimEmission.a * SpecRimEmission;

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
