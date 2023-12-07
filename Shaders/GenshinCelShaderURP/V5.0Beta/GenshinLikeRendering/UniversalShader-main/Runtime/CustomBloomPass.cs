using System;
using System.Diagnostics;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.UIElements;
using Debug = UnityEngine.Debug;

public class CustomBloomPass : ScriptableRenderPass
{
    private CustomBloomParams _params;
    private RenderTargetIdentifier _finalRenderTarget;
    private Material _material;
    private Shader _shader;
    
    private static readonly string BufferName = "Bloom Pass";
    private static readonly int GaussianBlurTempTargetID = Shader.PropertyToID("_GaussianBlurTempRenderTarget");
    //Bloom Parameters
        //Area Extraction
    private static readonly int BloomThresholdID = Shader.PropertyToID("_ExtractThreshold");
        //Down-Sample Gaussian-Blur
    private static readonly int BlurSizeID = Shader.PropertyToID("_BlurSize");
        //Up-Sample Mipmaps Blending 
    private static readonly int BloomScatterID = Shader.PropertyToID("_BloomScatter");
    private static readonly int BloomMipIntensityID = Shader.PropertyToID("_BloomMipIntensity");
        //Final Blending
    private static readonly int BloomIntensityID = Shader.PropertyToID("_BloomIntensity");
    private static readonly int BloomColorTintID = Shader.PropertyToID("_BloomColorTint");
    
    private int[] _bloomRTArray;

    private static readonly float BaseResolution = 1920f;
    private float _resolutionScale;
    public CustomBloomPass()
    {
        _shader = Shader.Find("QiuHanMMDRender/CustomPostProcess/Bloom");
        if (_shader == null)
        {
            Debug.LogError("'QiuHanMMDRender/CustomPostProcess' Shader Not Found!");
            return;
        }
        _material = CoreUtils.CreateEngineMaterial(_shader);
    }
    
    public void SetUp(in RenderTargetIdentifier finalRenderTarget)
    {
        _finalRenderTarget = finalRenderTarget;
    }

  public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (!GetParamsAndCheckValidation(ref renderingData))
        {
            // Debug.Log("Custom Bloom Failed");
            return;
        }

