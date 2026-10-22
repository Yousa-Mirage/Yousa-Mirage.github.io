#import "../index.typ": template, tufted
#show: template.with(
  title: "Python itertools 完全指南：理解常见数据迭代模式",
  date: datetime(year: 2026, month: 10, day: 22),
  description: "Python 标准库 itertools 提供了一组高效、内存友好的迭代器工具，覆盖组合、排列、分组、切片和无限序列等常见任务。本文按使用场景逐一介绍常用函数、输入输出、版本差异与常见陷阱。",
)

= Python itertools 完全指南：理解常见数据迭代模式
#tufted.margin-note[
  #link("./itertools cheatsheet.pdf", "英文 PDF 速查表") \
  by Rodrigo Girão Serrão / mathspp.com
]
== 1. 为什么需要 itertools 库？

先看三个常见问题：①计算时间序列中相邻两个数据的变化量；②计算两个序列所有可能的组合；③展开一个嵌套列表。

```python
# 1. 计算相邻两个数据的变化量
data = [10, 13, 12, 15, 18]

# for 循环实现
changes = []
for i in range(len(data) - 1):
    changes.append(data[i + 1] - data[i])
print(changes)
# [3, -1, 3, 3]

# itertools 实现
from itertools import pairwise

changes = [b - a for a, b in pairwise(data)]
print(changes)
# [3, -1, 3, 3]
```

```python
# 2. 计算两个序列所有可能的组合
a = [1, 2, 3]
b = ['A', 'B']

# for 循环实现
combinations = []
for x in a:
    for y in b:
        combinations.append((x, y))
print(combinations)
# [(1, 'A'), (1, 'B'), (2, 'A'), (2, 'B'), (3, 'A'), (3, 'B')]

# itertools 实现
from itertools import product

combinations = list(
  product(a, b)
)
print(combinations)
# [(1, 'A'), (1, 'B'), (2, 'A'), (2, 'B'), (3, 'A'), (3, 'B')]
```

```python
# 3. 展开一个嵌套列表
nested_list = [[1, 2], [3, 4], [5]]

# for 循环实现
flattened = [item for sublist in nested_list for item in sublist]
print(flattened)
# [1, 2, 3, 4, 5]

# Python 3.15 后可用解包实现
flattened = [*sublist for sublist in nested_list]

# itertools 实现
from itertools import chain

flattened = list(
  chain.from_iterable(nested_list)
)
print(flattened)
# [1, 2, 3, 4, 5]
```

`itertools` 的价值在于把一些反复出现的迭代操作封装成明确、可复用的工具。例如，取得部分数据、处理相邻元素、根据条件筛选、按照固定大小分批、遍历参数组合，都是编程中经常遇到的模式。

普通循环完全能够完成这些工作，但使用适当的迭代工具，可以减少循环嵌套，让代码更简洁、更易读。

== 2. 认识 itertools：迭代器和惰性求值

先了解三个概念：

- *可迭代对象*（iterable）：能交给 `iter()` 的对象，例如列表、字符串、`range`、文件对象、生成器等都是可迭代对象。
- *迭代器*（iterator）：同时实现 `__iter__` 和 `__next__` 的对象。它记住当前位置，只能向前，耗尽后再调用 `next()` 会抛出 `StopIteration`。一个对象是可迭代的不等于它是迭代器。
- *`itertools` 工具*：大多数函数接收一个或多个可迭代对象，返回一个新的迭代器。它们不会立刻计算结果，而是在你调用 `next()`、写 `for` 循环或执行 `list()` 时按需计算。

例如，`count()` 可以表示无限序列，但创建它时并不会生成无限个数字：

```python
from itertools import count

counter = count(10, 5) # 没有任何新的数字被生成
next(counter)  # 10
next(counter)  # 15
next(counter)  # 20
# 25, 30, ...
```

只有在继续请求时，它才会计算下一个值。这种“用到才算”的方式叫*惰性求值*（lazy evaluation）。

惰性求值有三个直接好处：

+ *按需计算*：不需要预先知道全部结果，也不需要一次性占用内存。
+ *可组合*：一个迭代器的输出可以直接作为另一个迭代器的输入，形成流水线。
+ *能表示无限序列*：`count()`、`cycle()`、`repeat()` 在理论上可以无限运行，只要下游有终止条件。

