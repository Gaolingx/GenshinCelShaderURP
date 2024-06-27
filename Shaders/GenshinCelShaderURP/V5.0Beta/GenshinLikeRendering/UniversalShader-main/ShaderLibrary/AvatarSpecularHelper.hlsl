void metalics(in float3 shadow, in float3 normal, float3 ndoth, float speculartex, float backfacing, inout float3 color)
{
    float shadow_transition = ((bool)shadow.y) ? shadow.z : 0.0f;
    float2 ugh = backfacing ? 1.0f : shadow.y;

    // calculate centered sphere coords for spheremapping
    float2 sphere_uv = mul(normal, (float3x3)UNITY_MATRIX_I_V ).xy;
    sphere_uv.x = sphere_uv.x * _MTMapTileScale; 
    sphere_uv = sphere_uv * 0.5f + 0.5f;  

    // sample sphere map 
    float sphere = _MTMap.Sample(sampler_MTMap, sphere_uv).x;
    sphere = sphere * _MTMapBrightness;
    sphere = saturate(sphere);
    
    // float3 metal_color = sphere.xxx;
    float3 metal_color = lerp(_MTMapDarkColor, _MTMapLightColor, sphere.xxx);
    metal_color = color * metal_color;

    ndoth = max(0.001f, ndoth);
    ndoth = pow(ndoth, _MTShininess) * _MTSpecularScale;
    ndoth = saturate(ndoth);

    float specular_sharp = _MTSharpLayerOffset<ndoth;

    float3 metal_specular = (float3)ndoth;
    if(specular_sharp)
    {
        metal_specular = _MTSharpLayerColor;
    }
    else
    {
        if(_MTUseSpecularRamp)
        {
            metal_specular = _MTSpecularRamp.Sample(sampler_MTSpecularRamp, float2(metal_specular.x, 0.5f)) * _MTSpecularColor;
            metal_specular = metal_specular * speculartex; 
        }
        else
        {  
            metal_specular = metal_specular * _MTSpecularColor;
            metal_specular = metal_specular * speculartex; 
        }    
    }

    float3 metal_shadow = lerp(1.0f, _MTShadowMultiColor, shadow_transition);
    metal_specular = lerp(metal_specular , metal_specular* _MTSpecularAttenInShadow, shadow_transition);
    float3 metal = metal_color + (metal_specular * (float3)0.5f);
    metal = metal * metal_shadow;  
    
    metal = (speculartex > 0.90f) ? metal : color;
    color.xyz = metal;   
}

void specular_color(in float ndoth, in float3 shadow, in float lightmapspec, in float lightmaparea, in float material_id, inout float3 specular)
{
    float2 spec_array[5] =
    {
        float2(_Shininess, _SpecMulti),
        float2(_Shininess2, _SpecMulti2),
        float2(_Shininess3, _SpecMulti3),
        float2(_Shininess4, _SpecMulti4),
        float2(_Shininess5, _SpecMulti5),        
    };
    
    float term = ndoth;
    term = pow(max(ndoth, 0.001f), spec_array[material_id - 1].x);
    float check = term > (-lightmaparea + 1.015);
    specular = term * (_SpecularColor * spec_array[material_id - 1].y) * lightmapspec; 
    specular = lerp((float3)0.0f, specular * (float3)0.5f, check);
}