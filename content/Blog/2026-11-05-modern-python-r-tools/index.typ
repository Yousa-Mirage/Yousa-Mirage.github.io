#import "../index.typ": template, tufted
#import "@preview/theorion:0.6.0": quote-block
#show: template.with(
  title: "我最喜欢的 Python 与 R 现代工具",
  author: "天然純真",
  date: datetime(year: 2026, month: 11, day: 5),
  description: "介绍一下现代化的 Python 和 R 工具",
)

= 我最喜欢的 Python 与 R 现代工具

今年年初，我翻译了 #link("https://www.practicalsignificance.com/about")[Ben Schneider] 的博客文章 #link("/Blog/2026-02-07-some-favorite-tools/")[2026 年展望：我最钟爱的几款数据科学工具]。其中介绍的内容我自己也很认同，但终究是翻译别人的文章。2026 年是 AI 编程大爆发的一年，我身边的人无论是做定量的还是做定性的还是做计算的，亦或者纯写开源代码的，几乎人手一个 Codex。Python 和 R 生态内也随之诞生了大量的新工具，让人眼花缭乱。

这篇文章我来介绍一些自己很喜欢的现代化工具，无一例外都是我经常使用的。希望能帮助读者沙里淘金，找到适合自己的工具，更新自己的工具箱，让自己工作更加高效。

== 1. 数据处理与计算

首先，还是先介绍数据处理包。R 的 #link("https://tidyverse.org/")[Tidyverse] 已经不用多介绍了，只要是数据量不大的数据分析任务，依然是第一选择。对于高性能计算，和 Ben Schneider 写的一样，我自己的推荐中也有 Polars 和 DuckDB。但我会多介绍 R 的新并行包 futurize 和数据文件格式 Parquet。

=== 1.1 futurize (R)

第一个要介绍的是 #link("https://futurize.futureverse.org/")[futurize] 包。这是一个 R 语言的并行计算工具包，2026 年 1 月 22 日首次提交到 CRAN，看名字就知道也是 futureverse 的一部分。它建立在 future 生态之上，能够通过一个魔法函数 `futurize()` 简单地并行化常用函数。

```r
# 安装 futureverse
# pak::pak("futureverse")

library(futurize)
plan(multisession) # once, at the top of your script

ys <- lapply(xs, fcn)
ys <- lapply(xs, fcn) |> futurize() # run in parallel

ys <- xs |> map(fcn)
ys <- xs |> map(fcn) |> futurize() # run in parallel

ys <- foreach(x = xs) %do% slow_fcn(x)
ys <- foreach(x = xs) %do% slow_fcn(x) |> futurize() # run in parallel

b <- boot(city, ratio, R = 999)
b <- boot(city, ratio, R = 999) |> futurize() # run in parallel
```

没错，并行变得如此简单。无论你使用 baseR 的 `lapply()`、tidyverse 的 `purrr::map_*()` 还是 foreach 的 `%do%`，都不需要改变编程风格或采用新的函数。唯一需要的就是写一个管道符 `|>` 和一个函数 `futurize()`。

`futurize()` 本质是在内部将计算重新使用 `future` 并行化，因此“只是”一层包装、转译而已。但这一层包装就让

futurize 包支持转译来自多个包的函数。可以用 `futurize_supported_packages()` 查询支持的包；可以用 `futurize_supported_functions(package)` 查询特定软件包支持哪些函数。

```r
# 查看 base 包支持的函数
futurize_supported_functions("base")
#>  [1] ".mapply"   "apply"     "by"        "eapply"    "Filter"    "lapply"   
#>  [7] "Map"       "mapply"    "replicate" "sapply"    "tapply"    "vapply"
```

其实在我刚学 R 还没有接触到 `future` 时，我是靠多开 RStudio 来手动并行的。。。而现在已经有 `futurize()` 这种极方便的魔法并行函数了，并行就方便了太多太多 :D

#quote-block[
  我想要太多太多 灿如朝日\
  光芒透入方寸鱼池\
  追光而去上浮便知\
  幸福遍布人世
]

