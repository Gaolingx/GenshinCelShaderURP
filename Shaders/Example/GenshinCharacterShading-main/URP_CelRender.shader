Shader "Toon/URP_Toon"
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
        [MainTexture] _MainTex ("Texture", 2D) = "white" {}
        [HDR][MainColor] _MainColor ("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [Space(30)]

        [Header(Shadow Setting)]
        [Space(5)]
        _LightMap ("LightMap", 2D) = "grey" {}
        _RampMap ("RampMap", 2D) = "white" {}
        _ShadowSmooth ("Shadow Smooth", Range(0, 1)) = 0.5
        _RampShadowRange ("Ramp Shadow Range", Range(0.5, 1.0)) = 0.8
        _RangeAO ("AO Range", Range(1, 2)) = 1.5
        _ShadowColor ("Shadow Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [Space(30)]

        [Header(Face Setting)]
        [Space(5)]
        _FaceShadowOffset ("Face Shadow Offset", range(0.0, 1.0)) = 0.1
        _FaceShadowPow ("Face Shadow Pow", range(0.001, 1)) = 0.1
        [Space(30)]

        [Header(Specular Setting)]
        [Space(5)]
        [Toggle] _EnableSpecular ("Enable Specular", int) = 1
        _MetalMap ("Metal Map", 2D) = "white" {}
        [HDR] _SpecularColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _BlinnPhongSpecularGloss ("Blinn Phong Specular Gloss", Range(0.01, 10)) = 5
        _BlinnPhongSpecularIntensity ("Blinn Phong Specular Intensity", Range(0, 1)) = 1
        _StepSpecularGloss ("Step Specular Gloss", Range(0, 1)) = 0.5
        _StepSpecularIntensity ("Step Specular Intensity", Range(0, 1)) = 0.5
        _MetalSpecularGloss ("Metal Specular Gloss", Range(0, 1)) = 0.5
        _MetalSpecularIntensity ("Metal Specular Intensity", Range(0, 1)) = 1
        [Space(30)]

        [Header(Rim Setting)]
        [Space(5)]
        [Toggle] _EnableRim ("Enable Rim", int) = 1
        [HDR] _RimColor ("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _RimOffset ("Rim Offset", Range(0, 0.5)) = 0.1    //粗细
        _RimThreshold ("Rim Threshold", Range(0, 2)) = 1  //细致程度
        [Space(30)]

        [Header(Outline Setting)]
        [Space(5)]
        [Toggle] _EnableOutline ("Enable Outline", int) = 1
        _OutlineWidth ("Outline Width", Range(0, 4)) = 1
        _OutlineColor ("Outline Color", Color) = (0.5, 0.5, 0.5, 1)
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque"}

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #pragma shader_feature _SHADERENUM_BASE _SHADERENUM_HAIR _SHADERENUM_FACE

        int _IsNight;
        TEXTURE2D(_MainTex);            SAMPLER(sampler_MainTex);
        TEXTURE2D(_LightMap);           SAMPLER(sampler_LightMap);
        TEXTURE2D(_RampMap);            SAMPLER(sampler_RampMap);
        TEXTURE2D(_MetalMap);           SAMPLER(sampler_MetalMap);
        TEXTURE2D(_CameraDepthTexture); SAMPLER(sampler_CameraDepthTexture);

        // 单个材质独有的参数尽量放在 CBUFFER 中，以提高性能
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        half4 _MainColor;

        float4 _LightMap_ST;
        float4 _RampMap_ST;
        half _ShadowSmooth;
        half _RampShadowRange;
        half4 _ShadowColor;

        int _EnableSpecular;
        float4 _MetalMap_ST;
        half4 _SpecularColor;
        half _BlinnPhongSpecularGloss;
        half _BlinnPhongSpecularIntensity;
        half _StepSpecularGloss;
        half _StepSpecularIntensity;
        half _MetalSpecularGloss;
        half _MetalSpecularIntensity;

        float _FaceShadowOffset;
        float _FaceShadowPow;

        int _EnableRim;
        half4 _RimColor;
        half _RimOffset;
        half _RimThreshold;

        int _EnableOutline;
        half _OutlineWidth;
        half4 _OutlineColor;
        CBUFFER_END

        struct a2v{
            float3 vertex : POSITION;       //顶点坐标
            half4 color : COLOR0;           //顶点色
            half3 normal : NORMAL;          //法线
            half4 tangent : TANGENT;        //切线
            float2 texCoord : TEXCOORD0;    //纹理坐标
        };
        struct v2f{
            float4 pos : POSITION;              //裁剪空间顶点坐标
            float2 uv : TEXCOORD0;              //uv
            float3 worldPos : TEXCOORD1;        //世界坐标
            float3 worldNormal : TEXCOORD2;     //世界空间法线
            float3 worldTangent : TEXCOORD3;    //世界空间切线
            float3 worldBiTangent : TEXCOORD4;  //世界空间副切线
            half4 color : COLOR0;               //平滑Rim所需顶点色
        };
        ENDHLSL

        Pass
        {
            Tags {"LightMode"="UniversalForward" "RenderType"="Opaque"}
            
            HLSLPROGRAM
            #pragma vertex ToonPassVert
            #pragma fragment ToonPassFrag

            v2f ToonPassVert(a2v v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.texCoord, _MainTex);
                o.worldPos = TransformObjectToWorld(v.vertex);
                // 使用URP自带函数计算世界空间法线
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(v.normal, v.tangent);
                o.worldNormal = vertexNormalInput.normalWS;
                o.worldTangent = vertexNormalInput.tangentWS;
                o.worldBiTangent = vertexNormalInput.bitangentWS;
                o.color = v.color;
                return o;
            }

            half4 ToonPassFrag(v2f i) : SV_TARGET
            {
                float4 BaseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _MainColor;
                float4 LightMapColor = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, i.uv);
                Light mainLight = GetMainLight();
                half4 LightColor = half4(mainLight.color, 1.0);
                half3 lightDir = normalize(mainLight.direction);
                half3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 halfDir = normalize(viewDir + lightDir);

                half halfLambert = dot(lightDir, i.worldNormal) * 0.5 + 0.5;

                //==========================================================================================
                // Base Ramp
                // 依据原来的lambert值，保留0到一定数值的smooth渐变，大于这一数值的全部采样ramp最右边的颜色，从而形成硬边
                halfLambert = smoothstep(0.0, _ShadowSmooth, halfLambert);
                // 常暗阴影
                float ShadowAO = smoothstep(0.1, LightMapColor.g, 0.7);

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
                half4 FinalRamp = lerp(rampColor * BaseColor * _ShadowColor, BaseColor, step(_RampShadowRange, halfLambert * ShadowAO));

                //— — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —
                // Hair Ramp
                #if _SHADERENUM_HAIR
                    if (_IsNight == 0.0)
                        RampY = RampPixelY * (33 - 2 * lerp(1, 3, step(0.5, LightMapColor.a)));
                    else
                        RampY = RampPixelY * (17 - 2 * lerp(1, 3, step(0.5, LightMapColor.a)));
                    RampUV = float2(RampX, RampY);
                    rampColor = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, RampUV);
                    FinalRamp = lerp(rampColor * BaseColor * _ShadowColor, BaseColor, step(_RampShadowRange, halfLambert * ShadowAO));
                #endif

                //— — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —
                // SDF脸部阴影
                #if _SHADERENUM_FACE
                    float4 upDir = mul(unity_ObjectToWorld, float4(0,1,0,0));  
                    float4 frontDir = mul(unity_ObjectToWorld, float4(0,0,1,0));
                    float3 rightDir = cross(upDir, frontDir);

                    float FdotL = dot(normalize(frontDir.xz), normalize(lightDir.xz));
                    float RdotL = dot(normalize(rightDir.xz), normalize(lightDir.xz));
                    // 切换贴图正反
                    float2 FaceMapUV = float2(lerp(i.uv.x, 1-i.uv.x, step(0, RdotL)), i.uv.y);
                    float FaceMap = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, FaceMapUV).r;
                    // 下面这句话是错的
                    //float FaceMap = lerp(LightMapColor.r, 1-LightMapColor.r, step(0, RdotL)) * step(0, FdotL);

                    // 调整变化曲线，使得中间大部分变化速度趋于平缓
                    FaceMap = pow(FaceMap, _FaceShadowPow);

                    // 直接用采样的结果和FdotL比较判断，头发阴影和面部阴影会对不上，需要手动调整偏移
                    // 但是直接在LightMap数据上±Offset会导致光照进入边缘时产生阴影跳变
                    float sinx = sin(_FaceShadowOffset);
                    float cosx = cos(_FaceShadowOffset);
                    float2x2 rotationOffset1 = float2x2(cosx, sinx, -sinx, cosx); //顺时针偏移
                    float2x2 rotationOffset2 = float2x2(cosx, -sinx, sinx, cosx); //逆时针偏移
                    float2 FaceLightDir = lerp(mul(rotationOffset1, lightDir.xz), mul(rotationOffset2, lightDir.xz), step(0, RdotL));
                    FdotL = dot(normalize(frontDir.xz), normalize(FaceLightDir));

                    //FinalRamp = float4(FaceMap, FaceMap, FaceMap, 1);
                    FinalRamp = lerp(BaseColor, _ShadowColor * BaseColor, step(FaceMap, 1-FdotL));
                #endif

                //==========================================================================================
                // 高光
                half4 BlinnPhongSpecular;
                half4 MetalSpecular;
                half4 StepSpecular;
                half4 FinalSpecular;
                // ILM的R通道，灰色为裁边视角高光
                half StepMask = step(0.2, LightMapColor.r) - step(0.8, LightMapColor.r);
                StepSpecular = step(1 - _StepSpecularGloss, saturate(dot(i.worldNormal, viewDir))) * _StepSpecularIntensity * StepMask;
                // ILM的R通道，白色为 Blinn-Phong + 金属高光
                half MetalMask = step(0.9, LightMapColor.r);
                // Blinn-Phong
                BlinnPhongSpecular = pow(max(0, dot(i.worldNormal, halfDir)), _BlinnPhongSpecularGloss) * _BlinnPhongSpecularIntensity * MetalMask;
                // 金属高光
                float2 MetalMapUV = mul((float3x3) UNITY_MATRIX_V, i.worldNormal).xy * 0.5 + 0.5;
                float MetalMap = SAMPLE_TEXTURE2D(_MetalMap, sampler_MetalMap, MetalMapUV).r;
                MetalMap = step(_MetalSpecularGloss, MetalMap);
                MetalSpecular = MetalMap * _MetalSpecularIntensity * MetalMask;
                
                FinalSpecular = StepSpecular + BlinnPhongSpecular + MetalSpecular;
                FinalSpecular = lerp(0, BaseColor * FinalSpecular * _SpecularColor, LightMapColor.b) ;
                FinalSpecular *= halfLambert * ShadowAO * _EnableSpecular;

                //==========================================================================================
                // 屏幕空间深度等宽边缘光
                // 屏幕空间UV
                float2 RimScreenUV = float2(i.pos.x / _ScreenParams.x, i.pos.y / _ScreenParams.y);
                // 法线外扩偏移UV，把worldNormal转换到NDC空间
                float3 smoothNormal = normalize(UnpackNormalmapRGorAG(i.color));
                float3x3 tangentTransform = float3x3(i.worldTangent, i.worldBiTangent, i.worldNormal);
                float3 worldRimNormal = normalize(mul(smoothNormal, tangentTransform));
                float2 RimOffsetUV = float2(mul((float3x3) UNITY_MATRIX_V, worldRimNormal).xy * _RimOffset * 0.01 / i.pos.w);
                RimOffsetUV += RimScreenUV;
                
                float ScreenDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, RimScreenUV);
                float Linear01ScreenDepth = LinearEyeDepth(ScreenDepth, _ZBufferParams);
                float OffsetDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, RimOffsetUV);
                float Linear01OffsetDepth = LinearEyeDepth(OffsetDepth, _ZBufferParams);

                float diff = Linear01OffsetDepth - Linear01ScreenDepth;
                float rimMask = step(_RimThreshold * 0.1, diff);
                // 边缘光颜色的a通道用来控制边缘光强弱
                half4 RimColor = float4(rimMask * _RimColor.rgb * _RimColor.a, 1) * _EnableRim;

                //return FinalSpecular;
                //return half4(1,1,1,1);
                return FinalRamp + FinalSpecular + RimColor;
            }
            ENDHLSL
        }

        Pass
        {
            Name "OUTLINE_PASS"
            Tags {}
            Cull Front

            HLSLPROGRAM
            #pragma vertex OutlinePassVert
            #pragma fragment OutlinePassFrag

            v2f OutlinePassVert(a2v v)
            {
                v2f o;
                float4 pos = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.texCoord, _MainTex);
                o.worldPos = TransformObjectToWorld(v.vertex);
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(v.normal, v.tangent);
                o.worldNormal = vertexNormalInput.normalWS;
                o.worldTangent = vertexNormalInput.tangentWS;
                o.worldBiTangent = vertexNormalInput.bitangentWS;

                // 获取预先烘焙进顶点色的切线空间平滑法线，修复描边断裂，同时避免蒙皮动画可能发生的错误描边
                // UnpackNormalmapRGorAG会自动将RG变为AG，也就将顶点色控制描边粗细变化一并实现了
                half3 smoothNormal = normalize(UnpackNormalmapRGorAG(v.color));
                // 将法线从切线空间变换到世界空间
                float3x3 tangentTransform = float3x3(o.worldTangent, o.worldBiTangent, o.worldNormal);
                half3 worldOutlineNormal = normalize(mul(smoothNormal, tangentTransform));
                // 再从世界空间变换到裁剪空间，此处 * pos.w 是为了消除齐次除法的影响，使得在摄像机远近发生变化时，描边粗细保持不变
                half3 outlineNormal = TransformWorldToHClip(worldOutlineNormal) * pos.w;
                // 求得屏幕宽高比，修正描边以适配窗口
                float aspect = _ScreenParams.x / _ScreenParams.y;
                pos.xy += 0.001 * _OutlineWidth * v.color.a * outlineNormal.xy * aspect * _EnableOutline;

                //pos.xy += 0.001 * _OutlineWidth * v.color.a * o.worldNormal.xy * pos.w * aspect * _EnableOutline;

                // float3 viewNormal = TransformWorldToHClip(TransformObjectToWorldNormal(v.tangent.xyz));
                // pos.xy += 0.001 * _OutlineWidth * v.color.a * viewNormal.xy * aspect * _EnableOutline;
                o.pos = pos;
                return o;
            }

            half4 OutlinePassFrag(v2f i): COLOR
            {
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                return _OutlineColor * col;
            }
            ENDHLSL
        }

        Pass
        {
            Tags {"LightMode" = "DepthOnly"}
        }
    }
}
