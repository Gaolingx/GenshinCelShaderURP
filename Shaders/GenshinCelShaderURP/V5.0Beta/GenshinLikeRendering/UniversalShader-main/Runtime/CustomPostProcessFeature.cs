using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CustomPostProcessFeature : ScriptableRendererFeature
{

    CustomBloomPass m_CustomBloomPass;

    /// <inheritdoc/>
    public override void Create()
    {
        m_CustomBloomPass = new CustomBloomPass();

        // Configures where the render pass should be injected.
        m_CustomBloomPass.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        m_CustomBloomPass.SetUp(renderer.cameraColorTarget);
        renderer.EnqueuePass(m_CustomBloomPass);
    }
}


