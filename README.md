# Vim 插件开发指南

## 简介

Vim 插件开发者无疑是从 Vim 的用户转换而来，而在开发 Vim 插件之前，你需要掌握 Vim 的基本使用技巧，可以先阅读 [《Vim 从入门到精通》](https://github.com/wsdjeg/vim-galore-zh_cn)，该文章主要介绍了 Vim 的基本使用技巧。

开发 Vim 插件，离不开 Vim 脚本语言，需要对 Vim 脚本语言有一个大致的了解。[《Vim 脚本语法指南》](https://github.com/lymslive/vimllearn)讲解了 Vim 脚本的一些语法技巧。

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



