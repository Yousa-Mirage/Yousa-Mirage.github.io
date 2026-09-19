#import "../index.typ": template, tufted
#import "@preview/theorion:0.6.0": quote-block
#show: template.with(
  title: "R 中的 if 也能返回值：从条件赋值到 NULL、类型与求值细节",
  date: datetime(year: 2026, month: 9, day: 19),
  description: "从 R 的求值规则出发，讨论 if 条件赋值的用法、NULL、类型、作用域与维护风险。",
)

= R 中的 if 也能返回值：从条件赋值到 NULL、类型与求值细节

#tufted.margin-note[
  本文示例基于 R 4.6.1；涉及 `dplyr::if_else()` 的示例基于 dplyr 1.2.1。
]

在 R 代码里，你可能见过这样的写法：

```r
cond <- TRUE
x <- if (cond) "this" else "that"
```

也可能见过它的多行版本：

```r
df <- if (cond) {
  data.frame()
} else {
  mtcars
}
```

如果你习惯把 `if` 理解成“决定执行哪几行代码”，第一次看到这样的赋值，可能会有点疑惑：`if` 还能放在赋值符号右边？它究竟返回什么？如果没有 `else` 呢？

如果你写过 Rust，这种结构又会显得很熟悉：

```rust
let x = if cond { "this" } else { "that" };
```

两种语言都允许用 `if` 产生一个值，但对类型、作用域以及缺省分支的处理并不相同。本文从 R 的求值规则出发，逐步讨论这种写法的用法、边界与维护风险，最后回到围绕它的一场真实社区讨论。

== 1. `if` 本身有值

在 R 中，`if` 不仅控制执行流程，还会产生一个结果。R 官方的 `Control` 帮助文档明确规定：`if` 返回被执行分支的表达式值；如果没有执行任何分支，则不可见地返回 `NULL`。#footnote[#link("https://stat.ethz.ch/R-manual/R-devel/library/base/html/Control.html")[R：Control Flow]，参见 `if` 的条件要求、返回值与换行注意事项。]

因此，下面的代码并不需要某种特殊的“条件赋值语法”：

```r
cond <- TRUE
x <- if (cond) "this" else "that"
```

它只是先对右侧的 `if` 表达式求值，再把结果赋给 `x`。在右侧正常求值完成的情况下，可以分成四步理解：

+ 对条件 `cond` 求值。
+ 根据条件，执行其中一个分支。
+ 取得该分支的结果。
+ 把结果赋给 `x`。

条件为真，得到 `"this"`；条件为假，得到 `"that"`。

这里的结果不限于一个数字或一段字符串。`if` 可以选择整个向量、数据框、列表、函数等对象：

```r
values <- if (TRUE) 1:3 else 4:6
values
# [1] 1 2 3

summary_fn <- if (TRUE) mean else median
summary_fn(c(1, 2, 100))
# [1] 34.33333
```

同样的机制也解释了函数中的隐式返回：

```r
choose_label <- function(cond) {
  if (cond) "this" else "that"
}

choose_label(FALSE)
# [1] "that"
```

函数体最后求值的是 `if`，所以函数把 `if` 的结果作为自己的结果返回。

== 2. `if` 只执行选中的分支

`if` 不会先计算两个分支，再从两个结果中挑选一个。它只对选中的分支求值：

```r
x <- if (TRUE) 1 else stop("这里不会执行")
x
# [1] 1
```

没有被选中的分支甚至可以引用当前不存在的对象：

```r
x <- if (TRUE) 1 else object_that_does_not_exist
```

只要条件为真，R 就不会去查找后面的对象。

== 3. 缺少 `else` 时，`FALSE` 会得到 `NULL`

这是条件赋值中最值得留意的行为：没有 `else`，而条件又不满足，就没有任何分支被执行。按照 `if` 的定义，结果是 `NULL`。

```r
x <- if (FALSE) 200

x
# NULL
```

这会直接影响外部赋值的含义。

=== 3.1 外部赋值不会保留旧值

比较下面两段代码：

```r
x <- 100
x <- if (FALSE) 200

x
# NULL
```

