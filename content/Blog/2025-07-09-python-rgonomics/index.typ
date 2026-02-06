#import "../index.typ": template, tufted
#show: template.with(
  title: "Python 的 R 式人体工学",
  date: datetime(year: 2025, month: 7, day: 9),
)

#tufted.margin-note[
  本文转载、翻译自 Emily Riederer 发表于 2025.1.26 的博客文章 #link("https://emilyriederer.netlify.app/post/py-rgo-2025/", [_Python Rgonomics - 2025_])。`Rgonomics` 是作者自造词，结合了 R 语言和 Ergonomics 人体工学，意指借鉴 R 语言的便利设计，让 Python 对 R 用户来说更好用，也就是*最佳的编程实践*。
]

= Python 的 R 式人体工学 - 2025

切换编程语言，关键在于思维模式的转变，而不仅仅是语法的改变。Python 数据科学工具的最新进展（如 Polars 和 seaborn 的面向对象接口），既能捕捉到 R/Tidyverse 爱好者所钟爱的那种“感觉”，又为通往真正具有 Python 风格（"Pythonic"）的工作流敞开了大门。

大约一年前，我写了 #link("https://emilyriederer.netlify.app/post/py-rgo/")[_Python Rgonomics_ 的初版]#footnote[Rgonomics，我将其译为了“R 式人体工学”，也就是为 R 用户准备的 Python 最佳编程实践。]，旨在帮助刚开始进入 Python 世界的 R 语言用户。那篇文章的核心观点是，新的 Python 工具（例如 Polars 相对于 Pandas）已经发展到了一个新阶段：既能保持出色的性能和 Pythonic 风格，又能为 R 语言用户提供更相似的使用体验。我还在 #link("https://posit.co/conference/")[posit::conf(2025)] 大会上探讨过这个话题。

颇具讽刺意味的是，这个论点本身是如此正确，以至于它实际上否定了让我 2024 年发表的第一篇关于此主题的文章。2024 年见证了一些颠覆性工具的发布，它们进一步精简了 Python 的工作流程。这篇文章提供了一系列更新的建议。具体来说，它强调了：

- 整合安装与环境管理工具：之前，我推荐使用 `pyenv` 来安装 Python 版本，使用 `pdm` 进行项目和环境管理。然而，去年 Astral 公司发布了出色的 #link("https://docs.astral.sh/uv/")[*uv*]，它将这些功能完美地整合到一个单一的高性能工具中。
- 考虑多种 IDE 选项：除了 VS Code，我还根据使用舒适度、需求和使用场景，推荐 Posit PBC 的 #link("https://positron.posit.co/")[Positron] 供参考。两者都基于开源的 Code - OSS，但提供了不同层次的灵活性和定制化选项。Positron 与 VS Code 的扩展大多兼容，但它为那些不想探索 VS Code 提供的定制选项的数据分析师来说，提供了一种更为“开箱即用”、带有明确设计主张的体验。

拥有一套稳定的技术栈而不是总去追逐下一个光鲜亮丽的新事物，这一点非常重要。然而，在看到这些项目在 2024 年中的不断发展后，我有信心说，它们绝非昙花一现。

*uv* 由 Charlie Marsh 创立的 Astral 公司支持，这家公司之前开发了 #link("https://docs.astral.sh/ruff/")[*ruff*]，用以整合大量的代码质量工具。Astral 对开源的承诺、精心的设计以及 *uv* 令人难以置信的性能表现，都足以说明一切。#footnote[我认为在 2025 年任何 Python 用户都应该使用 *uv* 和 *ruff*，如果你看到某个 Python 文章/教程还在推荐同类的其他工具，那就应该毫不犹豫地关闭。]同样地，Positron 则由可靠的 Posit PBC（前身为 RStudio）公司支持，作为 Code OSS 的一个开源扩展（Code OSS 也是微软 VS Code 的开源框架）。

本文的其余部分是在初版基础上全文转载并进行了相关更新，以便读者可以从头到尾阅读，无需参考新旧版本之间的更改。

== 让我们开始吧！

