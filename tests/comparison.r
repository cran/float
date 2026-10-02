suppressPackageStartupMessages(library(float))
set.seed(1234)

same = function(test, truth) stopifnot(identical(test, truth))
tester = function(s, x, test)
{
  same(s >  test, x > test)
  same(s >= test, x >= test)
  same(s == test, x == test)
  same(s <  test, x < test)
  same(s <= test, x <= test)
  
  same(test >  s, test > x)
  same(test >= s, test >= x)
  same(test == s, test == x)
  same(test <  s, test < x)
  same(test <= s, test <= x)
}

x = matrix(-4:5, 5)
s = fl(x)

tester(s, x, 0L)
tester(s, x, 0.0)
tester(s, x, fl(0))
tester(s, x, s)
tester(s, x, x)



### Empty operands and recycling
comparison_ops = list(`>` = `>`, `>=` = `>=`, `==` = `==`, `<` = `<`, `<=` = `<=`)
empty = numeric(0)
empty_rows = matrix(numeric(0), 0, 3)
empty_cols = matrix(numeric(0), 3, 0)

for (op in comparison_ops)
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
    same(test, truth)
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
    same(test, truth)
  }
}
