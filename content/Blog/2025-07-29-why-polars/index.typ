#import "../index.typ": template, tufted
#import "@preview/theorion:0.4.1": *
#show: template.with(
  title: "我为什么放弃 Pandas 而转用 Polars？",
  date: datetime(year: 2025, month: 7, day: 29),
)

#{
  tufted.margin-note[
    本文转载、翻译自 Ari Lamstein 发表于 2024.9.4 的博客文章 #link("https://arilamstein.com/blog/2024/09/04/why-im-switching-to-polars/")[_Why I’m Switching to Polars_]，这篇文章通过比较 Polars 和 Pandas、Tidyverse 和 Base R 在实现一个基本数据分析任务上的差异，展示了促使其由 Pandas 转向 Polars 的原因。
  ]
  tufted.margin-note[正文字数：5467]
}

= 我为什么放弃 Pandas 而转用 Polars？

#image("img/pandas & polars.webp", alt: "Pandas vs Polars")

== 1. Polars 简介与性能

#tufted.margin-note[
  这一部分转载自古明地盆的博客文章#link("https://www.cnblogs.com/traditional/p/17959796")[《数据处理神器可不止 Pandas 哦，还有 Polars，全方位解析 Polars》]
]

Python 在数据处理领域有如今的地位，和 Pandas 的存在密不可分，然而除了 Pandas 之外，还有一个库也在为 Python 的数据处理添砖加瓦，它就是我们本次要介绍的 #link("https://pola.rs/")[Polars]。和 Pandas 相比，Polars 的速度更快，执行常见运算的速度是 Pandas 的 5 到 10 倍。另外 Polars 运算的内存需求也明显小于 Pandas，Pandas 需要数据集大小的 5 到 10 倍左右的内存来执行运算，而 Polars 需要 2 到 4 倍。之所以会有这种性能，是因为 Polars 在设计上从一开始就以性能为宗旨，并通过多种方式实现。

- 用 Rust 编写

  Rust 是一种几乎与 C 和 C++ 一样快的低级语言，并且 Rust 天然允许安全并发，使并行性尽可能可预测。这意味着 Polars 可以安全使用所有的 CPU 核心执行涉及多个列的复杂查询，所以 Polars 的性能远高于 Pandas，因为 Pandas 只使用一个核心执行运算。

- 基于 Arrow

  Polars 具有惊人性能的一个原因是使用 Apache Arrow，一种独立于语言的内存格式。在 Arrow 上构建数据库的主要优点之一是互操作性，这种互操作性可以提高性能，因为它避免了将数据转换为不同格式以在数据管道的不同步骤之间传递（换句话说它避免了对数据进行序列化和反序列化）。此外 Arrow 还具有更高的内存效率，因为两个进程可以共享相同的数据，无需创建副本。据估计，序列化/反序列化占数据工作流中 80-90% 的计算开销，Arrow 的通用数据格式为 Polars 带来了显著性能提升。
  
  Arrow 还具有比 Pandas 更广泛的数据类型内置支持，由于 Pandas 基于 NumPy#footnote[Pandas 在 2.0 版本中也引入了 Arrow 数据后端，可以在导入/构建数据时指定`dtype_backend="pyarrow"`。]，它在处理整数和浮点列方面非常出色，但难以应对其他数据类型。虽然 NumPy 的核心是以 C 编写，但它仍然受到 Python 某些类型的制约，导致处理这些类型时性能不佳，比如字符串、列表等等，因为 Numpy 本身就不是为 Pandas 而设计的。相比之下，Arrow 对日期时间、布尔值、字符串、二进制甚至复杂的列类型*（例如包含列表和复杂结构体的列类型）*提供了很好的支持。另外，Arrow 能够原生处理缺失数据，这在 NumPy 中需要额外步骤。最后，Arrow 使用列式数据存储，无论数据类型如何，所有列都存储在连续内存块中。这不仅使并行更容易，也使数据检索更快。
  
  （与之 Arrow 内存格式相匹配的存储格式是 Parquet。首先与行式存储#footnote[如 CSV。]相比，Parquet 是一种列式存储，同一列的数据被连续存储在一起，从而允许快速读取、处理和聚合特定的列数据，而不需要加载整个数据集。另外列式存储对数据压缩更为友好，由于同一列中的数据类型相同，且往往具有一定的相关性，因此可以应用更高效的压缩算法。Polars 的内存布局在许多方面反映了 Parquet 文件在磁盘上的布局，这意味着 Polars DataFrame 与 Parquet 数据文件相互转换时所需的数据转换非常少，从而加快了读写速度。）
  
  Polars 读写 Parquet 数据也非常简单：

  ```python
  import polars as pl
  
  df = pl.read_parquet("data/path.parquet")
  df = pl.write_parquet("data/path.parquet")
  ```
  
