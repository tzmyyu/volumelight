using UnityEngine;
using UnityEngine.Serialization;

using Const;
using Managers;

namespace PostEffect
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Camera))]
    public class Bokeh : PostEffectsBase
    {
        private bool effectEnable;
		private void Awake() 
		{
			effectEnable = false;
			EventManager.AddEvent(EventString.BokehOpen,effectAwake);
			EventManager.AddEvent(EventString.BokehClose,effectSleep);

            //避免报错
            _visualize = !!_visualize;
		}
		private void effectAwake()
		{
			effectEnable = true;
		}
		private void effectSleep()
		{
			effectEnable = false;
		}

        #region Editable properties

        [SerializeField, FormerlySerializedAs("_subject")]
        Transform _pointOfFocus;

        public Transform pointOfFocus {
            get { return _pointOfFocus; }
            set { _pointOfFocus = value; }
        }

        [SerializeField, FormerlySerializedAs("_distance")]
        float _focusDistance = 10.0f;

        public float focusDistance {
            get { return _focusDistance; }
            set { _focusDistance = value; }
        }

        [SerializeField]
        float _fNumber = 1.4f;

        public float fNumber {
            get { return _fNumber; }
            set { _fNumber = value; }
        }

        [SerializeField]
        bool _useCameraFov = true;

        public bool useCameraFov {
            get { return _useCameraFov; }
            set { _useCameraFov = value; }
        }

        [SerializeField]
        float _focalLength = 0.05f;

        public float focalLength {
            get { return _focalLength; }
            set { _focalLength = value; }
        }

        public enum KernelSize { Small, Medium, Large, VeryLarge }

        [SerializeField, FormerlySerializedAs("_sampleCount")]
        public KernelSize _kernelSize = KernelSize.Medium;

        public KernelSize kernelSize {
            get { return _kernelSize; }
            set { _kernelSize = value; }
        }

        #endregion

        #if UNITY_EDITOR

        #region Debug properties

        [SerializeField]
        bool _visualize;

        #endregion

        #endif

        #region Private members

        const float kFilmHeight = 0.024f;

        [SerializeField] Shader _shader;
        Material _material;

        Camera TargetCamera {
            get { return GetComponent<Camera>(); }
        }

        float CalculateFocusDistance()
        {
            if (_pointOfFocus == null) return _focusDistance;
            var cam = TargetCamera.transform;
            return Vector3.Dot(_pointOfFocus.position - cam.position, cam.forward);
        }

        float CalculateFocalLength()
        {
            if (!_useCameraFov) return _focalLength;
            var fov = TargetCamera.fieldOfView * Mathf.Deg2Rad;
            return 0.5f * kFilmHeight / Mathf.Tan(0.5f * fov);
        }

        float CalculateMaxCoCRadius(int screenHeight)
        {
            var radiusInPixels = (float)_kernelSize * 4 + 6;

            return Mathf.Min(0.05f, radiusInPixels / screenHeight);
        }

        void SetUpShaderParameters(RenderTexture source)
        {
            var s1 = CalculateFocusDistance();
            var f = CalculateFocalLength();
            s1 = Mathf.Max(s1, f);
            _material.SetFloat("_Distance", s1);

            var coeff = f * f / (_fNumber * (s1 - f) * kFilmHeight * 2);
            _material.SetFloat("_LensCoeff", coeff);

            var maxCoC = CalculateMaxCoCRadius(source.height);
            _material.SetFloat("_MaxCoC", maxCoC);
            _material.SetFloat("_RcpMaxCoC", 1 / maxCoC);

            var rcpAspect = (float)source.height / source.width;
            _material.SetFloat("_RcpAspect", rcpAspect);
        }

        #endregion

        #region MonoBehaviour functions

        void OnEnable()
        {
            var shader = Shader.Find("PostEffects/Bokeh");
            if (!shader.isSupported) return;
            if (!SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.ARGBHalf)) return;

            if (_material == null)
            {
                _material = new Material(shader);
                _material.hideFlags = HideFlags.HideAndDontSave;
            }

            TargetCamera.depthTextureMode |= DepthTextureMode.Depth;
        }

        void OnDestroy()
        {
            if (_material != null)
                if (Application.isPlaying)
                    Destroy(_material);
                else
                    DestroyImmediate(_material);
        }

        void Update()
        {
            if (_focusDistance < 0.01f) _focusDistance = 0.01f;
            if (_fNumber < 0.1f) _fNumber = 0.1f;
        }

        void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            if (_material == null || effectEnable == false)
            {
                Graphics.Blit(source, destination);
                // if (Application.isPlaying) enabled = false;
                return;
            }

            var width = source.width;
            var height = source.height;
            var format = RenderTextureFormat.ARGBHalf;

            SetUpShaderParameters(source);

            #if UNITY_EDITOR

            if (_visualize)
            {
                Graphics.Blit(source, destination, _material, 7);
                return;
            }

            #endif

            var rt1 = RenderTexture.GetTemporary(width / 2, height / 2, 0, format);
            source.filterMode = FilterMode.Point;
            Graphics.Blit(source, rt1, _material, 0);

            var rt2 = RenderTexture.GetTemporary(width / 2, height / 2, 0, format);
            rt1.filterMode = FilterMode.Bilinear;
            Graphics.Blit(rt1, rt2, _material, 1 + (int)_kernelSize);

            rt2.filterMode = FilterMode.Bilinear;
            Graphics.Blit(rt2, rt1, _material, 5);

            _material.SetTexture("_BlurTex", rt1);
            Graphics.Blit(source, destination, _material, 6);

            RenderTexture.ReleaseTemporary(rt1);
            RenderTexture.ReleaseTemporary(rt2);
        }

        #endregion
    }
}
