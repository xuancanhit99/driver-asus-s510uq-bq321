struct VSOut
{
    float4 position : SV_Position;
    float2 texcoord: TexCoord;
};

cbuffer globalParams
{
	float2 screenSize;
	int captureState;
	float4 tileUV;
}

cbuffer controlBuf
{
	float g_sldColor;
	float g_sldSketch;
	float g_sldVignette;
	float g_chkThirds;
}

Texture2D txDiffuse;
SamplerState samLinear;

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

float3 colorEnhancer(float3 color)
{
	float3 clr = color;

	float3 clr_out = float3(0.5954f * clr.r, 0.58f * clr.g, 0.3487f * clr.b);

	float3 clr2 = clr * clr;
    	clr_out += float3(-1.492f * clr2.r, -3.916f * clr2.g, -1.835f * clr2.b);

	float3 clr3 = clr2 * clr;
    	clr_out += float3(19.17f * clr3.r, 26.03f * clr3.g, 12.92f * clr3.b);

	float3 clr4 = clr2 * clr2;
    	clr_out += float3(-45.04f * clr4.r, -50.52 * clr4.g, -19.09 * clr4.b);
	
	float3 clr5 = clr3 * clr2;
    	clr_out += float3(41.23f * clr5.r, 41.09 * clr5.g, 9.679 * clr5.b);

	float3 clr6 = clr4 * clr2;
    	clr_out += float3(-13.47f * clr6.r, -12.28 * clr6.g, -1.066 * clr6.b);

	return lerp(color, clamp(clr_out, float3(0.0f, 0.0f, 0.0f), float3(1.0f, 1.0f, 1.0f)), g_sldColor);
}

float3 sketch(float3 colorInput, float2 texCoords, Texture2D texColor, SamplerState sampState)
{
	const int ks = 3;
	// Sobel Horizontal
	float filterKernelH[ks * ks] =
			{
				 -1,  0,  1,
				 -2,  0,  2,
				 -1,  0,  1
			};
	// Sobel Vertical
	float filterKernelV[ks * ks] =
			{
				 -1, -2, -1,
				  0,  0,  0,
				  1,  2,  1
			};

	float4 clrH = { 0.0f, 0.0f, 0.0f, 0.0f };
	float4 clrV = { 0.0f, 0.0f, 0.0f, 0.0f };
	float4 clrOriginal;

	[unroll]
	for (int i = 0; i < ks; ++i)
	{
		[unroll]
		for (int j = 0; j < ks; ++j)  
		{
			float4 clr = texColor.Sample(sampState, texCoords, int2(i - ks/2, j - ks/2));
			
			if (i == ks/2 && j == ks/2)
				clrOriginal = clr;
			
			clrH += filterKernelH[i+j*ks] * clr;
			clrV += filterKernelV[i+j*ks] * clr;
		}
	}

	// BW result
//	const float4 lumFilter = { 0.2126, 0.7152, 0.0722, 0.0 };
//	return float4( (1.0 - length(float2( dot(clrH, lumFilter), dot(clrV, lumFilter) ))).xxx, 1.0 ); 

#define INVERT

	float3 sobelLengths =
#ifndef INVERT
		{
			length( float2(clrH.r, clrV.r) ),
			length( float2(clrH.g, clrV.g) ),
			length( float2(clrH.b, clrV.b) )
		};
#else
		{
			1.0 - length( float2(clrH.r, clrV.r) ),
			1.0 - length( float2(clrH.g, clrV.g) ),
			1.0 - length( float2(clrH.b, clrV.b) )
		};
#endif

	float3 outputColor = lerp(colorInput, sobelLengths, 0.45);
	return lerp(colorInput, outputColor, g_sldSketch);
}

float3 vignette(float3 color, float2 texCoords)
{
	float2 inTex; // Distance from center
	if (captureState == CAPTURE_STATE_HIGHRES)
	{
		inTex = float2((tileUV.z - tileUV.x) * texCoords.x + tileUV.x, (tileUV.w - tileUV.y) * texCoords.y + tileUV.y) - 0.5.xx;
	}
	else 
	{
		inTex = texCoords - 0.5.xx;
	}
	inTex.x *= 1.2; // Slight aspect ratio correction
	float vignette = saturate(1.0 - dot( inTex, inTex )); // Length
	vignette = saturate(smoothstep(0.3, 1.0, vignette)); // Smoothstep
	float3 color_vign = color * vignette;

	if (captureState != CAPTURE_STATE_360 && captureState != CAPTURE_STATE_360STEREO)
		color = lerp(color, color_vign, g_sldVignette);	
	
	return color;
}

float4 PS( VSOut frag ): SV_Target
{
	float4 color = txDiffuse.Sample(samLinear, frag.texcoord);
	
	if (
		-0.001 < g_sldColor && g_sldColor < 0.001 &&
		-0.001 < g_sldSketch && g_sldSketch < 0.001 &&
		-0.001 < g_sldVignette && g_sldVignette < 0.001
		)
	{
		// Sliders are in default mode - color shouldn't be changed or processed in any way
	}
	else
	{
		color.xyz = sketch(color.xyz, frag.texcoord, txDiffuse, samLinear);
		color.xyz = colorEnhancer(color.xyz);
		color.xyz = vignette(color.xyz, frag.texcoord);
	}
	
	// Render Grid of Thirds
	if ((-0.001 < g_chkThirds && g_chkThirds < 0.001) || (captureState != CAPTURE_STATE_NOT_STARTED))
	{
		// Either grid of thirds is disabled, or we are in capture mode
		// we don't want this grid to be present on output images
	}
	else
	{
		const float2 onePixelSize = float2(1.0 / screenSize.x, 1.0 / screenSize.y);
		const float2 whiteGridWidth = 2.0*onePixelSize;
		const float2 invGridWidth = 1.0*onePixelSize;
		const float2 distTo1stBar = frag.texcoord - float2(1.0 / 3.0, 1.0 / 3.0);
		const float2 distTo2ndBar = frag.texcoord - float2(2.0 / 3.0, 2.0 / 3.0);
		
		float3 gridColorRGB = color.rgb;
		
		if ((distTo1stBar.x > -invGridWidth.x && distTo1stBar.x < invGridWidth.x) ||
			(distTo2ndBar.x > -invGridWidth.x && distTo2ndBar.x < invGridWidth.x) ||
			(distTo1stBar.y > -invGridWidth.y && distTo1stBar.y < invGridWidth.y) ||
			(distTo2ndBar.y > -invGridWidth.y && distTo2ndBar.y < invGridWidth.y))
		{
			gridColorRGB = 1.0 - color.rgb;
		} else
		if ((distTo1stBar.x > -whiteGridWidth.x && distTo1stBar.x < whiteGridWidth.x) ||
			(distTo2ndBar.x > -whiteGridWidth.x && distTo2ndBar.x < whiteGridWidth.x) ||
			(distTo1stBar.y > -whiteGridWidth.y && distTo1stBar.y < whiteGridWidth.y) ||
			(distTo2ndBar.y > -whiteGridWidth.y && distTo2ndBar.y < whiteGridWidth.y))
		{
			gridColorRGB = float3(1.0, 1.0, 1.0);
		}
		color.rgb = lerp(color.rgb, gridColorRGB, g_chkThirds);
	}

	return color;
}
