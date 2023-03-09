Shader "ToonShader"
{
    //【汇入：贴图】
    Properties
    {
        [Header(Main Setting)]
        _MainTex ("主贴图", 2D) = "white" { }//贴图汇入窗口：代码中的名字，开放的名字，类型，初始值
        _MainShadowTex ("主阴影贴图", 2D) = "black" { }//贴图汇入窗口：代码中的名字，开放的名字，类型，初始值
        _NormalTex ("法线贴图", 2D) = "bump" { }//贴图汇入窗口：代码中的名字，开放的名字，类型，初始值
        _NormalScale ("法线影响程度", float) = 1.0
        [Toggle(_CLIPPING)] _Clipping ("Alpha裁剪", Float) = 0 //alpha剔除
        _ClipScale ("裁剪强度", Range(0.0, 1.0)) = 1.0

        [Header(Light Setting)]
        _ShadowSmooth ("阴影平滑", Range(0, 1)) = 0
        _ShadowRange ("阴影范围", Range(0, 1)) = 0
        _ShadowsAdd ("阴影强度", Range(0, 1)) = 1

        [Header(Shadow Setting)]
        [Toggle(_)] _ShadowOn ("阴影调整", Float) = 1 //alpha剔除
        //_ShadowMaskTex ("阴影遮罩贴图", 2D) = "white" { }//贴图汇入窗口：代码中的名字，开放的名字，类型，初始值
        _ShadowChange ("阴影修正", Range(-0.5, 0.5)) = 0
        _Shadow_Step ("阴影位移", Range(0, 1)) = 0
        _Shadow_Feather ("阴影平滑", Range(0, 1)) = 0
        
        [Header(OutLine Setting)]
        _OutLineColor ("描边颜色", Color) = (1, 1, 1, 1)
        _Outline_Width ("描边宽度", Range(0, 1)) = 1
        _Farthest_Distance ("描边最远距离", float) = 1
        _Nearest_Distance ("描边最近距离", float) = 0
        _Offset_Z ("描边摄像机调整", Range(0, 1)) = 0

        [Header(Hair Setting)]
        _HairHighLightTex ("高光贴图", 2D) = "black" { }
        _HighLightColor ("高光颜色", Color) = (1, 1, 1, 1)
    }
    //【模型的处理】
    SubShader
    {

        pass
        {
            //定义一个使用的语言类型
            Tags { "LightMode" = "UniversalForward" }
            HLSLPROGRAM

            //汇入模型的一堆数据
            struct appdata
            {
                float4 vertex : POSITION;//顶点的数据（位置）
                float3 normal : NORMAL;//汇入法线数据
                float4 tangent : TANGENT;//切线
                float2 uv : TEXCOORD0;//模型的UV坐标

            };
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"//函数库：主要用于各种的空间变换
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"//从unity中取得我们的光照
            TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);//采样贴图
            TEXTURE2D(_NormalTex);SAMPLER(sampler_NormalTex);//采样贴图
            TEXTURE2D(_ShadowMaskTex);SAMPLER(sampler_ShadowMaskTex);//采样贴图
            TEXTURE2D(_MainShadowTex);SAMPLER(sampler_MainShadowTex);//采样贴图
            TEXTURE2D(_HairHighLightTex);SAMPLER(sampler_HairHighLightTex);//采样贴图
            float _NormalScale;//法线影响程度
            float _Clipping;
            float _ClipScale;
            float _ShadowChange;
            float _Shadow_Step;
            float _Shadow_Feather;
            float _ShadowOn;
            float _ShadowSmooth;
            float _ShadowRange;
            float _ShadowsAdd;
            float4 _HighLightColor;
            //定义出顶点着色器
            #pragma vertex vert
            //定义出片元着色器
            #pragma fragment frag

            //阴影宏
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

            
            //模型处理
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 vertex_world : TEXCOORD2;
                float3 tangent : TEXCOORD3;
                float3 bitangent : TEXCOORD4;
            };

            real MainLightRealtimeShadowUTS(float4 shadowCoord, float4 positionCS)
            {
                #if !defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                    return 1.0h;
                #endif
                ShadowSamplingData shadowSamplingData = GetMainLightShadowSamplingData();
                half4 shadowParams = GetMainLightShadowParams();
                #if defined(UTS_USE_RAYTRACING_SHADOW)
                    float4 screenPos = ComputeScreenPos(positionCS / positionCS.w);
                    return SAMPLE_TEXTURE2D(_RaytracedHardShadow, sampler_RaytracedHardShadow, screenPos);
                #endif

                return SampleShadowmap(TEXTURE2D_ARGS(_MainLightShadowmapTexture, sampler_MainLightShadowmapTexture), shadowCoord, shadowSamplingData, shadowParams, false);
            }

            v2f vert(appdata v)//顶点着色器

            {
                v2f o;//初始化
                //物体，从模型空间->裁剪空间
                o.vertex = TransformObjectToHClip(v.vertex);
                
                o.vertex_world = TransformObjectToWorld(v.vertex.xyz);//完成了顶点从模型空间转换到世界空间的位置
                o.normal = normalize(TransformObjectToWorldNormal(v.normal));//法线
                o.tangent = normalize(TransformObjectToWorldDir(v.tangent));//切线
                o.bitangent = normalize(cross(o.normal, o.tangent)) * v.tangent.w * unity_WorldTransformParams.w;//切线
                o.uv = v.uv;//顶点UV到片元UV
                return o;//返回值

            }
            half4 frag(v2f i) : SV_TARGET
            {
                //基础色与法线
                float4 base_color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);//得到基础颜色
                float4 base_shadow_color = SAMPLE_TEXTURE2D(_MainShadowTex, sampler_MainShadowTex, i.uv);//得到基础颜色
                float4 height_light_color = SAMPLE_TEXTURE2D(_HairHighLightTex, sampler_HairHighLightTex, i.uv);//得到基础颜色
                float4 pack_normal = SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, i.uv);//采样法线贴图
                float3 unpack_normal = UnpackNormal(pack_normal);//得到法线的具体数据

                //阴影
                float4 SHADOW_COORDS = TransformWorldToShadowCoord(i.vertex_world);//阴影变量
                Light mainLight = GetMainLight(SHADOW_COORDS);//得到主光源的方向
                half shadow = 1;
                if (_ShadowOn)
                {
                    shadow = mainLight.shadowAttenuation;//得到实时阴影
                    shadow = saturate(saturate(shadow * 2) * 0.5 + 0.5 + _ShadowChange);//阴影修正
                    shadow = saturate((shadow - (_Shadow_Step - _Shadow_Feather)) / (_Shadow_Feather + 0.0001));
                }

                float3 N = normalize(_NormalScale * unpack_normal.x * i.tangent + _NormalScale * unpack_normal.y * i.bitangent + unpack_normal.z * i.normal);//法线
                float3 L = mainLight.direction;//光照
                float3 V = normalize(_WorldSpaceCameraPos - i.vertex_world);//视角方向
                float3 H = normalize(V + L);//得到我们的半程向量

                //漫反射
                float NoL = max(0.0f, dot(N, L));//法线和光照的点乘
                float diffuse_var = (NoL + 1) / 2;//半兰伯特模型
                half ramp = saturate(smoothstep(0, _ShadowSmooth, diffuse_var - _ShadowRange) + (1 - _ShadowsAdd));

                float3 diffuse = mainLight.color.rgb * lerp(base_shadow_color, base_color, min(ramp, shadow));//漫反射的光

                if (_Clipping > 0)
                {
                    clip(base_color.a - 0.01 - (1 - _ClipScale));
                }

                return float4(diffuse , 1.0f);
            }

            ENDHLSL

            //定义一个使用的语言类型

        }

        Pass
        {
            Name "Outline"
            Tags { "LightMode" = "SRPDefaultUnlit" }
            Cull Front
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma target 2.0
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float _Outline_Width;
            float _Farthest_Distance;
            float _Nearest_Distance;
            float _Offset_Z;
            float4 _OutLineColor;

            struct appdata
            {
                float4 vertex : POSITION;//顶点的数据（位置）
                float3 normal : NORMAL;//汇入法线数据
                float4 tangent : TANGENT;//切线
                float2 uv : TEXCOORD0;//模型的UV坐标

            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)//顶点着色器

            {
                v2f o;//初始化
                //物体，从模型空间->裁剪空间
                float4 objPos = mul(unity_ObjectToWorld, float4(0, 0, 0, 1));//模型空间的(0,0,0)点转换到世界空间
                float Set_Outline_Width = (_Outline_Width * 0.01 * smoothstep(_Farthest_Distance, _Nearest_Distance, distance(objPos.rgb, _WorldSpaceCameraPos))).r;//描边宽度 * 基于摄像机远距进行smoothstep操作避免过宽问题的出现

                //v.2.0.7.5
                float4 _ClipCameraPos = mul(UNITY_MATRIX_VP, float4(_WorldSpaceCameraPos.xyz, 1));//摄像机裁剪空间坐标
                //v.2.0.4.3 baked Normal Texture for Outline
                o.vertex = TransformObjectToHClip(float4(v.vertex.xyz + v.normal * Set_Outline_Width, 1));//基于法线进行外扩
                //v.2.0.7.5
                o.vertex.z = o.vertex.z - 0.01 * _Offset_Z * _ClipCameraPos.z;//裁剪空间的Z轴进行偏移

                return o;//返回值

            }
            half4 frag(v2f i) : SV_TARGET
            {

                return _OutLineColor;
            }


            ENDHLSL
        }

        //【pass：深度】
        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ColorMask 0
            Cull off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }
        pass
        {
            Tags { "LightMode" = "ShadowCaster" }
            ColorMask 0

            HLSLPROGRAM

            #pragma target 3.5
            //是否剔除的shader feature
            #pragma shader_feature _ _SHADOWS_CLIP _SHADOWS_DITHER
            //GPU需要CPU给它的数组数据
            #pragma multi_compile_instancing
            //设置LOD
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"//函数库：主要用于各种的空间变换
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"//从unity中取得我们的光照
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            ENDHLSL
        }
    }


    //【输出结果】

}