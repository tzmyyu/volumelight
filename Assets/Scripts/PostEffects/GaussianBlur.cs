using UnityEngine;
using System.Collections;

using Const;
using Managers;

namespace PostEffect{
	[ExecuteInEditMode]
	public class GaussianBlur : PostEffectsBase {

		public Shader gaussianBlurShader;

		[Range(0, 4)]
		public int iterations = 3;
		
		[Range(0.2f, 3.0f)]
		public float blurSpread = 0.6f;
		
		[Range(1, 8)]
		public int downSample = 2;

		private Material Blurmaterial;
		[HideInInspector]
		public Material material {  
			get {
				Blurmaterial = CheckShaderAndCreateMaterial(gaussianBlurShader, Blurmaterial);
				return Blurmaterial;
			}  
		}

		private bool effectEnable;
		private void Awake() 
		{
			effectEnable = false;
			EventManager.AddEvent(EventString.GaussianBlurOpen,effectAwake);
			EventManager.AddEvent(EventString.GaussianBlurClose,effectSleep);
		}
		private void effectAwake()
		{
			effectEnable = true;
		}
		private void effectSleep()
		{
			effectEnable = false;
		}
		void OnRenderImage (RenderTexture src, RenderTexture dest) {
			if (material != null && effectEnable) {
				int rtW = src.width/downSample;
				int rtH = src.height/downSample;

				RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
				buffer0.filterMode = FilterMode.Bilinear;

				Graphics.Blit(src, buffer0);

				for (int i = 0; i < iterations; i++) {
					material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

					RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

					Graphics.Blit(buffer0, buffer1, material, 0);

					RenderTexture.ReleaseTemporary(buffer0);
					buffer0 = buffer1;
					buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

					Graphics.Blit(buffer0, buffer1, material, 1);

					RenderTexture.ReleaseTemporary(buffer0);
					buffer0 = buffer1;
				}

				Graphics.Blit(buffer0, dest);
				RenderTexture.ReleaseTemporary(buffer0);
			} else {
				Graphics.Blit(src, dest);
			}
		}
	}
}