在 R 和 Python 等语言之间切换时，“专家-新手”的双重身份是件令人不舒服的事。学习一门新语言本身很容易，像真值表和控制流这样的编程入门概念可以无缝转换，但一门语言的人体工学#footnote[即最佳实践。]却并非如此。我们为了在主语言中实现超高效率而学习的技巧和窍门，既舒适、熟悉、优雅又高效，它们就是让人“感觉良好”。而在使用一门新语言时，开发者常常面临一个选择：是把他们偏爱的工作流强行用在一个可能并不“适配”的新工具上；还是编写技术上正确但冗长乏味的代码来完成任务；亦或是作为真正的初学者，从头开始学习一门新语言的“感觉”。

幸运的是，一些更高层次的编程范式已经开始跨越语言界限，丰富了那些以往相互隔离的开发者部落，并使开发者能够将他们的高级技能运用到不同的语言中。对于任何希望在 2024 年提升 Python 技能的 R 用户来说，一些新工具和旧版热门工具的新版本，已经在融合 R 和 Python 的数据科学生态栈方面取得了长足进步。在本文中，我将概述一些推荐的工具，它们既符合真正的 Pythonic 风格，同时又抓住了 Tidyverse 系列中那些备受喜爱的 R 包所带来的舒适感和熟悉感。

（当然，不同语言也有各自的亚文化，如R 语言中的 Tidyverse 和 data.table 就倾向于不同的语义和人体工学。这篇文章更侧重于前者。）

== 这篇文章不是 ...

首先需要明确的是：#footnote[开始叠甲！]

- 本文并非主张 Python 比 R 更好，因此 R 用户应该把所有工作都转向 Python；
- 本文并非主张 R 比 Python 更好，因此 R 的语义和惯例应强加于 Python 上；
- 本文并非主张 Python 用户比 R 用户更优秀，因此 R 用户需要“特殊照顾”；
- 本文并非主张 R 用户比 Python 用户更优秀，并且在工具选择上更有品味；
- 本文并非主张文中的这些 Python 工具是唯一的好工具，而其他的都糟糕。

如果你告诉我你喜欢纽约大都会艺术博物馆，我可能会说那你也许会喜欢芝加哥艺术学院。但这并不意味着你应该只去芝加哥的博物馆，或者你永远不该去巴黎卢浮宫。无论是人类还是推荐系统，推荐都并非如此运作。本文是一篇“主观”的文章，其“主观”体现在“我喜欢这个”，而非“你必须这么做”。

== 关于工具选择 ...

我下面重点介绍的工具往往具有两个相互权衡的特点：

- 它们的工作流程和人体工学方面，应该能让熟悉 R 语言工具的用户感到非常舒适；
- 它们本身应该是已被广泛接受、成功且维护良好的 Python 项目，并带有真正的 Pythonic 精神。

前者之所以重要，是因为如果缺失这一点，这些推荐就失去了针对性；后者之所以重要，是为了让用户能真正融入 Python 语言和社区，而不是仅仅在其外围浅尝辄止。简而言之，这两条原则排除了那些仅仅是语言之间的直接移植品、并将此作为其唯一或主要优点的工具。

语言移植无疑有其一席之地，尤其是在项目的早期阶段，此时还没有特定于该语言的原生标准。例如，我喜欢 Karandeep Singh 实验室在 #link("https://github.com/TidierOrg/Tidier.jl")[Julia 版 Tidyverse] 方面的工作，我自己也维护着一个名为 #link("https://github.com/emilyriederer/dbtplyr")[dbtplyr] 的包，用以将 dplyr 的 `select` 辅助函数移植到 dbt 中。

例如，#link("https://siuba.org/")[siuba] 和 #link("https://plotnine.org/")[plotnine] 的编写初衷就是直接模仿 R 的语法。它们取得了一定的成功和应用，但这类小众工具也伴随着一些弊端。由于用户基数较小，它们往往在开发速度、社区支持、现有技术、Stack Overflow 上的问题、博客文章、会议演讲、相关讨论、合作者、以及在个人作品集中的分量等方面有所欠缺。语言移植有时会迫使开发者投入精力去学习一种“神秘的第三件事”，这不仅将他们与两个社区隔离开来，还让他们不得不独自面对不可避免的障碍，而不是享受旧语言的人体工学体验之便或迎接学习新语言的挑战。

