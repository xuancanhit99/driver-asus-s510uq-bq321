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

Texture2D txDiffuse;

SamplerState samLinear;
SamplerState samLinearWrap;

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

float4 PS_RedMonochrome( VSOut frag ): SV_Target
{
	float2 uv = frag.texcoord;
	float4 color = txDiffuse.Sample(samLinear, frag.texcoord);
	
	// Sepia
	const float4 sepiaLight = { 1.2, 1.0, 0.8, 1.0 };
	const float4 lumFilter = { 0.2126, 0.7152, 0.0722, 0.0 };
	
	return float4(lerp(color, (dot(color, lumFilter)).xxxx * sepiaLight, g_sldIntensity));
}
