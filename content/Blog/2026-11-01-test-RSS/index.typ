#import "../index.typ": template, tufted
#show: template.with(
  title: "测试全文 RSS",
  date: datetime(year: 2026, month: 11, day: 1),
  description: "这是 description 中的内容",
)

= 这是正文标题

== 第一部分

这是全文的一部分。

```py
a = [1, 2, 3, 4, 5]
b = [i^2 for i in a]
```

#image("大狗叫.jpg")