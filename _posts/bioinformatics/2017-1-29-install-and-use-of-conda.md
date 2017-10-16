---
layout: post
title: "安装 conda"
categories: bioinformatics
tags: (python, conda)
---

第一次安装使用conda，真心累，不多说，标记下踩的坑吧。
1. 安装
- 如果安装过python的衍生版本anaconda，那么你就已经安装过conda了。
- 若没有就去官网下个安装包
2. 使用
```
- conda -h 这是首先要会用的
- conda creat -h
- conda info [-e][-h]
- conda creat -n envname packagename  可以指定版本
- soure activate envname  #切换工作环境
- soure deactivate envname #
```
canda的特点是把所有的东西都看作package，甚至它自己，所以你可以用`conda update conda`来更新conda；坑爹的是，好像无法管理非canda或pip安装的包

