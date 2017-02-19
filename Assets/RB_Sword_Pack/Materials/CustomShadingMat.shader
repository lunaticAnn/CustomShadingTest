Shader "Custom/CustomShadingMat" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_SpecularColor("Specular Color", Color) =(1,1,1,1)
		_SpecTex("Specular Texture", 2D) = "white" {}
		_SpecPower("Specular Power", Range(0.1,100)) =3
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf CustomSpecular

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0
		
		sampler2D _MainTex;
		sampler2D _SpecTex;
		float4 _Color;
		float4 _SpecularColor;
		float _SpecPower;

		struct Input {
			float2 uv_MainTex;
			float2 uv_SpecTex;
		};


		struct SurfaceCustomOutput {
			fixed3 Albedo;
			fixed3 Normal;
			fixed3 Emission;
			fixed3 SpecularColor;
			half Specular;
			half Gloss;
			fixed Alpha;
		};

		inline fixed4 LightingCustomSpecular(SurfaceCustomOutput s, half3 lightDir, half3 viewDir, fixed atten) {
			
			float DiffLight = dot(s.Normal, lightDir);
			float3 RefVector = normalize(DiffLight * 2 * s.Normal - lightDir);

			float spec = pow(max(0.0, dot(RefVector, viewDir)), _SpecPower) * s.Specular;
			float3 SpecFinal = s.SpecularColor * spec *_SpecularColor.rgb;

			fixed4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * DiffLight) + (_LightColor0 * SpecFinal);
			c.a = s.Alpha;

			return c;
		}

		void surf (Input IN, inout SurfaceCustomOutput o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed4 specMask = tex2D(_SpecTex, IN.uv_SpecTex) * _SpecularColor;

			o.Albedo = c.rgb;
			o.Specular = specMask.r;
			o.SpecularColor = specMask.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
