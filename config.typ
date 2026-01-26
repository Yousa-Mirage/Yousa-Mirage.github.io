#import "tufted-lib/tufted.typ" as tufted

#let template = tufted.tufted-web.with(
  title: "天然純真 / Yousa Mirage",
  description: "天然純真的个人网站，随便写一点东西。",
  site-url: "https://yousa-mirage.github.io/",
  lang: "zh",
  header-links: (
    "/": "Home",
    "/Blog/": "Blog",
    "/Entry": "Entry",
    "/About/": "About",
  ),
  header-elements: (
    [岁岁年年 叠于我身 皆循时光 逝而不返],
  ),
  footer-elements: (
    "© 2026 Yousa-Mirage",
    [Powered by #link("https://github.com/Yousa-Mirage/Tufted-Blog-Template")[Tufted-Blog-Template]],
  ),
)
