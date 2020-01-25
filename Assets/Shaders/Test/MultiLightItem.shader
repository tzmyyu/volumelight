Shader "Test/MultiLightItem" {
	Properties {
        //颜色
		_Color ("Color", Color) = (1, 1, 1, 1)
        _HColor ("Highlight Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _SColor ("Shadow Color", Color) = (0.8, 0.8, 0.8, 1.0)

        //主纹理
		_MainTex ("Main Texture", 2D) = "white" {}
		
        //梯度
        _ToonSteps ("Steps of Toon", range(1, 9)) = 2
        _RampThreshold ("Ramp Threshold", Range(0.1, 1)) = 0.5
        _RampSmooth ("Ramp Smooth", Range(0, 1)) = 0.1
        
        //高光
		[HDR]
        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
        _SpecSmooth ("Specular Smooth", Range(0, 1)) = 0.1
        _Shininess ("Shininess", Range(0.001, 10)) = 0.2
        _Gloss("Gloss",Range(0.0,1.0))=1.0
        
        // 边缘光
		[HDR]
        _RimColor ("Rim Color", Color) = (0.8, 0.8, 0.8, 0.6)
        _RimThreshold ("Rim Threshold", Range(0, 1)) = 0.5
        _RimSmooth ("Rim Smooth", Range(0, 1)) = 0.1
	}
    SubShader {
		Tags { "RenderType"="Opaque" }
		Pass {
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
		
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#pragma multi_compile_fwdbase
			#pragma multi_compile_instancing

			#pragma enable_d3d11_debug_symbols
		
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			float4 _Color;
            float4 _HColor;
            float4 _SColor;
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float _RampThreshold;
            float _RampSmooth;
            float _ToonSteps;
            
            float _SpecSmooth;
            float _Shininess;
            float _Gloss;
            
            float4 _RimColor;
            float _RimThreshold;
            float _RimSmooth;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			}; 
		
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				SHADOW_COORDS(3)
				UNITY_FOG_COORDS(4)
			};

			UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_INSTANCING_BUFFER_END(Props)

			v2f vert (a2v v) {
				v2f o;

				UNITY_SETUP_INSTANCE_ID(v);
				o.pos = UnityObjectToClipPos( v.vertex);
				o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
				o.worldNormal  = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				TRANSFER_SHADOW(o);
				UNITY_TRANSFER_FOG(o,o.pos);
				
				return o;
			}
			float4 frag(v2f i) : SV_Target { 
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				
                float3 lightColor = _LightColor0.rgb;

                float4 c = tex2D (_MainTex, i.uv);

				float3 albedo = c.rgb * _Color.rgb;


                float Alpha = c.a*_Color.a;
                float Specular = _Shininess;

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                float3 floatDir = normalize(worldLightDir + worldViewDir);

                float3 ndl = max(0,dot(worldNormal, worldLightDir));      //光照系数
                float ndh = max(0, dot(worldNormal, floatDir));          //高光系数
                float ndv = max(0, dot(worldNormal, worldViewDir));     //边缘光系数
                
                //控制光影比例
                float diff = smoothstep(_RampThreshold - ndl, _RampThreshold + ndl, ndl);
                float interval = 1 / _ToonSteps;
                
                //简化颜色，划分色阶
                float level = round(diff * _ToonSteps) / _ToonSteps;
                float ramp ;

                //平滑过渡色阶
                ramp = interval * smoothstep(level - _RampSmooth * interval * 0.5, level + _RampSmooth * interval * 0.5, diff) + level - interval;
                ramp = max(0, ramp);
                ramp *= atten;

                //使用颜色叠加，对高光部分和阴影部分叠色
                _SColor = lerp(_HColor, _SColor, _SColor.a);
                float3 rampColor = lerp(_SColor.rgb, _HColor.rgb, ramp);
                
                
                //高光计算
                float spec = pow(ndh, Specular * 128.0) * _Gloss;
                spec *= atten;
                spec = smoothstep(0.5 - _SpecSmooth * 0.5, 0.5 + _SpecSmooth * 0.5, spec);
                
                //边缘光计算
                float rim = (1.0 - ndv) * ndl;
                rim *= atten;
                rim = smoothstep(_RimThreshold - _RimSmooth * 0.5, _RimThreshold + _RimSmooth * 0.5, rim);
                
                float4 color;
                float3 diffuse = albedo * lightColor * rampColor; //叠加颜色
                float3 specular = _SpecColor.rgb * lightColor * spec;
                float3 rimColor = _RimColor.rgb * lightColor * _RimColor.a * rim;
                
                color.rgb = diffuse + specular + rimColor;
                color.a = Alpha;
				UNITY_APPLY_FOG(i.fogCoord, color);
                return color;
			}
		
			ENDCG
		}
		Pass {
			Tags { "LightMode"="ForwardAdd" }
			Blend One One
		
			CGPROGRAM
			#pragma multi_compile_fwdadd	
			#pragma multi_compile_instancing
			#pragma enable_d3d11_debug_symbols		
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			float4 _Color;
            float4 _HColor;
            float4 _SColor;
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float _RampThreshold;
            float _RampSmooth;
            float _ToonSteps;
            
            float _SpecSmooth;
            float _Shininess;
            float _Gloss;
            
            float4 _RimColor;
            float _RimThreshold;
            float _RimSmooth;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			}; 
		
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				SHADOW_COORDS(3)
			};
			
			v2f vert (a2v v) {
				v2f o;
				
				o.pos = UnityObjectToClipPos( v.vertex);
				o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
				o.worldNormal  = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				TRANSFER_SHADOW(o);
				
				return o;
			}

			UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_INSTANCING_BUFFER_END(Props)

			float4 frag(v2f i) : SV_Target { 
				float3 worldNormal = normalize(i.worldNormal);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif

				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				
                float3 lightColor = _LightColor0.rgb;

                float4 c = tex2D (_MainTex, i.uv);

				float3 albedo = c.rgb * _Color.rgb;

                float Alpha = c.a*_Color.a;
                float Specular = _Shininess;

                #ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					#if defined (POINT)
				        float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #elif defined (SPOT)
				        float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
				        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #else
				        fixed atten = 1.0;
				    #endif
				#endif

                float3 floatDir = normalize(worldLightDir + worldViewDir);

                float3 ndl = max(0,dot(worldNormal, worldLightDir));      
                float ndh = max(0, dot(worldNormal, floatDir));           

                float diff = smoothstep(_RampThreshold - ndl, _RampThreshold + ndl, ndl);
                float interval = 1 / _ToonSteps;
                
                float level = round(diff * _ToonSteps) / _ToonSteps;   

                float ramp = interval * smoothstep(level - _RampSmooth * interval * 0.5, level + _RampSmooth * interval * 0.5, diff) + level - interval;
                ramp = max(0, ramp);  
				ramp *=atten;
                
                float spec = pow(ndh, Specular * 128.0) * _Gloss;
                spec *= atten;
                spec = smoothstep(0.5 - _SpecSmooth * 0.5, 0.5 + _SpecSmooth * 0.5, spec);
                
                float4 color;
                float3 diffuse = albedo * lightColor * ramp;
                float3 specular = _SpecColor.rgb * lightColor * spec;
                
                color.rgb = specular + diffuse;
                color.a = Alpha;
                return color;
			}
			ENDCG
		}
        pass 
		{
			Tags{ "LightMode" = "ShadowCaster"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#pragma enable_d3d11_debug_symbols
			#include "UnityCG.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
			};

			v2f vert(appdata_full v) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			float4 frag(v2f o) :SV_Target
			{
				SHADOW_CASTER_FRAGMENT(o)
			}

			ENDCG
		}
	}
}

