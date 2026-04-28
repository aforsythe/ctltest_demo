// CTL-native tests. Each `void test_*()` is a case driven by
// test_OT_Properties_suite.yaml.

ctlversion 1;

import "testkit";
import "OT_Encoding";
import "OT_Tonescale";
import "OT_Colorspace";

namespace test_OT_Properties
{

void
test_encode_decode_roundtrip_sweep()
{
    for (int i = 0; i <= 20; i = i + 1)
    {
        float fi  = i;
        float x   = fi / 20.0;
        float enc = OT_Encoding::linear_to_srgb(x);
        float dec = OT_Encoding::srgb_to_linear(enc);
        testkit::expect_near_f(dec, x, 1e-5);
    }
}

void
test_tonescale_monotonic()
{
    OT_Tonescale::TSParams p;
    p.exposure    = 1.0;
    p.white_point = 4.0;
    p.shoulder    = 0.25;

    float prev = OT_Tonescale::tonescale(0.0, p);
    for (int i = 1; i <= 100; i = i + 1)
    {
        float fi   = i;
        float x    = fi * 0.05;
        float curr = OT_Tonescale::tonescale(x, p);
        testkit::expect_true(curr >= prev);
        prev = curr;
    }
}

void
test_rec709_matrix_pair_inverts()
{
    float R = 0.42;
    float G = 0.18;
    float B = 0.65;

    float X;
    float Y;
    float Z;
    OT_Colorspace::rec709_rgb_to_xyz(R, G, B, X, Y, Z);

    float R2;
    float G2;
    float B2;
    OT_Colorspace::xyz_to_rec709_rgb(X, Y, Z, R2, G2, B2);

    testkit::expect_near_f(R2, R, 1e-5);
    testkit::expect_near_f(G2, G, 1e-5);
    testkit::expect_near_f(B2, B, 1e-5);
}

// Asserts on a mid-pipeline value that isn't a public output of the
// chain — the case YAML can't express.
void
test_pipeline_intermediate_in_range()
{
    float enc = 0.5;
    float lin = OT_Encoding::srgb_to_linear(enc);

    testkit::expect_true(lin > 0.20);
    testkit::expect_true(lin < 0.22);

    OT_Tonescale::TSParams p;
    p.exposure    = 1.0;
    p.white_point = 4.0;
    p.shoulder    = 0.25;
    float ts = OT_Tonescale::tonescale(lin, p);

    testkit::expect_true(ts > 0.10);
    testkit::expect_true(ts < 0.20);
}

} // namespace test_OT_Properties
