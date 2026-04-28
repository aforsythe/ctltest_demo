#!/usr/bin/env python3
"""Generate the input + reference EXRs for the image-mode test suite.

The chain below is a Python mirror of OT_OutputTransform — keep them
in lockstep, otherwise the image-mode oracle drifts.
"""
import os
import sys

import numpy as np
import OpenEXR


# 24 Macbeth-like patches in encoded sRGB. Exact values aren't load-
# bearing; they only need to be deterministic.
MACBETH_SRGB = np.array([
    [115/255,  82/255,  68/255],
    [194/255, 150/255, 130/255],
    [ 98/255, 122/255, 157/255],
    [ 87/255, 108/255,  67/255],
    [133/255, 128/255, 177/255],
    [103/255, 189/255, 170/255],
    [214/255, 126/255,  44/255],
    [ 80/255,  91/255, 166/255],
    [193/255,  90/255,  99/255],
    [ 94/255,  60/255, 108/255],
    [157/255, 188/255,  64/255],
    [224/255, 163/255,  46/255],
    [ 56/255,  61/255, 150/255],
    [ 70/255, 148/255,  73/255],
    [175/255,  54/255,  60/255],
    [231/255, 199/255,  31/255],
    [187/255,  86/255, 149/255],
    [  8/255, 133/255, 161/255],
    [243/255, 243/255, 242/255],
    [200/255, 200/255, 200/255],
    [160/255, 160/255, 160/255],
    [122/255, 121/255, 121/255],
    [ 85/255,  85/255,  85/255],
    [ 52/255,  52/255,  52/255],
], dtype=np.float64)


def srgb_to_linear(x):
    if x <= 0.04045:
        return x / 12.92
    return ((x + 0.055) / 1.055) ** 2.4


def linear_to_srgb(x):
    if x <= 0.0031308:
        return 12.92 * x
    return 1.055 * (x ** (1.0 / 2.4)) - 0.055


def apply_view_dim(R, G, B):
    k = 0.98
    return R * k, G * k, B * k


def tonescale(x, exposure=1.0, white_point=4.0, shoulder=0.25):
    x = x * exposure
    if x < 0.0:
        return 0.0
    w  = white_point
    w2 = w * w
    if w2 <= 0.0:
        return 0.0
    reinhard = (x * (1.0 + x / w2)) / (1.0 + x)
    clipped  = min(x, w) / w
    return reinhard * (1.0 - shoulder) + clipped * shoulder


REC709_RGB_TO_XYZ = np.array([
    [0.4123907992659593,  0.357584339383878,   0.1804807884018343 ],
    [0.21263900587151022, 0.715168678767756,   0.07219231536073371],
    [0.01933081871559182, 0.11919477979462598, 0.9505321522496607 ],
])
XYZ_TO_REC709_RGB = np.array([
    [ 3.2409699419045226, -1.5373831775700935, -0.4986107602930033  ],
    [-0.9692436362808796,  1.8759675015077202,  0.04155505740717561 ],
    [ 0.05563007969699366,-0.20397695888897652, 1.0569715142428786  ],
])


def output_transform_pixel(R, G, B):
    R_lin = srgb_to_linear(R)
    G_lin = srgb_to_linear(G)
    B_lin = srgb_to_linear(B)
    R_v, G_v, B_v = apply_view_dim(R_lin, G_lin, B_lin)
    R_ts = tonescale(R_v)
    G_ts = tonescale(G_v)
    B_ts = tonescale(B_v)
    xyz = REC709_RGB_TO_XYZ @ np.array([R_ts, G_ts, B_ts])
    rgb = XYZ_TO_REC709_RGB @ xyz
    return linear_to_srgb(rgb[0]), linear_to_srgb(rgb[1]), linear_to_srgb(rgb[2])


def write_exr(path, rgb_HxWx3):
    R = rgb_HxWx3[..., 0].astype(np.float32)
    G = rgb_HxWx3[..., 1].astype(np.float32)
    B = rgb_HxWx3[..., 2].astype(np.float32)
    header = {
        "compression": OpenEXR.NO_COMPRESSION,
        "type":        OpenEXR.scanlineimage,
    }
    channels = {
        "R": OpenEXR.Channel("R", R),
        "G": OpenEXR.Channel("G", G),
        "B": OpenEXR.Channel("B", B),
    }
    OpenEXR.File([OpenEXR.Part(header, channels)]).write(path)


def main():
    repo = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    refs = os.path.join(repo, "tests", "references")
    os.makedirs(refs, exist_ok=True)

    src = MACBETH_SRGB.reshape(1, 24, 3).astype(np.float32)
    ref = np.zeros_like(src)
    for x in range(24):
        ref[0, x] = output_transform_pixel(*src[0, x])

    src_path = os.path.join(refs, "macbeth_rec709_src.exr")
    ref_path = os.path.join(refs, "macbeth_rec709_ref.exr")
    write_exr(src_path, src)
    write_exr(ref_path, ref)
    print(f"wrote {src_path}")
    print(f"wrote {ref_path}")


if __name__ == "__main__":
    sys.exit(main() or 0)