=== 1.2 Parquet

#link("https://parquet.apache.org/")[Parquet] 是一种开源的列式存储格式，现在由 Apache 基金会维护。它是为分析型工作负载设计的二进制数据格式：数据按列而不是按行存储，每列可以独立编码、压缩和读取。

这也是它和 CSV、Excel 最根本的区别。CSV 是纯文本、按行组织，所有值都是字符串，读取时再推断类型；Excel 则把数据、格式、公式、合并单元格混在一个工作簿里。两者都适合小规模、需要人工查看或编辑的场景，但一旦数据变大、变复杂，问题就会暴露：

- *类型不可靠*：CSV 里的 `001`、`NA`、`2026-01-01` 都要靠读取时猜；日期、时区、小数精度、缺失值在不同工具里可能得到不同结果。
- *不支持复杂类型*：列表、嵌套结构、字典这类数据，CSV 只能拆成多张表或塞进 JSON 字符串。
- *按行存储，读取慢*：分析通常只用到少数几列，但 CSV/Excel 必须把整行、甚至整个文件读进来再解析。
- *体积大、压缩差*：文本格式重复多，压缩率有限；Excel 的 XML/zip 结构更臃肿。

而 Parquet 的优势正好对应这些点：

+ *列式存储*：只读取查询用到的列，I/O 和内存占用都更小；同一列的数据类型一致，压缩和编码效率更高。
+ *自带完整的数据结构*：整数、浮点、布尔、字符串、日期时间等类型，以及 list、struct、map 等嵌套类型都能原样保存，并且内嵌了元数据表。
+ *高效编码与压缩*：配合 Zstd 等压缩算法和分块储存，文件体积通常比 CSV 小很多。
+ *可并行、可下推*：文件按 row group（一组行）切分，多个线程/进程可以并行读取；谓词下推让查询只扫描可能匹配的数据块。
+ *生态互通*：Polars、DuckDB、Arrow、Spark 等工具都能直接读写、查询。

本地实测，一个 500 万行、20 列的由数字、日期、字符串组成的 CSV 文件体积为 1053.34 MB，转换为 Zstd Parquet 后体积为 438.84 MB，体积减少 58.34%。

在 Python、R 和 DuckDB 里读写 Parquet 都很简单：

```py
import polars as pl

df = pl.read_parquet("data.parquet") # 读取 Parquet 文件
df.write_parquet("data.parquet")     # 写入 Parquet 文件
```

```r
df <- arrow::read_parquet("data.parquet") # 读取 Parquet 文件
arrow::write_parquet(df, "data.parquet")  # 写入 Parquet 文件
```

```sql
-- 使用 DuckDB
SELECT * FROM 'data.parquet';
COPY (SELECT * FROM 'data.csv') TO 'data.parquet';
```

此外，Positron 自带的数据分析器可以直接打开 Parquet 文件，将其展示为类似电子表格的可视化形式，非常方便。

不过 Parquet 也不是万能的。它适合“一次写入、多次读取”的分析型数据；如果你需要手动修改单元格、要让人直接打开看，或者数据只有几百行，CSV/Excel 则更合适。

=== 1.3 Polars

这是本号的老朋友了，是博主的心头之好。自从用了 Polars 后，我的

=== 1.4 DuckDB

== 2. 代码检查与格式化

格式化工具负责调整代码的布局。格式化不会改变代码的含义；它们只确保空格、换行符和其他标点符号符合一系列规则和标准。Ruff、Air 等格式化工具会自动强制你编写清晰易读的代码，代码宽度适中，语法元素之间留有适当的空间。有了代码格式化工具的辅助，编写代码的过程会大大改善，因为你不再需要过多考虑代码风格——格式化工具会为你完成这项工作。

我最初接触到的代码静态检查工具应该是 PyCharm 和 RStudio 自带的检查。接触到代码格式化工具则要晚得多，当时还是 RStudio 中的 `styler` 插件，并且当时没有感觉到这个东西到底有什么用。而时至今日，代码静态检查工具和格式化工具早已是我离不开的工具了，它们能帮助写出更加规范、更高质量、风格更统一的代码，以至于现在看到写成一坨的代码就会浑身不舒服。