```python
from itertools import count, islice

squares = (x * x for x in count(1))  # squares 是一个迭代器
list(
  islice(squares, 4)
)  # [1, 4, 9, 16]
```

代价也同样明显：

+ *只能消费一次*：迭代器耗尽后不能回头；需要重复遍历时，要么重新创建，要么用 `list()` 物化，要么用 `tee()` 分叉。#footnote[`range` 对象不是迭代器，它可以被多次迭代。有一篇文章专门讨论 `range` 对象，以后翻译过来。]
+ *调试不那么直观*：直接打印迭代器通常只看到对象地址；想看内容，需要 `list()` 等。
+ *无限迭代器不能直接 `list()`*：那会一直运行下去，直到内存耗尽。必须先用 `islice()`、`zip()`、`takewhile()` 等方式截断。

`itertools` 的函数大多返回迭代器；`groupby()` 返回 `(key, group)` 形式的迭代器，其中 `group` 本身也是迭代器；`tee()` 返回一个由多个迭代器组成的元组。理解这一点是正确使用 `itertools` 的基础。

== 3. 六类功能函数

官方文档把 `itertools` 分成无限迭代器、有限迭代器和组合生成器三类。下面按更贴近日常任务的方式分成六类：数据重组、数据筛选、无限迭代、配对计算、排列组合、迭代器分叉。

`itertools` 一共提供 19 个迭代器工具，外加 `tee()` 这一个函数。`zip()`、`map()`、`filter()` 是内置函数，`reduce()` 则来自 `functools`；它们经常和 `itertools` 一起使用对迭代器进行操作，所以也在相应章节一并讨论。

以下代码均默认已经执行 `import itertools as it`。

=== 3.1 数据重组：islice、pairwise、groupby、batched、chain

这一组函数不改变元素本身，而是改变“怎么取出元素”：取一段、取相邻对、分组、分批、拼接。

==== `islice()`

用于对任意可迭代对象做切片，不需要先转换成列表。

```python
nums = range(10)
list(
  it.islice(nums, 3)
)  # [0, 1, 2]
list(
  it.islice(nums, 2, 5)
)  # [2, 3, 4]
list(
  it.islice(nums, 0, None, 2)
)  # [0, 2, 4, 6, 8]
```

`islice(iterable, stop)` 只给一个停止位置；`islice(iterable, start, stop[, step])` 则同时指定起点、终点和步长。`stop` 不包含在结果里，`start` 从 0 开始。

`islice()` 是惰性的，但它必须把输入消费到 `stop` 才能结束。被跳过的元素同样会被消费。如果 `stop=None`，它会一直读到输入耗尽。

```python
gen = (x for x in range(10))
list(
  it.islice(gen, 3)
)  # [0, 1, 2]
list(
  it.islice(gen, 3)
)  # [3, 4, 5]
```

这里第二次切片得到 `[3, 4, 5]`，而不是重新从 0 开始，因为 `gen` 是迭代器，已经被第一次调用推进了。

细节：

+ 不支持负数索引；`start`、`stop` 必须是非负整数或 `None`，*`step` 必须是正整数*。
+ `islice()` 不会复制数据，适合处理大文件、生成器、网络流等无法一次性载入内存的输入。
+ 如果只需要“前 n 个”，`islice(xs, n)` 通常比 `list(xs)[:n]` 更节省内存。

==== `pairwise()`

Python 3.10 引入，用于生成相邻元素组成的重叠二元组。

```python
list(
  it.pairwise([1, 2, 3, 4])
)  # [(1, 2), (2, 3), (3, 4)]
list(
  it.pairwise([1])
)  # []
```

长度为 n 的输入会产生 n-1 个元组。`pairwise()` 只保留上一个元素，内存占用是 O(1)，不需要像 `zip(xs, xs[1:])` 那样复制列表。

它特别适合计算相邻差值、相邻比率、简单的滑动窗口，以及“比较当前元素和前一个元素”的场景：

```python
prices = [100, 102, 99, 105]
changes = [b - a for a, b in it.pairwise(prices)]
# [2, -3, 6]
```

