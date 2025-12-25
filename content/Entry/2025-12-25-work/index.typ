#import "../index.typ": template, tufted
#import "@preview/theorion:0.4.1": *
#show: template.with(title: "学期小记 - 12.25")

#{
  tufted.margin-note(image("兄弟能等等我吗.jpg", width: 250pt))
  tufted.margin-note(image("兄弟能等等我吗.jpg", width: 250pt))
  tufted.margin-note(image("兄弟能等等我吗.jpg", width: 250pt))
}

= 学期小记

#box(image("兄弟能等等我吗.jpg", width: 250pt))
#box(image("兄弟能等等我吗.jpg", width: 250pt))

这学期很忙碌，忙忙又碌碌，很累。

推进的项目不知道前景如何。公管那边的进展还不错，概念处理还算有成效，种子词的处理自认为还是相当精妙的，他们那边想做的课题似乎有点困惑，师兄怎么说就怎么做吧。自己想用这份数据写另外的研究，比如对中国社会学或科学学的考察。芝大那边我有点不知道在干什么，Bernie 是想让我自己完全主导这个项目的推进吗？LLM 生成方法、LLM 生成正则，数据也不尽如人意，总感觉处处是问题，但 Bernie 感觉良好，不知道怎么样。继续干活吧，每周慢慢汇报，哪怕没什么进展，能有一个这样的机会也是好的。至于和师姐合作的项目，可谓是“心有余而力不足”，一直没有什么时间和精力去推进，直到年底才终于有点进展，用 LLM + Active Learning + PU Bagging 成功获取了数据集，看看寒假能不能有所进展吧。这个方法想写方法论文。倒是从中衍生出来的想法可以试着投一投《社会研究方法评论》，#link("https://mp.weixin.qq.com/s/uklvyX3QPTj1ZZ99jv-bDw")[2026 年重点选题]有这几个可以尝试的：
- 中国社会研究方法自主知识体系研究
- “人工智能+”创新哲学社会科学研究方法
- 生成式人工智能辅助社会科学研究的应用
- 中国社会研究方法史
这几个选题都可以从目前的项目中找到一些切入点，看看能不能写出点东西来。

最令人惊喜的应该是有 HR 来主动联系上自己。自己写的#link("../../Blog/2025-11-08-speed-test")[一篇公众号文章]获得了 7000+ 阅读，很高！然后有个人私信我要不要跳槽，他说他读到了我文章，感觉写得不错，然后发在了公司群里，得到了 CTO 的认可，然后 HR 就联系我了。然后我才发现原来是 #link("https://www.manjusaka.blog/")[Manjusaka]#tufted.margin-note(image("manjusaka.jpg", width: 150pt)) 的那个二次元 AI 公司。真好！可惜我现在没法去，等明年希望能去实习！

继续学习了 Rust，基本做完了 Exercism 上的 #link("https://exercism.org/tracks/rust")[Rust 练习题]。目前有两个想做的项目：一个是写一个带有 GUI 的 OpenAlex 批量下载工具，虽然没什么用，但可以练习 Rust 的爬虫、异步并发和简单 GUI 功能；另一个则是自己想了很久的 PolarView 项目，看能不能用 AI 整个搞出来，无论是哈基米 3.0 Pro 还是 Claude Opus 4.5 都很强，可以先用 Claude 写出主体，然后用免费的 GLM 4.7 打磨，总之寒假要搞出来。

这学期给几个开源项目做了贡献，如 #link("https://github.com/SakiRinn/LiveCaptions-Translator", "LiveCaptions-Translator")、#link("https://github.com/sinelaw/fresh", "Fresh") 等，做贡献最多的是 #link("https://github.com/etiennebacher/tidypolars", "Tidypolars")。自己给 Tidypolars 提了 4 个 PR，两大两小，主要贡献了三个新函数：
- `unnest_longer_polars()`
- `separate_longer_delim_polars()` #tufted.margin-note(image("兄弟能等等我吗.jpg", width: 250pt))
- `separate_longer_position_polars()`
争取新年继续把剩下几个函数写出来，把 `unnest` 和 `separate` 系列写完。希望能找到一个 Rust + R/Python 的项目做贡献，开源贡献真的很有获得感和自豪感。也许有朝一日我也能成为一个研究软件开发员，所以说：

#quote-box[
  万能的宇宙大人啊，告诉我未来会好吗？
]

这学期的组会自己讲了两次，居然还是讲的次数最多的，其他人应该狠狠反思，嗯嗯！每次开组会都很累，自己想准备充分一些，于是每次都要熬大夜磨十几个小时。但大家喜欢，还是值得的。

这学期状态不好，总是晚上干活白天睡觉，总听#link("https://www.bilibili.com/video/BV1XZQ1YHEkN")[《昼寝》]#tufted.margin-note(image("昼寝.webp"))，总是心想“黄昏你快点走吧，太阳想早点回家”。感觉自己越来越鼠鼠了，这学期说话最多的人居然是 Bernie，毕竟有一周稳定一个小时的见面时间。谁能想到我一个英语这么差的鼠鼠，一学期下来居然跟一个牢美说话最多呢？和朋友没什么见面，见面也几乎没有自己能说的话，小鱼老师忙自己的生活，半年只发给我一个👍，那还能怎么办呢？和对象见面也很少很短，几乎没有出去玩过。忙，都忙，忙点儿好啊。
#tufted.margin-note(image("兄弟能等等我吗.jpg", width: 250pt))
#tufted.margin-note(image("兄弟能等等我吗.jpg", width: 250pt))
#tufted.margin-note(image("兄弟能等等我吗.jpg", width: 250pt))
#quote-box[
  有什么消失了\
  又是什么消失了\
  在醒来时已经是落日时分了\
  到底是什么不见了\
  在心底回响的什么东西\
  消逝了

  我必须知道爱是什么啊\
  我明明很清楚 我明明很清楚\
  *在夕阳里醒来的中途 我不清不楚\
  我却看不出 什么都留不住*

  ——《昼寝》

]

再有几天 2025 年就要过完了，时间过得真快。希望寒假能把下学期课程的人物赶一赶，希望明年能有论文发，希望明年能找到工作，希望明年能有钱赚，希望明年大家还都喜欢我。

#box(image("兄弟能等等我吗.jpg", width: 250pt))
#box(image("兄弟能等等我吗.jpg", width: 250pt))
