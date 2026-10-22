#import "../index.typ": template, tufted
#import "@preview/theorion:0.6.0": quote-block
#show: template.with(
  title: "Python 中的 range 是迭代器吗？",
  date: datetime(year: 2026, month: 10, day: 22),
  description: "Python 的 range 对象可以被多次遍历、支持索引和 len，却并不实现迭代器协议。本文解释 range 与迭代器的区别，以及为什么它更适合重复使用。",
  extra-info: [译者：#link("https://github.com/Yousa-Mirage")[天然純真]],
)

= Python 中的 range 不是迭代器

#tufted.margin-note[
  本文翻译自 Trey Hunner 在 2018 年 2 月 28 日发表的博客文章 #link("https://treyhunner.com/2018/02/python-range-is-not-an-iterator/", [_Python: range is not an iterator_])。
]

#tufted.margin-note[
  我大概在两年前读到过这篇文章，当时感觉非常有意思，可能是我个人读的第一篇对于 Python 一些细节进行讨论的博客，因此印象非常深刻。现将其翻译、存档在这里。其实这些细节具体有什么作用，可能还真没有什么作用，但至少是有趣的。
]

在 #link("https://2017.pygotham.org/")[2017 年的 PyGotham 大会]上，我做了关于#link("https://www.youtube.com/watch?v%3DWd7vcuiMhxU")[“更好的循环”]的演讲。之后有人问了我一个很好的问题：*_迭代器（iterators）是惰性可迭代对象，而 `range` 也是惰性可迭代对象，所以 `range` 是迭代器吗？_*

我不记得问我这个问题的人的名字了。但我记得我用“oh I love that question!”回答了他。

我很喜欢这个问题#footnote[我也一样]，因为在 Python 中，`range` 对象的确是惰性的，也是可迭代的，但却*不是迭代器*。

我经常看到人们混淆这两个概念。过去一年里，我听到过 Python 初学者、资深 Python 程序员，甚至有些 Python 老师都错误地将 Python 的 `range` 对象称为_迭代器_。#footnote[
  但首先，无论是否能够区分，都不影响许多人一直顺利使用 Python 并编写出高质量的代码。这些小知识不足以成为优越感的来源或者借此对其他人进行不友善指责。这些细节知识对于 Python 这样一门服务于“应用”的语言来说真的无关紧要。
]

== 确实有些令人困惑

当人们讨论 Python 中的*迭代器*（iterators）和*可迭代对象*（iterables）时，你可能会听到一些人重复这种误解：`range` 是迭代器。乍一看，这个错误似乎无关紧要，但我认为它实际上非常关键。如果你认为 `range` 对象是迭代器，那么说明你对 Python 中迭代器的工作原理的理解还不够清晰。`range` 和迭代器在某种意义上都是“惰性”的，但他们的惰性机制并不相同。

在本文中，我将分别解释迭代器和 `range` 是如何工作的，以及这两种“惰性可迭代对象”的惰性机制有何不同。

== 什么是迭代器（iterator）？

在 Python 中，*可迭代对象（iterable）*是指任何可以被 `for` 循环遍历的对象。而*迭代器（iterator）*执行实际迭代操作的对象。#footnote[
  迭代器一定是可迭代对象，但可迭代对象不一定是迭代器。也就是 $"Iterator" subset "Iterable"$ 。可迭代对象不一定是可索引的，他们不一定具有长度，也不一定总是有限的。
]

可迭代对象可以被迭代，迭代器则执行迭代。

在 Python 中，你可以使用 `iter()` 函数从*任何可迭代对象*中获取迭代器：

```python
iter([1, 2, 3])
# <list_iterator object at 0x101806500>

iter("hello")
# <str_ascii_iterator object at 0x10667ad10>
```

可以看到，无论是得到的 `list_iterator` 还是 `str_ascii_iterator`，它们都是迭代器对象。

有了迭代器后，你_*唯一*_能做的就是获取它的下一个元素（next）。如果你请求下一个元素但实际上没有更多元素来，就会抛出 `StopIteration` 异常。

```python
my_iterator = iter([1, 2])
next(my_iterator)
# 1
next(my_iterator)
# 2
next(my_iterator)
# Traceback (most recent call last):
#   File "<python-input-6>", line 1, in <module>
#     next(my_iterator)
#     ~~~~^^^^^^^^^^^^^
# StopIteration
```