如果需要长度为 3 或更大的滑动窗口，标准库没有直接函数；可以用 `tee()`、多个 `islice()` 或 `collections.deque` 组合实现。

==== `groupby()`

用于把相邻且键相同的元素分成一组，返回 `(key, group_iterator)`。

```python
data = [
    ("p", "red"), ("p", "blue"),
    ("m", "red"), ("m", "green"),
    ("p", "black"),
]

for key, group in it.groupby(data, key=lambda x: x[0]):
    print(key, list(group))
# p [('p', 'red'), ('p', 'blue')]
# m [('m', 'red'), ('m', 'green')]
# p [('p', 'black')]
```

注意最后一个 `p` 单独成组，因为中间隔了 `m`。*`groupby()` 只合并*连续*且键相同的元素*，不会自动排序。

如果要按 key 做全局分组，先按 key 排序：

```python
sorted_data = sorted(data, key=lambda x: x[0])
for key, group in it.groupby(sorted_data, key=lambda x: x[0]):
    print(key, [item[1] for item in group])
# m ['red', 'green']
# p ['red', 'blue', 'black']
```

细节：

+ `group` 是一个迭代器，只在下一次外层迭代前有效；一旦继续推进 `groupby()`，前一个 `group` 就不能再用了。需要保留时写成 `list(group)`。
+ `key=None` 时按元素本身分组。
+ `groupby()` 是惰性的，但为了全局分组而做的 `sorted()` 会计算数据。
+ 关键不是“值是否相同”，而是“相同的值是否相邻”。

==== `batched()`

Python 3.12 引入，用于把数据切成固定大小的元组，适合分页、批量调用 API、把流式数据交给要求定长块的接口。默认情况下，最后一批可能不足 n 个。

```python
list(
  it.batched(range(7), 3)
)  # [(0, 1, 2), (3, 4, 5), (6,)]
list(
  it.batched(range(6), 3)
)  # [(0, 1, 2), (3, 4, 5)]
```

默认情况下，最后一批可能较短。如果业务要求每一批都必须是完整长度，可以加 `strict=True`（Python 3.13+）：

```python
list(it.batched(range(7), 3, strict=True))
# Traceback (most recent call last):
#   File "<python-input-20>", line 1, in <module>
#     list(it.batched(range(7), 3, strict=True))
#     ~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# ValueError: batched(): incomplete batch
```

==== `chain()`

按顺序把多个可迭代对象串成一个连续迭代器。

```python
list(
  it.chain([1, 2], [3, 4], [5])
)  # [1, 2, 3, 4, 5]
list(
  it.chain.from_iterable([[1, 2], [3, 4], [5]])
)  # [1, 2, 3, 4, 5]
```

`chain(*iterables)` 接收多个可迭代对象；`chain.from_iterable(iterable_of_iterables)` 只接收一个参数，这个参数本身产生多个可迭代对象。后者适合动态列表或生成器：

```python
def chunks():
    yield [1, 2]
    yield [3, 4]
    yield [5]

list(
  it.chain.from_iterable(chunks())
)  # [1, 2, 3, 4, 5]
```

细节：

+ 两者都是惰性的，不会复制元素。
+ `chain.from_iterable` 是 `chain` 的类方法，不是普通函数。
+ 它只展开一层；深层嵌套需要递归或其他方法。
+ 常见用途包括展开一层嵌套列表、合并多个文件分片、把多个生成器串联起来。

在 Python 3.15+ 中，引入了推导式中的解包语法，类似的功能可以直接写为:

```python
[*sublist for sublist in nested_list]
```

=== 3.2 数据筛选：filterfalse、takewhile、dropwhile、compress

这一组函数解决“保留哪些元素”和“什么时候停止”的问题。它们看起来相似，但停止条件和是否消耗边界元素差别很大。

==== `filterfalse()`

用于保留 predicate 为假的元素，是 `filter()` 的补集。

```python
list(
  it.filterfalse(lambda x: x % 2 == 0, range(6))
)  # [1, 3, 5]
list(
  it.filterfalse(None, [0, 1, "", "x", None, 2])
)  # [0, '', None]
```

