using UnityEngine;

using Const;
using Managers;

namespace PostEffect
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Camera))]
    public class Vignette : PostEffectsBase
    {
        private bool effectEnable;
		private void Awake() 
		{
			effectEnable = false;
			EventManager.AddEvent(EventString.VignetteOpen,effectAwake);
			EventManager.AddEvent(EventString.VignetteClose,effectSleep);
            _shader = Shader.Find("PostEffects/Vignette");
		}
		private void effectAwake()
		{
			effectEnable = true;
		}
		private void effectSleep()
		{
			effectEnable = false;
		}

        #region Public Properties

        [SerializeField, Range(0.0f, 1.0f)]
        float _falloff = 0.5f;

        public float intensity {
            get { return _falloff; }
            set { _falloff = value; }
        }

        #endregion

        #region Private Properties

        public Shader _shader;
        Material _material;

        #endregion

        #region MonoBehaviour Functions
        private void OnEnable() {
            _material = new Material(_shader);
            _material.hideFlags = HideFlags.DontSave;
        }

        void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            if (_material == null || effectEnable == false)
            {
                Graphics.Blit(source, destination);
                return;
            }

            var cam = GetComponent<Camera>();
            _material.SetVector("_Aspect", new Vector2(cam.aspect, 1));
            _material.SetFloat("_Falloff", _falloff);

            Graphics.Blit(source, destination, _material, 0);
        }

        #endregion
    }
}
