#import "tufted-lib/tufted.typ" as tufted

#let template = tufted.tufted-web.with(
  header-links: (
    "/": "Home",
    "/Blog/": "Blog",
    "/Entry": "Entry",
    "/About/": "About",
  ),
  lang: "zh",
  title: "天然純真 / Yousa Mirage",
  header-elements: (
    [你好],
    [Ciallo～(∠・ω< )⌒☆],
  ),
  footer-elements: (
    "© 2026 Yousa-Mirage",
    [Powered by #link("https://github.com/Yousa-Mirage/Tufted-Blog-Template")[Tufted-Blog-Template]],
  ),
)
