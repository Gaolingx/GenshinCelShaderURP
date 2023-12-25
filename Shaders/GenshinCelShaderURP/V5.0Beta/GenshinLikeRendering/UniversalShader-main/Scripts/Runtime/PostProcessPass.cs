using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Nahida.Rendering
{
    public class PostProcessPass : ScriptableRenderPass
    {
        private Material _material;

        private RTHandle[] _bloomBufferA;

        private RTHandle[] _bloomBufferB;

        private bool _useBloom;

        private int _iterations;

        private float _downSampleScale;

        public PostProcessPass(RenderPassEvent renderPassEvent, Shader shader, int iterations)
        {
            _material = CoreUtils.CreateEngineMaterial(shader);
            _iterations = iterations;
            _bloomBufferA = new RTHandle[_iterations];
            _bloomBufferB = new RTHandle[_iterations];

            base.profilingSampler = new ProfilingSampler(nameof(PostProcessPass));
            base.renderPassEvent = renderPassEvent;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var cameraType = renderingData.cameraData.cameraType;
            if (cameraType == CameraType.Preview || cameraType == CameraType.Reflection)
            {
                return;
            }

            var stack = VolumeManager.instance.stack;
            var bloomVolume = stack.GetComponent<BloomVolume>();
            var colorGradingVolume = stack.GetComponent<ColorGradingVolume>();

            if (!bloomVolume.IsActive() && !colorGradingVolume.IsActive())
            {
                return;
            }

            _useBloom = bloomVolume.IsActive();
            _downSampleScale = bloomVolume.downSampleScale.value;
            SetupBuffer(ref renderingData);
            SetupMaterial(bloomVolume, colorGradingVolume, ref renderingData);

            var command = CommandBufferPool.Get();
            Render(command, ref renderingData);
            context.ExecuteCommandBuffer(command);
            CommandBufferPool.Release(command);
        }

        private void SetupBuffer(ref RenderingData renderingData)
        {
            var cameraDescriptor = renderingData.cameraData.cameraTargetDescriptor;
            var descriptor = new RenderTextureDescriptor(cameraDescriptor.width, cameraDescriptor.height, cameraDescriptor.graphicsFormat, 0, 0);

            if (_useBloom)
            {
                descriptor.width = (int)Math.Round(descriptor.width * _downSampleScale);
                descriptor.height = (int)Math.Round(descriptor.height * _downSampleScale);
                for (int i = 0; i < _iterations; i++)
                {
                    RenderingUtils.ReAllocateIfNeeded(ref _bloomBufferA[i], descriptor, FilterMode.Bilinear, name: $"_BloomBufferA_{i}");
                    RenderingUtils.ReAllocateIfNeeded(ref _bloomBufferB[i], descriptor, FilterMode.Bilinear, name: $"_BloomBufferB_{i}");
                    descriptor.width = Math.Max(descriptor.width / 2, 1);
                    descriptor.height = Math.Max(descriptor.height / 2, 1);
                }
            }
        }

        private void SetupMaterial(BloomVolume bloomVolume, ColorGradingVolume colorGradingVolume, ref RenderingData renderingData)
        {
            float screenFactor = renderingData.cameraData.cameraTargetDescriptor.height / 1080f;

            CoreUtils.SetKeyword(_material, "_BLOOM_COLOR", bloomVolume.mode.value == BloomMode.Color);
            CoreUtils.SetKeyword(_material, "_BLOOM_BRIGHTNESS", bloomVolume.mode.value == BloomMode.Brightness);
            CoreUtils.SetKeyword(_material, "_TONEMAPPING", colorGradingVolume.useTonemapping.value);
            _material.SetFloat("_Exposure", colorGradingVolume.exposure.value);
            _material.SetFloat("_Contrast", 1f + colorGradingVolume.contrast.value / 100f);
            _material.SetFloat("_Saturation", 1f + colorGradingVolume.saturation.value / 100f);

            if (_useBloom)
            {
                _material.SetFloat("_BloomThreshold", bloomVolume.threshold.value);
                _material.SetFloat("_BloomIntensity", bloomVolume.intensity.value);
                _material.SetVector("_BloomWeights", bloomVolume.weights.value);
                _material.SetColor("_BloomColor", bloomVolume.color.value);
                _material.SetFloat("_BlurRadius", bloomVolume.blurRadius.value * _downSampleScale * screenFactor);
            }
        }

        private void Render(CommandBuffer commandBuffer, ref RenderingData renderingData)
        {
            var source = renderingData.cameraData.renderer.cameraColorTargetHandle;

            using (new ProfilingScope(commandBuffer, profilingSampler))
            {
                if (_useBloom)
                {
                    RTHandle[] bufferA = _bloomBufferA, bufferB = _bloomBufferB;

                    Blit(commandBuffer, source, bufferA[0], Pass.BloomPrefilter);

                    Blit(commandBuffer, bufferA[0], bufferB[0], Pass.BloomHorizontalBlur1x);
                    Blit(commandBuffer, bufferB[0], bufferA[0], Pass.BloomVerticalBlur1x);

                    for (int i = 1; i < _iterations; i++)
                    {
                        Blit(commandBuffer, bufferA[i - 1], bufferB[i], Pass.BloomHorizontalBlur2x);
                        Blit(commandBuffer, bufferB[i], bufferA[i], Pass.BloomVerticalBlur1x);
                    }

                    commandBuffer.SetGlobalTexture("_BloomTextureA", bufferA[0]);
                    commandBuffer.SetGlobalTexture("_BloomTextureB", bufferA[1]);
                    commandBuffer.SetGlobalTexture("_BloomTextureC", bufferA[2]);
                    commandBuffer.SetGlobalTexture("_BloomTextureD", bufferA[3]);

                    Blit(commandBuffer, bufferB[0], bufferB[0], Pass.BloomUpsample);

                    commandBuffer.SetGlobalTexture("_BloomTextureA", bufferB[0]);
                }

                base.Blit(commandBuffer, ref renderingData, _material, (int)Pass.ColorGrading);
            }
        }

        private void Blit(CommandBuffer commandBuffer, RTHandle source, RTHandle destination, Pass pass)
        {
            const RenderBufferLoadAction Load = RenderBufferLoadAction.DontCare;
            const RenderBufferStoreAction Save = RenderBufferStoreAction.Store;
            Blitter.BlitCameraTexture(commandBuffer, source, destination, Load, Save, _material, (int)pass);
        }

        public void Dispose()
        {
            for (int i = 0; i < _iterations; i++)
            {
                _bloomBufferA[i]?.Release();
                _bloomBufferB[i]?.Release();
            }
            CoreUtils.Destroy(_material);
        }

        public enum Pass
        {
            Blit,
            BloomPrefilter,
            BloomHorizontalBlur1x,
            BloomHorizontalBlur2x,
            BloomVerticalBlur1x,
            BloomVerticalBlur2x,
            BloomUpsample,
            ColorGrading
        }
    }
}
