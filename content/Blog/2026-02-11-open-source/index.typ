#import "../index.typ": template, tufted
#import "@preview/theorion:0.4.1": *
#show: template.with(
  title: "开源贡献（2025.9 ~ 2026.2）",
  date: datetime(year: 2026, month: 2, day: 11),
  description: "记录自己在 2025 年 9 月至 2026 年 2 月期间对多个开源项目的贡献经历。",
)

= 开源贡献（2025.9 \~ 2026.2）

#quote-box[“陪伴是最长情的告白。”]

== 缘起： LiveCaptions-Translator

缘起要追溯到 2025 年 9 月 14 日的 #link("https://github.com/SakiRinn/LiveCaptions-Translator/pull/200")[LiveCaptions-Translator \#200]。由于需要和 Bernard Koch 进行会议，但自己又听不懂英语，所以找到了 LiveCaptions-Translator 项目。这个 C\# 软件通过 Windows 自带的“实时字幕”程序获取内容，然后调用翻译 API。

当时看到了一个 ISSUE，内容是 CSV 导出会出现错位，原因是仅仅使用最简单的 `,` 作为分隔符，与文本中的 `,` 相冲突。我首先尝试使用 `\t` 作为分隔符，但作者指出这并非最佳实践。于是我引入了 `CSVHelper` 库来正确处理转义字符和引号，最终提交了 PR 并被合并。

虽然只是一个相当简单的修复，但这是我第一次在 GitHub 提交 PR 并被合并，实在是十分有参与感的事。

在 2026 年 1 月 31 日，我又针对 CSV 导出的时间格式问题提交了一个  #link("https://github.com/SakiRinn/LiveCaptions-Translator/pull/238")[PR \#238]，尝试将时间格式改为标准的 `yyyy-MM-dd HH:mm:ss`。目前还在等待审查和合并。

== Fresh

#link("https://github.com/sinelaw/fresh")[Fresh] 是一个用 Rust 编写的终端文本编辑器，非常像终端里的 VS Code，轻量且快速。我为其提交了两个 PR：

