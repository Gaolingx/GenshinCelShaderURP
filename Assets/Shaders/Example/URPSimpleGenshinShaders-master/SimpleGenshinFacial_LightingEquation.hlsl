// For more information, visit -> https://github.com/NoiRC256/UnityURPToonLitShaderExample
// Original shader -> https://github.com/ColinLeung-NiloCat/UnityURPToonLitShaderExample

// This file is intented for you to edit and experiment with different lighting equation.
// Add or edit whatever code you want here

// #ifndef XXX + #define XXX + #endif is a safe guard best practice in almost every .hlsl, 
// doing this can make sure your .hlsl's user can include this .hlsl anywhere anytime without producing any multi include conflict
#ifndef SimpleGenshinFacial_LightingEquation_Include
#define SimpleGenshinFacial_LightingEquation_Include

half3 InternalShadeGI(ToonSurfaceData surfaceData, ToonLightingData lightingData)
{
    // hide 3D feeling by ignoring all detail SH
    // SH 1 (only use this)
    // SH 234 (ignored)
    // SH 56789 (ignored)
    // we just want to tint some average envi color only
    half3 averageSH = SampleSH(0);

    // occlusion
    // separated control for indirect occlusion
    half indirectOcclusion = lerp(1, surfaceData.occlusion, _OcclusionIndirectStrength);
    half3 indirectLight = averageSH * (_IndirectLightMultiplier * indirectOcclusion);
    return max(indirectLight, _IndirectLightMinColor); // can prevent completely black if lightprobe was not baked
}

half3 InternalShadeMainLight(ToonSurfaceData surfaceData, ToonLightingData lightingData, Light light, bool isAdditionalLight)
{
    half3 L = light.direction;

    // Get forward and right directions from rotation matrix.
    float3 Forward = unity_ObjectToWorld._m02_m12_m22;
    float3 Right = unity_ObjectToWorld._m00_m10_m20;

    // Get xz plane dot products with light direction.
    float FdotL = dot(normalize(Forward.xz), normalize(L.xz));
    float RdotL = dot(normalize(Right.xz), normalize(L.xz));

    // Choose original lightmapÅ L (light from left) or flipped lightmap R (light from right).
    float LightMap = lerp(surfaceData._lightMapR.r, surfaceData._lightMapL.r, step(RdotL, 0));

    // Calculate result.
    float litOrShadow = step((-FdotL + 1) / 2, LightMap);

    return light.color * lerp(litOrShadow, 1, step(surfaceData._useLightMap, 0));
}

half3 InternalShadeAdditionalLights(ToonSurfaceData surfaceData,
    ToonLightingData lightingData, Light light, bool isAdditionalLight)
{
    return 0; //write your own equation here ! (see ShadeSingleLightDefaultMethod(...))
}

half3 InternalShadeEmission(ToonSurfaceData surfaceData, ToonLightingData lightingData, Light light, bool isAdditionalLight)
{
    half3 N = lightingData.normalWS;
    half3 L = light.direction;
    half3 V = lightingData.viewDirectionWS;
    half3 H = normalize(L + V);

    half3 shadowColor = surfaceData._shadowColor;

    half3 emission = surfaceData.emission;
    half NoL = dot(N, L);

    half3 emissionResult = lerp(emission, emission * surfaceData.albedo, _EmissionMulByBaseColor); // optional mul albedo
    return emissionResult;
}

// Composite all shading results.
half3 InternalCompositeLightResults(half3 indirectResult, half3 mainLightResult, half3 additionalLightSumResult, half3 emissionResult,
    ToonSurfaceData surfaceData, ToonLightingData lightingData, Light light)
{
    half3 shadowColor = light.color * lerp(1 * surfaceData._shadowColor, 1, mainLightResult);
    half3 rawLightSum = max(indirectResult * shadowColor, mainLightResult + additionalLightSumResult); // pick the highest between indirect and direct light
    half lightLuminance = Luminance(rawLightSum);

    half3 finalLightMulResult = rawLightSum / max(1, lightLuminance / max(1, log(lightLuminance))); // allow controlled over bright using log
    return surfaceData.albedo * finalLightMulResult + emissionResult;
}


// We split lighting functions into: 
// - indirect
// - main light 
// - additional lights (point lights/spot lights)
// - emission

half3 ShadeGI(ToonSurfaceData surfaceData, ToonLightingData lightingData)
{
    return InternalShadeGI(surfaceData, lightingData);
}

half3 ShadeMainLight(ToonSurfaceData surfaceData, ToonLightingData lightingData, Light light)
{
    return InternalShadeMainLight(surfaceData, lightingData, light, false);
}

half3 ShadeAdditionalLight(ToonSurfaceData surfaceData, ToonLightingData lightingData, Light light)
{
    return InternalShadeAdditionalLights(surfaceData, lightingData, light, true);
}

half3 ShadeEmission(ToonSurfaceData surfaceData, ToonLightingData lightingData, Light light)
{
    return InternalShadeEmission(surfaceData, lightingData, light, false);
}

half3 CompositeAllLightResults(half3 indirectResult, half3 mainLightResult, half3 additionalLightSumResult, half3 emissionResult,
    ToonSurfaceData surfaceData, ToonLightingData lightingData, Light light)
{
    return InternalCompositeLightResults(indirectResult, mainLightResult, additionalLightSumResult, emissionResult, surfaceData, lightingData, light);
}

#endif
