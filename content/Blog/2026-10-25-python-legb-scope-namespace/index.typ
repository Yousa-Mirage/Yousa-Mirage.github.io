#import "../index.typ": template, tufted
#show: template.with(
  title: "Python 的 LEGB 规则：作用域与命名空间",
  author: "Stephen Gruppetta",
  date: datetime(year: 2026, month: 10, day: 25),
  description: "从局部、嵌套、全局到内置作用域，理解 Python 的变量查找顺序，以及 for 循环、列表推导式和 nonlocal 的作用域差异。",
  extra-info: [译者：#link("https://github.com/Yousa-Mirage")[天然純真]],
)

= Python 的 LEGB 规则：作用域与命名空间

#tufted.margin-note[
  本文翻译自 Stephen Gruppetta 于 2024 年 10 月 27 日发表的文章 #link("https://www.thepythoncodingstack.com/p/python-legb-rule-scope-namespace")[_Let's Eliminate General Bewilderment • Python's LEGB Rule, Scope, and Namespaces_]，有删节和改写。
]

在 Python 里，变量能不能被访问，要看它所在的作用域。关于 Python 的作用域与命名空间，有一个简单的 *LEGB* 规则#sub[#strike[（LEGO？？？）]]。理解 LEGB，就能解释大部分“这里能读到、那里读不到”的问题。

简而言之，LEGB 是 Python 查找名字的四个层次：

+ *L*：Local，当前函数的局部作用域
+ *E*：Enclosing，外层嵌套函数的作用域
+ *G*：Global，模块的全局作用域
+ *B*：Built-in，Python 内置名字的作用域

查找时从上到下进行，找到第一个匹配的变量名就停止。

== 从函数内部开始：L

函数内部赋值的变量，默认属于这个函数的局部作用域。函数调用结束后，这个局部作用域就不再直接可见。

```python
def outer():
    name = "函数局部"
    print("函数内部：", name)

outer()
# 函数内部： 函数局部

print("函数外部：", name)
# NameError: name 'name' is not defined
```

`name` 只在 `outer()` 内部存在。函数外部没有这个名字，所以最后一行会抛出 `NameError`。

== 同名变量：全局与局部

全局也可以有一个 `name`。两个变量同名，但因为处于不同作用域，彼此不会覆盖。

```python
name = "全局"

def outer():
    name = "函数局部"
    print("函数内部：", name)

outer()
print("函数外部：", name)
# 函数内部： 函数局部
# 函数外部： 全局
```

这里有两个不同的 `name`：一个在全局命名空间，一个在 `outer()` 的局部命名空间。函数内部的赋值不会改动全局变量。

== 本地找不到，就向外找：L → G

如果函数内部没有定义某个名字，Python 不会立刻报错，而是继续到外层查找。

```python
message = "全局消息"

def outer():
    name = "函数局部"
    print("局部 name：", name)
    print("全局 message：", message)

outer()
# 局部 name： 函数局部
# 全局 message： 全局消息
```

`name` 在局部找到，`message` 在局部找不到，于是到全局找到。这就是 L 在 G 前面的含义。

== 嵌套函数：E（Enclosing）

嵌套函数会多出一层“外层函数作用域”。如果内层函数找不到某个名字，它会先到外层函数里找。Enclosing 作用域只在*嵌套函数*中出现：如果函数定义在模块顶层，它就没有 E 这一层。

```python
name = "全局"

def outer():
    name = "外层"

    def inner():
        print("内层看到：", name)

    inner()
    print("外层看到：", name)

outer()
print("全局看到：", name)
# 内层看到： 外层
# 外层看到： 外层
# 全局看到： 全局
```

`inner()` 的局部没有 `name`，于是进入 E（Enclosing），在 `outer()` 中找到“外层”。全局的 `name` 没有被改动。

如果内层函数自己给 `name` 赋值，它会在自己的局部作用域里创建一个新变量，而不是修改外层变量。

```python
def outer():
    name = "外层"

    def inner():
        name = "内层"
        print("内层看到：", name)

    inner()
    print("外层看到：", name)

outer()
# 内层看到： 内层
# 外层看到： 外层
```

内层的赋值只影响内层。要让内层修改外层的 `name`，需要显式声明 `nonlocal`。`nonlocal` 告诉 Python：这个赋值要落到最近的外层函数作用域，而不是当前局部作用域。

```python
def outer():
    name = "外层"

    def inner():
        nonlocal name
        name = "被内层修改"
        print("内层修改后：", name)

    inner()
    print("外层再读取：", name)

outer()
# 内层修改后： 被内层修改
# 外层再读取： 被内层修改
```

有了 `nonlocal`，`inner()` 修改的就是 `outer()` 的 `name`。这也是闭包能够更新外层状态的基础。

同理，`global` 也能把赋值指向全局变量，但它会让数据流更难追踪，通常应尽量避免。

== 最后是 B：内置作用域

如果 L、E、G 都找不到，Python 最后会查内置作用域。`print`、`len`、`range`、`list` 这些名字都在这里。

```python
print("正常打印")
# 正常打印

print = "我不再是函数了"
print("这行会失败")
# TypeError: 'str' object is not callable
```

第二行在全局作用域创建了一个叫 `print` 的字符串。第三行调用 `print(...)` 时，Python 先找到全局的字符串，而不会继续去内置作用域找函数，因此抛出 `TypeError`。

这也是为什么不应该用 `print`、`len`、`list` 这类内置名字做变量名。

== 类的作用域：一个特殊的存在

