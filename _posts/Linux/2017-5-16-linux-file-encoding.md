---
layout: post
title: linux下编码问题
categories: Linux
tags: format
---


* content
{:toc}


## [转](http://www.itnose.net/detail/6524108.html)

在 Linux 中操作 windows 下的文件，可能会经常遇到文件编码转换的问题。Windows中默认的文件格式是GBK(gb2312)，而Linux一般都是UTF-8。下面介绍一下，在Linux中如何查看文件的编码及如何进行对文件进行编码转换。

### 查看文件编码
在Linux中查看文件编码可以通过以下几种方式：
#### 在Vim中可以直接查看文件编码
`:set fileencoding`
即可显示文件编码格式。
如果你只是想查看其它编码格式的文件或者想解决用Vim查看文件乱码的问题，那么你可以在
~/.vimrc 文件中添加以下内容：
`set encoding=utf-8 fileencodings=ucs-bom,utf-8,cp936`
这样，就可以让vim自动识别文件编码（可以自动识别UTF-8或者GBK编码的文件），其实就是依照fileencodings提供的编码列表尝试，如果没有找到合适的编码，就用latin-1(ASCII)编码打开。

#### 文件编码转换
1. 在Vim中直接进行转换文件编码,比如将一个文件转换成utf-8格式
`:set fileencoding=utf-8`

2. iconv 转换，iconv的命令格式如下：
`iconv -f encoding -t encoding inputfile`
比如将一个UTF-8 编码的文件转换成GBK编码
```
iconv -f GBK -t UTF-8 file1 -o file2
iconv -f gbk -t utf8 linux常用命令.txt > linux常用命令.txt.utf8
```

### 文件名编码转换:

从Linux 往 windows拷贝文件或者从windows往Linux拷贝文件，有时会出现中文文件名乱码的情况，出现这种问题的原因是因为，windows的文件名 中文编码默认为GBK,而Linux中默认文件名编码为UTF8,由于编码不一致，所以导致了文件名乱码的问题，解决这个问题需要对文件名进行转码。
在Linux中专门提供了一种工具convmv进行文件名编码的转换，可以将文件名从GBK转换成UTF-8编码,或者从UTF-8转换到GBK。 

首先看一下你的系统上是否安装了convmv,如果没安装的话用:
`yum -y install convmv`
安装。

下面看一下convmv的具体用法：

`convmv -f 源编码 -t 新编码 [选项] 文件名`

常用参数：
-r 递归处理子文件夹
--notest 真正进行操作，请注意在默认情况下是不对文件进行真实操作的，而只是试验。
--list 显示所有支持的编码
--unescap 可以做一下转义，比如把%20变成空格
比如我们有一个utf8编码的文件名，转换成GBK编码，命令如下：
```
convmv -f UTF-8 -t GBK --notest utf8编码的文件名
```
这样转换以后"utf8编码的文件名"会被转换成GBK编码（只是文件名编码的转换，文件内容不会发生变化）   

  为什么在linux下查看.txt格式的文件会出现乱码呢？因为linux操作系统和windows操作系统对于中文的压缩方式不同。在windows 中，中文压缩一般是.gbbk，而在linux环境中压缩为utf8，这就导致了在windows下能正常显示的.txt文件在linux中打开后呈现乱 码状态。对于这种情况的处理方法为在包含要打开的.txt文件的目录下，在终端输入：
```
iconv -f gbk -t utf8 filename.txt -> filename.txt.utf8
```
用ls命令查看，生成了.utf8格式的文件，此时打开该文件就不再有乱码了.

