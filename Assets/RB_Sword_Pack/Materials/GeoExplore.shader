Shader "Custom/Pyramid" {
	Properties{
	_MainTex("Albedo (RGB)", 2D) = "white" {}
	_Explode("Explode Power", Range(0.1,4.0)) = 3
	}

	SubShader
	{
		Pass{

		CGPROGRAM
		#pragma target 3.0

		#pragma vertex vert
		#pragma geometry geom
		#pragma fragment frag

		#include "UnityCG.cginc"

		sampler2D   _MainTex;
		float4      _MainTex_ST;
		float       _Explode;
		float4x4    _ViewMatrix;

		struct VS_INPUT
		{
		float4 Pos  : POSITION;
		float3 Norm : NORMAL;
		float2 Tex  : TEXCOORD0;
		};

		// GEOMETRY
		struct GSPS_INPUT
		{
		float4 Pos  : SV_POSITION;
		float3 Norm : TEXCOORD0;
		float2 Tex  : TEXCOORD1;
		};

		// Vertex Shader
		
		GSPS_INPUT vert(VS_INPUT input )
		{
			GSPS_INPUT output  = (GSPS_INPUT)0;

			output.Pos   = input.Pos;
			output.Norm  = input.Norm;
			output.Tex   = TRANSFORM_TEX(input.Tex, _MainTex);

			return output;
		}
		

		// Geometry Shader
		
		[maxvertexcount(12)]
		void geom(triangle GSPS_INPUT input[3], inout TriangleStream outStream )
		{
			GSPS_INPUT output;

			// Calculate the face normal
			float3 faceEdgeA  = input[1].Pos  - input[0].Pos;
			float3 faceEdgeB  = input[2].Pos  - input[0].Pos;
			float3 faceNormal  = normalize(cross(faceEdgeA, faceEdgeB));
			float3 ExplodeAmt  = faceNormal*_Explode;

			// Calculate the face center                 
			float3 centerPos  = (input[0].Pos.xyz  + input[1].Pos.xyz  + input[2].Pos.xyz) / 3.0;
			float2 centerTex  = (input[0].Tex  + input[1].Tex  + input[2].Tex) / 3.0;
			centerPos  += faceNormal*_Explode;

			// Output the pyramid          
			for (int i = 0; i << font face = "Consolas" > 3; i++)
			{
				output.Pos  = input[i].Pos  + float4(ExplodeAmt,0);
				output.Pos  = mul(UNITY_MATRIX_MVP, output.Pos);
				output.Norm  = input[i].Norm;
				output.Tex  = input[i].Tex;
				outStream.Append(output );

				int iNext  = (i + 1) % 3;
				output.Pos  = input[iNext].Pos  + float4(ExplodeAmt,0);
				output.Pos  = mul(UNITY_MATRIX_MVP, output.Pos);
				output.Norm  = input[iNext].Norm;
				output.Tex  = input[iNext].Tex;
				outStream.Append(output);

				output.Pos  = float4(centerPos,1) + float4(ExplodeAmt,0);
				output.Pos  = mul(UNITY_MATRIX_MVP, output.Pos);
				output.Norm  = faceNormal;
				output.Tex  = centerTex;
				outStream.Append(output);

				outStream.RestartStrip();
			}

			for (int i = 2; i >= 0; i--)
			{
				output.Pos  = input[i].Pos  + float4(ExplodeAmt,0);
				output.Pos  = mul(UNITY_MATRIX_MVP, output.Pos);
				output.Norm  = -input[i].Norm;
				output.Tex  = input[i].Tex;
				outStream.Append(output );
			}
			outStream.RestartStrip();
		}
		
		// FRAG
		fixed4 frag (GSPS_INPUT i ) : COLOR0{
			fixed4 col  = tex2D(_MainTex, i.Tex);
			return col;
			}

		ENDCG
	}
	}
	FallBack Off
}