因为上文已经提到，所有的迭代器都是可迭代对象，因此你也可以从一个迭代器中获取另一个迭代器（返回自身）：

```python
iterator1 = iter([1, 2])
iterator2 = iter(iterator1)
iterator1 is iterator2
# True
```

不用多说，迭代器也是可以迭代的：

```python
my_iterator = iter([1, 2])
for item in my_iterator:
    print(item)
# 1
# 2
```

需要注意的是，迭代器是有状态的、不可重用的。这意味着，一旦你从迭代器中消费了一个元素，它就消失了，不能回退、不能重新迭代。因此，当你遍历了一个迭代器后，它就“用完了”。如果你想要再次迭代，你必须重新创建一个新的迭代器。

```python
my_iterator = iter([1, 2])
[item for item in my_iterator]
# [1, 2]
[item for item in my_iterator]
# []
```

在 Python 中，`enumerate`、`zip`、`map`、`filter`、`reversed` 等很多内置函数都返回迭代器。

```python
nums = [1, 2, 3]
enumerate(nums)
# <enumerate object at 0x106719cb0>
zip(nums, nums)
# <zip object at 0x106706e80>
reversed(nums)
# <list_reverseiterator object at 0x106711b10>
```

生成器（generator）是创建自定义迭代器的更简单的方式之一。你可以通过生成器函数或使用生成器表达式来创建迭代器。

```python
nums = [1, 2, 3]
squares = (n ** 2 for n in nums)
squares
# <generator object <genexpr> at 0x1067402e0>

def my_generator():
    yield 1
    yield 2
    yield 3
my_generator()
# <generator object my_generator at 0x1065f5fc0>
```

我常说，迭代器是惰性的一次性可迭代对象。之所以是“惰性”的，是因为他们只在循环遍历时才生成下一个元素。之所以是“一次性”的，是因为一旦你从迭代器中消费了一个元素，它就永远消失了；一旦迭代器被遍历完了，它就不能再被迭代了。因此，生成器是可以被“耗尽”的。

以上是对迭代器的简要概述。我们并没有深入到迭代器的实现细节（也就是迭代器协议，一个对象为什么是可迭代的），但我们已经了解了迭代器的基本行为。

== range 有什么不同？

上文简单介绍了迭代器的行为。现在我们来看看 `range` 对象。

我们都知道，Python 中的 `range` 对象可以像其他可迭代对象一样进行循环遍历：

```python
for i in range(3):
    print(i)
```

因为 `range` 是*可迭代的*，所以你可以从它中获取一个*迭代器*：

```python
my_range = range(3)
my_iterator = iter(my_range)
my_iterator
# <range_iterator object at 0x1017b3ba0>

next(my_iterator)  # 注意这里我们使用 `next()` 来获取下一个元素
# 0
```

但 `range` 对象本身并不是*迭代器*。从本质上来说，它没有实现*迭代器协议*。因此，我们不能对 `range` 对象调用 `next()`：

```python
next(range(3))
# Traceback (most recent call last):
#   File "<python-input-16>", line 1, in <module>
#     next(range(3))
#     ~~~~^^^^^^^^^^
# TypeError: 'range' object is not an iterator
```

而且和迭代器不同，我们可以多次遍历 `range` 对象而不消耗它：

```python
nums = range(3)
[item for item in nums]
# [0, 1, 2]
tuple(nums)
# (0, 1, 2)
for a, b in zip(nums, nums):
    print(a, b * 2)
# 0 0
# 1 2
# 2 4
```

就像上文所说的，如果我们使用迭代器，第二次循环就不会得到任何内容：

```python
nums = iter(range(3))
[item for item in nums]
# [0, 1, 2]
[item for item in nums]
# []
```

== 到底什么是 `range`？

从某种意义上来说，`range` 对象是惰性的，因为它在创建时并没有生成所有的数字，而是根据需要生成它们。也就是说，当我们运行 `range(10000)` 时，它并不会立刻在内存中一次性生成 10000 个数字。

和迭代器不同，尽管并没有实际生成所有的数字，但 `range` 对象仍然是有长度、可索引、可切片的。

