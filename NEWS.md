# float 0.3-4

## Bug fixes

- Arithmetic and comparison operations with an empty `float32` operand no
  longer crash R. This includes exponentiation and combinations of vectors and
  matrices. Empty results and zero-dimension matrices now follow base R's
  behavior.

## Documentation and maintenance

- Added regression tests for empty vectors, zero-dimension matrices, and
  uneven recycling in arithmetic and comparison operations.
- Documented the complete `rcond()` S4 method signature and corrected the
  comparison help page for R-devel checks.
- Added the missing RcppArmadillo vignette citation and updated the Intel MKL
  link.
- Removed a macOS startup workaround for R versions older than the package's
  minimum supported version (R 3.6.0).
- Stefano Cacciatore is the package maintainer.