`filterfalse(predicate, iterable)` 会扫描整个输入，把所有让 predicate 返回假值的元素交出来。`predicate` 可以是 `None`，此时按元素本身的真值判断，保留所有假值元素（例如 `0`、`""`、`None` 在条件语句中为假值）。

它和 `filter()` 的关系是互补的：

```python
xs = range(6)
list(
  filter(lambda x: x % 2 == 0, xs)
)  # [0, 2, 4]
list(
  it.filterfalse(lambda x: x % 2 == 0, xs)
)  # [1, 3, 5]
```

细节：`filterfalse()` 会看完整个输入，不会在某个位置提前停止；如果只需要处理“开头满足条件的一段”，应该用 `takewhile()`。

==== `takewhile()`

用于从头开始产出元素，直到 predicate 第一次为假；之后停止。

```python
list(
  it.takewhile(lambda x: x < 5, [1, 2, 5, 1, 3])
)  # [1, 2]
```

第一个不满足条件的元素 `5` 会被消费掉，但不会出现在结果里。之后的元素也不会再被检查。用一个迭代器看得更清楚：

```python
nums = iter([1, 2, 5, 1, 3])
list(
  it.takewhile(lambda x: x < 5, nums)
)  # [1, 2]
list(
  nums
)  # [1, 3]；5 已经被 takewhile 消费掉了
```

细节：

+ `takewhile()` 只判断前缀，不会在中间“重新开始”。
+ 第一个失败的元素会被消耗，这是一个常见陷阱；如果需要保留它，可以改用 `dropwhile()`、`tee()` 或手动循环。
+ 适合读取日志直到分隔符、解析连续头部行、处理“前缀满足某条件”的流。

==== `dropwhile()`

用于丢弃开头满足 predicate 的元素，从第一个不满足的元素开始产出。

```python
list(
  it.dropwhile(lambda x: x < 5, [1, 2, 5, 1, 3])
)  # [5, 1, 3]
```

`dropwhile()` 和 `takewhile()` 是一对互补工具：一个保留前缀，一个丢弃前缀。不同的是，`dropwhile()` 会把第一个不满足条件的元素包含在结果里，因此不会丢失边界元素。

细节：

+ 一旦 predicate 第一次为假，后面的元素不再判断，全部原样产出。
+ 如果输入全部满足条件，结果是空迭代器；如果第一个元素就不满足，结果就是原序列。
+ 适合跳过文件头、跳过空白行、跳过满足某条件的前导记录。

==== `compress()`

用于用一个布尔选择器序列筛选数据。适合用预先计算好的掩码筛选数据，例如保留某些日期、某些列、某些样本。

```python
list(
  it.compress("ABCDEF", [1, 0, 1, 0, 1, 1])
)  # ['A', 'C', 'E', 'F']
list(
  it.compress([10, 20, 30], [True, False])
)  # [10]
```

`compress(data, selectors)` 按位置配对：selector 为真时保留对应位置的 data 元素。选择器可以是任意可迭代对象，元素按真值判断。

细节：

+ 当 data 或 selectors 任一耗尽时停止，所以结果长度是 `min(len(data), len(selectors))`。
+ 和 `filter()` 的区别是：`filter()` 看元素本身，`compress()` 看外部选择器。

=== 3.3 无限迭代：repeat、cycle、count

这三个函数可以产生无限序列。它们本身不会停止，必须由下游的 `islice()`、`zip()`、`takewhile()` 等提供终止条件。

==== `repeat()`

用于重复同一个对象；可以指定次数，也可以无限重复。

```python
list(
  it.repeat("x", 3)
)  # ['x', 'x', 'x']
list(
  it.islice(it.repeat("x"), 4)
)  # ['x', 'x', 'x', 'x']
```

`repeat(object, times=None)` 省略 `times` 时无限重复。常见用法是给 `map()` 或 `zip()` 提供常量参数：

```python
list(
  map(pow, [2, 3, 4], it.repeat(2))
)  # [4, 9, 16]

# 这里相当于
[pow(x, 2) for x in [2, 3, 4]]
```

细节：

