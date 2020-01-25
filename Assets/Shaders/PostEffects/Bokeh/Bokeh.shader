Shader "PostEffects/Bokeh"
{
    Properties
    {
        _MainTex("", 2D) = ""{}
        _BlurTex("", 2D) = ""{}
    }
    Subshader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag_Prefilter
            #pragma multi_compile _ UNITY_COLORSPACE_GAMMA
            #define PREFILTER_LUMA_WEIGHT
            #include "Prefilter.cginc"
            ENDCG
        }
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag_Blur
            #define KERNEL_SMALL
            #include "DiskBlur.cginc"
            ENDCG
        }
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag_Blur
            #define KERNEL_MEDIUM
            #include "DiskBlur.cginc"
            ENDCG
        }
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag_Blur
            #define KERNEL_LARGE
            #include "DiskBlur.cginc"
            ENDCG
        }
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag_Blur
            #define KERNEL_VERYLARGE
            #include "DiskBlur.cginc"
            ENDCG
        }
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag_Blur2
            #include "Composition.cginc"
            ENDCG
        }
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma multi_compile _ UNITY_COLORSPACE_GAMMA
            #pragma fragment frag_Composition
            #include "Composition.cginc"
            ENDCG
        }
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag_CoC
            #include "Debug.cginc"
            ENDCG
        }
    }
}