- *文档纠错* (#link("https://github.com/sinelaw/fresh/pull/232")[\#232]): 修正了用户手册中关于侧边栏切换快捷键的错误描述（将 `Ctrl+B` 修正为实际的 `Ctrl+E`）。
- *配置路径标准化* (#link("https://github.com/sinelaw/fresh/pull/287")[\#287]): 优化了配置文件的加载逻辑。此前 Fresh 在 macOS 上未能正确遵循 XDG 标准路径，导致配置文件位置与文档描述不符。我通过支持标准 XDG 路径，使得 Fresh 在不同操作系统（特别是 macOS 和 Linux）上的配置行为更加统一且符合预期。

第一次参与 Rust 项目！

== Tidypolars

2025 年 12 月，我主要为 #link("https://github.com/etiennebacher/tidypolars")[Tidypolars] 贡献了一些代码。这是一个旨在让 R 用户能以熟悉的 Tidyverse 语法来通过 Polars 高效处理数据的库。出发点自然也是在使用过程中发现了一些功能上的不足，想要通过贡献代码来完善它。

- *`unnest_longer_polars`* (#link("https://github.com/etiennebacher/tidypolars/pull/281")[\#281]): 允许将列表列展开为行。
- *`separate_longer_delim_polars`* (#link("https://github.com/etiennebacher/tidypolars/pull/285")[\#285]): 支持按分隔符拆分字符串列。
- *`wday`* (#link("https://github.com/etiennebacher/tidypolars/pull/292")[\#292]): 增加了对 `week_start` 参数的支持，使其行为与 `lubridate::wday` 保持一致。
- #link("https://github.com/etiennebacher/tidypolars/pull/291")[\#291] 改进了 Windows 上的 CI 工作流，缓解了此前频繁出现的测试失败问题。
- 一些文档改进。

目前我为 Tidypolars 贡献了 7 commits，新增了 3000+ 行代码。美中不足的是受限于 Polars 的接口功能，`wider_()` 函数难以实现。但这个过程还是收获很多，特别是了解和参与了 R 包开发的整个流程。

== Gemini Voyager

#link("https://github.com/Nagi-ovo/gemini-voyager")[Gemini Voyager] 是一个 Gemini 浏览器增强插件，好用！我主要修复了一些 Firefox 浏览器的兼容性问题。例如：

- 导出按钮无效
- 时间线右键无效
- Deep Research 导出按钮消失
- “引用回复”与输入框折叠的冲突
- 去水印功能无效
- Prompt-Logo 不显示
- ...

和项目作者在微信上讨论了很多！

== ZeroLaunch-rs

#link("https://github.com/ghost-him/ZeroLaunch-rs")[ZeroLaunch-rs] 是一个 Windows 平台上的轻量应用启动器，作者是 #link("https://github.com/ghost-him")[`@ghost-him`]。非常好用！由于不想运行安装程序，我一直使用的是便携版。某次更新之后我发现软件报错缺失 `.dll`，一通检查发现是忘记打包了，遂提交 #link("https://github.com/ghost-him/ZeroLaunch-rs/pull/51")[PR]！

#link("https://github.com/ghost-him")[`@ghost-him`] 佬自己也是我的 `Tufted-Blog-Template` 模板的用户，他给 `Tufted-Blog-Template` 项目提交了 #link("https://github.com/Yousa-Mirage/Tufted-Blog-Template/pull/19")[PR]，提供了 RSS 订阅源功能，实现了模板的一个大改进！

== PyAlex

因为科研项目需要使用 OpenAlex 数据库，我使用了 #link("https://github.com/J535D165/pyalex")[pyalex] 这个 Python 库来查询和导出数据集。在使用过程中，我发现其#link("https://github.com/J535D165/pyalex/issues/71")[类型提示支持不够完善]。

于是我提交了 #link("https://github.com/J535D165/pyalex/pull/96")[PR \#96]，主要工作是添加大量类型提示和静态分析支持。这让 IDE 能够提供更准确的代码补全和错误检查，提升了开发体验。目前还没有被审查和合并。

== Tufted-Blog-Template

最后当然是投入心血最多的个人项目 —— #link("https://github.com/Yousa-Mirage/Tufted-Blog-Template")[Tufted-Blog-Template]。

这是一个基于 #link("https://typst.app/")[Typst] 的 Tufte 风格博客模板（如你目前所见）。最初受 #link("https://github.com/vsheg/tufted")[Tufted] 项目的启发，在此基础上进行了大量修改和优化，以“优雅”和“易用”为目标（毕竟最初是给身边的萌新同学开发的）。

这个项目目前已经有 $128$ star，是我目前 star 最多的项目，也得知一些社会学学者和社区大佬开始使用这个模板。在这个项目中我第一次审核和合并他人的 PR，在此感谢 #link("https://github.com/yanwenwang24")[\@yanwenwang24] 和 #link("https://github.com/ghost-him")[\@ghost-him]！

此外，还纯依赖 AI 做了一个 #link("https://github.com/Yousa-Mirage/ToDuo-rs")[`ToDuo-rs`] 项目，是一个基于 `todo.txt` 规范的任务管理工具，一套核心代码同时支持命令行和 GUI 界面，挺有意思的。

接下来想投入的开源项目一个是 `faststm`，一个是 `ggtypst`。两个都有了思路，但没有时间和精力去研究和实现...

== 结语

有点体会到“劳动”和“异化劳动”的区别了，也应了那句台词：

#quote-box[
  “是，人活着总想发点光散点热，可你不能拿我们当劈柴烧！”\
  ——《我的团长我的团》
]

当然，参与开源项目还有内心深处的其他原因，在此就不多说了。

AI 真强，特别是 Claude Opus，可惜自己只有 GitHub Copilot 提供的那点额度，还要分给科研项目用。但对于一些特别具体的算法、偏门的 Rust 库，AI 的实现还是不怎么样，很可能需要推倒重来。也许等自己闲下来，能有钱买个把月的 Claude Code Plus 来开展自己的那几个项目。赚钱养 AI！

总之，希望今年能够忙中偷闲，多多参与一些开源项目的贡献，以及开发自己的项目！