+ 无限 `repeat()` 必须配合终止条件。
+ 如果对象是可变对象，重复的是同一个引用，而不是每次新建一个副本。例如 `list(it.repeat([], 3))` 得到三个指向同一列表的引用，修改其中一个会影响全部。
+ `repeat()` 与 `cycle()` 不同：`repeat()` 重复同一个对象，`cycle()` 循环遍历一个序列中的不同元素。

==== `cycle()`

用于把输入遍历完后从头再来，形成无限循环。

```python
list(
  it.islice(it.cycle("AB"), 5)
)  # ['A', 'B', 'A', 'B', 'A']
```

`cycle(iterable)` 会先消费输入并把元素缓存起来，之后不断重复这些缓存。因此内存占用与输入长度成正比。

细节：

+ 空输入会立即结束，不会无限空转。
+ 如果输入本身是无限迭代器，`cycle()` 永远不会进入第二轮。
+ 适合轮询、循环分配、重复固定模式。
+ 必须用 `islice()`、`zip()`、`takewhile()` 等截断，不能直接 `list()`。

==== `count()`

用于生成无限等差序列。

```python
list(
  it.islice(it.count(), 5)
)  # [0, 1, 2, 3, 4]
list(
  it.islice(it.count(2, 3), 4)
)  # [2, 5, 8, 11]
```

`count(start=0, step=1)` 从 `start` 开始，每次增加 `step`。`start` 和 `step` 可以是整数、浮点数、`Fraction`、`Decimal` 等支持加法的对象。

常见用法是给 `zip()` 提供索引：

```python
words = ["a", "b", "c"]
list(
  zip(it.count(1), words)
)  # [(1, 'a'), (2, 'b'), (3, 'c')]
```

细节：

+ `count()` 永远不会自己停止，必须用 `islice()`、`zip()`、`takewhile()` 等截断。
+ 如果只是给序列编号，`enumerate(words, start=1)` 更直接；`count()` 更适合自定义步长、跨多个序列共享计数器，或者需要无限序列的场景。
+ `count()` 不会预先分配内存，适合作为其他迭代器的“计数器”。

=== 3.4 配对计算：zip_longest、starmap、accumulate 及相关内置函数

这一组把多个序列按位置组合起来，或者把二元函数连续应用到序列上。其中 `zip()` 和 `map()` 是 Python 内置函数，`reduce()` 来自 `functools`，`zip_longest()`、`starmap()`、`accumulate()` 来自 `itertools`。

==== `zip()`

用于按位置把多个可迭代对象组合成元组，遇到最短的输入耗尽就停止。

```python
list(
  zip([1, 2, 3], "ab")
)  # [(1, 'a'), (2, 'b')]
```

默认的 `zip()` 会静默截断。Python 3.10+ 支持 `strict=True`，长度不一致时抛出 `ValueError`：

```python
list(zip([1, 2, 3], "ab", strict=True))
# Traceback (most recent call last):
#   File "<python-input-26>", line 1, in <module>
#     list(zip([1, 2, 3], "ab", strict=True))
#     ~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# ValueError: zip() argument 2 is shorter than argument 1
```

细节：

+ `zip()` 是内置函数，不是 `itertools` 的函数，但和 `zip_longest()`、`starmap()` 经常一起使用。
+ 它返回惰性迭代器，不会提前生成所有元组。

==== `zip_longest()`

用于组合到最长的输入耗尽，缺失位置用 `fillvalue` 填充。`fillvalue` 默认是 `None`。它适合处理长度不一致、但又必须对齐的序列，例如合并不同长度的实验数据、把稀疏记录补齐。

```python
list(
  it.zip_longest([1, 2, 3], "ab")
)  # [(1, 'a'), (2, 'b'), (3, None)]
list(
  it.zip_longest([1, 2], "abc", fillvalue="-")
)  # [(1, 'a'), (2, 'b'), ('-', 'c')]
```

细节：

+ `zip_longest()` 会一直消费到最长的输入结束。
+ 如果输入中有无限迭代器，`zip_longest()` 永远不会停止；必须先用 `islice()` 截断。
+ *`fillvalue` 是同一个对象*；如果填充可变对象，所有缺失位置会共享同一个引用。

==== `map()`

