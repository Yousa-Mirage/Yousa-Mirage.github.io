#import "../index.typ": template, tufted
#show: template.with(
  title: "用 Just 只运行部分测试文件",
  author: "Etienne Bacher",
  date: datetime(year: 2026, month: 10, day: 19),
  description: "在 justfile 中给 devtools::test() 加上 filter 参数，用 just test 加上关键词，只跑文件名匹配的测试，省下等待整套测试的时间。",
  extra-info: [译者：#link("https://github.com/Yousa-Mirage")[天然純真]],
)

= 用 Just 只运行部分测试文件

#tufted.margin-note[
  *原文* #link("https://www.etiennebacher.com/posts/2026-10-15-using-just-with-test-files/")[Using Just to run a subset of test files] \
  *作者* #link("https://www.etiennebacher.com/")[Etienne Bacher] \
  *发表* 2026-10-15 \
  *说明* 本文为中文翻译，版权归原作者所有
]

我现在在终端里花很多时间，无论是运行 Git、#link("https://posit-dev.github.io/air/")[Air] 还是 #link("https://jarl.etiennebacher.com/")[Jarl]。最近，我一直在用 #link("https://github.com/casey/just")[Just] 来执行自定义命令，做代码检查、格式化和测试。

#link("https://github.com/casey/just")[Just] 是一个易于安装和使用的命令运行器。你可以在 `justfile` 中定义命令，然后用 `just <命令名>` 来运行。例如，我们的 `justfile` 可以定义一个 `lint` 命令，用来执行自定义的 Jarl 命令：

```just
lint:
  jarl check . --output-format concise
```

然后就可以在终端里调用 `just lint`。对于代码检查、格式化和测试等重复性任务，这种方式比直接在终端里敲命令要方便得多。

我之前已经在 #link("https://tidypolars.etiennebacher.com/")[tidypolars] 中使用 Just 了。这个项目的测试套件有数千个测试，通常要跑两三分钟；不过 #link("https://github.com/Yousa-Mirage")[\@Yousa-Mirage] 给了一个很棒的建议：在 `justfile` 里加上下面这条规则：

```just
test filter="":
    Rscript -e 'devtools::test(filter = commandArgs(TRUE)[[1]])' {{ quote(filter) }}
```

这条规则利用 `devtools::test()` 的 `filter` 参数，只运行文件名中包含 `filter` 值的测试文件。不过，直接在 R 控制台里运行有点麻烦：要么把整条命令完整敲一遍，要么翻控制台历史记录，再修改 `filter` 的值。

现在，我可以直接到终端里运行 `just test foo`、`just test bar` 等等。如果你的测试套件要跑不止几秒钟，这会非常有用。#footnote[如果你的终端支持自动补全，效果还会更好。]

这段命令也展示了 Just 的灵活性：你可以在 `justfile` 里定义一个命令并带有自定义参数或选项，然后在终端里传入参数。Just 会把这些参数传给命令的执行体。

再比如 `Jarl` 项目中的这个命令配方：

```just
# Update the list of rules and the website
[arg("no_quarto", long="no-quarto", value="true")]
document no_quarto="false":
    Rscript docs/check_pkgs.R
    Rscript docs/make_docs.R
    @if [ "{{ no_quarto }}" != "true" ]; then (cd docs && quarto render); fi
```

这个命令用于更新规则列表、文档和网站。最初每次都需要依次运行 `Rscript docs/make_docs.R` 和 `quarto render`，其中 `quarto render` 会花费几分钟时间构建网站。#link("https://github.com/Yousa-Mirage")[\@Yousa-Mirage] 和 #link("https://github.com/mattkerlogue")[\@Matt Kerlogue] 进行了#link("https://github.com/etiennebacher/jarl/issues/703")[相关的讨论]，随后 #link("https://github.com/Yousa-Mirage") 添加了 `--no-quarto` 选项。

`no_quarto` 选项默认值为 `false`。如果你在终端里运行 `just document`，就会像之前一样执行所有命令，包括 Quarto 渲染；如果你运行 `just document --no-quarto`，就会跳过 Quarto 渲染，只生成规则文档，从而极大缩短了调试时间。

_难道不能直接用 Make 代替 Just 吗？_

大概可以。我只是从来没写过 Makefile，而且是通过一位合作开发者才知道 Just 的。

我相当确定，对这个简单的例子来说，Make 也能很好地完成。不过 #link("https://github.com/casey/just#just")[Just 的文档]列出了它与 Make 的许多差异和改进。这篇文章只是想展示一个能小幅提升工作流体验的小技巧。

译者：我认为 Just 在单纯的“运行命令”方面比 Make 更加直观和易用，尤其是对于不熟悉 Makefile 语法的人来说。