```r
x <- 100
if (FALSE) x <- 200

x
# [1] 100
```

第一段中，条件为假只意味着没有执行 `200` 那个分支。外面的赋值仍然存在，它把 `if` 的结果 `NULL` 赋给了 `x`。第二段中，赋值本身位于分支内部。没有进入分支，就没有执行赋值，因此 `x` 保持原值。

这两种写法分别表达了不同的意图：

- `x <- if (...) ...`：根据条件计算一个结果，并赋给 `x`。
- `if (...) x <- ...`：只有条件满足时，才修改 `x`。

如果想要“条件满足时更新，否则保留已有值”，后一种形式更直接：

```r
x <- 100
cond <- FALSE

if (cond) {
  x <- 200
}
```

如果想要“无论如何都给 `x` 一个确定的结果”，则应该把默认结果写出来：

```r
x <- if (cond) 200 else 100
```

=== 3.2 `else if` 链条也需要检查最后的出口

多个条件并不能消除这个问题：

```r
x <- if (FALSE) {
  1
} else if (FALSE) {
  2
}

x
# NULL
```

R 中的 `else if` 可以理解为：`else` 后面又放了一个 `if` 表达式。前面的条件不满足，就继续求值后面的 `if`；最后仍然没有命中分支，就得到 `NULL`。

甚至外层有完整的 `else`，也不代表内部每条路径都能产生你想要的结果：

```r
x <- if (TRUE) {
  if (FALSE) 1
} else {
  2
}

x
# NULL
```

这里进入了外层的真分支，但该分支的结果来自一个没有 `else` 的内层 `if`，因此依然会返回 `NULL`。

=== 3.3 `NULL` 也可以是刻意设计的结果

并不是所有没有 `else` 的条件赋值都有问题。有些接口本来就用 `NULL` 表示“不提供这个选项”：

```r
use_names <- FALSE
labels <- if (use_names) letters[1:3]
```

如果作者明确知道 `labels` 在条件为假时应当为 `NULL`，这段代码的语义是合理的。R 自己的 `arrayInd()` 实现中，就有按 `useNames` 决定是否生成维度名称、否则使用 `NULL` 的类似写法。#footnote[#link("https://github.com/wch/r-source/blob/b5cf23a805f4305852f55c4148f2a302b06844b5/src/library/base/R/which.R#L32")[R 源码：`arrayInd()` 中有意使用缺省 `NULL` 的例子]。]

为了让这个默认结果更明确，更好的方式是写为：

```r
labels <- if (use_names) letters[1:3] else NULL
```

== 4. `NULL` 不只是“什么都没有”

=== 4.1 将变量赋值为 `NULL`

对于变量来说，`x` 仍然存在，只是它的值变成了 `NULL`。这与 `rm(x)` 删除变量绑定不同。

```r
x <- if (FALSE) 1

exists("x", inherits = FALSE)
# [1] TRUE

is.null(x)
# [1] TRUE
```

=== 4.2 列表/数据框中的 `NULL`

对于列表元素和数据框列，使用 `$<-` 或 `[[<-` 赋入 `NULL`，通常表示删除元素。以下代码原本可能只是想“条件满足时替换这一列”，结果却在条件不满足时删除了它。

```r
items <- list(a = 1, b = 2)
items$a <- if (FALSE) 3

names(items)
# [1] "b"

df <- data.frame(a = 1, b = 2)
df$a <- if (FALSE) 3

names(df)
# [1] "b"
```

=== 4.3 拼接时，`NULL` 可能直接消失

```r
c(1, if (FALSE) 2, 3)
# [1] 1 3
```

这种行为既可能导致意外的长度变化，也可以用于有意的条件拼接：

```r
verbose <- FALSE
args <- c("--input", "data.csv", if (verbose) "--verbose")

args
# [1] "--input" "data.csv"
```

关键在于后续代码是否把 `NULL` 当成了预期输入。

=== 4.4 不可见的 `NULL` 仍然是一个值

缺少 `else` 且条件为假时，`if` 返回的是#strong[不可见的 `NULL`]：

