#import "../index.typ": template, tufted
#import "@preview/theorion:0.6.0": *
#show: template.with(title: "天然純真的工作")

= 工作 / Work

#quote-block[
  “是，人活着总想发点光散点热……”\
]

#tufted.margin-note[
  #link("https://github.com/Yousa-Mirage")[GitHub 主页]
]

== 个人项目 / Personal Projects

- #link("https://github.com/Yousa-Mirage/Tufted-Blog-Template")[Tufted-Blog-Template]
  - 2025.12.31 \~ 今
  - 也就是当前这个博客模板了。拿了不少星，我感觉还挺好看的，配置也方便，写东西也舒服。
- #link("https://github.com/Yousa-Mirage/ggtypst")[ggtypst]
  - 2026.3.4 \~ 今
  - 开发的第一个 R 包，利用 Typst 强大的渲染能力给 ggplot2 的图像中添加、替换文本和公式。没想到第一个包就是 R+Rust+Typst 的大活，但得益于 Typst crate 的良好封装，整体开发体验还是很顺利的。反倒是体会到了 R 中混乱的面向对象系统，S3、S4、S7、R6 还有 ggplot2 自己用的一套。。。性能问题有些严重，后面有时间了再维护一下吧。开发时也得到了 extendr discord 和 r/rstats 社区的支持鼓励，还是挺好的。R 的中文开发者真的不多，可能都还没有 Rust 的多。#link("https://d.cosx.org/d/425776-hao-qi-wen-wen-wei-sa-jiebar-bao-yi-zhi-mei-ren-wei-hu-ya")[谢益辉说得没错]，确实得多多善待 R 包维护者啊（比如我）。
- #link("https://github.com/Yousa-Mirage/jiebaRS")[jiebaRS]
  - 2026.3.14 \~ 今
  - 自从 #link("https://github.com/qinwf/jiebaR")[jiebaR] 不再维护以至于从 CRAN 移除后，R 中的中文分词就成为一个令人困扰的问题。大家仍然可以从 GitHub 上下载覃大侠的包，但总归是不够方便。之前在上课时好多人就只得到一句摸不着头脑的 `package ‘jiebaR’ is not available for this version of R` 报错，助教还得教大家怎么从本地或 GitHub 安装，这让大家对 R 的印象就差了。好在 Rust 有又快又全又活跃的 #link("https://github.com/messense/jieba-rs")[jieba-rs crate]，让我能够以此为基础开发这个 jiebaR 的替代包。
- #link("https://github.com/Yousa-Mirage/r-ahocorasick")[r-ahocorasick]
  - 2026.5.22 \~ 今
  - 偶然发现 R 中居然没有算得上能用的 Aho-Corasick 算法实现（不算 Polars 中的字符串算法的话），于是乎，#link("https://github.com/BurntSushi/aho-corasick")[语言神]，启动！这种包写好了估计也不会有太多人用，但好在也不需要怎么维护，有人用就挺好。
- #link("https://github.com/Yousa-Mirage/cidian-rs")[cidian-rs] / #link("https://github.com/Yousa-Mirage/r-cidian")[r-cidian] / #link("https://github.com/Yousa-Mirage/py-cidian")[py-cidian]
  - 2026.8.6 \~ 今
  - 和 jiebaRS 类似，qinwf 开发的 cidian 包早已不再维护了，网上的存档版本也已经无法编译。解析中文词典、从而为分词器提供中文词表功能的需求依然存在。于是自然而然地，选择使用 Rust 编写一个通用的解析 crate，然后再分别为 R 和 Python 提供绑定。这也是我第一个 Rust crate 和 Python 包。开发过程中主要参考了 #link("https://github.com/nopdan")[nopdan] 大佬的#link("https://nopdan.com/series/lexicon/")[输入法词库解析系列文章]以及#link("https://github.com/nopdan/rose")[蔷薇词库转换库]。借助 AI 将这些文章和代码的逻辑改写为 Rust，并进行了不少测试。
- faststm
  - 还在推进中，理解数值计算的细节挺难的。
  - 之前用 R 的 #link("https://github.com/bstewart/stm")[stm 包] 做结构主题模型分析，跑得那叫一个慢。。。然后就打算用 Rust 实现一个更快的版本，也许进而能用做以前没办法做的分析。看的时候还发现 stm 包 README 中一个链接成赌博网站了，给普林斯顿的老师发了邮件提醒这件事，也挺有意思。

== 开源贡献 / Open Source Contributions

开源贡献主要是和 #link("https://github.com/etiennebacher")[Etienne Bacher] 的合作，集中在 tidypolars 和 Jarl 两个项目上。在 AI 的帮助下，为这两个包进行了全面的 BUG 审查，并提交了大量修复。目前是 tidypolars 的协作者之一，感谢 Etienne Bacher 的信任。

- #link("https://github.com/etiennebacher/tidypolars")[tidypolars]
  - `tidypolars` 为 `tidyverse` 提供了一个高性能 p`olars` 后端，目标是让用户能够在保留现有 `tidyverse` 代码的同时，利用 `polars` 获得显著的性能提升。
  - 截至 2026.9.19，目前有 35 commits，8,828 ++，590 \-\-。
- #link("https://github.com/etiennebacher/Jarl")[Jarl]
  - _Just Another R Linter_。Jarl 是一个 Rust 编写的快速 R 代码检查工具，它进行静态代码分析，以查找编程错误、漏洞和可疑的代码模式。
  - 截至 2026.9.19，目前有 33 commits，4,143 ++，351 \-\-。

== 论文 / Papers

跟公管的论文开始投了，等发出来吧。。。没有什么科研天分。
