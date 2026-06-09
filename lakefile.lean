import Lake
open Lake DSL

package «OSforGFF2D3D» where
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩
  ]

require OSforGFF from git
  "https://github.com/mrdouglasny/OSforGFF.git" @ "60ab679e09b764de6dfe01767ae361ac1bea30b8"

@[default_target]
lean_lib «OSforGFFin3D» where

@[default_target]
lean_lib «OSforGFFin2D» where