入乡随俗——但如果你来自美国，这并不意味着你不能带一个万能转换插头，帮助你的设备在欧洲插座上充电。

== 技术栈

言归正传，下面我将推荐一些最具人体工学的工具，用于环境搭建、核心数据分析和结果沟通。推荐概览：

- 配置（Set Up）
  - 环境安装：#link("https://docs.astral.sh/uv/")[uv]
  - IDE：#link("https://code.visualstudio.com/docs/languages/python")[VS Code] 或 #link("https://positron.posit.co/")[Positron]
- 分析（Analysis）
  - 数据处理：#link("https://pola.rs/")[Polars]#footnote[可以参考 #link("../2025-07-29-why-polars/")[7.29 - 我为什么放弃 Pandas 而转用 Polars？]。]
  - 可视化：#link("https://seaborn.pydata.org/")[seaborn]#footnote[我个人认为作者上文提到的 #link("https://plotnine.org/")[plotnine] 也相当好用，提供了类似 R ggplot2 的语法，当然我个人还是最推荐直接使用 R ggplot2 来画图。]
- 沟通（Communication）
  - 表格：#link("https://posit-dev.github.io/great-tables/articles/intro.html")[Great Tables]
  - 笔记本：#link("https://quarto.org/")[Quarto]#footnote[我个人认为对于 Python 来说，Jupyter Notebook 仍然是数据科学和探索开发的最优选择，也可以尝试一下新一代笔记本 #link("https://marimo.io/")[marimo]。]
- 其他（Miscellaneous）
  - 环境管理：#link("https://docs.astral.sh/uv/")[uv]
  - 代码质量：#link("https://docs.astral.sh/ruff/")[ruff]
  
=== 用于配置 ...（For setting up）

最初的障碍往往是如何开始——这既包括安装所需的工具，也包括进入一个舒适的集成开发环境 (IDE) 来运行它们。

- *安装*

  R 的安装过程非常简单；只有一种方法，下载、安装，你照做就行了。#footnote[为了突出这里的一些进步，Posit 的新项目 #link("https://github.com/r-lib/rig")[rig] 似乎受到了 Python 安装管理工具的启发，提供了一个方便的 CLI 来管理多个版本的 R。]但 Python 用户在能 `print("hello world")` 之前，会面临一系列选择（系统自带 Python、Python 安装程序、Anaconda、Miniconda 等），而每种方式都有自己的麻烦之处。在 Python 中，这些决定变得更加困难，因为项目往往对语言版本有更强的依赖性，需要用户在不同版本之间切换。幸运的是，现在 `uv` 让这项任务变得很简单，它提供了许多不同的命令用于：
  - 安装一个或多个特定的版本：`uv python install <version, constraints, etc.>`
  - 列出所有可安装的版本：`uv python list`
  - 返回 python 解释器的路径：`uv python find`
  - 快速启动一个带有临时 Python 版本和包配置的交互式 Python：`uv run python --python 3.12 --with pandas`

