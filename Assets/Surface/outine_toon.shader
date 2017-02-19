Shader "Custom/CustomeShadowPattern" {
	Properties {
      _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _Outline ("Outline width", Range (0, 0.1)) = .005
         _MainTex ("Base (RGB)", 2D) = "white" { }
           _Ramp ("ramptex", 2D) = "white" { }
	}
	SubShader {
		Tags { "RenderType"="Opaque" }

        Pass 
        {
            // Pass drawing outline
            Cull Front
        
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
            
            uniform float _Outline;
            uniform float4 _OutlineColor;
            uniform float4 _MainTex_ST;
            uniform sampler2D _MainTex;

            struct v2f 
            {
                float4 pos : POSITION;
                float4 color : COLOR;
            };
            
            v2f vert(appdata_base v) 
            {
                v2f o;
                o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                float3 norm   = mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                float2 offset = TransformViewToProjection(norm.xy);
                o.pos.xy += offset  * _Outline;
                o.color = _OutlineColor;
                return o;
            }
            
            half4 frag(v2f i) :COLOR 
            { 
                return i.color; 
            }
                    
            ENDCG
        }

         Pass
        {   
            // pass drawing object
            
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #pragma vertex vert
            #pragma fragment frag
            
            uniform float4 _MainTex_ST;
            uniform sampler2D _MainTex;
            uniform sampler2D _Ramp;

            struct v2f {
                float2 uv : TEXCOORD0;
                half4 diff : COLOR0; 
                float4 vertex : SV_POSITION;
            };
            
            v2f vert(appdata_base v) {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = v.texcoord;

                // get vertex normal in world space
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                
				// dot product between normal and light direction for
                half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                // factor in the light color

                o.diff.rgb = nl*_LightColor0.rgb;

			//save the normal and pass it by the alpha channel to gragment shader
                o.diff.a=nl; 
 

                return o;
            }
            
            half4 frag(v2f i) :COLOR 
            { 

                half4 col= tex2D (_MainTex, i.uv);
                 half4 rampcol=tex2D(_Ramp,float2(i.diff.a,i.diff.a));
				 //map the texture to the grey part
				 col.rgb=i.diff.rgb* max(col.rgb,rampcol.rgb)*step(0.4, rampcol.rgb);
                 col.a=1;
               
                return col;
            }
                    
            ENDCG
        }
    
	}
	FallBack "Diffuse"
}
