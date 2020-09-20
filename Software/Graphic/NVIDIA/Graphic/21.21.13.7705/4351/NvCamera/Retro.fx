struct VSOut
{
    float4 position : SV_Position;
    float2 texcoord: TexCoord;
};

cbuffer globalParams
{
	float2 screenSize;
	float elapsedTime;
	int captureState;
	float4 tileUV;
}

cbuffer controlBuf
{
	float g_sldIntensity;
}

// This should move to a centralized file but not appropriate to make that change now.
#ifndef NV_COMMON
#define NV_COMMON

#define CAPTURE_STATE_NOT_STARTED		0
#define CAPTURE_STATE_REGULAR			1
#define CAPTURE_STATE_REGULARSTEREO		2
#define CAPTURE_STATE_HIGHRES			3
#define CAPTURE_STATE_360				4
#define CAPTURE_STATE_360STEREO			5

#endif 

Texture2D txDiffuse;
Texture2D txNoise;
Texture2D txBlur;

SamplerState samLinear;
SamplerState samLinearWrap;

// Blur
#define fBlurSpeed				0.4 // [0.0 to 0.5] Speed at which to lerp to blur texture in half uv

// Toning (for the actual curves, see the shader)
#define fToningSpeed			0.4 // [0.0 to 0.5] Speed of toning change from center, in half uv

// Distort
#define fDistortStrength		0.2

// Desat
#define fDesat					0.2

// Vignette
#define g_sldVignette			1.5 //[0.0 to 1.0] Vignette amount


float Curve(float x, float contrast, float scale)
{
	x -= 0.5;
	x *= contrast;
	x += 0.5;
	x *= scale;
	return x;
}

float4 PSMain( VSOut frag ): SV_Target
{
	float2 uv;
	if (captureState == CAPTURE_STATE_HIGHRES)
	{
		uv = float2((tileUV.z - tileUV.x) * frag.texcoord.x + tileUV.x, (tileUV.w - tileUV.y) * frag.texcoord.y + tileUV.y);//frag.texcoord;
	}
	else
	{
		uv = frag.texcoord;
	}
	float2 uvScreen = uv;

	bool arePartsAllowed = (captureState != CAPTURE_STATE_360 && captureState != CAPTURE_STATE_360STEREO);
	
	// Barrel distortion
	float2 uvDistort = (uv - 0.5);
	float2 uvTexCoord = frag.texcoord;
	if (arePartsAllowed)
	{
		float maxDistort = (1.0 - 0.5) * (fDistortStrength / (tileUV.z - tileUV.x));
		float distortNrm = 1.0;
		// For highres pictures, we need to limit distortion to avoid artifacts
		if (captureState == CAPTURE_STATE_HIGHRES)
		{
			const float maxDistortAllowed = 0.2;
			if (maxDistort > maxDistortAllowed)
				distortNrm = maxDistortAllowed / maxDistort;
		}
		float distort = saturate(dot(uvDistort, uvDistort)) * (fDistortStrength / (tileUV.z - tileUV.x)) * distortNrm;
		uvTexCoord -= normalize(uvDistort) * distort * g_sldIntensity;
		
		// special clamping for games that have garbage on the edge of the frame
		const float borderWidth = 15.0;
		const float2 oneTexel = float2(1.0/screenSize.x, 1.0/screenSize.y);
		if (uvTexCoord.x > 1.0) uvTexCoord.x = 1.0 - borderWidth*oneTexel.x;
		if (uvTexCoord.x < 0.0)	uvTexCoord.x = 0.0 + borderWidth*oneTexel.x;
		if (uvTexCoord.y > 1.0) uvTexCoord.y = 1.0 - borderWidth*oneTexel.y;
		if (uvTexCoord.y < 0.0)	uvTexCoord.y = 0.0 + borderWidth*oneTexel.y;
	}

	float4 color = txDiffuse.Sample(samLinear, uvTexCoord);

	// Corner blur
	if (arePartsAllowed)
	{
		float blur = saturate(smoothstep(0.0, fBlurSpeed, dot(uvDistort, uvDistort))) * g_sldIntensity;
		float4 colorBlur = txBlur.Sample(samLinear, uvTexCoord);
		color = lerp(color, colorBlur, blur);
	}

	// Desat
	color = lerp(color, dot(color, 0.333), fDesat * g_sldIntensity);

	// Toning
	if (arePartsAllowed)
	{
		float toning = saturate(smoothstep(0.0, fToningSpeed, dot(uvDistort, uvDistort)));
		float3 colorCenter = color.rgb;
		colorCenter.r = Curve(colorCenter.r, 1.3, 1.4);
		colorCenter.g = Curve(colorCenter.g, 1.3, 1.3);
		colorCenter.b = Curve(colorCenter.b, 0.7, 0.8);
		float3 colorEdge = color.rgb;
		colorEdge.r = Curve(colorEdge.r, 1.0, 0.6);
		colorEdge.g = Curve(colorEdge.g, 1.0, 0.7);
		colorEdge.b = Curve(colorEdge.b, 0.5, 1.5);

		color.xyz = lerp(color.xyz, saturate(lerp(colorCenter, colorEdge, toning)), g_sldIntensity);
	}

	// Apply vignette
	if (arePartsAllowed)
	{
		float2 inTex = uv - 0.5.xx; // Distance from center
		inTex.x *= 1.2; // Slight aspect ratio correction
		float vignette = saturate(1.0 - dot( inTex, inTex )); // Length
		vignette = saturate(smoothstep(0.3, 1.0, vignette)); // Smoothstep
		color.xyz = lerp(color.xyz, float3(0.0, 0.0, 0.0), (1.0 - vignette) * g_sldVignette * g_sldIntensity);
	}

	return color; 
}

float4 PSBilinear( VSOut frag ): SV_Target
{
	return txDiffuse.Sample(samLinear, frag.texcoord);
}

float4 PSBlurHorizontal( VSOut frag ): SV_Target
{
	const float blurScale = 1.3;
	const int taps = 6;
	float offset[taps] = {0.0, 1.485052749, 3.465171586, 5.445404617, 7.425799782, 9.406428313};
	float weight[taps] = {0.082607, 0.157253, 0.12909, 0.090493, 0.054171, 0.02769};

	float4 clr = weight[0] * txDiffuse.Sample(samLinear, frag.texcoord);
	for (int i = 1; i < taps; ++i)
	{
		clr += weight[i] * txDiffuse.Sample( samLinear, frag.texcoord - float2(blurScale*offset[i]/screenSize.x, 0.0) );
		clr += weight[i] * txDiffuse.Sample( samLinear, frag.texcoord + float2(blurScale*offset[i]/screenSize.x, 0.0) );
	}

	return clr;
}

float4 PSBlurVertical( VSOut frag ): SV_Target
{
	const float blurScale = 1.3;
	const int taps = 6;
	float offset[taps] = {0.0, 1.485052749, 3.465171586, 5.445404617, 7.425799782, 9.406428313};
	float weight[taps] = {0.082607, 0.157253, 0.12909, 0.090493, 0.054171, 0.02769};

	float4 clr = weight[0] * txBlur.Sample(samLinear, frag.texcoord);
	for (int i = 1; i < taps; ++i)
	{
		clr += weight[i] * txBlur.Sample( samLinear, frag.texcoord - float2(0.0, blurScale*offset[i]/screenSize.y) );
		clr += weight[i] * txBlur.Sample( samLinear, frag.texcoord + float2(0.0, blurScale*offset[i]/screenSize.y) );
	}
	
	return clr;
}