这里不再介绍那些生态中的传统工具，而是介绍我自己每天都在使用的现代化工具：Python 的 `ruff`、`ty`，R 的 `air`、`jarl`。

=== 2.1 Ruff (Python)

#link("https://docs.astral.sh/ruff/")[`ruff`] 是由 Astral 公司开发的 Python 代码检查与格式化工具。用于替代 `black` 等传统工具。其检查速度极快，单二进制文件，只需要 `ruff check .` 即可检查项目中的全部 Python 文件，使用 `ruff format .` 即可格式化全部 Python 文件。其内置了 900 多条稳定规则，覆盖 Flake8、isort 等传统 linter 的常见检查；`ruff format` 则与 Black 高度兼容。

Ruff 官方给出的速度对比如下:

#image("ruff.png")

Ruff 能够查找编程错误、漏洞和可疑的代码模式。Ruff 默认只启用一组精选规则；为了同时展示三类问题，下面用 `--select E,F,S` 打开 pycodestyle（E）、Pyflakes（F）和 flake8-bandit（S）三组规则。比如这段代码：

```py
import os
import pickle

def load(path, user_input):
    if path == None:
        return None
    with open(path, "rb") as f:
        data = pickle.load(f)
    eval(user_input)
    return data
```

运行：

```sh
$ ruff check --select E,F,S --output-format concise example.py
example.py:1:8: F401 [*] `os` imported but unused
example.py:5:16: E711 Comparison to `None` should be `cond is None`
example.py:8:16: S301 `pickle` and modules that wrap it can be unsafe when used to deserialize untrusted data, possible security issue
example.py:9:5: S307 Use of possibly insecure function; consider using `ast.literal_eval`
Found 4 errors.
[*] 1 fixable with `--fix` (1 unsafe fix available with `--fix --unsafe-fixes`).
```

`F401` 是未使用的导入，`E711` 是 `== None` 这种可疑写法，`S301` 和 `S307` 则分别对应不安全的反序列化和 `eval` 调用。加上 `--fix`，Ruff 还能自动修掉其中一部分问题。

Ruff 的格式化效果如下：

```py
# Input
def _make_ssl_transport(
    rawsock, protocol, sslcontext, waiter=None,
    *, server_side=False, server_hostname=None,
    extra=None, server=None,
    ssl_handshake_timeout=None,
    call_connection_made=True):
    '''Make an SSL transport.'''
    if waiter is None:
      waiter = Future(loop=loop)

    ...

# Ruff
def _make_ssl_transport(
    rawsock,
    protocol,
    sslcontext,
    waiter=None,
    *,
    server_side=False,
    server_hostname=None,
    extra=None,
    server=None,
    ssl_handshake_timeout=None,
    call_connection_made=True,
):
    """Make an SSL transport."""
    if waiter is None:
        waiter = Future(loop=loop)

    ...
```

推荐在 VS Code 中安装 `ruff` 扩展来使用它，Positron 则已经内置了 `ruff` 支持。

=== 2.2 ty (Python)

近年来 Python 的一大趋势是类型注解。尽管 Python 是一门动态类型语言，但动态类型不等于没有类型。显式类型注解有助于提供更丰富的信息，让工具进行更好的补全，也有助于减少代码中的错误。推荐尽可能多的在 Python 脚本中编写类型注解和注释。

#link("https://docs.astral.sh/ty/")[`ty`] 是由 Astral 公司开发的 Python 类型检查工具与语言服务器，目前处于 Beta 版本，但已高度可用。它速度极快，单二进制文件，只需要 `ty check .` 即可检查项目中的全部 Python 文件。可以在 VS Code 或 Positron 中安装 `ty` 扩展使用。

例如这个代码：

```py
def add(a, b):
    return a + b
result = add(1, 2)
```