```r
withVisible(if (FALSE) 1)
# $value
# NULL
#
# $visible
# [1] FALSE
```

“不可见”只意味着在通常的顶层自动打印中不显示它，并不意味着没有返回值，也不会阻止赋值。而显式写出的 `else NULL` 通常返回可见的 `NULL`：

```r
withVisible(if (FALSE) 1 else NULL)
# $value
# NULL
#
# $visible
# [1] TRUE
```

`if` 也会保留选中分支的可见性：

```r
withVisible(if (TRUE) invisible(3) else 4)
# $value
# [1] 3
#
# $visible
# [1] FALSE
```

所以，判断结果是什么，应该查看值本身，而不能只根据控制台有没有自动显示内容。

== 5. 分支结果取决于最后一个表达式

单行分支的结果通常很直观，多行分支则要理解 `{ ... }` 的规则。

R 的大括号把多个表达式组合在一起，按顺序求值，并返回最后一个实际求值的表达式的结果及其可见性。#footnote[#link("https://stat.ethz.ch/R-manual/R-devel/library/base/html/Paren.html")[R：Parentheses and Braces]，参见大括号的结果与可见性。]

```r
x <- if (TRUE) {
  10
  20
} else {
  30
}

x
# [1] 20
```

这条规则既让多步计算变得方便，也带来了维护风险。

=== 5.1 加一条日志，可能改变结果

下面的代码返回数据框：

```r
df <- if (TRUE) {
  data.frame(a = 1)
} else {
  mtcars
}
```

如果在分支末尾添加一条消息：

```r
df <- if (TRUE) {
  data.frame(a = 1)
  message("创建完成")
} else {
  mtcars
}

df
# NULL
```

`message()` 返回不可见的 `NULL`，而它现在是分支中的最后一个表达式，因此这个条件赋值最终返回 `NULL`。

如果既要输出消息，又要返回数据框，需要把数据框明确放到最后：

```r
df <- if (TRUE) {
  out <- data.frame(a = 1)
  message("创建完成")
  out
} else {
  mtcars
}
```

需要注意，不同输出函数的返回值也不同。例如，与 `message()` 的行为不同，`print()` 通常不可见地返回它打印的对象，因此 `x <- print(mtcars)` 会在打印的同时将 `mtcars` 赋值给 `x`。

=== 5.2 最后一行是赋值，也会产生一个结果

R 的赋值表达式本身有值，通常是所赋的右侧值，并且不可见地返回。#footnote[#link("https://stat.ethz.ch/R-manual/R-devel/library/base/html/assignOps.html")[R：Assignment Operators]，参见赋值表达式与返回值。]

```r
result <- if (TRUE) {
  tmp <- 42
} else {
  0
}

result
# [1] 42
```

最容易误判的是替换赋值：

```r
result <- if (TRUE) {
  d <- data.frame(a = 1:2)
  d$a <- d$a * 2
} else {
  NULL
}

result
# [1] 2 4
```

最后一行虽然修改了数据框 `d`，但这个赋值表达式的结果是右侧的数值向量，而不是整个数据框。

若想返回数据框，需要在修改后补上 `d`：

```r
result <- if (TRUE) {
  d <- data.frame(a = 1:2)
  d$a <- d$a * 2
  d
} else {
  NULL
}
```

空代码块也是一个特殊情况。即使进入了一个分支，如果该分支是空块，得到的仍然是 `NULL`。

```r
is.null(if (TRUE) {} else 1)
# [1] TRUE
```

=== 5.3 大括号不会创建独立作用域

R 的 `{ ... }` 只是组织表达式，不会创建新的环境：

```r
x <- if (TRUE) {
  temporary <- 10
  temporary * 2
} else {
  0
}

temporary
# [1] 10
x
# [1] 20
```

在顶层执行时，`temporary` 留在顶层环境；在函数内部执行时，它位于该函数的调用环境。因此，`x <- if (...) { ... }` 可以让读者感觉“这段代码是在计算 `x`”，#strong[但它并不保证分支没有其他赋值或副作用]。