- *IDE*

  R 语言安装好后，R 用户通常会立即上手直观的 RStudio IDE，这能帮助他们立刻进行 REPL（读取-求值-输出-循环）操作。RStudio 的用户界面分为四个象限，用户可以编写并运行 R 脚本并在控制台中查看结果，通过变量浏览器了解程序“知道”什么，并通过文件浏览器导航文件。Python 并不缺乏 IDE 选项，但用户在开始之前就面临着又一个决策点。Pycharm#footnote[我个人极不推荐 JetBrains 家的工具。]、Sublime、Spyder、Eclipse、Atom、Neovim，天！对于 Python，我推荐 `VS Code` 或 `Positron`，它们都是 Code - OSS 的扩展。
  - VS Code 是软件开发的行业标准工具，这意味着它拥有一套丰富的功能，用于编码、调试、大型项目导航等，其丰富的扩展生态系统也意味着大多数主流工具（例如 Quarto、git、linters 和 stylers 等）都有很好的扩展插件。因此，就像 RStudio 一样，你可以定制你的平台，以纯文本方式或在额外插件的支持下执行许多附带任务。（如果说 VS Code 有什么使用挑战，那便是其极为繁多的设置选项。不过，一开始你可以参考 Rami Krispin 这些关于 #link("https://github.com/RamiKrispin/vscode-python")[VS Code - Python] 和 #link("https://github.com/RamiKrispin/vscode-r")[VS Code - R] 推荐配置的优秀教程。）
  - Positron 是 Posit PBC（前身为 RStudio）公司推出的一款较新的产品。它精简了 VS Code 的功能，专注于对数据分析最实用的特性。Positron 可能会让你感觉更容易从零开始,它在查找和一致使用正确版本的 R、Python、Quarto 等方面做得很好，并优先考虑了许多使 RStudio 在处理数据方面表现出色的 IDE 元素（例如对象预览窗格）。此外，大多数 VS Code 扩展都可以在 Positron 中使用；但 Positron 无法使用依赖于微软 `Pylance`的扩展，这意味着一些实时代码检查和错误检测工具（如 `Error Lens`）无法开箱即用#footnote[可以使用 `BasedPyright` 等替代工具。]。最终，你对 VS Code 的熟悉程度以及你工作中开发与数据分析的比例，可能会决定哪个更适合你。

=== 用于数据分析 ...（For data analysis）

数据从业者都知道，我们大部分时间都花在数据清洗和整理上。因此，R 用户可能特别难以放弃他们最喜欢的探索性数据分析工具，如 dplyr 和 ggplot2。这些包的爱好者通常很欣赏其函数式编程范式如何帮助他们达到一种“心流状态”。尽管精确的语法可能有所不同，但 Python 数据整理领域的新发展，为这些备受喜爱的 R 语言人体工学特性提供了一些日益接近的对应工具。

- *数据整理*

  尽管 Pandas 无疑是 Python 领域最知名的数据整理工具，但我相信日益发展的 Polars 项目能为转型中的开发者提供最佳体验#footnote[可以参考 #link("../2025-07-29-why-polars/")[7.29 - 我为什么放弃 Pandas 而转用 Polars？]。]，同时还具有一些不错的优点，比如无依赖和极快的速度。出于多种原因，R 用户可能会觉得 Polars 更自然、更不易出错：
  - 它具有更强的内部一致性（且类似于 dplyr）的语法，如 `select`、`filter` 等，并且该项目已证明其对简洁 API 的重视（例如，最近将 `groupby` 重命名为 `group_by`）；
  - 它不依赖于列和索引之间的区别，这种区别可能会令人费解，并且引入了一套需要学习的新概念；
  - 它始终返回数据框的副本（而 Pandas 有时会直接原地修改），因此代码更具幂等性，为新用户避免了一类的失败模式；
  - 它通过高级语义代码实现了许多与 dplyr 中相同的“高级”整理工作流，例如使用#link("https://docs.pola.rs/api/python/stable/reference/selectors.html")[列选择器（Column Selectors）]一次性快速转换多个变量，简洁地表达#link("https://docs.pola.rs/user-guide/expressions/window-functions/")[窗口函数（Window Functions）]，以及使用#link("https://docs.pola.rs/user-guide/expressions/")[列表（Lists）和结构体（Structs）]处理嵌套数据（即 dplyr 所谓的“列表列”）；
  - 支持用户处理日益增长的数据。与 dplyr 的多个后端（例如 dbplyr）类似，Polars 可用于编写惰性求值、优化转换，并且其语法也让人联想到 PySpark，以备用户将来切换。

- *可视化*

  即使是 R 语言的一些批评者，也不得不承认 ggplot2 在可视化方面的强大之处，无论是其直观渐进的 API，还是它能生成的精美图表。而 #link("https://seaborn.pydata.org/tutorial/objects_interface")[seaborn 的面向对象接口]似乎取得了很好的平衡：它既提供了类似的工作流#link("https://seaborn.pydata.org/whatsnew/v0.12.0.html")[（其灵感来源正是 ggplot2）]，又兼具了作为一个行业标准工具的所有优点。
  
=== 用于沟通 ...（For communication）