- 惰性计算与查询优化

  Polars 性能的另一个核心是评估代码的方式，Pandas 默认使用 Eager 执行，也就是按照代码编写的顺序执行运算。相比之下，Polars 能够同时执行 Eager 和 Lazy 执行，查询优化器将对所有必需运算求值并制定最有效的代码执行方式，这可能包括重写运算的执行顺序或删除冗余计算。例如，我们要基于列 `Category` 对列 `Number` 进行聚合求平均值，然后将 `Category` 中值 `A` 和 `B` 的记录筛选出来：
  ```python
  import polars as pl
  
  (
      df.group_by("Category")
      .agg(pl.col("Number").mean().alias("Average_Number"))
      .filter(pl.col("Category").is_in(["A", "B"]))
  )
  ```
  如果表达式是 Eager 执行，则会多余地对整个 DataFrame 执行分组运算，然后按 `Category` 筛选。通过 Lazy 执行，会先经过筛选，并仅对所需数据执行分组运算。
  
- 表达性 API

  最后，Polars 拥有一个极具表达性的 API，基本上你想执行的任何运算都可以用 Polars 方法表达。相比之下，Pandas 中更复杂的运算通常需要作为 `lambda` 表达式传递给 `apply` 方法。`apply` 由于需要逐行遍历 DataFrame 效率很低，而 Polars 能够让你在列级别上通过 SIMD 实现并行。

以上是 Polars 在性能方面的优点，安装则只需要 `pip install polars[all]` 即可。#footnote[强烈建议使用 *uv* 而非 pip 进行环境依赖管理。]

== 2. 正文：我为什么转用 Polars？

我最近决定，在我那些使用 DataFrame （数据框/数据表）的 Python 项目中，从 *Pandas* 转向 *Polars*。这个决定是在我上周参加了一个关于 Polars 的研讨会时做出的：我发现它的*语法是如此直观*，以至于我无法再为继续努力“精进”Pandas 找借口了，尽管 Pandas 是一个更成熟的库。令人惊讶的是，Polars 速度更快这一事实#footnote[这是 Polars 的主要卖点。]，并不是我做出决定的原因。

在 R 语言中，最近也发生了类似的转变。在 R 语言的大部分历史中，与数据帧交互只有一种方式：*Base R*。后来 *Tidyverse* 出现了，它不仅提供了性能改进，还带来了更简单的语法。最终，Tidyverse 成为了许多人与 DataFrame 交互的主要方式。我相信 Tidyverse 更简单的语法是其被广泛采用的原因，而且我认为类似的事情很可能也会发生在 Polars 身上。#footnote[Tidyverse-R 优雅、流畅的管道流程和语法表达正在影响包括 Polars 在内的多个数据处理工具，不幸的是 Pandas 似乎不在此列。（再次补充，Pandas 在 3.0 版本中引入了列表达式 `pd.col()`，似乎也在朝着更具表达力的语法前进。）]

很多情况下，这可以用*布鲁姆分类法（Bloom’s Taxonomy）*来解释。该分类法列出了人们从初学者到专家所经历的各个阶段。关键点是：*金字塔的基础是“记忆”*。如果你记不住如何完成一个基本任务（比如对数据框进行筛选），那么你就无法将其应用于工作中，无法评估他人的代码，或者为你所使用的语言/库贡献自己的扩展。

