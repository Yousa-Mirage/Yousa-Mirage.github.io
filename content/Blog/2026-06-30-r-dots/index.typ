#import "../index.typ": template, tufted
#import "@preview/theorion:0.6.0": *
#import "@preview/tablem:0.3.0": three-line-table
#show: template.with(
  title: "R 中的三个点 ...：小符号的大作用",
  date: datetime(year: 2026, month: 6, day: 30),
  description: "R 中的三个点 ...：小符号的大作用",
)

#tufted.margin-note[
  类似的主题内容也可参见 #link( "https://design.tidyverse.org/dots-after-required.html", [_Tidy design principles_]) 和 #link("https://www.cynkra.com/blog/2026-06-12-dots/", [_Three small dots for more readable code_])。
]

= R 中的三个点 `...`：小符号的大作用

```r
paste(..., sep = " ", collapse = NULL)
```

如果你读过一些 R 函数文档，大概率见过函数参数里的 `...`，比如 `paste()`、`lapply()` 或 `plot()`。你可能也用过它，但并没有特别在意。事实上，`...`，也常被称为 _dots_，是 R 中非常灵活的功能之一。在自己写函数时，有意识地安排 `...` 的位置，可以明显提升代码的可读性和稳健性。

== 什么是三个点 `...`？

`...` 是一种特殊参数，主要有三个用途：

1. *收集数量不固定的输入*：当你事先不知道调用者会传入多少个参数时，可以用它接收这些参数；
2. *转发参数*：把额外参数继续传给内部调用的函数，而不必把这些参数逐一写在当前函数的参数列表里；
3. *强制可选参数使用命名传参*。

== 用法一：收集数量不固定的输入

经典例子是 `paste()`。无论传入一个字符串还是十个字符串，它都可以处理：

```r
paste("Hello", "world")
#> [1] "Hello world"
paste("a", "b", "c", "d", sep = "-")
#> [1] "a-b-c-d"
```

我们也可以在自己的函数中这样使用 `...`。下面这个小函数会把传入的值放进方括号，并用逗号分隔：

```r
bracket_paste <- function(...) {
  items <- c(...)
  paste0("[", paste(items, collapse = ", "), "]")
}

bracket_paste("apple", "banana", "cherry")
#> [1] "[apple, banana, cherry]"
```

在函数内部，`list(...)` 可以把三个点中的内容捕获为一个命名列表，`...length()` 则可以告诉我们调用者传入了多少个参数：

```r
peek_dots <- function(...) {
  cat("Number of arguments:", ...length(), "\n")
  str(list(...))
}

peek_dots(x = 1:3, label = "test", flag = TRUE)
#> Number of arguments: 3
#> List of 3
#>  $ x    : int [1:3] 1 2 3
#>  $ label: chr "test"
#>  $ flag : logi TRUE
```

== 用法二：把参数转发给内部函数

在实际写代码时，`...` 最常见的用途之一，是写包装函数。包装函数可以把额外参数原样传给内部函数，从而保持灵活性，而不需要把内部函数支持的每一个参数都重新列出来。

例如，下面这个绘图包装函数总是会添加网格线，同时允许你传入任何 `plot()` 支持的参数：

```r
plot_with_grid <- function(x, y, ...) {
  plot(x, y, ...)
  grid()
}

# col、pch 和 main 会通过 ... 传给 plot()
plot_with_grid(1:10, (1:10)^2,
               col = "steelblue", pch = 16,
               main = "Squares")
```

`lapply(X, FUN, ...)` 也是同样的逻辑。你传入的额外参数会通过 `...` 继续传给 `FUN`：

```r
# na.rm 参数通过 ... 传给 mean()
lapply(list(c(1, 2, NA), c(4, 5, 6)), mean, na.rm = TRUE)
#> [[1]]
#> [1] 1.5
#>
#> [[2]]
#> [1] 5
```

== 一个设计模式：把 `...` 放在必填参数之后

接下来是在设计现代函数 API 时更有用处的功能。大多数函数都有两类参数：

- *必填参数*：没有默认值，函数运行离不开它们。
- *可选参数*：有默认值，用来调节或定制函数行为。

一个常见的函数定义可能长这样：

