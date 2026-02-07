# 2026 年展望：我最钟爱的几款数据科学工具

> 本博文旨在盘点我在迎接新的一年之际，最令我期待和兴奋的若干数据科学工具。
>
> 本文翻译自 [Ben Schneider](https://www.practicalsignificance.com/about) 于
> 2026 年 1 月 21 日发布的博客文章 [_Some Favorite Data Science Tools Going into 2026_](https://www.practicalsignificance.com/posts/favorite-data-science-tools-going-into-2026/)，一切权利归原作者所有，本文仅做翻译、学习用途。

在过去一年里，我参与的项目对软件灵活性提出了越来越高的要求。一个可能的典型流程是：先使用 Python 脚本爬取网页数据，
接着用 R 语言进行数据清洗并将其加载到数据库中，最后由分析师通过 SQL 进行查询。这些工作既可以在笔记本电脑的本地环境上完成，
也可以完全在 Databricks 或 Palantir Foundry 等平台上运行。为了管理不同版本的脚本，我可能周一还在用 GitHub，
周二就换成了 GitLab，到了周三又得切换到 Bitbucket。面对今年这些多得令人眼花缭乱的工具，我想花点时间重点介绍几款我真正喜欢使用的利器。
希望其他统计学家和数据科学家也能觉得这份清单对自己有价值，并在 2026 年将这些新工具纳入自己的"工具箱"中。

## 数据处理工具

首先，我想重点介绍几款我日常工作中离不开的数据处理包。

### dplyr (R)

R 语言中的 [`dplyr`](https://www.tidyverse.org/packages/) 包依然是我最喜欢的数据处理工具。
其优雅的语法允许使用者将分析过程拆解为一系列清晰的步骤，相比原生 R（Base R）或我在 R 语言之外见过的任何工具，它生成的代码在可读性上都遥遥领先。
`dplyr` 不仅启发了其他编程语言中的相关扩展
（例如 Julia 中的 [`TidierData`](https://tidierorg.github.io/TidierData.jl/latest/)），
还深刻影响了 Python 中两款日益流行的处理包——[`Polars`](https://docs.pola.rs/) 和
[`Ibis`](https://ibis-project.org/) （这两者的操作体验都比 Pandas 流畅得多）。

`dplyr` 今年让我爱不释手的一个强大特性，在于它编写的代码能够无缝适配多种不同的计算后端。同一段 `dplyr` 代码，
既能处理从 CSV 文件加载到 R 环境的数据，也能直接操作存储在数据库中的海量数据集。

> 译者注：通过 [`dbplyr`](https://dbplyr.tidyverse.org/) 包直接操作数据库。

此外，还有一些 R 包支持通过 `dplyr` 语法处理存储在 Parquet 或 Apache Arrow 文件中的大型数据集。

> 译者注：可参考 R4DS 书中 [22 Arrow 章节](https://r4ds.hadley.nz/arrow.html#sec-parquet)。

最近，我特别热衷于使用 [`duckplyr`](https://duckplyr.tidyverse.org/) 包，它对 `dplyr` 进行了增强，
使其能够调用 _DuckDB_ 计算引擎来高效处理数据库或 Parquet/Arrow 文件中的数据。而这也正引出了我要介绍的下一个工具。

### DuckDB

[DuckDB](https://duckdb.org/) 是我近期接触到的心头好之一。作为一款关系型数据库管理系统（RDMS），
它极大地简化了数据库内数据的存储与分析流程。有了它，你就能快速处理那些足以让普通电脑罢工的海量数据集。与 PostgreSQL 这种传统的 RDMS 相比，
DuckDB 十分轻量且安装简便。而在分析性能上，它也远超 SQLite 或 MariaDB 等其他开源选项，速度更快、效率更高。

> 译者注：笔者的经验是，相比于 Lazy Polars，DuckDB 常常能带来更高效的内存使用，从而在爆内存的场景下带来更快的速度。

由于 DuckDB 是一款 SQL 数据库，当你的团队成员语言偏好各异时——有人钟情于 R，有人偏爱 Python，还有人仍在使用像 SAS 或 SPSS
这种笨重的**古代工具**——它便成了一个极佳的协作工具。SQL 是一门通用语言，绝大多数数据科学家都被要求具备其读写能力；而在当下，
几乎所有 AI 工具都已经能轻松编写 SQL，或用通俗易懂的语言解析其逻辑。即便如此，如果你想利用 DuckDB 的威力却又想避开原生 SQL，
也可以使用 `duckplyr` 或 `Ibis` 等工具包。

> 译者注：例如 `duckplyr` 包能够将 tidy 语法流程和 DuckDB 的超高性能结合起来。

对于大多数数据科学家来说，安装和使用它的最简单方法是通过 [R 包](https://cran.r-project.org/web/packages/duckdb/readme/README.html)
或 [Python 库](https://duckdb.org/docs/stable/clients/python/overview)。

### Ibis (Python)

在 Python 生态中，与 `dplyr` 最接近的替代方案当属 [`Ibis` 包](https://ibis-project.org/)。
它拥有与 `dplyr` 相似的语法，并允许你编写能够适配多种不同数据后端的代码。这使得开发者可以轻松编写出既能处理笔记本电脑上的小型数据集，又能应对远程数据库中海量数据的通用代码。
目前还有一个名为 [`narwhals`](https://narwhals-dev.github.io/narwhals/installation/) 的类似新项目，
它更侧重于兼容 `Polars` 的用户界面，尽管到目前为止，比起 `narwhals`，我个人还是更青睐 `Ibis` 的语法和设计。

> 译者注：关于 `narwhals`，推荐阅读 CodeCut 上的这篇文章：
> [_Narwhals: Unified DataFrame Functions for pandas, Polars, and PySpark_](https://codecut.ai/unified-dataframe-functions-pandas-polars-pyspark/)

### Polars (Python and R)

译者注：本博客已经出过两篇介绍 `Polars` 的文章了！

Python 的 [`Polars`](https://docs.pola.rs/) 库是近年来 Python 数据科学生态系统中出现的最佳利器之一。在几乎所有维度上，
它都是 `Pandas` 绝佳的替代方案。虽然它的代码可读性仍略逊于 `dplyr`，但这已是 Python 环境下最接近完美的一次尝试。
对我个人而言，选择 `Polars` 而非 `Pandas` 的核心动力在于其出色的用户界面（API 设计），而更广泛的 Python 社区则多是被其惊人的计算速度所折服。
令人欣慰的是，`Polars` 在过去两年中迎来了爆发式增长，越来越多的开发者正告别笨重过时的 `Pandas`，全面拥抱 `Polars`。

> 译者注：笔者认为并不逊色，事实上在接触 `Polars` 后我已经完全使用 Python 进行数据处理工作了。

`Polars` 并不局限于 Python 平台。其核心是一个 Rust 库，只是拥有一个广受欢迎的 Python 接口。但就像 Python 包一样，
R 语言中也有几个优秀的包为 Rust 核心提供了用户接口。其中我最钟爱的是 `tidypolars`，它能让用户在保留习惯的 `dplyr` 编写方式的同时，
获取 `Polars` 带来的强大性能。此外，还有一个直接命名为 `polars` 的 R 包，其接口风格与 `Polars` 的 Rust 及 Python 原生接口高度一致。
虽然我个人目前并不经常使用 `polars` 包提供的原生 R 接口，但不可否认它们在某些特定场景下非常有价值。

> 译者注：笔者是 `tidypolars` 包除原作者外贡献最多的人。但 `tidypolars` 并没有为所有的 `dplyr`、`tidyr`、`stringr`
的操作提供接口，因此有些功能必须回退到 `polars` 包提供的原生表达。此外，对于有些 `Polars` 难以实现的功能（例如 `unnest_wider()`），
仍然需要和 R 原生数据框进行转换。

### Apache Arrow

译者注：此处笔者没有进行完整翻译，因为 Apache Arrow 更多是作为数据后端发光发热，而不是被用户直接使用。

[Apache Arrow 项目](https://github.com/apache/arrow)并非像上面提到的其他工具那样的数据处理软件包，尽管它们密切相关。
该项目主要为数据提供了高效的内存格式和存储格式，因此，即使你不直接使用 `arrow` 包，也可能在不知不觉中受益于 Arrow。

译者注：例如，`Polars` 默认的数据后端正是 Arrow；`Pandas` 在 3.0 版本中正式支持以 Arrow 为默认后端，从而极大提高字符串列处理性能；
`duckplyr` 在处理数据时数据也是以 Arrow 格式流转；高效的 Parquet 存储格式也是 Arrow 项目的作品。

## 文档沟通工具

### Quarto

[Quarto](https://quarto.org/) 是一款出色的内容创作与交流工具：它可以用来编写报告、演示文稿、书籍、博客、软件文档、网站等等。
它是一种["文学化编程"（Literate Programming）](https://en.wikipedia.org/wiki/Literate_programming)工具，将说明文本、代码及其运行输出完美结合。
Quarto 是从 [RMarkdown](https://rmarkdown.rstudio.com/) 演变而来的更强大的版本，其设计初衷就是让 RMarkdown 用户能够无缝切换。
事实上，这个博客网站最初就是用 RMarkdown 编写的，后来我只花了一个下午的时间就将其转换成了 Quarto。

译者注：指[原作者的博客网站](https://www.practicalsignificance.com/)。本博客网站由 [Typst](https://typst.app/) 编写，Typst 是一款出色、轻便、极快的排版软件。

我非常喜欢使用 Quarto 的一个场景是为 R 包编写文档：R 语言中的 [`pkgdown`](https://pkgdown.r-lib.org/articles/pkgdown.html) 包让生成基于 Quarto 的 R 包文档网站变得异常简单。在 Python 中目前还没有完全与之对等的工具，虽然 [Sphinx](https://www.sphinx-doc.org/) 和 [quartodoc](https://github.com/machow/quartodoc) 也能实现类似的功能。今年我一直在使用 Sphinx 来维护一些遗留软件，并尝试进行一些 Python 开发。那段经历让我更加期待 quartodoc（一个用于编写 Python 库文档的包）能在未来一年里流行开来。

Quarto 不仅擅长生成文档，还可以用于制作 Notebook。你可以使用 Quarto 生成 Jupyter 和 [marimo notebook](https://marimo-team.github.io/quarto-marimo/tutorials/intro.html)，甚至可以在 Quarto 文档中[嵌入 Shiny 应用](https://quarto.org/docs/blog/posts/2022-10-25-shinylive-extension/)。

### WebR, Pyodide 和 Shinylive

开源软件中一个令人兴奋的趋势是，得益于 [WebAssembly (Wasm)](https://webassembly.org/) 技术，现在已经能够完全在浏览器中本地运行数据科学软件。借助 [`WebR`](https://docs.r-wasm.org/webr/latest/) 以及类似的 Python 项目 [`Pyodide`](https://pyodide.org/en/stable/)，在浏览器中运行 R 和 Python 已变得轻而易举。这意味着，如果你想分享一些使用 R 或 Python 的代码或 Web 应用程序，不再需要运行动态 Web 服务器。你只需将一系列文件放置在便宜的**静态** Web 服务器上，就能以极低的成本服务大量用户。

译者注：因为代码或程序并不运行在服务器上，而是在浏览器提供的沙箱中本地运行。换言之，消耗的并不是远程服务器的资源，而是用户本地机器在执行代码。因此，你可以将程序部署在诸如 GitHub Pages、Cloudfare Pages 等免费的静态站点上，从而既不用花钱购买域名，也不用花钱租用服务器。

Posit 公司（前身为 RStudio）开发了一个名为 `Shinylive` 的框架，让我们能够以这种方式部署使用 [R](https://posit-dev.github.io/r-shinylive/) 或 [Python](https://shiny.posit.co/py/get-started/shinylive.html) 编写的 Shiny 应用。这为数据科学家快速部署 Shiny 应用提供了一个极佳的选择。

## 依赖管理 / 环境管理 (Python)

### uv

我以前很讨厌使用 Python，主要原因有两个：

- Pandas 笨重且晦涩的语法
- 令人抓狂的"依赖地狱"

所幸的是，随着新工具的崛起，尤其是 `Polars` 和 `Ibis` 的出现，`Pandas` 在 Python 生态中已不再是唯一的选择。与此同时，一款出色的新型依赖管理工具大大减少了我在 Python 依赖管理方面的头疼事。这款名为 [_uv_](https://docs.astral.sh/uv/) 的工具是一个极其强大的包管理和项目管理利器，它拥有令人耳目一新的交互体验和惊人的运行速度。_uv_ 提供了一个更优越的一站式方案，足以替代 `pip`、`poetry`、`pyenv` 以及 `virtualenv` 等多种工具。它有效地清理并简化了近年来日益碎片化的 Python 包管理生态。

译者注：更多关于 _uv_ 的介绍可见本博客的[另一篇文章](../2025-07-09-python-rgonomics/)。

我在 Python 中使用 _uv_ 的体验，不禁让我希望 R 语言也能拥有类似的利器。总的来说，我发现 R 语言的依赖管理要轻松得多，这很大程度上归功于 [CRAN](<https://en.wikipedia.org/wiki/R_package#Comprehensive_R_Archive_Network_(CRAN)>)——它维护着一套严格的标准和兼容性保证，而这在 Python 的对应平台 [PyPI](https://pypi.org/) 中几乎是完全缺失的。

译者注：CRAN 也并非完美无缺，其严格的包审查机制常常导致部分常用包被移除（例如 [jiebaR](https://cran.r-project.org/web/packages/jiebaR/index.html)）。

即便如此，在 R 项目中，你往往还是需要一套正式的依赖管理工具。[Docker](https://www.docker.com/) 和 [Nix](https://nixos.org/) 固然出色，但它们的学习曲线过于陡峭。目前看来，[`renv`](https://rstudio.github.io/renv/index.html) 包似乎是 R 语言中最优秀的轻量级包管理器，尽管在深入体验过 [`rix`](https://cran.r-project.org/web/packages/rix/readme/README.html) 包后，我的看法可能会有所改变。

## 代码编辑器 / IDE

只要我坐在办公桌前，多半不是在盯着 Outlook、Word 文档，就是在用 RStudio 这样的集成开发环境（IDE）。而最近这段时间，我使用的几乎全是 Positron。

译者注：我个人的推荐是使用 Positron 进行 R 语言编程和开发，但也有不少人依旧习惯 RStudio。Positron 是 Posit 的开发重点，也必然是未来的选择，哪怕仍然使用 RStudio 作为主力开发软件，我也推荐下载、体验、熟悉 Positron。

### Positron

根据我的经验，[Positron](https://positron.posit.co/) 是目前数据科学家和统计学家的最佳选择，无论你是在编写 R、Python 还是 Julia 代码。Positron 由 RStudio 的开发商 Posit 公司打造，基于 VS Code 的开源版本构建。因此，它将 RStudio 那些出色的、以数据为中心的功能（如变量监控和绘图面板）与 VS Code 的灵活性及强大的扩展性完美结合。这感觉就像是兼顾了两个世界的长处。

与 VS Code 不同，安装 Positron 后运行 R 或 Python 极其简单，你完全不需要再折腾像 [`radian`](https://github.com/randy3k/radian) 这样的扩展插件。查看图表、渲染 Quarto 文档、预览数据集……所有这些功能都做到了开箱即用。而且相比于 RStudio，在 Positron 中处理远程 SSH 会话或 WSL (Windows Subsystem for Linux) 等高级操作要容易得多。所以，别犹豫了，快去试一试吧。