函数和类都会创建自己的作用域，但类的作用域和函数不一样。类执行时会创建一个新的命名空间；类中定义的名字会成为类属性。但这个命名空间不会自动成为方法的 Enclosing 作用域。

=== 类有自己的命名空间

```python
class Demo:
    a = 1
    b = a + 1

print(Demo.a, Demo.b)  # 1 2
```

类从上到下执行一次，`a`、`b` 都进入类的命名空间，成为类属性。类内部可以读取前面已经定义的名字，因此 `b = a + 1` 能正常工作。

类也能读取外层作用域的名字：

```python
base = 10

class Demo:
    value = base + 1

print(Demo.value)  # 11
```

如果类定义在函数里，它同样可以读取外层函数的变量：

```python
def make_class():
    base = 1

    class Demo:
        value = base + 1

    return Demo

print(make_class().value)  # 2
```

=== 方法不会把类作用域当作 Enclosing

这是类作用域最容易被误解的地方。方法里的名字查找仍然遵循 L → E → G → B，但这里的 E 是外层的*函数*，而不是所在的类。

```python
class Demo:
    class_value = 1

    def get(self):
        return class_value

Demo().get()
# NameError: name 'class_value' is not defined
```

显然 `get()` 的局部没有 `class_value`，它会去找外层*嵌套函数*（这里没有），再找全局（没有），最后找内置（没有）。类命名空间不在它的查找链里。

要访问类属性，必须通过实例或类：

```python
class Demo:
    class_value = 1

    def get(self):
        return self.class_value

print(Demo().get())  # 1
```

也可以写 `Demo.class_value`；用 `self.class_value` 则会先查实例属性，再查类属性。

=== 嵌套类也看不到外层类的名字

同样的规则适用于嵌套类：

```python
class Outer:
    outer_value = 1

    class Inner:
        inner_value = outer_value

Outer.Inner.inner_value
# NameError: name 'outer_value' is not defined
```

`Inner` 的类不能把 `Outer` 的类命名空间当作 Enclosing。要引用外层类的属性，需要写 `Outer.outer_value`。

=== 类里的 nonlocal 指向哪里？

如果类定义在函数里，类里的 `nonlocal` 指向外层函数，而不是类本身：

```python
def make_class():
    value = 1

    class Demo:
        nonlocal value
        value = 2

    return Demo, value

print(make_class()[1])  # 2
```

类可以用 `nonlocal` 修改外层函数的变量；但类中的方法不会因此获得类作用域，方法里的 `nonlocal` 仍然指向函数层。

总之，类有自己的命名空间，类中的赋值会成为类属性。类作用域不是方法的 Enclosing，方法里不能直接使用类变量，必须通过 `self.attr`、`cls.attr` 或 `Class.attr`。类作用域更像“类定义执行时使用的一块命名空间”，而不是函数那种会参与闭包捕获的外层作用域。

== 作用域和命名空间

作用域回答的是“这个名字在哪儿可见”，命名空间回答的是“当前有哪些名字，以及它们指向什么对象”。命名空间本质上是一个从名字到对象的映射。

```python
def outer():
    name = "外层"

    def inner():
        name = "内层"
        print("内层命名空间：", list(locals()))

    inner()
    print("外层命名空间：", list(locals()))

outer()
# 内层命名空间： ['name']
# 外层命名空间： ['name', 'inner']
```

`locals()` 返回当前局部命名空间中的名字。`inner()` 只有 `name`，`outer()` 则有 `name` 和 `inner`。

模块也有自己的命名空间。`import random` 之后通过 `random.randint` 访问，`from random import randint` 则会把 `randint` 直接放进当前全局命名空间。类同样有自己的命名空间；类是独立的作用域，但方法内部不会自动把类变量当作外层变量，访问类属性仍然要通过类名或 `self`。

== 边缘情况

 并不是所有缩进块都会创建新的作用域，例如 `for`、`if`、`while`、`try`、`with`等：

```python
name = "全局"

for name in range(3):
    pass

print("for 循环后：", name)  # 2

if True:
    inside = "if 块里定义的"

print("if 块外：", inside)  # if 块里定义的
```

循环变量 `name` 覆盖了外层的同名变量；`if` 块里定义的 `inside` 在块外仍然可见。它们都处于当前作用域，而不是各自拥有一个作用域。

函数、类和*推导式*则会创建自己的作用域。这种区别在处理循环变量和临时变量时很重要。

这里值得注意的是，和普通的 `for` 循环不同，列表推导式有自己的作用域，推导式里的循环变量不会泄漏到外部。

```python
name = "全局"

values = [f"第 {name} 次" for name in range(3)]
print("列表：", values)   # ['第 0 次', '第 1 次', '第 2 次']
print("推导式后：", name) # 全局
```

== 总结

#table(
  columns: 4,
  align: (center, left, left, left),
  table.header([顺序], [作用域], [存在时机], [典型]),
  table.hline(),
  [L], [Local（局部）], [函数调用时], [函数内赋值的变量],
  [E], [Enclosing（嵌套）], [存在嵌套函数时], [外层函数的变量],
  [G], [Global（全局）], [程序运行期间], [模块顶层变量],
  [B], [Built-in（内置）], [解释器启动时], [`print`、`len`、`range`],
  [C（补充）], [Class（类）], [类执行时], [类属性；不进入方法的 LEGB],
)

类不在 LEGB 的四层查找链里；它单独拥有类命名空间，方法内部不会把类作用域当作 Enclosing，访问类属性需要 `self.attr` 或 `Class.attr`。
