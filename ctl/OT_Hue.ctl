namespace OT_Hue
{

struct RotatedRGB
{
    float R;
    float G;
    float B;
    float angle_deg;
};

// Rotation around the (1,1,1) grey axis via the Rodrigues expansion.
RotatedRGB
rotate_hue(float R, float G, float B, float degrees)
{
    float pi    = 3.14159265358979323846;
    float theta = degrees * pi / 180.0;
    float c     = cos(theta);
    float s     = sin(theta);

    float k = (1.0 - c) / 3.0;
    float p = s / sqrt(3.0);

    float Rr = R * (c + k) + G * (k - p) + B * (k + p);
    float Gr = R * (k + p) + G * (c + k) + B * (k - p);
    float Br = R * (k - p) + G * (k + p) + B * (c + k);

    RotatedRGB out;
    out.R         = Rr;
    out.G         = Gr;
    out.B         = Br;
    out.angle_deg = degrees;
    return out;
}

} // namespace OT_Hue
