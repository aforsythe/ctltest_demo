// Rec.709 / sRGB primaries with D65 white.
// Source: ITU-R BT.709-6 §3 / IEC 61966-2-1.

namespace OT_Colorspace
{

const int SURROUND_DARK    = 0;
const int SURROUND_DIM     = 1;
const int SURROUND_AVERAGE = 2;

struct ViewingCondition
{
    float white_x;
    float white_y;
    int   surround;
    float adapting_lum;   // cd/m^2
};

void
rec709_rgb_to_xyz(float R, float G, float B,
                  output float X, output float Y, output float Z)
{
    X = 0.4123907992659593  * R + 0.357584339383878   * G + 0.1804807884018343 * B;
    Y = 0.21263900587151022 * R + 0.715168678767756   * G + 0.07219231536073371 * B;
    Z = 0.01933081871559182 * R + 0.11919477979462598 * G + 0.9505321522496607 * B;
}

void
xyz_to_rec709_rgb(float X, float Y, float Z,
                  output float R, output float G, output float B)
{
    R =  3.2409699419045226 * X - 1.5373831775700935 * Y - 0.4986107602930033 * Z;
    G = -0.9692436362808796 * X + 1.8759675015077202 * Y + 0.04155505740717561 * Z;
    B =  0.05563007969699366 * X - 0.20397695888897652 * Y + 1.0569715142428786 * Z;
}

void
apply_view(float R, float G, float B,
           ViewingCondition view,
           output float R_out, output float G_out, output float B_out)
{
    float k = view.adapting_lum / 100.0;
    if (view.surround == SURROUND_DARK) k = k * 0.95;
    if (view.surround == SURROUND_DIM)  k = k * 0.98;
    R_out = R * k;
    G_out = G * k;
    B_out = B * k;
}

} // namespace OT_Colorspace
