﻿//https://github.com/unitycoder/DoomStyleBillboardTest

Shader "UnityCoder/DoomSprite3" 
{

	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Frames ("Frames", Float) = 8
	}

	SubShader 
	{
    	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}
    	
    	ZWrite Off
    	Blend SrcAlpha OneMinusSrcAlpha		
	    
		Pass 
		{
	        CGPROGRAM

		    #pragma vertex vert
		    #pragma fragment frag
			#define PI 3.1415926535897932384626433832795
			#define RAD2DEG 57.2957795131
		    #define SINGLEFRAMEANGLE (360/_Frames)
		    #define UVOFFSETX (1/_Frames)
		    #include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;

            struct appdata {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
            };

            float4x4 _CameraToWorld;
            float _Frames;

            float atan2Approximation(float y, float x) // http://http.developer.nvidia.com/Cg/atan2.html
			{
				float t0, t1, t2, t3, t4;
				t3 = abs(x);
				t1 = abs(y);
				t0 = max(t3, t1);
				t1 = min(t3, t1);
				t3 = float(1) / t0;
				t3 = t1 * t3;
				t4 = t3 * t3;
				t0 =         - 0.013480470;
				t0 = t0 * t4 + 0.057477314;
				t0 = t0 * t4 - 0.121239071;
				t0 = t0 * t4 + 0.195635925;
				t0 = t0 * t4 - 0.332994597;
				t0 = t0 * t4 + 0.999995630;
				t3 = t0 * t3;
				t3 = (abs(y) > abs(x)) ? 1.570796327 - t3 : t3;
				t3 = (x < 0) ?  PI - t3 : t3;
				t3 = (y < 0) ? -t3 : t3;
				return t3;
			}

            v2f vert (appdata v) 
            {
                v2f o;
                o.pos = mul (UNITY_MATRIX_MVP, v.vertex);

                // object world position
   				float3 objWorldPos=float3(_Object2World._m03,_Object2World._m13,_Object2World._m23);

				// get angle between object and camera
				float3 fromCameraToObject = normalize(objWorldPos - _WorldSpaceCameraPos.xyz);
				float angle = atan2Approximation(fromCameraToObject.z, fromCameraToObject.x)*RAD2DEG+180;

				// get current tilesheet frame and feed it to UV
				int index = angle/SINGLEFRAMEANGLE;
                o.uv = float2(v.texcoord.x*UVOFFSETX+UVOFFSETX*index,v.texcoord.y);
                          
               // billboard mesh towards camera
  				float3 vpos=mul((float3x3)_Object2World, v.vertex.xyz);
 				float4 worldCoord=float4(_Object2World._m03,_Object2World._m13,_Object2World._m23,1);
				float4 viewPos=mul(UNITY_MATRIX_V,worldCoord)+float4(vpos,0);
				float4 outPos=mul(UNITY_MATRIX_P,viewPos);
				
				o.pos = UnityPixelSnap(outPos); // uses pixelsnap
				
                return o;
            }

            fixed4 frag(v2f i) : SV_Target 
            {
                return tex2D(_MainTex,i.uv);
            }
	        ENDCG
	    }
	}
}
