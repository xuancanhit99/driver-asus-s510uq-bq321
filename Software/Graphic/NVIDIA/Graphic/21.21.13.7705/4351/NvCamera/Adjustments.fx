// This filter is in part based on MasterEffect ReBorn 1.1.287 
// Copyright (c) 2009-2015 Gilcher Pascal aka Marty McFly
// See Tools/tools_licenses.txt for the terms that the work is being licensed under.

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
	float g_sldBrightness;
	float g_sldContrast;
	float g_sldVibrance;
}

Texture2D txDiffuse;

SamplerState samLinear;
SamplerState samLinearWrap;

float3 rgb2hsv(float3 c)
{
	float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
	float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
float3 hsv2rgb(float3 c)
{
	float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float3 ColormodPass( float3 color )
{

#define ColormodChroma 			1.0		// Saturation
#define ColormodGammaR 			1.0		// Gamma for Red color channel
#define ColormodGammaG 			1.0		// Gamma for Green color channel
#define ColormodGammaB 			1.0		// Gamma for Blue color channel
#define ColormodContrastR 		1.0		// Contrast for Red color channel
#define ColormodContrastG 		1.0		// ...
#define ColormodContrastB 		1.0		// ...
#define ColormodBrightnessR 	0.0		// Brightness for Red color channel
#define ColormodBrightnessG 	0.0		// ...
#define ColormodBrightnessB 	0.0		// ...
#define g_sldGamma				0.5

	float brightnessTerm = 2.0f * g_sldBrightness - 1.0f;
	
	const float contrastMin = -1.6094379124341003746007593332262; //ln(0.2)
	const float contrastMax = 1.6094379124341003746007593332262; //ln(5.0)
	
	float contrastFactor = exp(contrastMin  + g_sldContrast * (contrastMax  - contrastMin)); 
	//float contrastFactor = g_sldContrast <= 0.5f ? (0.5f - g_sldContrast) * -2.0f + 1.0f : (g_sldContrast - 0.5f) * 10.0f + 1.0f;

	color.xyz = (color.xyz - dot(color.xyz, 0.333)) * ColormodChroma + dot(color.xyz, 0.333);
	color.xyz = saturate(color.xyz);
	color.x = (pow(color.x, 2.0 * (1.0 - g_sldGamma) * ColormodGammaR) - 0.5) * ColormodContrastR * contrastFactor  + 0.5 + brightnessTerm;
	color.y = (pow(color.y, 2.0 * (1.0 - g_sldGamma) * ColormodGammaG) - 0.5) * ColormodContrastG * contrastFactor  + 0.5 + brightnessTerm;
	color.z = (pow(color.z, 2.0 * (1.0 - g_sldGamma) * ColormodGammaB) - 0.5) * ColormodContrastB * contrastFactor  + 0.5 + brightnessTerm;
	return color;	
}

float3 vibrance(float3 color)
{
	// Original had double precision
	float3 hsv;
	float m, v, h, s, vm_diff, f, p, q, t;
	float r, g, b;
	int in_val;

	r = color.r;
	g = color.g;
	b = color.b;
	
	// convert rgb to hsv
	hsv = rgb2hsv(color.rgb);

	// perform gamma [0..2] enhancement
	// 	actually gamma is [0.001 .. 2.0] since otherwise we can observe artifacts
	hsv.y = pow(hsv.y, 1.0 / ((g_sldVibrance * 0.999 + 0.001) * 2.0));

	// convert hsv to rgb
	color.rgb = hsv2rgb(hsv);

	return color;
}

float4 PS_Vibrance( VSOut frag ): SV_Target
{
	float2 uv = frag.texcoord;
	float4 color = txDiffuse.Sample(samLinear, frag.texcoord);

	if (
		 0.499 < g_sldBrightness && g_sldBrightness < 0.501 &&
		 0.499 < g_sldContrast && g_sldContrast < 0.501 &&
		 0.499 < g_sldVibrance && g_sldVibrance < 0.501
		)
	{
		// Sliders are in default mode - color shouldn't be changed or processed in any way
		return color;
	}
	
	color.xyz = ColormodPass(color.xyz);
	color.xyz = vibrance(color.xyz);
	
	return color;
}
