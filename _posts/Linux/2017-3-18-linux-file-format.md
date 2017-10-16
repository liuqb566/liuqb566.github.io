---
layout: post
title: linux下的格式问题
categories: Linux
tags: format
---

由于 unix 和 windos 使用的换行符不同，所以从 windos 上拷贝文件到 unix 系统时可能会出现问题，例如用 `cat` 命令循环文件的每行时，由于换行符的原因，会使变量拼接出现问题，而这通常用`echo $i`发现不了。

有几个办法可以对来自 windos 的文件进行格式处理：
1. fileformats 命令

通过有两种文件格式 dos 和 unix
```
vim test.txt 
:set fileformat?  #查看文件格式
:set fileformat=unix #转换文件格式为 unix 格式
:set fileformats=unix,dos #将 dos 作为第二选择
```

2. 使用正则表达式删除换行符
```
：%s/\n//g
```