== 6. R 不会要求两个分支具有一致的类型

下面的代码完全合法：

```r
choose_value <- function(cond) {
  if (cond) 1L else "one"
}

typeof(choose_value(TRUE))
# [1] "integer"

typeof(choose_value(FALSE))
# [1] "character"
```

R 返回选中分支的结果，不会把两个分支放在一起检查，也不会主动求一个共同类型。即使两个分支都是数值，这一点仍然成立：

```r
typeof(if (TRUE) 1L else 2.5)
# [1] "integer"
```

未选中的 `2.5` 不会使 `1L` 自动提升为 double。

这种灵活性也有直接的好处：`if` 会保留选中对象的类和属性，不会为了逐元素拼接而重建结果。例如选择 `Date` 对象时，仍然得到 `Date`。

== 7. 与 Rust 相似，但不能照搬 Rust 的直觉

Rust 和 R 都允许把 `if` 当作产生值的表达式，这正是下面两段代码看起来很相似的原因：

```r
x <- if (cond) "this" else "that"
```

```rust
let x = if cond { "this" } else { "that" };
```

但 Rust Reference 要求，`if` 表达式在各种情况下具有一致的类型；如果没有执行任何分支，结果是单位值 `()`。#footnote[#link("https://doc.rust-lang.org/reference/expressions/if-expr.html")[Rust Reference：if expressions]。]

因此，下面这种普通数值分支与隐含单位值分支的组合无法通过编译：

```rust
// 无法编译：缺少 else，不能把整数结果与隐含的 () 匹配。
let x = if cond { 1 };
```

R 则允许一个分支产生数值，另一路径产生 `NULL`：

```r
cond <- FALSE
x <- if (cond) 1
```

两者还有其他差别：

#figure(
  table(
    columns: 3,
    align: (auto, auto, auto),
    table.header([方面], [R], [Rust]),
    table.hline(),
    [`if` 可以产生值], [可以], [可以],
    [分支类型], [不要求统一，也不自动寻找共同类型], [受静态类型规则约束，整个表达式需要一致的结果类型],
    [未命中分支且没有 `else`], [不可见的 `NULL`], [`()`，并受类型检查约束],
    [普通条件表达式], [单个非缺失逻辑值；部分其他类型可以转换], [`bool`；另有 `if let` 等模式匹配形式],
    [大括号], [不创建新的环境], [创建块作用域],
    [块末尾的分号], [不会因此丢弃最后表达式的值], [通常使尾表达式变成语句，块结果为 `()`],
  ),
  kind: table,
)

最后一项也很容易让跨语言使用者误判：

```r
if (TRUE) { 1; } else { 2; }
# [1] 1
```

在 R 里，末尾加一个分号，并不会让这个分支失去数值结果。

== 8. `ifelse()` 和 `if_else()` 不是直接替代品

看到 `x <- if (...) ... else ...`，有时会建议换成 `ifelse()`，或者换成类型规则更严格的 `dplyr::if_else()`。但在改写之前，必须先确定：你需要的是选择整个对象，还是按元素生成一个向量？

=== 8.1 `ifelse()` 的结果长度由 test 决定

```r
if (TRUE) 1:3 else 4:6
# [1] 1 2 3

ifelse(TRUE, 1:3, 4:6)
# [1] 1
```

`ifelse()` 的结果长度和形状主要由 `test`（条件）决定。`test` 只有一个元素，就不会因为 `yes` 是长度为 3 的向量而返回整个向量。对于向量条件，较短的 `yes`、`no` 还可能被循环使用。#footnote[#link("https://stat.ethz.ch/R-manual/R-devel/library/base/html/ifelse.html")[R：Conditional Element Selection]，参见 `ifelse()` 的长度、属性、求值和使用建议。] 因此 `ifelse()` 适合这样的逐元素操作：

```r
values <- c(-2, 0, 3)
ifelse(values > 0, "positive", "non-positive")
# [1] "non-positive" "non-positive" "positive"
```

这与根据一个条件选择整张表、整个模型或整个函数，是不同的任务。