用于把函数应用到每个元素上，返回惰性迭代器。`map(function, *iterables)` 可以接收多个输入；它会按位置调用函数，并在最短的输入耗尽时停止。

```python
list(
  map(str.upper, ["a", "b"])
)  # ['A', 'B']
list(
  map(pow, [1, 2, 3], [2, 3, 4])
)  # [1, 8, 81]
```

细节：

+ `map()` 是内置函数，不是 `itertools` 的函数。
+ `map()` 和列表推导式都能完成逐元素转换；在简单场景下，列表推导式通常更易读。
+ `map()` 与 `starmap()` 的区别在参数形式：`map(f, xs)` 调用 `f(x)`，`starmap(f, xys)` 调用 `f(*xy)`。

==== `starmap()`

用于对可迭代对象中的每个参数元组做解包调用：`function(*args)`。它等价于 `map(lambda args: function(*args), iterable)`，但少了一层 lambda，语义也更直接。

```python
list(
  it.starmap(pow, [(2, 3), (3, 2), (10, 0)])
)  # [8, 9, 1]

# 等价于
[pow(*args) for args in [(2, 3), (3, 2), (10, 0)]]
```

细节：

+ 输入中的每个元素必须能解包成函数的参数；否则会抛出 `TypeError`。
+ `starmap()` 是惰性的，适合参数已经成组的场景，例如 `product()`、`zip()` 或数据库查询返回的元组。
+ 如果参数不在元组里，用 `map()`；如果参数已经打包成元组，用 `starmap()`。

==== `reduce()`

用于把二元函数连续应用到元素上，折叠成*单个值*。`reduce(function, iterable[, initial])` 先取前两个元素计算，再把结果与下一个元素计算，依此类推。`initial` 会作为初始计算的左操作数。

```python
from functools import reduce

reduce(lambda a, b: a + b, [1, 2, 3, 4])       # 1 + 2 + 3 + 4 = 10
reduce(lambda a, b: a + b, [1, 2, 3, 4], 100)  # 100 + 1 + 2 + 3 + 4 = 110
```

细节：

+ `reduce()` 来自 `functools`，不是 `itertools` 的函数。
+ 它是急切的：调用时就会遍历完整个输入，返回一个值。
+ 空序列且没有 `initial` 会抛出 `TypeError`。
+ 对加法、乘法、最大值等常见操作，可以直接用 `sum()`、`math.prod()`、`max()` 等内置函数，通常更清晰。

==== `accumulate()`

`accumulate(iterable, func=operator.add, *, initial=None)` 用于返回每一步的累计结果，是惰性的“带中间值的折叠”。默认做累加，也可以传入任意二元函数。`initial` 会作为第一个输出（Python 3.8+）。

```python
list(
  it.accumulate([2, 5, 8, 11])
)  # [2, 7, 15, 26]
list(
  it.accumulate([2, 5, 8, 11], initial=0)
)  # [0, 2, 7, 15, 26]
list(
  it.accumulate([1, 2, 3, 4], lambda a, b: a * b)
)  # [1, 2, 6, 24]
```

细节：

+ `accumulate()` 是惰性的，返回迭代器；`reduce()` 是急切的，只返回最终值。
+ `reduce(f, xs)` 大致等于 `list(accumulate(xs, f))[-1]`，但空输入和 `initial` 的情况要单独处理。
+ 适合累计和、累计乘积、运行最大值，以及其他需要保留中间结果的递推计算。

=== 3.5 排列组合：product、permutations、combinations、combinations_with_replacement

这一组函数把输入元素按不同规则组合成元组。它们的区别集中在两点：*顺序是否重要*，以及*同一个元素能否重复使用*。

==== `product()`

用于计算多个输入的笛卡尔积，等价于多层嵌套循环。输出顺序是“最右边的输入变化最快”。`repeat=2` 等价于把同一个输入传两次。

```python
list(
  it.product([1, 2], "ABC")
)
# [(1, 'A'), (1, 'B'), (1, 'C'), (2, 'A'), (2, 'B'), (2, 'C')]

list(
  it.product([1, 2], repeat=3)
)
# [(1, 1, 1), (1, 1, 2), (1, 2, 1), (1, 2, 2), (2, 1, 1), (2, 1, 2), (2, 2, 1), (2, 2, 2)]
```

