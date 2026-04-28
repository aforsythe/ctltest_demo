// Display-P3: DCI-P3 primaries adapted to D65 via Bradford,
// reusing the sRGB transfer function from OT_Encoding.

import "OT_Encoding";

namespace OT_DisplayP3
{

void
displayp3_rgb_to_xyz(float R, float G, float B,
                     output float X, output float Y, output float Z)
{
    X = 0.486570948648216 * R + 0.265667693169093 * G + 0.198217285234362 * B;
    Y = 0.228974564775377 * R + 0.691738605302214 * G + 0.079286829922408 * B;
    Z = 0.0               * R + 0.045113381858903 * G + 1.043944368900976 * B;
}

void
xyz_to_displayp3_rgb(float X, float Y, float Z,
                     output float R, output float G, output float B)
{
    R =  2.4934969119414253 * X - 0.9313836179191242 * Y - 0.4027107844507168 * Z;
    G = -0.8294889695615749 * X + 1.7626640603183465 * Y + 0.0236246858419436 * Z;
    B =  0.0358458302437845 * X - 0.0761723892680418 * Y + 0.9568845240076872 * Z;
}

void
encode_to_display(float R_lin, float G_lin, float B_lin,
                  output float R_enc, output float G_enc, output float B_enc)
{
    float r = R_lin;
    float g = G_lin;
    float b = B_lin;
    if (r < 0.0) r = 0.0; if (r > 1.0) r = 1.0;
    if (g < 0.0) g = 0.0; if (g > 1.0) g = 1.0;
    if (b < 0.0) b = 0.0; if (b > 1.0) b = 1.0;

    R_enc = OT_Encoding::linear_to_srgb(r);
    G_enc = OT_Encoding::linear_to_srgb(g);
    B_enc = OT_Encoding::linear_to_srgb(b);
}

} // namespace OT_DisplayP3
