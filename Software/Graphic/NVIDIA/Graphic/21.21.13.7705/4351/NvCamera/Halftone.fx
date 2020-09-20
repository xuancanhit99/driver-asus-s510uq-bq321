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

SamplerState samLinear;
SamplerState samLinearWrap;

#define FREQUENCY ((float)(screenSize.x) / 6.0)
#define CONTRAST 0.7

float AntiAlias(float threshold, float value)
{
	float width = 0.75 * length(float2(ddx(value), ddy(value)));
	return smoothstep(threshold - width, threshold + width, value);
}

float DotGrid(float2 uvSquare, float angle, float radius, float noise, float coeff)
{
	noise *= 0.1; // Noise breaks up moire etc
	float s = sin(angle);
	float c = cos(angle);
	float2 uvRot = mul(float2x2(c, -s, s, c), uvSquare);
	float2 nearest = 2.0 * frac(FREQUENCY / coeff * uvRot) - 1.0;
	return AntiAlias(1.0 - radius, length(nearest) * CONTRAST - noise) + noise;
}

float4 CmykFromRgb(float3 c)
{
	float k = 1.0 - max(max(c.r, c.g), c.b);
	float4 cmyk;
	cmyk.rgb = (1.0.xxx - c.rgb - k.xxx) / (1.0 - k);
	cmyk.a = k;
	return cmyk;
}

float3 RgbFromCmyk(float4 c)
{
	return (1.0.xxx - c.rgb) * (1.0 - c.a);
}

float4 PSMain( VSOut frag ): SV_Target
{
	float2 uv = frag.texcoord;
	float aspect = screenSize.y / screenSize.x;
	float2 uvSquare = float2(uv.x, uv.y * aspect);

	// Sample color

	float3 color = txDiffuse.Sample(samLinear, uv).rgb;

	if (captureState == CAPTURE_STATE_360 ||
		captureState == CAPTURE_STATE_360STEREO)
	{
		return float4(color, 1.0);
	}
	
	// Sample noise

	float3 noise = txNoise.Sample(samLinearWrap, uv).rgb;

	// Convert to CMYK

	float4 cmyk = 1.0.xxxx - CmykFromRgb(color);

	// Compute dot pattern

	float coeff = 1.0;
	// This code is somewhat redundant since we early out on 360/360Stereo anyway
	// 	but this code shows how to increase halftone points radius to try and avoid
	//	moire patterns due to 360s being forcefully downscaled
	if (captureState == CAPTURE_STATE_360 ||
		captureState == CAPTURE_STATE_360STEREO)
	{
		coeff = 2.0;
	}
	
	float4 cmykDot;
	cmykDot.r = DotGrid(uvSquare, 0.261799, cmyk.r, noise.x, coeff);	// C 15 degrees
	cmykDot.g = DotGrid(uvSquare, 1.309, cmyk.g, noise.y, coeff);		// M 75 degrees
	cmykDot.b = DotGrid(uvSquare, 0, cmyk.b, noise.z, coeff);			// Y  0 degrees
	cmykDot.a = DotGrid(uvSquare, 0.785398, cmyk.a, noise.x, coeff);	// K 45 degrees

	// Convert to RGB
	return float4(lerp(color, RgbFromCmyk(1.0.xxxx - cmykDot), g_sldIntensity), 1.0);
}