#figure(caption: "Bloom’s Taxonomy")[#image("img/bloom.jpg")]

我相信 Polars 和 Tidyverse 都比之前的库拥有更易于记忆、更符合直觉的语法。就 Tidyverse 而言，这很可能促使它成为许多用户首选的 DataFrame 数据库#footnote[也使 R 成为了许多用户首选的数据处理语言。]。我预计类似情况也会发生在 Polars 身上。#footnote[我也很乐观！]

理解这些语法差异可以帮助我们所有人成为更好的程序员。虽然很少有人开发下载量达数百万的库，但我们大多数人确实会编写供他人使用的代码。弄清楚是什么让某些 API 比其他 API 更容易掌握，可以帮助我们的下一个项目取得更大的成功。为了帮助说明这一点，下面我将用 Polars 和 Tidyverse，以及它们之前的 DataFrame 库（Pandas 和 Base R），解决同一个简单问题。这个问题是：

+ 读取包含美国各县的 CSV 文件；
+ 筛选名为“Washington”的县；
+ 筛选名为“county.name”和“state.name”的列。

之所以选择这个例子，是因为筛选行和列是最基本的数据操作之一，但它仍然能证明我的观点。而且，当我做一个使用美国县数据的项目时，我发现很多州都有一个名为“Washington”的县，这很有趣。

本文使用的代码也可以在 #link("https://github.com/arilamstein/polars-pandas")[GitHub] 上找到。您可以将其作为起点，自行探索这些库。

=== 2.1 Polars vs Pandas

==== 2.1.1 Polars

在 Polars 中，你可以使用函数 `filter` 来筛选行，使用函数 `select` 来筛选列。这两个函数都是 Polars DataFrame 类的方法。Python 用户习惯将方法链放入括号 `()` 中，因此，读取数据后，代码看起来像这样：

```python
import polars as pl

(
    pl.read_csv("data/counties.csv")
    .filter(pl.col("county.name") == "washington")
    .select("county.name", "state.name")
)
```

阅读这段代码时，我首先注意到的是，对数据框执行的每个操作都有一个描述性的函数名。虽然这听起来很浅显，但 Pandas 和 Base R 都经常使用*运算符/符号*而不是*函数*，而且这些运算符会根据输入执行不同的操作。这会使记住如何使用这个库和这些方法变得困难。

R 语言使用者会注意到，`filter` 和 `select` 这两个函数与 `dplyr` 包中用于相同任务的函数名完全一致。当我看到这一点时，我以为 Polars 的创始人 Ritchie Vink 只是简单借用了 Tidyverse 的做法。但当我在领英上问他时，他说他并不使用 R 语言，实际上对此一无所知！他幽默地称之为“趋同进化”#footnote[优秀的设计总是心有灵犀！]。

我第一次看到这种语法时非常高兴，因为我觉得它很容易记住：每个任务（根据条件筛选行、按名称选择列）都有一个与之关联的函数，而且这个函数的命名方式也很容易记忆。正如我们将在下文看到的，这与 Tidyverse 非常相似，但与 Pandas 和 Base R 则截然不同。

==== 2.1.2 Pandas

当我尝试用 Pandas 编写这段代码时，我心想：“啊，这里我应该用 `.loc`（而不是 `.iloc`）吧？但这个函数是接受 `[]` 还是 `()` 呢？”我总是忘记，让我问问 AI。AI 的回复让我很惊讶，它既没有提到 `.loc` 也没有提到 `.iloc`，它说直接使用普通的 `[]`：

```python
df[df["county.name"] == "washington"]
```