        var cmd = CommandBufferPool.Get(BufferName);
        Render(cmd, ref renderingData);
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }
  
    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        ReleaseRenderTextures(cmd);
    }

    private bool GetParamsAndCheckValidation(ref RenderingData renderingData)
    {
        if (_material == null)
        {
            Debug.LogError("Material Not Created!");
            return false;
        }
        if (!renderingData.cameraData.postProcessEnabled)
        {
            // Debug.Log("Camera's Post Process is Not Enable");
            return false;
        }
        
        var stack = VolumeManager.instance.stack;
        _params = stack.GetComponent<CustomBloomParams>();
        
        if (_params == null)
        {
            Debug.LogError("Bloom Params Not Find");
            return false;
        }
        if (!_params.IsActive())
        {
            // Debug.Log("Custom Bloom Not Enable");
            return false;
        }

        _resolutionScale = Math.Max(Screen.width, Screen.height) / BaseResolution;
        
        return true;
    }

    private void Render(CommandBuffer cmd, ref RenderingData renderingData)
    {
        ref var cameraData = ref renderingData.cameraData;
        RenderTargetIdentifier source = _finalRenderTarget;
        var w = cameraData.camera.scaledPixelWidth;
        var h = cameraData.camera.scaledPixelHeight;

        CreateRenderTextures(cmd, w, h);
        
        BloomAreaExtractionPassRender(cmd, source, _bloomRTArray[0]);
        BloomPassRender(cmd, source, _finalRenderTarget);
    }

    private void CreateRenderTextures(CommandBuffer cmd, int w, int h)
    {
        cmd.GetTemporaryRT(GaussianBlurTempTargetID, 
            w, 
            h, 
            0, FilterMode.Bilinear, RenderTextureFormat.Default);
        _bloomRTArray = new int[_params.gaussianBlurIterations.value + 1];
        _bloomRTArray[0] = Shader.PropertyToID("_BloomRT_0");
        cmd.GetTemporaryRT(_bloomRTArray[0], w,h,0, FilterMode.Bilinear,RenderTextureFormat.Default);
        int downSize = _params.basicDownSample.value;
        for (int i = 1; i < _params.gaussianBlurIterations.value + 1; i++)
        {
            int rtWidth = w / downSize;
            int rtHeight = h / downSize;
            int propertyID = Shader.PropertyToID("_BloomRT_" + i);
            
            _bloomRTArray[i] = propertyID;
            cmd.GetTemporaryRT(propertyID, rtWidth, rtHeight, 0, FilterMode.Bilinear, RenderTextureFormat.Default);
            
            cmd.SetRenderTarget(_bloomRTArray[i]);
            cmd.ClearRenderTarget(false, true, Color.clear);
            
            downSize *= 2;
        }
    }

    private void ReleaseRenderTextures(CommandBuffer cmd)
    {
        cmd.ReleaseTemporaryRT(GaussianBlurTempTargetID);
        for (int i = 0; i < _params.gaussianBlurIterations.value + 1; i++)
        {
            cmd.ReleaseTemporaryRT(Shader.PropertyToID("_BloomRT_"+i));
        }
    }

    private void BloomAreaExtractionPassRender(CommandBuffer cmd, RenderTargetIdentifier source, RenderTargetIdentifier target)
    {
        _material.SetFloat(BloomThresholdID, _params.bloomThreshold.value);
        if (_params.bloomAreaExtractBy.value == CustomBloomParams.BloomAreaExtractionMode.Luminance)
        {
            _material.EnableKeyword("_EXTRACTBYLUMINANCE");
            _material.DisableKeyword("_EXTRACTBYCOLOR");
        }
        else if (_params.bloomAreaExtractBy.value == CustomBloomParams.BloomAreaExtractionMode.Color)
        {
            _material.EnableKeyword("_EXTRACTBYCOLOR");
            _material.DisableKeyword("_EXTRACTBYLUMINANCE");
        }
        else
        {
            _material.DisableKeyword("_EXTRACTBYCOLOR");
            _material.DisableKeyword("_EXTRACTBYLUMINANCE");
        }
        cmd.Blit(source, target, _material, 0);
    }

    private void GaussianBlurPassRender(CommandBuffer cmd, RenderTargetIdentifier source, RenderTargetIdentifier target)
    {
        cmd.Blit(source, GaussianBlurTempTargetID, _material, 1);
        cmd.Blit(GaussianBlurTempTargetID, target, _material, 2);
    }
    
    private void BloomPassRender(CommandBuffer cmd, RenderTargetIdentifier source, RenderTargetIdentifier target)
    {
        //Down-Sample
        _material.SetFloat(BlurSizeID, _params.gaussianBlurSize.value * _resolutionScale);
        for (int i = 1; i < _params.gaussianBlurIterations.value + 1; i++)
        {
            GaussianBlurPassRender(cmd, _bloomRTArray[i - 1], _bloomRTArray[i]);
        }
        //Up-Sample
            //Mipmaps Blend
        _material.SetFloat(BloomScatterID, _params.bloomScatter.value);
        _material.SetFloat(Shader.PropertyToID("_MipsCounts"), _params.gaussianBlurIterations.value);
        _material.SetVector(BloomMipIntensityID, new Vector4(_params.mipIntensity1.value,
            _params.mipIntensity2.value, _params.mipIntensity3.value, _params.mipIntensity4.value));
        cmd.Blit(source, _bloomRTArray[0]);
        cmd.Blit(source, _bloomRTArray[1], _material, 3);
            //Final Blend
        _material.SetFloat(BlurSizeID, _params.gaussianBlurSize.value * _resolutionScale * _params.finalGaussianBlurBlurSizeScale.value);
        GaussianBlurPassRender(cmd, _bloomRTArray[1], _bloomRTArray[1]);
        _material.SetFloat(BloomIntensityID, _params.bloomIntensity.value);
        _material.SetColor(BloomColorTintID, _params.bloomColorTint.value);
        cmd.Blit(_bloomRTArray[0],target, _material, 4);
    }
}