例如，我们创建一个 `range` 对象和一个生成器对象（Generator）#footnote[
  生成器对象也是迭代器，也就是说 $"Generator" subset "Iterator" subset "Iterable"$
]：

```python
nums = range(10000)
squares = (n ** 2 for n in nums)
```

与迭代器不同， `range` 对象具有长度：

```python
len(nums)
# 10000
len(squares)
# Traceback (most recent call last):
#   File "<python-input-20>", line 1, in <module>
#     len(squares)
#     ~~~^^^^^^^^^
# TypeError: object of type 'generator' has no len()
```

`range` 对象也可以被索引：

```python
nums[0]
# 0
nums[-2]
# 9998
squares[0]
# Traceback (most recent call last):
#   File "<python-input-21>", line 1, in <module>
#     squares[0]
#     ~~~~~~~^^^
# TypeError: 'generator' object is not subscriptable
```

与迭代器不同，你可以在不改变其状态的情况下检查 `range` 对象是否包含元素：

```python
0 in nums
# True
0 in nums
# True
0 in squares
# True
0 in squares
# False
```

如果非要描述 `range` 对象，可以叫它“惰性序列”。它是序列（sequence），就像列表、元组、字符串一样，因为它是可索引的、可切片的、可迭代的，并且具有长度。但它底层不包含任何实际元素，而是通过计算来生成这些元素。#footnote[
  在#link("https://docs.python.org/3/builtins/stdtypes.html")[官方文档]中，只有三种 basic sequence types：`list`、`tuple` 和 `range`。也就是说，`range` 和常见的列表、元组是平级的。字符串是不可变的序列类型，属于 sequence 的子类。
]

```python
from collections.abc import Sequence
isinstance([1, 2], Sequence)
# True
isinstance((1, 2), Sequence)
# True
isinstance("hello", Sequence)
# True
isinstance(range(3), Sequence)
# True
isinstance((n ** 2 for n in range(3)), Sequence)
# False
```

== 这种区别为何重要？

也许有人会觉得我说“`range` 不是迭代器”是在吹毛求疵，但我真的不这么认为。

如果我告诉你一个东西是迭代器，你就能确信，当你对它调用 `iter()` 时，你总是会得到同一个对象：

```python
iter(my_iterator) is my_iterator
# True
```

而且你肯定可以对它调用 `next()`，并且每次调用都会返回下一个元素，直到迭代器被耗尽。

实际上以上两点也就是所谓的“迭代器协议”：

+ 迭代器对象必须实现 `__iter__()` 方法，并且返回自身。
+ 迭代器对象必须实现 `__next__()` 方法，并且在没有更多返回值时抛出 `StopIteration` 异常。

当你遍历迭代器时，你会知道其中的元素会被逐个消耗掉。有时，这个特性在以特定方式处理迭代器时非常有用：

```python
my_iterator = iter([1, 2, 3, 4])
list(zip(my_iterator, my_iterator))
# [(1, 2), (3, 4)]
```

因此，虽然“惰性可迭代对象”和“迭代器”之间的区别可能看似细微，但实际上它们的含义截然不同。“惰性可迭代对象”是一个非常宽泛的术语，没有具体的含义，而“迭代器”则特指具有特定行为的对象。

== 总结

如果你知道可以循环遍历某个对象，那么它就是一个可迭代对象（iterable）。

如果你知道你正在循环遍历的对象会在你遍历时才进行计算，那么它就是一个惰性可迭代对象（lazy iterable）。

如果你知道你可以使用 `next()` 来获取它的下一个元素，那么它就是一个迭代器（iterator），尽管不那么严谨。

如果你可以多次循环遍历某个对象而不会“耗尽”它，那么它就不是迭代器。同样，如果你不能调用 `next()` 来获取它的下一个元素，那么它也不是迭代器。因此，`range` 对象不是迭代器。

但话又说回来，如果你看到有人说“`range` 是迭代器”，你也不必太过纠结或者苛责。可以指出来，但对于实际使用来说，这个区别并不重要。你可以继续使用 `range` 对象，就像你一直以来所做的那样。

#line()

#quote-block[“万能的宇宙大人啊，告诉我未来会好吗？”]
#image("miku.jpg")