这种语法优势在于简洁。所以如果你清楚自己在做什么，那么编写和阅读都很快。但对于新手来说，这可能会让人感到困惑，一个困惑之处是，你使用的是*运算符/符号*，而不是一个命名清晰的*函数*（因此你必须记住 `[]` 的作用）。其次，在同一行代码中，`[]` 实际上做了两件不同的事情。在内部表达式 `df["county.name"]` 中，你给了它一个列名，它返回了该列的值；但在外部表达式 `df[...]` 中，你给了它一个逻辑序列，它返回了数据框中相应的行。

既然我想看 `.loc` 版本，我便告诉 AI：“给我看看另一种方式。”它返回了以下内容：

```python
df.query('`county.name` == "washington"')
```

刚开始学习 Pandas 的时候，我曾对 `query` API 感到兴奋，因为它看起来很简单易用#footnote[我实在不明白哪里看起来“简单易用”了🤔，我本人确实并不精通 Pandas，但我认为从这行代码就可以看出 Pandas (至少是这个 `query`) 的表达多么糟糕。]。但后来一位我所敬重的“高级” Pandas 用户告诉我他从不用这个 API，因此我也决定不再使用它。于是我又一次告诉 AI：“再给我展示另一种方式。”它返回了：

```python
df.loc[df["county.name"] == "washington"]
```

这正是我想要的。所以我在这里使用 `.loc` 的直觉是正确的。尽管我不确定它是否应该使用 `[]` 而非 `()`，但我还是记得这一点需要多加注意。加入用于选择列的代码后，我们得到了这个解决方案：

```python
df.loc[df["county.name"] == "washington"][["county.name", "state.name"]]
```

有趣的是#footnote[并非有趣😇]，筛选列的代码又增加了两对 `[]`。而且它们在这里的意思又不同：内部的 `[]` 表示“一个 Python 列表”，外部的表示“选择列”操作。

对我来说，要攀登关于 Pandas 的布鲁姆分类法，有两个明显的障碍。首先，我需要知道在众多可能的方法中，我应该使用哪一种来完成任务。这让我想起了《Python 之禅》中的那句话：“There should be one – and preferably only one – obvious way to do it.”#footnote[“任何问题应有一种——且最好只有一种——显而易见的解决方法。”]其次，记住复杂而抽象的语法细节本身也令人困扰。

=== 2.2 Tidyverse vs. Base R

==== 2.2.1 Tidyverse

#quote-box[
  Programs must be written for people to read, and only incidentally for
  machines to execute. \ 
  —— Hal Abelson #footnote[这是一个引用块脚注]
]

Tidyverse 有一个原则：#link("https://tidyverse.tidyverse.org/articles/manifesto.html#design-for-humans")[代码应该为人设计]
#footnote[
  设计 API 时，首先要考虑的是用户能否轻松使用。计算机效率是次要考虑因素，因为大多数数据分析的瓶颈在于思考时间，而非计算时间。这包括：*1)* 花些时间为你的函数命名。易于理解的函数名能让你的 API 更易于使用和记忆；*2)* 尽量使用明确、冗长的名称，而不是简短、隐含的名称。将最短的名称留给最重要的操作；*3)* 确保函数族使用共同的前缀，而不是共同的后缀。这样，自动补全功能就能更好地帮助你回忆起函数名称。对于较小的包，这意味着每个函数都可以使用共同的前缀。
]
。在实践中，这意味着创建名称清晰的函数，并且每个函数只做一件事。这也意味着可以使用管道操作符 `|>` 或 `%>%` 来组合这些函数。进而，我们简单的分析可以这样完成，这段代码与等效的 Polars 代码非常相似：

```r
df |>
  filter(county.name == "washington") |>
  select(county.name, state.name)
```

今年七月我举办了一个“R 语言入门”研讨会。我们同时讲解了 Tidyverse 和 Base R。学生们使用 Tidyverse 解决简单问题的速度，远快于使用 Base R 解决类似问题。我将这归因于 Tidyverse 使用具有明确名称且只做一件事的函数来进行数据操作。