=== 8.2 `ifelse()` 可能改变类型和属性

```r
d1 <- as.Date("2026-01-01")
d2 <- as.Date("2026-01-02")

class(if (TRUE) d1 else d2)
# [1] "Date"

class(ifelse(TRUE, d1, d2))
# [1] "numeric"
```

`ifelse()` 的结果属性主要来自 `test`，而不是完整继承被选分支对象的属性，因此可能丢失 `Date`、factor 等对象所需的类信息。

=== 8.3 向量化选择，不等于逐元素执行分支

`ifelse()` 也有条件求值行为：只要 `test` 中存在真值，就需要求值 `yes`；存在假值，就需要求值 `no`。如果条件全为真，它可以不求值 `no`：

```r
ifelse(TRUE, 1, stop("不会执行"))
# [1] 1
```

但当条件真假混合时，两侧通常都要计算。更重要的是，表达式会对它所使用的整个对象进行运算：

```r
values <- c(-1, 4)
ifelse(values >= 0, sqrt(values), NA_real_)
# [1] NA  2
# 同时出现警告：sqrt(values) 对 -1 计算时产生 NaN。
```

结果中虽然没有保留负数位置的平方根，计算 `sqrt(values)` 时仍然包含了负数。

如果想先排除无效输入，可以把选择放进计算内部：

```r
sqrt(ifelse(values >= 0, values, NA_real_))
# [1] NA  2
```

=== 8.4 `if_else()` 提供运行时的共同类型规则

`dplyr::if_else()` 会根据 `true`、`false`，以及适用时的 `missing` 参数确定共同类型，并检查大小规则。#footnote[#link("https://dplyr.tidyverse.org/reference/if_else.html")[dplyr：Vectorised if-else]。]

```r
# 报错：整数与字符不能按这里的规则组合为共同类型。
dplyr::if_else(TRUE, 1L, "one")

typeof(dplyr::if_else(TRUE, 1L, 2.5))
# [1] "double"
```

即使 `false` 分支没有贡献最终元素，它的类型仍然参与了结果类型的确定。

这通常也意味着两侧参数需要求值：

```r
# 报错：不能依靠 TRUE 来跳过 false 参数的计算。
dplyr::if_else(TRUE, 1, stop("仍然会求值"))
```

此外，它仍然是向量选择工具，不会用一个标量条件替你选择一个任意长度的完整对象：

```r
# 报错：条件长度为 1，分支长度为 3，不符合这里的大小规则。
dplyr::if_else(TRUE, 1:3, 4:6)
```

三种写法可以这样区分：

#figure(
  table(
    columns: 3,
    align: (auto, auto, auto),
    table.header([写法], [主要用途], [类型与求值特点]),
    table.hline(),
    [`if (...) ... else ...`], [单个条件下的流程控制或整体选值], [只执行选中分支，返回该分支结果],
    [`ifelse()`], [向量逐元素选择], [可能循环使用分支值、转换类型或改变类属性],
    [`dplyr::if_else()`], [具有共同类型与大小规则的向量选择], [运行时检查类型和大小，通常需要计算两侧参数],
  ),
  kind: table,
)

R 官方的 `ifelse()` 文档还特别指出，对于单个简单真假条件，`if (test) yes else no` 往往更合适。#footnote[#link("https://stat.ethz.ch/R-manual/R-devel/library/base/html/ifelse.html")[R：Conditional Element Selection]。]

== 9. 条件本身也有规则：`NA` 不等于 `FALSE`

无论是否从 `if` 赋值，条件都必须满足 `if` 的要求。在当前 R 中，条件应当是长度为 1、且不是 `NA` 的逻辑值。部分其他类型可以转换成逻辑值，但 R 并不是把任意“非空对象”都视为真。#footnote[#link("https://stat.ethz.ch/R-manual/R-devel/library/base/html/Control.html")[R：Control Flow]。]

例如，数值零转换为假，非零数值转换为真：

```r
if (0) "yes" else "no"
# [1] "no"

if (-1) "yes" else "no"
# [1] "yes"
```

以下条件则会报错：

