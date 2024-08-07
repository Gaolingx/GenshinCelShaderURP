#ifndef CUSTOM_AVARTAR_RIMLIGHTING_INCLUDED
#define CUSTOM_AVARTAR_RIMLIGHTING_INCLUDED

#include "../ShaderLibrary/AvatarShaderUtils.hlsl"

///////////////////////////////////////////////////////////////////////////////
//                      Lighting Functions                                   //
///////////////////////////////////////////////////////////////////////////////

bool isVR()
{
    // USING_STEREO_MATRICES
    #if UNITY_SINGLE_PASS_STEREO
        return true;
    #else
        return false;
    #endif
}

// genshin fov range = 30 to 90
float3 camera_position()
{
    #ifdef USING_STEREO_MATRICES
        return lerp(unity_StereoWorldSpaceCameraPos[0], unity_StereoWorldSpaceCameraPos[1], 0.5);
    #endif
    return _WorldSpaceCameraPos;
}

// from: https://github.com/cnlohr/shadertrixx/blob/main/README.md#best-practice-for-getting-depth-of-a-given-pixel-from-the-depth-texture
float GetLinearZFromZDepth_WorksWithMirrors(float zDepthFromMap, float2 screenUV)
{
	#if defined(UNITY_REVERSED_Z)
	zDepthFromMap = 1 - zDepthFromMap;
			
	// When using a mirror, the far plane is whack.  This just checks for it and aborts.
	if( zDepthFromMap >= 1.0 ) return _ProjectionParams.z;
	#endif

	float4 clipPos = float4(screenUV.xy, zDepthFromMap, 1.0);
	clipPos.xyz = 2.0f * clipPos.xyz - 1.0f;
	float4 camPos = mul(unity_CameraInvProjection, clipPos);
	return -camPos.z / camPos.w;
}

float extract_fov()
{
    return 2.0f * atan((1.0f / unity_CameraProjection[1][1]))* (180.0f / 3.14159265f);
}

float fov_range(float old_min, float old_max, float value)
{
    float new_value = (value - old_min) / (old_max - old_min);
    return new_value; 
}

float3 rimlighting(float4 sspos, float3 normal, float4 wspos, float3 light, float material_id, float3 color, float3 view)
{
    // // // instead of relying entirely on the camera depth texture, calculate a camera depth vector like this
    float4 camera_pos =  mul(unity_WorldToCamera, wspos);
    float camera_depth = saturate(1.0f - ((camera_pos.z / camera_pos.w) / 5.0f)); // tuned for vrchat

    float fov = extract_fov();
    fov = clamp(fov, 0, 150);
    float range = fov_range(0, 180, fov);
    float width_depth = camera_depth / range;
    float rim_width = lerp(_RimLightThickness * 0.5f, _RimLightThickness * 0.45f, range) * width_depth;

    if(isVR())
    {
        rim_width = rim_width * 0.66f;
    }
    // screen space uvs
    float2 screen_pos = sspos.xy / sspos.w;

    // camera space normals : 
    float3 vs_normal = mul((float3x3)unity_WorldToCamera, normal);
    vs_normal.z = 0.001f;
    vs_normal = normalize(vs_normal);

    // screen normals reconstructed using screen position
    float cs_ndotv = -dot(-view.xyz, vs_normal) + 1.0f;
    cs_ndotv = saturate(cs_ndotv);
    cs_ndotv = max(cs_ndotv, 0.0099f);
    float cs_ndotv_pow = pow(cs_ndotv, 5.0f);

    // sample original camera depth texture
    float4 depth_og = GetLinearZFromZDepth_WorksWithMirrors(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, screen_pos), screen_pos);

    float3 normal_cs = mul((float3x3)unity_WorldToCamera, normal);
    normal_cs.z = 0.001f;
    normal_cs.xy = normalize(normal_cs.xyz).xy;
    normal_cs.xyz = normal_cs.xyz * (rim_width);
    float2 pos_offset = normal_cs * 0.001f + screen_pos;
    // sample offset depth texture 
    float depth_off = GetLinearZFromZDepth_WorksWithMirrors(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, pos_offset), pos_offset);

    float depth_diff = (-depth_og) + depth_off;

    depth_diff = max(depth_diff, 0.001f);
    depth_diff = pow(depth_diff, 0.04f);
    depth_diff = (depth_diff - 0.8f) * 10.0f;
    depth_diff = saturate(depth_diff);
    
    float rim_depth = depth_diff * -2.0f + 3.0f;
    depth_diff = depth_diff * depth_diff;
    depth_diff = depth_diff * rim_depth;
    rim_depth = (-depth_og) + 2.0f;
    rim_depth = rim_depth * 0.3f + depth_og;
    rim_depth = min(rim_depth, 1.0f);
    depth_diff = depth_diff * rim_depth;

    depth_diff = lerp(depth_diff, 0.0f, saturate(step(depth_diff, _RimThreshold)));

    float4 rim_colors[5] = 
    {
        _RimColor1, _RimColor2, _RimColor3, _RimColor4, _RimColor5
    };

    // get rim light color 
    float3 rim_color = rim_colors[get_index(material_id)] * _RimColor;
    rim_color = rim_color * cs_ndotv;

    depth_diff = depth_diff * _RimLightIntensity;
    depth_diff *= camera_depth;

    float3 rim_light = depth_diff * cs_ndotv_pow;
    rim_light = saturate(rim_light);

    rim_light = saturate(rim_light * rim_color.xyz);
    
    return rim_light;
}

float3 GetRimLight(float4 sspos, float3 normal, float4 wspos, float3 light, float material_id, float3 color, float3 view)
{
    return rimlighting(sspos, normal, wspos, light, material_id, color, view);
}

#endif