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

== 代码项目 / Code Projects

- #link("https://github.com/Yousa-Mirage/Tufted-Blog-Template")[Tufted-Blog-Template]
  - 2025.12.31 \~ 今
  - 也就是当前这个博客模板了。拿了不少星，我感觉还挺好看的，配置也方便，写东西也舒服。
- #link("https://github.com/Yousa-Mirage/ggtypst")[ggtypst]
  - 2026.3.4 \~ 今
  - 开发的第一个 R 包，利用 Typst 强大的渲染能力给 ggplot2 的图像中添加、替换文本和公式。没想到第一个包就是 R+Rust+Typst 的大活，但得益于 Typst crate 的良好封装，整体开发体验还是很顺利的。反倒是体会到了 R 中混乱的面向对象系统，S3、S4、S7、R6 还有 ggplot2 自己用的一套。。。性能问题有些严重，后面有时间了再维护一下吧。开发时也得到了 extendr discord 和 r/rstats 社区的支持鼓励，还是挺好的。R 的中文开发者真的不多，可能都还没有 Rust 的多。#link("https://d.cosx.org/d/425776-hao-qi-wen-wen-wei-sa-jiebar-bao-yi-zhi-mei-ren-wei-hu-ya")[谢益辉说得没错]，确实得多多善待 R 包维护者啊（比如我）。
- #link("https://github.com/Yousa-Mirage/jiebaRS")[jiebaRS]
  - 2026.3.14 \~ 今
  - 自从 #link("https://github.com/qinwf/jiebaR")[jiebaR] 不再维护以至于从 CRAN 移除后，R 中的中文分词就成为一个令人困扰的问题。大家仍然可以从 GitHub 上下载覃大侠的包，但总归是不够方便。之前在上课时好多人就只得到一句摸不着头脑的 `package ‘jiebaR’ is not available for this version of R` 报错，助教还得教大家怎么从本地或 GitHub 安装，这让大家对 R 的印象就差了。好在 Rust 有又快又全又活跃的 #link("https://github.com/messense/jieba-rs")[jieba-rs crate]，让我能够以此为基础开发这个 jiebaR 的替代包。（希望能被认可喵\~）
- #link("https://github.com/Yousa-Mirage/r-ahocorasick")[r-ahocorasick]
  - 2026.5.22 \~ 今
  - 偶然发现 R 中居然没有算得上能用的 Aho-Corasick 算法实现（不算 Polars 中的字符串算法的话），于是乎，#link("https://github.com/BurntSushi/aho-corasick")[语言神]，启动！这种包写好了估计也不会有太多人用，但好在也不需要怎么维护，有人用就挺好。
- faststm
  - 还在推进中，理解数值计算的细节挺难的。
  - 之前用 R 的 #link("https://github.com/bstewart/stm")[stm 包] 做结构主题模型分析，跑得那叫一个慢。。。然后就打算用 Rust 实现一个更快的版本，也许进而能用做以前没办法做的分析。看的时候还发现 stm 包 README 中一个链接成赌博网站了，给普林斯顿的老师发了邮件提醒这件事，也挺有意思。

== 论文 / Papers

跟公管的论文开始投了，等发出来吧。。。没有什么科研天分。
