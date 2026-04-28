// sRGB transfer function (IEC 61966-2-1).

namespace OT_Encoding
{

float
linear_to_srgb(float x)
{
    if (x <= 0.0031308) return 12.92 * x;
    return 1.055 * pow(x, 1.0 / 2.4) - 0.055;
}

half
linear_to_srgb_h(half x)
{
    half result;
    if (x <= 0.0031308)
        result = 12.92 * x;
    else
        result = 1.055 * pow(x, 1.0 / 2.4) - 0.055;
    return result;
}

float
srgb_to_linear(float x)
{
    if (x <= 0.04045) return x / 12.92;
    return pow((x + 0.055) / 1.055, 2.4);
}

half
srgb_to_linear_h(half x)
{
    half result;
    if (x <= 0.04045)
        result = x / 12.92;
    else
        result = pow((x + 0.055) / 1.055, 2.4);
    return result;
}

} // namespace OT_Encoding
