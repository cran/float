#' @useDynLib float R_init_NAf R_machine_spm R_init_NaNf

.onLoad <- function(libname, pkgname)
{
  NA_float_ = float32(.Call(R_init_NAf, PACKAGE="float"))
  # NaNf = float32(.Call(R_init_NaNf, PACKAGE="float"))
  # .Machine_float = .Call(R_machine_spm)
  invisible()
}
