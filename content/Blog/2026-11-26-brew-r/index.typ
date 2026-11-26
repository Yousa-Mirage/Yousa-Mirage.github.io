#import "../index.typ": template, tufted
#import "@preview/theorion:0.6.0": quote-block
#show: template.with(
  title: "Homebrew 装的 R 总是从源码编译 R 包",
  author: "天然純真",
  date: datetime(year: 2026, month: 11, day: 26),
  tags: ("R", "macOS", "ggtypst"),
)

= Homebrew 装的 R 总是从源码编译 R 包

前不久，看到一个说法是，年轻的时候没钱，等努力几年后，就不年轻了。深以为然，于是一怒之下购入了一台 MacBook Air。

虽是初次使用 macOS，但早就知道 Homebrew 是一个很好用的包管理器，于是很自然地使用 `brew install r` 安装了 R，装了一堆包，开始开发！

不过很快我就注意到一个问题：在从 #link("https://community.r-multiverse.org/packages")[R-multiverse] 安装 `arrow` 时，总是会触发本地编译。当时没有放在心上，耐心等 `arrow` 编译完了也就过去了。

直到今天，我发布了 #link("https://github.com/Yousa-Mirage/ggtypst")[ggtypst v0.2.0]。我照常将其上传到了 R-universe 和 R-multiverse 上，编译成功。运行

```r
install.packages("ggtypst", repos = "https://yousa-mirage.r-universe.dev")
```

然后发现只会下载源码包并开始本地编译。那这就非常奇怪了，因为我确信 R-universe 已经提供了给 macOS 的预编译好的二进制包。

于是展开了一圈排查（问了 AI），发现罪魁祸首竟然是*从 Homebrew 安装的 R*！

具体来说，R 安装包时用二进制还是源码，由 `getOption("pkgType")` 决定，默认值来自 `.Platform$pkgType`。这个值是在*编译 R 本身的时候*就写死的：

```r
.Platform$pkgType
#> CRAN 版 R：     "mac.binary.sonoma-arm64"
#> Homebrew 版 R： "source"
```

Homebrew 的 R 被标记为 `"source"`，所以 R 只会去 CRAN 或其他仓库下载源码包，二进制目录根本不在它的搜索范围里。

而 CRAN 或其他仓库的 macOS 二进制包是专门为 CRAN 官方构建的 R 编译的，依赖的 R 路径、系统库和编译器（尤其是 Fortran）都和 Homebrew 的 R 不一样。即使通过指定 `install.packages(type = "...")` 强行下载二进制包，含 C/C++/Fortran 代码的包也很可能加载失败。R-Core 的立场也很明确：选择用 Homebrew、MacPorts 这类包管理器编译 R，就意味着放弃 CRAN 二进制包。

除了通过 `brew install r` 安装的 R，自己从源码编译的 R、conda / conda-forge 的 `r-base`、Linux 上几乎所有 R 也都会有这个问题，同时 CRAN 自己也不提供 Linux 的二进制包#footnote[
  好在现在有了 #link("https://packagemanager.posit.co")[Posit Public Package Manager (P3M)]，它为 CRAN 上收录的所有包都提供了多平台的二进制构建，也包括各种 Linux 发行版。
]。

要解决这个问题也很简单，只需要换成 CRAN 官方构建的 R 即可：

```bash
brew uninstall r  # 卸载 Homebrew 版 R

# 方式一：Homebrew cask 中是 CRAN 官方版 R
brew install --cask r-app

# 方式二：使用 rig 安装 R（适合管理多个 R 版本和项目环境）
brew install r-rig
rig add release
```

换成官方版 R 之后，`install.packages()` 或 `pak::pak()` 会默认下载二进制包，几秒钟就能装好。

#line()

谢益辉大佬也曾经遇到并尝试解决这个问题，并乐观地认为 “Perhaps building only the top 30 trickiest and also frequently used R packages is enough for most R users on macOS.”。我认为谢益辉显然低估了这些编译工作所需的复杂度和时间。他当时尝试创建了一个自建的 CRAN 仓库 `macos.rbind.io`，但最终也放弃维护了。可见即使是大佬也没有什么好办法，最好的办法就是不要用 `brew install r`。见他写的博客 #link("https://yihui.org/en/2018/06/homebrew-binary-r-packages/")[_Build Binary R Packages for the Homebrew Version of R?_] 。