```r
summarise_col <- function(data, column, digits = 2, show_na = TRUE) {
  # ...
}
```

这看起来没有问题，但它允许调用者用位置传参的方式传入可选参数：

```r
summarise_col(mtcars, "mpg", 3, FALSE)
```

这段代码可以运行，但如果不去看函数定义，很难一眼看出 `3` 和 `FALSE` 分别是什么意思。更麻烦的是，如果以后决定调整 `digits` 和 `show_na` 的顺序，那些依赖位置传参的旧代码可能会在没有任何明显提示的情况下改变含义或无法运行。

*解决办法是：把 `...` 放在必填参数和可选参数之间，并配合使用 `rlang::check_dots_empty()`。*

```r
summarise_col <- function(data, column, ..., digits = 2, show_na = TRUE) {
  rlang::check_dots_empty()
  # ...
}
```

这样，`...` 后面的所有参数都只能通过参数名传入：

```r
# 这会立刻报错，并给出清楚的提示：
summarise_col(mtcars, "mpg", 3, FALSE)
#> Error in `summarise_col()`:
#> ! `...` must be empty.
#> ✖ Problematic argument:
#> • ..1 = 3
#> ℹ Did you forget to name an argument?

# 这是正确写法，也更容易阅读：
summarise_col(mtcars, "mpg", digits = 3, show_na = FALSE)
```

完整实现如下：

```r
summarise_col <- function(data, column, ..., digits = 2, show_na = TRUE) {
  rlang::check_dots_empty()

  x <- data[[column]]

  cat("Column:", column, "\n")
  cat("  Min: ", round(min(x, na.rm = TRUE), digits), "\n")
  cat("  Mean:", round(mean(x, na.rm = TRUE), digits), "\n")
  cat("  Max: ", round(max(x, na.rm = TRUE), digits), "\n")
  if (show_na) {
    cat("  NAs: ", sum(is.na(x)), "\n")
  }
}

summarise_col(mtcars, "mpg")
#> Column: mpg
#>   Min:  10.4
#>   Mean: 20.09
#>   Max:  33.9
#>   NAs:  0

summarise_col(mtcars, "mpg", digits = 1, show_na = FALSE)
#> Column: mpg
#>   Min:  10.4
#>   Mean: 20.1
#>   Max:  33.9
```

== 为什么要用 `rlang::check_dots_empty()`？

如果不加检查，`...` 会默默吃掉那些意外传进去的内容。拼写错误、记错参数名、漏写逗号造成的异常参数，都可能不留痕迹地消失：

```r
f <- function(x, ..., quiet = FALSE) {
  if (!quiet) cat("Result:", x * 2, "\n")
}

f(5, quet = TRUE)   # "quiet" 拼错了，但不会报错，也不会抑制输出
#> Result: 10
```

加上 `rlang::check_dots_empty()` 之后，拼写错误或错误传参会立刻被发现：

```r
f <- function(x, ..., quiet = FALSE) {
  rlang::check_dots_empty()
  if (!quiet) cat("Result:", x * 2, "\n")
}

f(5, quet = TRUE)
#> Error in `f()`:
#> ! `...` must be empty.
#> ✖ Problematic argument:
#> • quet = TRUE
#> ℹ Did you forget to name an argument?
```

对于会被他人使用、或者需要在团队中共享的函数来说，这一点尤其重要。它可以消除一整类很难排查的静默错误。

== 总结

R 语言中，三个点 `...` 虽然小，但作用并不小：

#three-line-table[
  | 用途           | 示例                                             |
  | ------------ | ---------------------------------------------- |
  | 收集数量不固定的输入   | `paste("a", "b", "c")`                         |
  | 转发给内部函数      | `plot_with_grid(x, y, col = "red")`            |
  | 强制可选参数使用命名传参 | `f(x, ..., digits = 2)` + `check_dots_empty()` |
]

把 `...` 放在必填参数之后、可选参数之前，是一个简单、低成本的函数接口改进。它会促使调用者写出更明确、更自解释的代码，也让你以后可以更自由地调整函数参数，而不容易破坏旧代码。

#line()

#quote-block[“万能的宇宙大人啊，告诉我未来会好吗？”]
#image("miku.webp")