```r
if (NA) 1 else 2
if (NULL) 1 else 2
if (logical(0)) 1 else 2
if (c(TRUE, FALSE)) 1 else 2
if ("hello") 1 else 2
```

特别要区分：`FALSE` 是一个有效判断，`NA` 表示判断结果缺失。后者不会自动进入 `else`。

另一种常见写法是：

```r
if (isTRUE(cond)) {
  # 只有 cond 为单个、非缺失的逻辑真时才执行。
}
```

这明确规定了“只有确实为真才进入分支”，但也会把 `NA`、长度不对等情况转成假。若这些输入本来应该被视为错误，就应先验证输入，而不是用 `isTRUE()` 默默绕过。

向量选择函数对此有不同的规定：

```r
ifelse(NA, 1, 2)
# [1] NA
```

`dplyr::if_else()` 还可以用 `missing` 参数指定条件为 `NA` 时的结果。不能把这些规则直接套到 `if` 上。

== 10. 函数参数、`return` 和语法位置的细节

=== 10.1 放在函数实参里时，可能延迟求值

这种写法也是合法的：

```r
cond <- TRUE
identity(if (cond) 1 else sqrt(pi))
```

如果使用命名实参，例如 `some_fn(arg = if (cond) 1 else sqrt(pi))`，其中的 `arg =` 是参数匹配语法，不是在调用环境里创建变量 `arg`。

对于普通 R 函数，实参通常作为 promise 传入，在需要时才求值。函数如果没有使用这个参数，连 `if` 的条件都可能不会执行：

```r
ignore <- function(arg) 42

ignore(if (stop("不会执行")) 1 else 2)
# [1] 42
```

这意味着，把内联实参提前提取成变量，虽然常常能改善可读性，也可能改变求值时机：

```r
# 提前求值时，这一行就会报错。
value <- if (stop("立即执行")) 1 else 2
```

对于有副作用、可能报错或计算昂贵的表达式，改写时应考虑这一点。使用非标准求值的函数还有自己的规则，不能一概视为普通函数调用。

另外，显式传入一个结果为 `NULL` 的表达式，不等于没有提供参数。函数默认值只会在参数未提供等相应情形下使用，不会因为已提供的参数求值成了 `NULL` 就自动接管。

```r
f <- function(arg = 100) arg

f()
# [1] 100

f(if (FALSE) 1)
# NULL
```

=== 10.2 `return()` 退出的是整个函数

```r
f <- function(cond) {
  x <- if (cond) return("提前退出") else "普通结果"
  paste("后续处理", x)
}

f(TRUE)
# [1] "提前退出"

f(FALSE)
# [1] "后续处理 普通结果"
```

`return()` 它直接退出所在函数。因此真分支中，外层对 `x` 的赋值没有完成，后面的 `paste()` 也不会执行。同理，循环中的 `break`、`next` 会转移循环控制，并不是返回一个普通的分支值。

== 11. 社区为什么会争论这种写法？

理解语义之后，再看风格争论，就能分清哪些担忧涉及实际行为，哪些属于阅读习惯。

2019 年，vctrs 的一个修复 PR 将原先的一行条件赋值展开成多行。Hadley 在审查中建议把 `idx <-` 移到分支内部，并说明当时还没有对应的原则。#footnote[#link("https://github.com/r-lib/vctrs/pull/329#discussion_r283047972")[r-lib/vctrs PR \#329 的相关审查评论]。] 随后，tidyverse/design 的 Issue \#71 专门讨论了“是否应该从 `if` 赋值”。#footnote[#link("https://github.com/tidyverse/design/issues/71")[tidyverse/design \#71：Don't assign from an if statement]。]

反对者的主要理由是：在较长的代码块里，阅读分支时还需要回头找外层的赋值，才能知道这个分支的结果最终交给谁。把赋值放进分支，可以使操作目的更局部、更显眼。

支持者也有合理理由：

- 外部的 `x <-` 一开始就告诉读者，整段代码是在计算 `x`。
- 变量名只写一次，避免两个分支中有一个漏改或拼错。
- 对于短表达式，`x <- if (cond) "this" else "that"` 很紧凑，也容易直接理解。