历史上，R 和 Python 之间的一条分界线可以被概括为 “Python 擅长与计算机打交道，R 擅长与人打交道”。虽然这种说法部分源于 “R 不是生产级别应用”这类过于简化的看法，但 R 的学术渊源确实促使其在丰富的沟通技术栈上投入巨大，并将分析输出转化为人类可读、可发布的成果。不过如今，这种差距也已开始缩小。

- *表格*

  R 不乏用于创建精美表格的软件包，而在 Python 领域，无论是在工作流还是结果输出方面历来都略显不足。除非面临来自 Python 原生领域的激烈竞争，我唯一看好的“移植”工具是最近发布的 #link("https://posit-dev.github.io/great-tables/articles/intro.html")[Great Tables] 包。这是 R 语言 #link("https://gt.rstudio.com/")[gt] 包的一个 Pythonic 克隆版。我之所以更愿意推荐它，是因为它由与 R 版本相同的开发者维护（以支持长期的功能对等），由机构而非个人支持（以确保它不是一个昙花一现的业余项目），并且其设计在借鉴 R 的灵感与遵循 Pythonic 实践之间取得了很好的平衡。
  
- *计算型笔记本*

  Jupyter Notebook 在 Python 工作流中被广泛使用，但也备受争议。虽然它能够混合 Markdown 和代码块，但对于新手来说，笔记本会引入新的 Bug；例如，它们难以进行版本控制，并且容易在错误的环境中执行#footnote[这些确实是 Jupyter Notebook 的痛点。]。对于来自 R Markdown 世界的人来说，像 Quarto 这样的纯文本计算型笔记本可能会提供更透明的开发体验#footnote[纯文本工作流是好文明，甚至#link("https://plain-text.co/")[专门有本书]，尽管我个人认为这本书更像是一种癖好。]。虽然 Quarto 允许用户编写更像其前身 `.rmd` 文件的 `.qmd` 文件，但其渲染器也能处理 Jupyter Notebook，从而让有不同偏好的团队成员能够协作#footnote[Quarto 现在也加入了 Typst 编译选项，无需再依赖慢得要死的 Latex。本网站正是完全由 Typst 编译的。]。
  
=== 其他工具 ...（Miscellaneous）

对于那些更偏向“开发者”而非“分析师”的 R 用户来说，还有一些可能有用且熟悉的工具。在我看来，这些工具的优缺点更加多样，但我还是将它们列出以供参考：

- *环境管理*

  在 Python 中，管理项目级依赖的方式多到令人应接不暇#footnote[pdm、virtualenv、conda、piptools、pipenv、poetry、uv、pixi ... 这些甚至只是冰山一角。]。因此，关于各种功能集的优缺点，也有很多过时的建议。在这里，*uv* 再次如瑞士军刀般脱颖而出。它具有安装速度快、自动更新 `pyproject.toml` 和 `uv.lock` 文件（因此你不需要记住去 `pip freeze`）、从完全解析的环境中独立跟踪主要依赖项（因此你可以干净、彻底地移除不再需要的“依赖的依赖”#footnote[例如，如果你用 `pip install pandas`，除了 Pandas 本身外还会安装 Numpy 等依赖。如果你再运行 `pip uninstall pandas`，只有 Pandas 自身会被卸载，而 Numpy 作为它的依赖则会永远留在环境中。而如果使用 `uv remove pandas`，则会一并移除所有不再需要的依赖的依赖。]）等诸多优点。*uv* 可以作为 pip 的直接替代品，如果为了兼容性需要也可生成 `requirements.txt` 文件。然而，鉴于其爆炸性的人气和符合人体工学的设计，我相信您不会难以说服合作者采纳它。
  
- *代码质量*

  *Ruff*（Astral 公司的另一个项目）提供了一系列代码检查和格式化选项，并为该领域中数量繁多的原子化工具（isort、Black、Flake8 等）提供了一站式解决方案。Ruff 速度极快，还拥有一个很好用的 VS Code 扩展。并且，虽然这类工具通常被认为是更高级的，但我认为代码检查工具可以成为新用户学习最佳实践的绝佳“教练”。#footnote[在 R 中，更现代、更快速的代码检查和格式化工具是 #link("https://posit-dev.github.io/air/")[Air]。]
  
#image("tail.jpg", width: 500pt)