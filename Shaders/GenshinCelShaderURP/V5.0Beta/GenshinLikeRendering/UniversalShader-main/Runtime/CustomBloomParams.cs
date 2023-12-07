using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[Serializable, VolumeComponentMenuForRenderPipeline("Custom Post-processing/Bloom", typeof(UniversalRenderPipeline))]
public class CustomBloomParams : VolumeComponent, IPostProcessComponent
{
    //Activity Controller
    public bool IsActive() => useCustomBloom.value;
    public bool IsTileCompatible() => false;


    [Serializable]
    public sealed class BloomAreaExtractionModeParameter : VolumeParameter<BloomAreaExtractionMode> {} 
    public enum BloomAreaExtractionMode 
    {
        Luminance,
        Color
    }

    //Parameters
    public BoolParameter useCustomBloom = new BoolParameter(false);

    [Header("Bloom Perception")]
    public BloomAreaExtractionModeParameter bloomAreaExtractBy = new BloomAreaExtractionModeParameter();
    public ClampedFloatParameter bloomThreshold = new ClampedFloatParameter(0.0f, 0.0f, 1.0f);
    public ClampedFloatParameter bloomIntensity = new ClampedFloatParameter(1.0f, 0.0f, 2.0f);
    public ClampedFloatParameter bloomScatter = new ClampedFloatParameter(0.5f, 0.0f, 1.0f);
    public ColorParameter bloomColorTint = new ColorParameter(Color.white);

    [Header("Bloom Quality")] 
    public ClampedIntParameter gaussianBlurIterations = new ClampedIntParameter(1, 1, 4);
    public ClampedFloatParameter gaussianBlurSize = new ClampedFloatParameter(0.6f, 0.2f, 3.0f);
    public ClampedIntParameter basicDownSample = new ClampedIntParameter(1, 1, 4);
    public ClampedFloatParameter finalGaussianBlurBlurSizeScale = new ClampedFloatParameter(4, 1, 10);

    [Header("Bloom Details")] 
    public ClampedFloatParameter mipIntensity1 = new ClampedFloatParameter(0.75f, 0.5f, 1.0f);
    public ClampedFloatParameter mipIntensity2 = new ClampedFloatParameter(0.85f, 0.5f, 1.0f);
    public ClampedFloatParameter mipIntensity3 = new ClampedFloatParameter(0.95f, 0.5f, 1.0f);
    public ClampedFloatParameter mipIntensity4 = new ClampedFloatParameter(1.0f, 0.5f, 1.0f);
}