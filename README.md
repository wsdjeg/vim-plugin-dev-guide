# Vim 插件开发指南

> - 作者： wsdjeg
> - LICENSE： [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0).

<!-- vim-markdown-toc GFM -->

- [简介](#简介)
- [基本语法](#基本语法)
  - [注释](#注释)
  - [变量](#变量)
  - [作用域](#作用域)
- [Vim 插件的项目结构](#vim-插件的项目结构)
- [Vim 自定义命令](#vim-自定义命令)
- [推荐阅读](#推荐阅读)

<!-- vim-markdown-toc -->

## 简介

Vim 插件开发中文指南，主要包括 Vim 脚本语法、插件开发技巧等。

## 基本语法

### 注释

在写脚本时，经常需要在源码里面添加一些注释信息，辅助阅读源码，Vim 脚本注释比较简单，是以 `"` 开头的，只存在行注释，不存在块注释。因此，对于多行注释，需要再每行开头添加 `"`。

示例：

```vim
" 这是一行注释，
let g:helloworld = 1  " 这是在行尾注释
```

### 变量

在 Vim 脚本里，可以使用关键字 `let` 来申明变量，最基本的方式为：

```vim
" 定义一个类型是字符串的变量 g:helloworld
let g:helloworl = "sss"
```

前面的例子中，是定义一个字符串，Vim 脚本中支持以下几种数据类型：

| 类型       | ID  | 描述     |
| ---------- | --- | -------- |
| Number     | 0   | 整数     |
| String     | 1   | 字符串   |
| Funcref    | 2   | 函数指针 |
| List       | 3   | 列表     |
| Dictionary | 4   | 字典     |
| Float      | 5   | 浮点数   |
| Boolean    | 6   |
| None       | 7   |
| Job        | 8   |
| Channel    | 9   |

### 作用域

Vim 变量存在三种作用域，全局变量、局部变量、和脚本变量。通常，我们以不同的前缀来区别作用域，比如使用 `g:` 表示全局变量，`s:` 表示脚本变量。
在一些特殊情况下，前缀是可以省略的，Vim 会为该变量选择默认的作用域。不同的情况下，默认的作用域是不一样的，在函数内部，默认作用域是局部变量，
而在函数外部，默认作用域是全局变量：

```vim
let g:helloworld = 1  " 这是一个全局变量， g: 前缀未省略
let helloworld = 1    " 这也是一个全局变量，在函数外部，默认的作用域是全局的

function! HelloWorld()
  let g:helloworld = 1    " 这是函数内部全局变量
  let helloworld = 1      " 这是一个函数内部的局部变量，在函数内部，默认的作用域为局部变量
endfunction
```

| 前缀 | 描述                                 |
| ---- | ------------------------------------ |
| `g:` | 全局变量                             |
| `l:` | 局部变量，只可在函数内部使用         |
| `s:` | 脚本变量，只可以在当前脚本函数内使用 |
| `v:` | Vim 特殊变量                         |
| `b:` | 作用域限定在某一个缓冲区内           |
| `w:` | 作用域限定在窗口内部                 |
| `t:` | 作用域限定在标签内部                 |

此外，在开发 Vim 插件之前，你还需要了解 vimrc 和 Vim 插件的区别。

## Vim 插件的项目结构

在开发 Vim 插件之前，需要了解一下，一个 Vim 插件项目的目录结构是怎样的，以及每一个目录里文件的意义是什么。 Vim 插件标准的目录结构为：

```text
autoload/               自动载入脚本
colors/                 颜色主题
plugin/                 在 Vim 启动时将被载入的脚本
ftdetect/               文件类型识别脚本
syntax/                 语法高亮文件
ftplugin/               文件类型相关插件
compiler/	              编译器
indent/                 语法对齐
```

下面，我们来逐一说明下每一个目录的用途：

**autoload/**

顾名思义，该文件夹下的脚本会在特点条件下自动被载入。这里的特定条件指的是当某一个 autoload 类型的函数被调用，并且 Vim 当前环境下并未定义该函数时。
比如调用 `call helloworld#init()` 时，Vim 会先检测当前环境下是否定义了该函数，若没有，则在 `autoload/` 目录下找 `helloworld.vim` 这一文件，
并将其载入，载入完成后执行 `call helloworld#init()`.

**plugin/**

该目录里的文件将在 Vim 启动事被运行，作为一个优秀的 Vim 插件，应当尽量该目录下的脚本内容。通常，可以将插件的快捷键、命令的定义保留在这个文件里。

**ftdetect/**

ftdetect 目录里通常存放的是文件类型检测脚本，该目录下的文件也是在 Vim 启动时被载入的。在这一目录里的文件内容，通常比较简单，比如：

```vim
autocmd BufNewFile,BufRead *.helloworld set filetype=helloworld
```

以上脚本使得 Vim 在打开以 `.helloworld` 为后缀的文件时，将文件类型设置为 `helloworld`。通常，这个脚本的文件名是和所需要设置的文件类型一样的，上面的例子中文件的名称就是 `helloworld.vim`。

**syntax/**

这一目录下的文件，主要是定义语法高亮的。通常文件名前缀和对应的语言类型相同，比如 Java 的语法文件文件名为 `java.vim`。 关于如何写语法文件，将在后面详细介绍。

**colors/**

colors 目录下主要存储一些颜色主题脚本，当执行 `:colorscheme + 主题名` 命令时，对应的颜色主题脚本将被载入。比如执行 `:colorscheme helloworld` 时，`colors/helloworld.vim` 这一脚本将被载入。

**compiler/**

这一名录里是一些预设的编译器参数，主要给 `:make` 命令使用的。在最新版的 Vim 中可以使用 `:compiler! 编译器名` 来为当前缓冲区设定编译器。比如当执行
`:compiler! helloworld` 时，`compiler/helloworld.vim` 这一脚本将被载入。

**indent/**

在 indent 目录里，主要是一些语法对齐相关的脚本。

## Vim 自定义命令

Vim 的自定义命令可以通过 `command` 命令来定义，比如：

```vim
command! -nargs=* -complete=custom,helloworld#complete HelloWorld call helloworld#test()
```

紧接 `command` 命令气候的 `!` 表示强制定义该命令，即使前面已经定义过了同样名称的命令，也将其覆盖掉。 `-nargs=*` 表示，该命令可接受任意个数的参数，
包括 0 个。`-nargs` 的取值有以下几种情况：

| 参数       | 定义                     |
| ---------- | ------------------------ |
| `-nargs=0` | 不接受任何参数（默认）   |
| `-nagrs=1` | 只接受一个参数           |
| `-nargs=*` | 可接收任意个数参数       |
| `-nargs=?` | 可接受 1 个或者 0 个参数 |
| `-nargs=+` | 至少提供一个参数         |

`-complete=custom,helloworld#complete` 表示，改命令的补全方式采用的是自定义函数 `helloworld#complete`。`-complete` 可以接受的参数包括如下内容：

| 参数                          | 描述                                          |
| ----------------------------- | --------------------------------------------- |
| `-complete=augroup`           | autocmd 组名                                  |
| `-complete=buffer`            | buffer 名称                                   |
| `-complete=behave`            | `:behave` 命令子选项                          |
| `-complete=color`             | 颜色主题                                      |
| `-complete=command`           | Ex 命令及参数                                 |
| `-complete=compiler`          | 编译器                                        |
| `-complete=cscope`            | `:cscope` 命令子选项                          |
| `-complete=dir`               | 文件夹名称                                    |
| `-complete=environment`       | 环境变量名称                                  |
| `-complete=event`             | 自动命令的事件名称                            |
| `-complete=expression`        | Vim 表达式                                    |
| `-complete=file`              | 文件及文件夹名称                              |
| `-complete=file_in_path`      | `path` 选项里的文件及文件夹名称               |
| `-complete=filetype`          | 文件类型                                      |
| `-complete=function`          | 函数名称                                      |
| `-complete=help`              | 帮助命令子选项                                |
| `-complete=highlight`         | 高亮组名称                                    |
| `-complete=history`           | `:history` 子选项                             |
| `-complete=locale`            | locale 名称（相当于命令 `locale -a` 的输出）  |
| `-complete=mapping`           | 快捷键名称                                    |
| `-complete=menu`              | 目录                                          |
| `-complete=messages`          | `:messages` 命令子选项                        |
| `-complete=option`            | Vim 选项名称                                  |
| `-complete=packadd`           | 可选的插件名称补全                            |
| `-complete=shellcmd`          | shell 命令补全                                |
| `-complete=sign`              | `:sign` 命令补全                              |
| `-complete=syntax`            | 语法文件名称补全                              |
| `-complete=syntime`           | `:syntime` 命令补全                           |
| `-complete=tag`               | tags                                          |
| `-complete=tag_listfiles`     | tags, file names are shown when CTRL-D is hit |
| `-complete=user`              | user names                                    |
| `-complete=var`               | user variables                                |
| `-complete=custom,{func}`     | custom completion, defined via {func}         |
| `-complete=customlist,{func}` | custom completion, defined via {func}         |

这里主要解释一些自定义的补全函数，从上面的表格可以看出，有两种定义自定义命令补全函数的方式。
`-complete=custom,{func}` 和 `-complete=customlist,{func}`。这两种区别再与函数的返回值，
前者要求是一个 `string` 而后者要求补全函数的返回值是 `list`.
自定义命令补全函数接受三个参数。

```vim
:function {func}(ArgLead, CmdLine, CursorPos)
```

我们已实际的例子来解释这三个参数的含义，比如在命令行是如下内容时，`|` 表示光标位置，我按下了 `<Tab>` 键调用了补全函数，那么传递给补全函数的三个参数分别是：

```vim
:HelloWorld hello|
```

| 参数名      | 描述                                                               |
| ----------- | ------------------------------------------------------------------ |
| `ArgLead`   | 当前需要补全的部分，通常是光标前的字符串，上面的例子中是指 `hello` |
| `CmdLine`   | 指的是整个命令行内的内容，此时是 `HelloWorld hello`                |
| `CursorPos` | 值得当前光标所在的位置，此时是 16, 即为 `len('HelloWorld hello')`  |

下面，我们来看下定义的函数具体内容：

```vim
function! helloworld#complete(ArgLead, CmdLine, CursorPos) abort
    return join(['hellolily', 'hellojeky', 'hellofoo', 'world']
            \ "\n")
endfunction
```

在上面的函数里，返回的实际上是一个有四行的字符串，Vim 会自动根据 `ArgLead` 来筛选出可以用来补全的选项，并展示在状态栏上。
此时，四行里最后一个 `world` 因为开头不匹配 `ArgLead` 所以不会被展示在状态栏上，因此补全效果只有三个可选项。

![command-complete](https://user-images.githubusercontent.com/13142418/44915590-f2b43a80-ad65-11e8-92aa-0f4eac3a0a26.gif)

`-complete=customlist,{func}` 这一参数所对应的补全函数，也是接受相同的三个参数，但该函数返回的是一个 list。

下面，我们来测试这个函数：

```vim
function! helloworld#complete(ArgLead, CmdLine, CursorPos) abort
    return ['hellolily', 'hellojeky', 'hellofoo', 'world']
endfunction
```

![command-complete](https://user-images.githubusercontent.com/13142418/44916266-e03b0080-ad67-11e8-9cb8-535a970768e4.gif)

区别很明显，`customlist` 补全时不会自动根据 `ArgLead` 进行筛选，并且直接补全整个返回的 list，即使列表中有一个 `world` 完全与 `ArgLead(hello)` 不同，
也会将其直接覆盖。因此，当使用 `customlist` 时，需要在函数内根据 `ArgLead` 进行筛选，将函数该为如下，就可以得到相同效果了：

```vim
function! helloworld#complete(ArgLead, CmdLine, CursorPos) abort
    return filter(['hellolily', 'hellojeky', 'hellofoo', 'world'], 'v:val =~ "^" . a:ArgLead')
endfunction
```

## 推荐阅读

- [Vim 中文简明使用教程](https://github.com/wsdjeg/vim-galore-zh_cn)
- [Vim 脚本语法指北](https://github.com/lymslive/vimllearn)
