// Variables

float exposure = 0.0;                    // [-1.0, 1.0]
float saturation = 0.0;                  // [-1.0, 1.0]

float3 fogColor = float3(0.0, 0.0, 0.0); // [0.0, 1.0]
float defog = 0.0;                       // [0.0, 1.0]

// Samplers

texture lastshader;

sampler s0 = sampler_state {
    texture = <lastshader>;
    addressu = clamp;
    addressv = clamp;
    magfilter = point;
    minfilter = point;
};

float4 sample0(sampler2D s, float2 t) {
    return tex2Dlod(s, float4(t, 0, 0));
}

// Functions

float4 tonemap(float2 tex : TEXCOORD) : COLOR0 {
    float3 color = tex2D(s0, tex);

    color = saturate(color - defog * fogColor * 2.55);
    color *= pow(2.0f, exposure);

    float3 mid = dot(color, (1.0 / 3.0));
    float3 diff = color - mid;
    color = (color + diff * saturation) / (1 + (diff * saturation));

    return float4(color, 1.0);
}

technique T0 < string MGEinterface = "MGE XE 0"; string category = "tone"; int priorityAdjust = 10000; > {
    pass { PixelShader = compile ps_3_0 tonemap(); }
}
