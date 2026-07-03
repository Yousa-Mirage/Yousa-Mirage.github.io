#import "tufted-lib/tufted.typ" as tufted

#let template = tufted.tufted-web.with(
  website-title: "天然純真 / Yousa Mirage",
  author: "天然純真",
  description: "天然純真的个人网站，随便写一点东西。",
  website-url: "https://yousa-mirage.github.io/",
  header-links: (
    "/": "Home",
    "/Blog/": "Blog",
    "/Entry": "Entry",
    "/Work/": "Work",
    "/About/": "About",
  ),
  header-elements: (
    [岁岁年年 叠于我身 皆循时光 逝而不返],
  ),
  footer-elements: (
    [无常之物 有常之物 时至今日 悉数于此],
    [Powered by #link("https://github.com/Yousa-Mirage/Tufted-Blog-Template")[Tufted-Blog-Template]],
  ),
  feed-dir: ("Blog/",),
)
