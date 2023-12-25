using System;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Nahida.Rendering
{
    [Serializable]
    [VolumeComponentMenuForRenderPipeline("Custom/ColorGrading", typeof(UniversalRenderPipeline))]
    public class ColorGradingVolume : VolumeComponent, IPostProcessComponent
    {
        public BoolParameter useTonemapping = new BoolParameter(false);

        public MinFloatParameter exposure = new MinFloatParameter(1f, 0f);

        public ClampedFloatParameter contrast = new ClampedFloatParameter(0f, -100f, 100f);

        public ClampedFloatParameter saturation = new ClampedFloatParameter(0f, -100f, 100f);

        public bool IsActive()
        {
            return useTonemapping.value || exposure.value != 1f || contrast.value != 0f || saturation.value != 0f;
        }

        public bool IsTileCompatible()
        {
            return false;
        }
    }
}
