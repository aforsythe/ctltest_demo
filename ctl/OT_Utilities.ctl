namespace OT_Utilities
{

float
clamp_f(float x, float lo, float hi)
{
    if (x < lo) return lo;
    if (x > hi) return hi;
    return x;
}

float
lerp_f(float a, float b, float t)
{
    return a + (b - a) * t;
}

float
safe_log2(float x, float floor_pos)
{
    float guarded = x;
    if (guarded < floor_pos) guarded = floor_pos;
    return log(guarded) / log(2.0);
}

float
safe_pow(float base, float exponent)
{
    if (base <= 0.0) return 0.0;
    return pow(base, exponent);
}

} // namespace OT_Utilities
