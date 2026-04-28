namespace OT_Tonescale
{

struct TSParams
{
    float exposure;
    float white_point;
    float shoulder;       // 0..1: 0 = pure Reinhard, 1 = hard clip at white_point
};

float
tonescale(float x_in, TSParams p)
{
    float x = x_in * p.exposure;
    if (x < 0.0) return 0.0;

    float w  = p.white_point;
    float w2 = w * w;
    if (w2 <= 0.0) return 0.0;

    float reinhard = (x * (1.0 + x / w2)) / (1.0 + x);
    float clipped  = x;
    if (clipped > w) clipped = w;
    clipped = clipped / w;

    return reinhard * (1.0 - p.shoulder) + clipped * p.shoulder;
}

void
sample_lut_256(TSParams p,
               float x_min, float x_max,
               output float lut[256])
{
    for (int i = 0; i < 256; i = i + 1)
    {
        float fi = i;
        float t  = fi / 255.0;
        float x  = x_min + (x_max - x_min) * t;
        lut[i]   = tonescale(x, p);
    }
}

} // namespace OT_Tonescale
