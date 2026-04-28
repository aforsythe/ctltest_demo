// encoded -> linear -> view gain -> tonescale -> XYZ round-trip -> encoded.
//
// The XYZ leg is a deliberate round-trip (no CAT, no cross-talk) so the
// image oracle can predict outputs analytically.

import "OT_Encoding";
import "OT_Colorspace";
import "OT_Tonescale";

namespace OT_OutputTransform
{

void
output_transform(
    float R_in, float G_in, float B_in,
    OT_Colorspace::ViewingCondition view,
    OT_Tonescale::TSParams ts,
    output float R_out, output float G_out, output float B_out)
{
    float R_lin = OT_Encoding::srgb_to_linear(R_in);
    float G_lin = OT_Encoding::srgb_to_linear(G_in);
    float B_lin = OT_Encoding::srgb_to_linear(B_in);

    float R_v;
    float G_v;
    float B_v;
    OT_Colorspace::apply_view(R_lin, G_lin, B_lin, view, R_v, G_v, B_v);

    float R_ts = OT_Tonescale::tonescale(R_v, ts);
    float G_ts = OT_Tonescale::tonescale(G_v, ts);
    float B_ts = OT_Tonescale::tonescale(B_v, ts);

    float X;
    float Y;
    float Z;
    OT_Colorspace::rec709_rgb_to_xyz(R_ts, G_ts, B_ts, X, Y, Z);

    float R_rt;
    float G_rt;
    float B_rt;
    OT_Colorspace::xyz_to_rec709_rgb(X, Y, Z, R_rt, G_rt, B_rt);

    R_out = OT_Encoding::linear_to_srgb(R_rt);
    G_out = OT_Encoding::linear_to_srgb(G_rt);
    B_out = OT_Encoding::linear_to_srgb(B_rt);
}

void
output_transform_pixel(
    float R, float G, float B,
    output float R_out, output float G_out, output float B_out)
{
    OT_Colorspace::ViewingCondition view;
    view.white_x      = 0.3127;
    view.white_y      = 0.3290;
    view.surround     = OT_Colorspace::SURROUND_DIM;
    view.adapting_lum = 100.0;

    OT_Tonescale::TSParams ts;
    ts.exposure    = 1.0;
    ts.white_point = 4.0;
    ts.shoulder    = 0.25;

    output_transform(R, G, B, view, ts, R_out, G_out, B_out);
}

} // namespace OT_OutputTransform
