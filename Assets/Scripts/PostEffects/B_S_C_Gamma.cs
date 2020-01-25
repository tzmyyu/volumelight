using UnityEngine;
using System.Collections;

using Const;
using Managers;

namespace PostEffect{
	[ExecuteInEditMode]
	public class B_S_C_Gamma : PostEffectsBase {

		public Shader briSatConShader;
		private Material bloomMaterial = null;
		[HideInInspector]
		public Material material {  
			get {
				bloomMaterial = CheckShaderAndCreateMaterial(briSatConShader, bloomMaterial);
				return bloomMaterial;
			}  
		}

		[Range(0.0f, 3.0f)]
		public float brightness = 1.0f;

		[Range(0.0f, 3.0f)]
		public float saturation = 1.0f;

		[Range(0.0f, 3.0f)]
		public float contrast = 1.0f;
		[Range(0.0f, 3.0f)]
		public float gamma = 1.0f;
		
		private bool effectEnable;
		private void Awake() 
		{
			effectEnable = false;
			EventManager.AddEvent(EventString.BSCGammaOpen,effectAwake);
			EventManager.AddEvent(EventString.BSCGammaClose,effectSleep);
		}
		private void effectAwake()
		{
			effectEnable = true;
		}
		private void effectSleep()
		{
			effectEnable = false;
		}

		void OnRenderImage(RenderTexture src, RenderTexture dest) {
			if (material != null && effectEnable) {
				material.SetFloat("_Brightness", brightness);
				material.SetFloat("_Saturation", saturation);
				material.SetFloat("_Contrast", contrast);
				material.SetFloat("_Gamma",gamma);

				Graphics.Blit(src, dest, material);
			} else {
				Graphics.Blit(src, dest);
			}
		}
	}
}