有人因此建议：当逻辑变复杂时，提取辅助函数，让主流程保留一个清楚的赋值：

```r
choose_label <- function(mode, bs_version) {
  if (mode %in% c("release", "default")) {
    if (bs_version == 3) "default" else "info"
  } else {
    "danger"
  }
}

label <- choose_label("release", 3)
```

函数让名称、作用域和职责更清楚，但函数体仍然需要正确设计各条返回路径；它不会自动消除隐式 `NULL` 或类型不稳定。

2021 年的 Issue \#131 延续了这个讨论。值得注意的是，Hadley 对嵌套代码的改写中，仍然保留了单行的 `version_label <- if (...) "default" else "info"`。#footnote[#link("https://github.com/tidyverse/design/issues/131")[tidyverse/design \#131：Assignment outside of if]。]

Jarl（R 语言的静态代码检查器） 的 Issue \#605 再次提出这个问题。作者希望提供一个可选规则，并提到自己观察到某些 AI 模型偏爱这种写法。#footnote[#link("https://github.com/etiennebacher/jarl/issues/605")[Jarl Issue \#605：New rule: flag assignment on if]。] 生态扫描新增了 186 个诊断后，维护者 Etienne Bacher 认为，很多开发者本来就知道条件为假时对象会是 `NULL`，并且正是想要这个结果。他进一步建议，重点关注这种模式：#footnote[#link("https://github.com/etiennebacher/jarl/pull/606")[Jarl PR \#606：`assignment_on_if_no_else`]，尤其是#link("https://github.com/etiennebacher/jarl/pull/606#issuecomment-5439685174")[维护者关于缩小检查范围的评论]。]

```r
x <- 1
x <- if (foo) y
```

如果前一个值在被使用之前就遭到覆盖，很可能是作者误以为 `1` 会作为条件为假时的默认值。而单独的：

```r
x <- if (foo) y
```

则可能是在有意构造“`y` 或 `NULL`”的结果，不宜一律报警。

== 12. 实际写代码时，怎样选择？

选择写法时，可以先问三个问题：这段代码是在选值还是在修改状态？各条路径会得到什么结果？读者能否轻松确认这些结果？

=== 12.1 简短、完整的选值，直接使用条件表达式

```r
verbose <- TRUE
level <- if (verbose) "debug" else "info"
```

这里两个分支都短，返回值清楚，赋值目标也一眼可见，没有必要仅仅因为它用了 `x <- if` 就拆开。

=== 12.2 条件成立才修改对象，把赋值放进分支

```r
timeout <- 30
use_long_timeout <- FALSE

if (use_long_timeout) {
  timeout <- 120
}
```

这清楚表达了“默认值已经存在，条件满足时才覆盖”。

=== 12.3 有意允许 `NULL` 时，让这个约定容易被看见

```r
use_labels <- FALSE
labels <- if (use_labels) letters[1:3] else NULL
```

省略 `else` 在语言层面是合法的；显式写出 `else NULL`，则有助于后来维护的人确认这是有意设计的值。

=== 12.4 分支复杂时，明确区分计算与副作用

如果分支里包含多次赋值、日志、嵌套条件，或者需要反复回看开头才能知道结果交给谁，就值得提取辅助函数，或改用分支内部的明确赋值。

若继续使用外部赋值，应使每个正常返回的分支末尾都清楚地给出预期对象，并留意后来添加的语句是否会改变结果。

=== 12.5 把类型与结构要求写成真正的契约

需要保证数值、长度、列名或类属性时，应通过返回值设计、输入输出验证和分支测试来保证。换一种排版、补上 `else` 或抽成函数，都不能代替这些约束。

对于 `x <- if (...) ... else ...`，真正值得审查的是每条执行路径，：#strong[条件是否有效，结果是否符合后续需要，副作用是否明确，默认行为是否符合作者意图。]

#html.elem("hr")

#quote-block[“万能的宇宙大人啊，告诉我未来会好吗？”]
#image("世末歌者.webp")