细节：

+ 结果数量是各输入长度的乘积；`repeat=k` 时是 $n^k$。
+ `product()` 会先把输入池缓存为元组，因此输入必须是有限的；输出本身是惰性的。
+ 如果只是两层循环的替代品，`product()` 往往比手写嵌套循环更清晰。
+ 它和 `combinations()` 不同：`product()` 允许同一个位置的元素重复出现，而且顺序重要。

==== `permutations()`

用于返回长度为 r 的有序排列，不允许重复使用同一位置的元素。结果数量是 $n! / (n-r)!$。`r` 省略时等于输入长度；`r > n` 时返回空迭代器。

```python
list(
  it.permutations("ABC", 2)
)
# [('A', 'B'), ('A', 'C'), ('B', 'A'), ('B', 'C'), ('C', 'A'), ('C', 'B')]

list(
  it.permutations("ABC")
)
# [('A', 'B', 'C'), ('A', 'C', 'B'), ('B', 'A', 'C'),
#  ('B', 'C', 'A'), ('C', 'A', 'B'), ('C', 'B', 'A')]
```

细节：

+ 输出顺序取决于输入顺序，并按输入位置做字典序排列。
+ 输入中的重复元素不会被去重，可能产生重复排列。
+ 输入会被缓存，因此需要有限的可迭代对象。

==== `combinations()`

用于返回长度为 r 的无序组合，不允许重复使用同一位置的元素。结果数量是 $C(n, r) = n! / (r!(n-r)!)$。输出按输入位置排序；`r > n` 时返回空迭代器。

```python
list(
  it.combinations("ABC", 2)
)
# [('A', 'B'), ('A', 'C'), ('B', 'C')]
```

细节：

+ `combinations()` 不关心顺序：`('A', 'B')` 和 `('B', 'A')` 被视为同一个组合，只输出前者。
+ 输入中的重复元素不会被去重，可能产生重复组合。
+ 它和 `permutations()` 的关系是：组合选出元素，排列再决定这些元素的顺序。

==== `combinations_with_replacement()`

用于返回长度为 r 的无序组合，允许同一个元素被重复选中。结果数量是 $C(n+r-1, r)$。`r=0` 时返回一个空元组 `[()]`。

```python
list(
  it.combinations_with_replacement("AB", 2)
)
# [('A', 'A'), ('A', 'B'), ('B', 'B')]
```

细节：

+ 允许重复，但仍然是组合：顺序不重要。
+ 输出按输入位置排序。
+ 输入中的重复元素不会被去重。
+ 它和 `product(..., repeat=r)` 的区别是：`product()` 认为顺序重要，而且每个位置都可以独立选择任意元素；`combinations_with_replacement()` 只保留非递减顺序的组合。

=== 3.6 迭代器分叉：tee

用于把一个可迭代对象分叉成 n 个独立的迭代器，默认为 2。

```python
a, b = it.tee([1, 2, 3])
list(a)  # [1, 2, 3]
list(b)  # [1, 2, 3]
```

两个迭代器各自记住自己的位置，但共享底层输入。当其中一个跑得更快时，`tee()` 会缓存它已经读过、另一个还没读的元素。分支之间的进度差越大，缓存就越多。

细节：

+ `tee(iterable, n=2)` 返回一个包含 n 个迭代器的元组。
+ 如果其中一个分支会先消费大部分数据，直接 `list(iterable)` 可能更快，也更省心。
+ `tee()` 返回的迭代器不是线程安全的；多线程共享时要加锁。
+ 它适合确实需要多次独立遍历、又不想立即 计算的场景，例如同时计算总和与最大值：

```python
a, b = it.tee([3, 1, 4, 1, 5])
sum(a), max(b)  # (14, 5)
```

== 4. 容易混淆的函数应该如何选择？

这些函数名字相近，但“保留什么”“什么时候停止”“长度不一致怎么办”差别很大。

=== 第一组：filter、filterfalse、takewhile、dropwhile、compress

