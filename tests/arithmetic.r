suppressPackageStartupMessages(library(float))
set.seed(1234)
tol = 1e-6

same = function(test, truth) stopifnot(all.equal(test, truth, tol=tol))

x1 = matrix(stats::rnorm(30), 10)
x2 = matrix(stats::rnorm(30), 10)
x3 = matrix(1:30, 10)

s1 = fl(x1)
s2 = fl(x2)



### Addition
test = dbl(s1 + s2)
truth = x1 + x2
same(test, truth)
test = s1 + x2
same(test, truth)
test = x2 + s1
same(test, truth)

test = dbl(s1 + x3)
truth = x1 + x3
same(test, truth)
test = dbl(x3 + s1)
same(test, truth)

test = dbl(s1 + 1L)
truth = x1 + 1
same(test, truth)
test = s1 + 1.0
same(test, truth)



### Multiplication
test = dbl(s1 * s2)
truth = x1 * x2
same(test, truth)
test = s1 * x2
same(test, truth)
test = x2 * s1
same(test, truth)

test = dbl(s1 * x3)
truth = x1 * x3
same(test, truth)
test = dbl(x3 * s1)
same(test, truth)

test = dbl(s1 * 1L)
truth = x1 * 1L
same(test, truth)
test = s1 * 1.0
same(test, truth)



### Subtraction
test = dbl(s1 - s2)
truth = x1 - x2
same(test, truth)
test = s1 - x2
same(test, truth)

truth = x2 - x1
test = x2 - s1
same(test, truth)

test = dbl(s1 - x3)
truth = x1 - x3
same(test, truth)

truth = x3 - x1
test = dbl(x3 - s1)
same(test, truth)

test = dbl(s1 - 1L)
truth = x1 - 1L
same(test, truth)
test = s1 - 1.0
same(test, truth)



### Division
test = dbl(s1 / s2)
truth = x1 / x2
same(test, truth)
test = s1 / x2
same(test, truth)

truth = x2 / x1
test = x2 / s1
same(test, truth)

test = dbl(s1 / x3)
truth = x1 / x3
same(test, truth)

truth = x3 / x1
test = dbl(x3 / s1)
same(test, truth)

test = dbl(s1 / 1L)
truth = x1 / 1L
same(test, truth)
test = s1 / 1.0
same(test, truth)



### Power
test = dbl(s1 ^ s2)
truth = x1 ^ x2
same(test, truth)
test = s1 ^ x2
same(test, truth)

truth = x2 ^ x1
test = x2 ^ s1
same(test, truth)

test = dbl(s1 ^ x3)
truth = x1 ^ x3
same(test, truth)

truth = x3 ^ x1
test = dbl(x3 ^ s1)
same(test, truth)

test = dbl(s1 ^ 1L)
truth = x1 ^ 1L
same(test, truth)
test = s1 ^ 1.0
same(test, truth)



### Empty operands and recycling
arithmetic_ops = list(`+` = `+`, `*` = `*`, `-` = `-`, `/` = `/`, `^` = `^`)
empty = numeric(0)
empty_rows = matrix(numeric(0), 0, 3)
empty_cols = matrix(numeric(0), 3, 0)

for (op in arithmetic_ops)
{
  for (inputs in list(
    list(empty, 1:3), list(1:3, empty), list(empty, empty),
    list(matrix(1:4, 2), empty), list(empty, matrix(1:4, 2)),
    list(empty_rows, 1), list(1, empty_rows),
    list(empty_cols, 1), list(1, empty_cols),
    list(empty_rows, empty_rows)))
  {
    test = op(fl(inputs[[1]]), fl(inputs[[2]]))
    truth = op(inputs[[1]], inputs[[2]])
    stopifnot(is.float(test))
    same(dbl(test), truth)
  }

  for (inputs in list(
    list(1:4, 1:3),
    list(matrix(1:4, 2), 1:3),
    list(1:3, matrix(1:4, 2))))
  {
    warned = FALSE
    test = withCallingHandlers(op(fl(inputs[[1]]), fl(inputs[[2]])), warning=function(w) {
      warned <<- TRUE
      invokeRestart("muffleWarning")
    })
    truth = suppressWarnings(op(inputs[[1]], inputs[[2]]))
    stopifnot(warned)
    same(dbl(test), truth)
  }
}
