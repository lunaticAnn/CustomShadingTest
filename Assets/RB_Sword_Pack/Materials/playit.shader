Shader "Custom/playit" {
   Properties {
      _MainTex ("Texture", 2D) = "white" {}
      _Ramp("Ramptexture",2D) ="white"{}
       _Crange("Color Range", Range (0, 1)) = .05
    }


    SubShader {
      Tags { "RenderType" = "Opaque" }

      CGPROGRAM
      #pragma surface surf Ramp

      sampler2D _Ramp;
   
        half4 LightingRamp (SurfaceOutput s, half3 lightDir, half atten) {
        half NdotL = dot (s.Normal, lightDir);
        half diff = NdotL*0.8+0.2;
        half3 ramp = tex2D (_Ramp, float2(diff,diff)).rgb;
        half4 c;
        c.rgb = s.Albedo * _LightColor0.rgb * ramp * atten;
        c.a = s.Alpha;
        return c;
       }


       struct Input {
          float2 uv_MainTex;
      };
      half _Crange;
      sampler2D _MainTex;

      void surf (Input IN, inout SurfaceOutput o) {
      float rg=tex2D (_MainTex, IN.uv_MainTex).r;
      rg=0.5*step(rg,_Crange)+0.5;
          float3 c=float3(rg,rg,rg);
          o.Albedo = c;
      }
      ENDCG
      }
	
	FallBack "Diffuse"
}