这段代码的另一个特点是它使用了#link("https://adv-r.hadley.nz/metaprogramming.html")[非标准求值（Non-Standard Evaluation, NSE）]。在使用 `filter` 函数时，我们可以直接写入列名（例如 `county.name`）来引用列的内容，而无需使用引号。在 Polars 中，我们需要写 `pl.col("county.name")`；而在 Pandas 中，我们则需要写 `df["county.name"]` 之类的表达。NSE 非常有用，并且能写出非常简洁的代码，我不明白为什么 Pandas 和 Polars 都没有采用它。#footnote[Polars 作者 Ritchie Vink 对此进行了回复：#link("https://www.linkedin.com/feed/update/urn:li:activity:7237182297102295041?commentUrn=urn%3Ali%3Acomment%3A%28activity%3A7237182297102295041%2C7237485477031759872%29&dashCommentUrn=urn%3Ali%3Afsd_comment%3A%287237485477031759872%2Curn%3Ali%3Aactivity%3A7237182297102295041%29")[“NSE 在 Python 中无法实现。这意味着某些领域特定语言无法在 Python 中表达，需要 `pl.col(..)` 这样的工具对象。”]] #footnote[在 Polars 中，如果列名没有空格，则可以使用 `pl.col.foo` 来选择 `foo` 列，如果提前导入 `from polars import col as c`，则可以使用更简洁的 `c.foo`。]

==== 2.2.2 Base R

相同功能的 Base R 版本代码则大相径庭。与 Pandas 类似，Base R 不使用显式的函数调用，相反，你需要使用运算符/符号 `[]` 和 `$`：

```r
df[df$county.name == "washington", c("county.name", "state.name")]
```

作为一名 R 语言的长期用户，我个人感觉这样的代码既容易阅读也容易编写，但研讨会上的学生们写起来却很费劲。他们能够轻松地编写向量化的逻辑判断（`df$county.name == "washington"`），但却难以将这个判断表达式放进 `[]` 中。

这段代码暴露的另一个问题是，运算符常常会被重载，这会让新手更加困惑。例如，在上面的代码中，`df$county.name == "washington"` 被用作下标索引。但在 R 语言中有#link("https://www.johndcook.com/blog/2008/10/23/five-kinds-of-r-language-subscripts/")[五种下标]，新手需要全部学习。但如果使用显式函数，这就不再是个问题了，事实上，Tidyverse 有很多针对特定需求的、符合直觉和命名规律的显式函数（例如 `starts_with` 和 `ends_with`）。

=== 2.3 结论

去年十二月，当我第一次开始学习如何在 Python 中处理表格数据时，我选择了 Pandas，因为它是 Python 中最流行的数据框库。我现在认为，*对于新手来说，学习 Polars 更好*，所以我把精力都投入其中。主要原因是，我发现 Polars 的语法更流畅、更容易记忆。根据布鲁姆分类法，我认为一个更容易记住如何使用的库，反过来能让我更快地做出重要贡献。此外，Polars 的性能也远优于 Pandas。

“Polars vs. Pandas” 之争让我想起了大约十年前开始的 “Tidyverse vs. Base R” 之争。那时，像我这样经验丰富的 R 用户会嘲笑那些认为 “学习 Tidyverse” 就等同于 “学习 R 语言” 的人。事后来看，我们错了。我们低估了人们采纳更简单、更明确的 DataFrame API 的速度。我认为，如今那些对 Polars 持类似立场的资深 Pandas 用户，很可能也会因为类似的原因被证明是错误的。当然，只有时间才能证明一切。

Polars 和 Tidyverse 的诞生让我想起了我第一份工作时，一位首席工程师告诉我的话：“第一次构建某物时，专注于让它能工作；第二次构建某物时，专注于让它更优雅。” Pandas 和 Base R 都对统计计算领域做出了巨大贡献。它们能很好地工作。而 Polars 和 Tidyverse 作为后继者则更胜一筹，拥有了专注于“优雅”和“流畅”的优势。

正如俗话所说：“历史不会重演，但总会似曾相识。”#footnote[“History doesn’t repeat itself, but it sure does rhyme.”]

#image("img/tail.jpg", width: 500pt)