我们并不知道 `add()` 函数能够接受什么类型的参数，也不知道 `add()` 函数的返回值类型，也就不知道 `result` 的类型，最终也就不知道 `result` 能够调用什么方法。这时候，我们就有必要为其添加上类型注解：

```py
def add(a: int, b: int) -> int:
    return a + b
result = add(1, 2)
```

这样一来，我们清晰地了解了参数和返回值的类型。如果我们传入错误的参数：

```py
result = add("a", "b")
```

那么 `ty` 就会检查出这个错误并报告出来，尽管上述代码依然是可以运行的，因为 Python 不会在运行时自动检查类型。

```sh
$ ty check test.py

error[invalid-argument-type]: Argument to function `add` is incorrect
 --> test.py:3:14
  |
3 | result = add("a", "b")
  |              ^^^ Expected `int`, found `Literal["a"]`
info: Function defined here
 --> test.py:1:5
  |
1 | def add(a: int, b: int) -> int:
  |     ^^^ ------ Parameter declared here
```

与 `ty` 类似的新检查工具还有 Meta 公司开发的 #link("https://pyrefly.org")[`pyrefly`]，其已经实现了正式版，对 beta 版有生产顾虑的读者可以考虑 `pyrefly`。Positron 预置了 `pyrefly` 扩展，但我个人则会卸载它并安装 `ty`。

=== 2.3 Air (R)

#link("https://posit-dev.github.io/air/")[Air] 是 Posit 公司开发的新一代 R 语言格式化工具。速度极快、单二进制文件，只需要 `air format .` 即可格式化项目中的全部 R 文件。Air 是 styler 的后继者。纯 `.R` 项目可以直接换用 Air；VS Code/Positron 里的 Quarto R 单元格也能通过 Quarto 扩展调用 Air。

例如这个 bad case：

```r
a=b*5 |> sum( ) |>
  mean(na.rm=TRUE)
```

将会被格式化为清晰的代码：

```r
a <- b * 5 |> sum() |> mean(na.rm = TRUE)
```

Air 提供的#link("https://posit-dev.github.io/air/configuration.html")[自定义配置]比较少，但仍然建议在项目中配置一个 `air.toml` 文件。你可以通过 `usethis::use_air()` 来快速生成一个默认的 `air.toml` 文件。`air.toml` 文件能确保团队成员、代码编辑器以及持续集成 (CI) 环境中的设置保持一致。如果你只想保持默认，可以保持 `air.toml` 为空。在具体配置参数上，`exclude` 可以方便地跳过一些文件，例如自动生成的文件；`skip` 则可以跳过一些函数的格式化，保持自定义的代码样式。其余则推荐保持默认。

值得注意的是，Air 只支持扁平布局和展开布局，而不支持过去 RStudio 中常见的悬挂布局：

```r
# 悬挂布局（Hanging indent）
fn <- function(this,
               that,
               those) {
  this + that + those
}
```

这是刻意设计的，因为这种悬挂布局有两个重大问题：1. 如果一行参数的缩进发生变化，其他参数的缩进也需要随之变化，从而导致不必要的代码差异；2. 参数前的缩进可能并非 2 或 4 的倍数，导致制表符和空格无法转换或缩进高亮产生异常，许多编辑器和插件难以处理。

除了命令行中，还可以安装 VS Code 插件来使用 Air。Positron 则已经默认集成了 Air，可开箱即用。如果在 RStudio 中，则需要配置外部命令行工具。

=== 2.4 Jarl (R)

#link("https://jarl.etiennebacher.com")[Jarl] 是 Etienne Bacher 开发的新一代 R 代码静态检查工具，用来查找编程错误、漏洞和可疑的代码模式，并尽可能提供自动修复。其检查规则大量来自 #link("https://lintr.r-lib.org/")[lintr]，目前已有约 90 条规则。相比于 `lintr`，Jarl 的检查速度极快、使用更友好。只需要 `jarl check .` 命令即可检查项目中所有 R 文件中的问题代码。

可以在 VS Code 或 Positron 中安装 Jarl 插件来提供检查，也可以通过命令行进行检查。例如如下代码：

