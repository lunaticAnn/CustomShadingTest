Shader "Custom/CustomShadingDiff" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_AmbientColor("Ambient Color", Color) = (1,1,1,1)
		_RimColor("Rim Color", Color) =(1,1,1,1)
		_RimPower("Rim Power",Range(0,5))=2.5
		_Saturate("Saturate", Range(0,5)) =2.5
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		//customized rendering model diffuse lighting
		#pragma surface surf BasicDiffuse

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Saturate;
		float4 _AmbientColor;
		float4 _Color;
		float _RimPower;
		float4 _RimColor;

		//custom lighting model of basic diffuse
		//add rim and ambient
		inline float4 LightingBasicDiffuse(SurfaceOutput s, half3 lightDir, half3 viewDir ,half atten) {
			float DiffLight = max(0, dot(s.Normal, lightDir));
			float Rim = 1.0 - saturate(dot(normalize(viewDir), s.Normal));
			float4 col;
			col.rgb = s.Albedo * _LightColor0.rgb * (DiffLight * atten * 2) + _RimColor *pow(Rim, _RimPower);
			col.a = s.Alpha;
			return col;
		}

		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			float4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			c = pow((c + _AmbientColor), _Saturate);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
