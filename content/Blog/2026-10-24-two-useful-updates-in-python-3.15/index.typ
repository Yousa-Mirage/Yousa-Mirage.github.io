#import "../index.typ": template, tufted
#show: template.with(
  title: "Python 3.15 中两个有用的小更新",
  date: datetime(year: 2026, month: 10, day: 24),
  description: "Python 3.15 的两个小更新：列表推导式支持解包语法，以及用 re.prefixmatch() 取代 re.match()。",
)

= 两个有用的小更新

2026 年 10 月 9 日，Python 正式发布了 3.15 版本。主要更新内容包括引入了显式延迟导入机制 `lazy import`（PEP 810）、新增不可变字典类型 `frozendict`、新增专用哨兵类型 `sentinel`、在推导式中支持解包语法（PEP 798）、将 UTF-8 设为默认文本编码、新增 Tachyon 性能分析器等。

本文将重点介绍两个小更新：列表推导式支持解包语法，以及用 `re.prefixmatch()` 取代 `re.match()`。

== 1. 列表推导式支持解包符号

你有没有曾经尝试过在列表推导式中使用星号（`*`）来展开嵌套列表？

```python
nested_list = [[1, 2], [3, 4], [5, 6]]
[*sublist for sublist in nested_list]
#   File "<python-input-0>", line 2
#     [*sublist for sublist in nested_list]
#      ^^^^^^^^
# SyntaxError: iterable unpacking cannot be used in comprehension
```

在 Python 3.14 及以下版本中尝试这样的操作时，将会收到 `SyntaxError`。Python 并不支持这种用法。

而在 Python 3.15 中，#link("https://peps.python.org/pep-0798/")[PEP 798] 引入了在列表推导式内部进行解包的功能（也包括元组、字典、集合和生成器推导式）。因此，现在可以使用这种非常自然的语法来展开嵌套列表、元组、集合、字典了。

解包列表：

```python
nested_list = [[1, 2], [3], [4, 5]]
[*sublist for sublist in nested_list]
# [1, 2, 3, 4, 5]
```

解包元组：

```python
nested_tuple = ((1, 2), (3,), (4, 5))
(*subtuple for subtuple in nested_tuple)  # Generator expression
# <generator object <genexpr> at 0x10ab7c3c0>
tuple(*subtuple for subtuple in nested_tuple)
# (1, 2, 3, 4, 5)
```

解包集合：

```python
nested_set = [{1, 2}, {3}, {4, 5}]
{*subset for subset in nested_set}
# {1, 2, 3, 4, 5}
```

解包字典（使用双星号 `**`）：

```
nested_dict = [{"a": 1, "b": 2}, {"c": 3}, {"d": 4, "e": 5}]
{**subdict for subdict in nested_dict}
# {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5}
```

=== 以前的一些做法

以这个输入数据为例：

```python
its = [[1, 2], [3], [4, 5]]
dicts = [{"a": 1, "b": 2}, {"c": 3}, {"d": 4, "e": 5}]
```

1. 显式循环

最直接的方式是创建空容器，然后逐个把内层元素添加进去：

```python
new_list = []
for it in its:
    new_list.extend(it)

new_set = set()
for it in its:
    new_set.update(it)

new_dict = {}
for d in dicts:
    new_dict.update(d)

def new_generator():
    for it in its:
        yield from it

new_list               # [1, 2, 3, 4, 5]
new_set                # {1, 2, 3, 4, 5}
new_dict               # {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5}
list(new_generator())  # [1, 2, 3, 4, 5]
```

`extend()` 和 `update()` 都是原地修改；`yield from` 则把内层可迭代对象逐个产出。

2. 推导式（两层循环）

可以把这些循环写成推导式，先遍历外层 `its`/`dicts`，再遍历每个 `it`/`d` 中的元素。

```python
[x for it in its for x in it]
# [1, 2, 3, 4, 5]

{x for it in its for x in it}
# {1, 2, 3, 4, 5}

{key: value for d in dicts for key, value in d.items()}
# {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5}

(x for it in its for x in it)
# <generator object ...>
```

3. 借助 `itertools`

`itertools.chain` 专门用来串联多个可迭代对象：

```python
import itertools

list(itertools.chain(*its))
# [1, 2, 3, 4, 5]

set(itertools.chain(*its))
# {1, 2, 3, 4, 5}

dict(itertools.chain(*(d.items() for d in dicts)))
# {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5}

itertools.chain(*its)
# <itertools.chain object ...>
```

`chain(*its)` 把 `its` 拆成多个参数；如果 `its` 本身是一个生成器或很大的列表，可以用 `chain.from_iterable()`：

```python
list(itertools.chain.from_iterable(its))
# [1, 2, 3, 4, 5]

set(itertools.chain.from_iterable(its))
# {1, 2, 3, 4, 5}

dict(itertools.chain.from_iterable(d.items() for d in dicts))
# {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5}

itertools.chain.from_iterable(its)
# <itertools.chain object ...>
```

4. 借助 `functools.reduce`

对列表、集合和字典，还可以用 `functools.reduce` 配合原地运算符：

```python
import functools
import operator

sets = [{1, 2}, {3}, {4, 5}]

functools.reduce(operator.iconcat, its, (new_list := []))
# [1, 2, 3, 4, 5]

functools.reduce(operator.ior, sets, (new_set := set()))
# {1, 2, 3, 4, 5}

functools.reduce(operator.ior, dicts, (new_dict := {}))
# {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5}
```

`operator.iconcat` 对应列表的 `+=`，`operator.ior` 对应集合或字典的 `|=`。`:=` 把初始累加器绑定到 `new_list`、`new_set`、`new_dict`，方便之后查看结果。

== 2. 用 `re.prefixmatch()` 取代 `re.match()`

如果你用过 Python 的正则表达式模块 `re`，你很可能见过或用过 `re.match()`，尽管你可能没有充分理解它实际的行为。

Python 3.15 正式引入了 `re.prefixmatch()`，并将原有的 `re.match()` 标记为“软弃用”（soft deprecated）。之所以是“软弃用”，是因为这并非功能上的弃用和替代，而是一次旨在消除语义歧义的 API 命名调整，是为了符合 Python 之禅中“显式优于隐式”的原则。

具体来说，Python 的 `re.match()` 实际上*只尝试从字符串的起始位置进行匹配*，而*不会搜索整个字符串*。但在许多其他编程语言和正则表达式库中，match 通常表示查找字符串中符合模式的内容，其语义更接近 Python 的 `re.search()`。

例如：

```python
import re

text = "hello python"

re.match("python", text)        # None
re.prefixmatch("python", text)  # None
re.match("hel", text)           # 匹配成功
re.search("python", text)       # 匹配成功
```

这种行为毫无疑问和“`match`”的语义常识不符，也引发了#link("https://discuss.python.org/t/add-re-prefixmatch-deprecate-re-match/")[相关的社区讨论]。许多人表示曾遇到过这个问题。出于兼容性考虑，Python 引入了新的名字 `re.prefixmatch()` 并推荐使用。
