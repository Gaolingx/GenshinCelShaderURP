using UnityEngine;
using UnityEngine.Rendering.Universal;

namespace Nahida.Rendering
{
    public class PostProcessFeature : ScriptableRendererFeature
    {
        [SerializeField]
        private RenderPassEvent m_RenderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

        [SerializeField]
        private Shader m_Shader;

        private PostProcessPass _postProcessPass;

        public const int BloomIterations = 4;

        public override void Create()
        {
            m_Shader = Shader.Find("URPGenshinPostProcess");
            _postProcessPass = new PostProcessPass(m_RenderPassEvent, m_Shader, BloomIterations);
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            renderer.EnqueuePass(_postProcessPass);
        }

        protected override void Dispose(bool disposing)
        {
            _postProcessPass?.Dispose();
            _postProcessPass = null;
        }
    }
}
