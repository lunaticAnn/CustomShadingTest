Shader "Custom/CustomShadingRamp" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_RampTex("RampTexture", 2D) = "white"{}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf CustomRamp

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _RampTex;

		struct Input {
			float2 uv_MainTex;
		};

        //use half lambert model
		inline float4 LightingCustomRamp(SurfaceOutput s, half3 lightDir, half3 viewDir,half atten) {
			float Lambert = max(0, dot(s.Normal, lightDir));
			float Rim = dot(s.Normal, viewDir);
			float4 col;

			float3 ramp = tex2D(_RampTex, float2(Lambert, Rim)).rgb;
			col.rgb = s.Albedo * _LightColor0.rgb * ramp ;
			col.a = s.Alpha;
			return col;
		}

		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			float4 c = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
