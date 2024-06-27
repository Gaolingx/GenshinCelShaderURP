#ifndef CUSTOM_AVATAR_GENSHIN_OUTLINE_PASS_INCLUDED
#define CUSTOM_AVATAR_GENSHIN_OUTLINE_PASS_INCLUDED

#include "../ShaderLibrary/AvatarGenshinInput.hlsl"

struct vs_in
{
    float4 vertex  : POSITION;
    float3 normal  : NORMAL;
    float4 tangent : TANGENT;
    float2 uv_0    : TEXCOORD0;
    float2 uv_1    : TEXCOORD1;
    float2 uv_2    : TEXCOORD2;
    float2 uv_3    : TEXCOORD3;
    float4 v_col   : COLOR0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
}; 

struct vs_out
{
    float4 pos       : SV_POSITION;
    float3 normal    : NORMAL; // ws normals
    float4 tangent   : TANGENT; // ws tangents
    float4 uv_a      : TEXCOORD0; // uv0 and uv1
    float4 uv_b      : TEXCOORD1; // uv2 and uv3
    float3 view      : TEXCOORD2; // view vector
    float4 ws_pos    : TEXCOORD3; // world space position
    float4 ss_pos    : TEXCOORD4; // screen space position
    float3 parallax  : TEXCOORD5;
    float4 light_pos : TEXCOORD6;
    float4 v_col     : COLOR0; // vertex color 
    float fogFactor  : TEXCOORD7;
    UNITY_VERTEX_OUTPUT_STEREO
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

vs_out BackFaceOutlineVertex(vs_in v)
{
    VertexPositionInputs vertexPositionInput = GetVertexPositionInputs(v.vertex.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);

    vs_out o = (vs_out)0.0f; // cast all output values to zero to prevent potential errors
    if(_OutlineType ==  0.0f || _EnableOutlineToggle == 0.0f)
    {
        vs_out o = (vs_out)0.0f;
    }
    else
    {
        float3 outline_normal = (_OutlineType == 1.0) ? v.normal : v.tangent.xyz;
        float4 wv_pos = mul(UNITY_MATRIX_MV, v.vertex);
        float3 view = _WorldSpaceCameraPos.xyz - (float3)mul(v.vertex, unity_ObjectToWorld);
        o.view = normalize(view);
        float3 ws_normal = mul(outline_normal, (float3x3)unity_ObjectToWorld);

        outline_normal = mul((float3x3)UNITY_MATRIX_MV, outline_normal);
        outline_normal.z = 0.01f;
        outline_normal.xy = normalize(outline_normal.xyz).xy;

        if(!_FallbackOutlines)
        {
            float fov_matrix = unity_CameraProjection[1].y;

            float fov = 2.414f / fov_matrix; // may need to come back in and change this back to 1.0f
            // can't remember in what vrchat mode this was messing up 

            float depth = -wv_pos.z * fov;

            float2 adjs = (depth <  _OutlineWidthAdjustZs.y) ? _OutlineWidthAdjustZs.xy : _OutlineWidthAdjustZs.yz; 
            float2 scales = (depth <  _OutlineWidthAdjustZs.y) ? _OutlineWidthAdjustScales.xy : _OutlineWidthAdjustScales.yz; 
            
            float z_scale = depth + -(adjs.x);
            float2 z_something = float2((-adjs.x) + adjs.y, (-scales.x) + scales.y);
            z_something.x = max(z_something.x, 0.001f);
            z_scale = z_scale / z_something.x;
            z_scale = saturate(z_scale);
            z_scale = z_scale * z_something.y + scales.x;

            // the next 5 or so lines could be written in one line like the above 
            float outline_scale = (_OutlineWidth * 1.5f) * z_scale;
            outline_scale = outline_scale * 100.0f;
            outline_scale = outline_scale * _Scale;
            outline_scale = outline_scale * 0.414f;
            outline_scale = outline_scale * v.v_col.w;
            if(_UseFaceOutline) outline_scale = outline_scale * _FaceMapTex.SampleLevel(sampler_FaceMapTex, v.uv_0.xy, 0.0f).z;

            float offset_depth = saturate(1.0f - depth);
            float max_offset = lerp(_MaxOutlineZOffset * 0.1, _MaxOutlineZOffset, offset_depth);

            float3 z_offset = (wv_pos.xyz) * (float3)max_offset * (float3)_Scale;
            // the above version of the line causes a floating point division by zero warning in unity even though it didnt used to do that
            // but it probably has something to do with the instancing support v added

            float blue = v.v_col.z + -0.5f; // never trust this fucking line
            // it always breaks things

            o.pos = wv_pos;
            o.pos.xyz = (o.pos.xyz + (z_offset)) + (outline_normal.xyz * outline_scale);
        }
        else
        {
            o.pos = wv_pos;
            o.pos.xyz = o.pos.xyz + (outline_normal.xyz * (_OutlineWidth * 100.0f * _Scale * 0.414f * v.v_col.w));
        }

        o.ws_pos = o.pos;
        
        o.pos = mul(UNITY_MATRIX_P, o.pos);
        o.ss_pos = ComputeScreenPos(o.pos);
        o.normal = normalize(ws_normal);
        o.uv_a = CombineAndTransformDualFaceUV(v.uv_0, v.uv_1, 1);
        o.v_col = v.v_col;
    }

    o.fogFactor = ComputeFogFactor(vertexPositionInput.positionCS.z);

    return o;
}

half4 BackFaceOutlineFragment(vs_out input, FRONT_FACE_TYPE isFrontFace : FRONT_FACE_SEMANTIC) : SV_Target
{
    SetupDualFaceRendering(input.normal, input.uv_a, isFrontFace);

    //根据ilmTexture的五个分组区分出五个不同颜色的描边区域
    half outlineColorMask = SAMPLE_TEXTURE2D(_ilmTex, sampler_ilmTex, input.uv_a.xy).a;
    float material_id = materialID(outlineColorMask);

    float4 outline_colors[5] = 
    {
        _OutlineColor1, _OutlineColor2, _OutlineColor3, _OutlineColor4, _OutlineColor5
    };

    half3 finalOutlineColor = 0;
    #if _OUTLINE_CUSTOM_COLOR_ON
        finalOutlineColor = _CustomOutlineCol.rgb;
    #else
        finalOutlineColor = outline_colors[material_id - 1].xyz;
    #endif
    
    float alpha = _Alpha;

    float4 FinalColor = float4(finalOutlineColor, alpha);
    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaClip);
    FinalColor.rgb = MixFog(FinalColor.rgb, input.fogFactor);

    return float4(FinalColor.rgb, 1);
}

#endif