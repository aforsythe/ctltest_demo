# ctltest_demo

A worked example of writing tests for [CTL](https://github.com/AcademySoftwareFoundation/CTL) modules with the
`ctltest` framework on the
[`ship/moduleTestFramework-v1`](https://github.com/aforsythe/CTL/tree/ship/moduleTestFramework-v1)
branch of the CTL fork.

The repo holds a simplified Output Transform — sRGB decode, viewing-
condition gain, Reinhard tonescale, Rec.709 matrix round-trip,
re-encode — exercised by 44 test cases that touch every YAML oracle
(`inline`, `csv`, `exr`, `snapshot`) and every test mode (`unit`,
`sweep`, `image`, `ctl_native`).

## Quickstart

```bash
./scripts/build_ctltest.sh                  # clone + build the binary
$(./scripts/build_ctltest.sh) tests/        # run every suite
```

First invocation clones and builds; subsequent runs are incremental.

### Prerequisites

Ubuntu 22.04+:

```bash
sudo apt-get install cmake libtiff-dev libimath-dev libopenexr-dev libyaml-cpp-dev
```

macOS:

```bash
brew install cmake openexr imath yaml-cpp
```

`numpy` + the `OpenEXR` Python package are only needed to regenerate
the reference EXRs (already checked in).

## What each suite demonstrates

| Suite | CTL module | Framework features |
|---|---|---|
| `tests/OT_Utilities_test.yaml` | `OT_Utilities.ctl` | `inline` oracle; `abs` / `rel` / `ulp` tolerances |
| `tests/OT_Encoding_test.yaml` | `OT_Encoding.ctl` | `inline` + `mode: sweep` from a CSV; `half` overload |
| `tests/OT_Colorspace_test.yaml` | `OT_Colorspace.ctl` | struct I/O (`ViewingCondition`); `per_field:` overrides |
| `tests/OT_Tonescale_test.yaml` | `OT_Tonescale.ctl` | `snapshot` oracle for a 256-tap 1D LUT |
| `tests/OT_Hue_test.yaml` | `OT_Hue.ctl` | struct return; `known_failure: true` (XFAIL) |
| `tests/OT_DisplayP3_test.yaml` | `OT_DisplayP3.ctl` | cross-module composition (imports `OT_Encoding`) |
| `tests/OT_OutputTransform_test.yaml` | `OT_OutputTransform.ctl` | `mode: image` EXR diff with `per_channel` ULP tolerances |
| `tests/test_OT_Properties_suite.yaml` | `tests/test_OT_Properties.ctl` | `mode: ctl_native` with `import "testkit"`: loops, properties, mid-pipeline asserts |

## Layout

```
ctltest_demo/
├── ctl/                     # CTL modules under test
├── tests/                   # YAML suites + one CTL-native test file
│   ├── snapshots/           # snapshot oracles (read-only by default)
│   └── references/          # reference EXRs for image-mode tests
├── scripts/
│   ├── build_ctltest.sh     # clone + build the pinned CTL fork
│   └── build_reference_exr.py
└── .github/workflows/ci.yml
```

## CI

Two jobs on `ubuntu-latest`:

1. `build-ctltest` — builds `ctltest` from the pinned CTL-fork SHA;
   the binary is cached by SHA, so repeat runs are seconds.
2. `test` — downloads the binary, runs every suite, uploads a JUnit
   XML artifact.

Bump `env.CTL_REF` in `.github/workflows/ci.yml` and `CTL_REF` in
`scripts/build_ctltest.sh` together to roll forward.

## Updating snapshots and reference EXRs

The checked-in assets are read-only in CI — drift fails the build.
To regenerate locally:

```bash
$(./scripts/build_ctltest.sh) --update-snapshots tests/OT_Tonescale_test.yaml
python3 scripts/build_reference_exr.py
```

## Further reading

- [Quickstart](https://github.com/aforsythe/CTL/blob/ship/moduleTestFramework-v1/moduletest/docs/QUICKSTART.md)
- [YAML schema](https://github.com/aforsythe/CTL/blob/ship/moduleTestFramework-v1/moduletest/docs/YAML_SCHEMA.md)
- [Tolerance semantics](https://github.com/aforsythe/CTL/blob/ship/moduleTestFramework-v1/moduletest/docs/TOLERANCE.md)
- [CLI reference](https://github.com/aforsythe/CTL/blob/ship/moduleTestFramework-v1/moduletest/docs/CLI.md)
- [`testkit::*` API](https://github.com/aforsythe/CTL/blob/ship/moduleTestFramework-v1/moduletest/docs/TESTKIT_API.md)

## License

Apache-2.0. See [LICENSE](./LICENSE).