#table(
  columns: 3,
  align: (left, left, left),
  table.header([函数], [保留哪些元素], [停止或扫描方式]),
  table.hline(),
  [`filter(pred, xs)`], [pred 为真的元素], [扫描完整个输入],
  [`filterfalse(pred, xs)`], [pred 为假的元素], [扫描完整个输入],
  [`takewhile(pred, xs)`], [开头连续满足 pred 的元素], [遇到第一个假值就停止，并消耗它],
  [`dropwhile(pred, xs)`], [第一个假值及其后的所有元素], [跳过开头真值，保留第一个假值],
  [`compress(xs, selectors)`], [selector 为真的位置], [任一输入耗尽即停止],
)

`filterfalse()` 是 `filter()` 的补集；`compress()` 的选择器与数据位置对应，不依赖元素本身。`takewhile()` 和 `dropwhile()` 都只判断前缀，不会在中间重新开始。

=== 第二组：zip、zip(strict=True)、zip_longest

#table(
  columns: 3,
  align: (left, left, left),
  table.header([写法], [长度策略], [长度不一致时]),
  table.hline(),
  [`zip(a, b)`], [以最短的输入为准], [静默截断],
  [`zip(a, b, strict=True)`], [要求所有输入等长], [抛出 `ValueError`（Python 3.10+）],
  [`zip_longest(a, b, fillvalue=...)`], [以最长的输入为准], [用 `fillvalue` 填充，默认 `None`],
)

默认的 `zip()` 适合“只关心公共部分”的场景；如果长度不一致说明数据有问题，用 `strict=True`；如果必须保留所有数据，用 `zip_longest()`。

=== 第三组：四种排列组合函数

#table(
  columns: 4,
  align: (left, center, center, left),
  table.header([函数], [顺序重要？], [允许重复？], [结果数量]),
  table.hline(),
  [`product(*pools, repeat=k)`], [是], [是], [各输入长度之积；`repeat=k` 时为 $n^k$],
  [`permutations(xs, r)`], [是], [否], [$n! / (n-r)!$],
  [`combinations(xs, r)`], [否], [否], [$C(n, r)$],
  [`combinations_with_replacement(xs, r)`], [否], [是], [$C(n+r-1, r)$],
)

这里的“重复”指同一个元素能否被重复选中。输入本身有重复值时，这四种函数都不会自动去重。

=== 补充：map 与 starmap、reduce 与 accumulate

#table(
  columns: 4,
  align: (left, left, left, left),
  table.header([函数], [调用形式], [输出], [求值方式]),
  table.hline(),
  [`map(f, xs)`], [`f(x)`], [逐元素结果], [惰性],
  [`starmap(f, xys)`], [`f(*xy)`], [逐元素结果], [惰性],
  [`reduce(f, xs)`], [连续折叠], [单个最终值], [急切],
  [`accumulate(xs, f)`], [连续折叠], [每一步的中间值], [惰性],
)

`map()` 和 `starmap()` 都是逐元素映射；`reduce()` 和 `accumulate()` 都是折叠，区别在于是否保留中间结果。

== 5. 总结与速查表

#table(
  columns: 3,
  align: (left, left, left),
  table.header([类别], [函数], [典型用途]),
  table.hline(),
  [数据重组], [`islice`、`pairwise`、`groupby`、`batched`、`chain`], [取片段、相邻对、分组、分批、拼接],
  [数据筛选], [`filterfalse`、`takewhile`、`dropwhile`、`compress`], [补集过滤、前缀/后缀、布尔选择],
  [无限迭代], [`repeat`、`cycle`、`count`], [常量、循环、计数器],
  [配对计算], [`zip`、`zip_longest`、`map`、`starmap`、`reduce`、`accumulate`], [组合、填充、映射、折叠],
  [排列组合], [`product`、`permutations`、`combinations`、`combinations_with_replacement`], [笛卡尔积、排列、组合],
  [迭代器分叉], [`tee`], [多次独立遍历],
)

官方文档：#link("https://docs.python.org/3/library/itertools.html")[itertools — Functions creating iterators for efficient looping]

#tufted.margin-note[
  #link("./itertools cheatsheet.pdf", "英文 PDF 速查表") \
  by Rodrigo Girão Serrão / mathspp.com
]