```r
!(a > b)
any(is.na(x))
x + - y
paste("a", , "b")
```

在安装插件后，Jarl 会进行检查并报告：

#image("jarl.png")

在命令行中同理，运行 `jarl check .` 后可以得到清晰的输出：

```sh
$ jarl check .

warning: comparison_negation
 --> test.R:1:1
  |
1 | !(a > b)
  | -------- `!(x > y)` can be simplified.
  |
  = help: Use `x <= y` instead.

warning: any_is_na
 --> test.R:2:1
  |
2 | any(is.na(x))
  | ------------- `any(is.na(...))` is inefficient.
  |
  = help: Use `anyNA(...)` instead.

warning: consecutive_signs
 --> test.R:3:3
  |
3 | x + - y
  |   --- Consecutive `+` and `-` operators are usually unnecessary and look like a typo.
  |
  = help: Consider removing the unnecessary operators or using parentheses to show that this is intentional.

warning: missing_argument
 --> test.R:4:1
  |
4 | paste("a", , "b")
  | ----------------- Argument 2 is empty.
  |
  = help: Consider removing or filling them.


── Summary ──────────────────────────────────────
Found 4 errors.
```

笔者为 Jarl 做了大量贡献，推荐在任何 R 项目中使用！

== 3. 环境管理

以前，Python 的环境管理绝对中是一个非常麻烦、非常恶心、经常出问题的话题，十几年来涌现了无数的工具试图解决这一问题。而 R 生态由于有 CRAN 的存在，依赖冲突则往往并不是一个严重的问题，对于“环境管理”“依赖管理”“可复现性”往往没有特别重视，`renv` 也足够使用。

然而，随着 `uv` 的横空出世，上述状态得到了戏剧性的逆转。`uv` 以极快的速度席卷了 Python 社区，并且似乎已经成为了那个一统天下的包和项目管理器。项目管理、虚拟环境、依赖管理、Python 版本管理，都被 `uv` 快速、简单地解决了。反而是 R 社区在看到 `uv` 大获成功之后开始反思 R 目前的环境管理工具，并迫切推出了一系列模仿 `uv` 的 Vibe Coding 作品，例如 `uvr`、`rv`、`ir`、`rig proj` 等。这些工具互不相通、互相割裂，有的甚至让人怀疑其代码质量。我会重点介绍三个工具：Python 的 `uv`，R 的 `rig`，以及面向 Conda 的现代化替代 `pixi`。

=== 3.1 uv (Python)

=== 3.2 rig (R)

=== 3.3 pixi (Conda)

在我看来，对于“Python 环境难配”这个说法#footnote[或者说谣传]，Conda 绝对难辞其咎。Conda 本身重、大、慢，而且其环境配置逻辑也并不符合直觉。小白随便一搜，可能就装上了动辄 10GB+ 的 Anaconda，还可能装上后面对各种入口眼花缭乱完全不知道怎么使用#footnote[我知道有 miniconda，但也不妨碍我讨厌 conda。更准确的说，我讨厌 conda 被装在电脑上的那一坨，而不是 conda 仓库。]。

== 4. 文档工具

quarto、typst



quarto+typst 能基本实现实时预览

不再单独讲了

== 5. IDE

下面是我喜欢的 IDE。我自己的日常开发以 Positron 为主，以 Zed 为辅，而 arf 则是一个现代化的 R console。

=== 5.1 Positron

Positron 有几个新功能

重写的笔记本支持
 quarto 的内联输出
 自带的包管理功能
 

=== 5.2 Zed

Zed 是一个很新的编辑器。

=== 5.3 arf

arf 是 radian 的现代化替代品，速度更快、功能更多、bug 更少。

Positron、Zed、arf

Positron 支持了 Jupyter 和 quarto

arf 是 radian 的现代化替代品，速度更快、功能更多、bug 更少

zed 更加轻量，写东西很舒服

== 6. 流程编排与命令整合

just

== 7. 最佳语言

Rust

pyo3、extendr、savvy