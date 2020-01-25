using UnityEngine;
using System.Collections;

using Const;
using Managers;

namespace PostEffect{
	[ExecuteInEditMode]
	public class Bloom : PostEffectsBase {
		public Shader bloomShader;
		private Material bloomMaterial = null;
		[HideInInspector]
		public Material material {  
			get {
				bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
				return bloomMaterial;
			}  
		}

		[Range(0, 8)]
		public int iterations = 3;
		
		[Range(0.2f, 3.0f)]
		public float blurSpread = 0.6f;

		[Range(1, 8)]
		public int downSample = 2;

		[Range(0.0f, 4.0f)]
		public float luminanceThreshold = 0.6f;

		private bool effectEnable;
		private void Awake() 
		{
			effectEnable = false;
			EventManager.AddEvent(EventString.BloomOpen,effectAwake);
			EventManager.AddEvent(EventString.BloomClose,effectSleep);
		}
		private void effectAwake()
		{
			effectEnable = true;
		}
		private void effectSleep()
		{
			effectEnable = false;
		}
		
		[ImageEffectOpaque]
		void OnRenderImage (RenderTexture src, RenderTexture dest) {
			if (material != null && effectEnable) {
				material.SetFloat("_LuminanceThreshold", luminanceThreshold);

				int rtW = src.width/downSample;
				int rtH = src.height/downSample;
				
				RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
				buffer0.filterMode = FilterMode.Bilinear;

				Graphics.Blit(src, buffer0, material, 0);
				
				for (int i = 0; i < iterations; i++) {
					material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
					
					RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
					
					Graphics.Blit(buffer0, buffer1, material, 1);
					
					RenderTexture.ReleaseTemporary(buffer0);
					buffer0 = buffer1;
					buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
					
					Graphics.Blit(buffer0, buffer1, material, 2);
					
					RenderTexture.ReleaseTemporary(buffer0);
					buffer0 = buffer1;
				}

				material.SetTexture ("_Bloom", buffer0);  
				Graphics.Blit (src, dest, material, 3);  

				RenderTexture.ReleaseTemporary(buffer0);
			} else {
				Graphics.Blit(src, dest);
			}
		}
	}
}

