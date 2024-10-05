using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Nahida.Rendering
{
    [Serializable]
    [VolumeComponentMenuForRenderPipeline("Custom/Bloom", typeof(UniversalRenderPipeline))]
    public class BloomVolume : VolumeComponent, IPostProcessComponent
    {
        public VolumeParameter<BloomMode> mode = new VolumeParameter<BloomMode>();

        public MinFloatParameter threshold = new MinFloatParameter(0.7f, 0f);

        public MinFloatParameter intensity = new MinFloatParameter(1.5f, 0f);

        public Vector4Parameter weights = new Vector4Parameter(0.25f * Vector4.one);

        public ColorParameter color = new ColorParameter(Color.white);

        public MinFloatParameter blurRadius = new MinFloatParameter(2f, 0f);

        public ClampedFloatParameter downSampleScale = new ClampedFloatParameter(0.5f, 0.1f, 1f);

        public bool IsActive()
        {
            return mode.value != BloomMode.None;
        }

        public bool IsTileCompatible()
        {
            return false;
        }
    }
}
