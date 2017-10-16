---
layout: post
title: linux下的中文输入问题
categories: Linux
tags: input
---

### 解决由于环境变量引起的软件不能使用中文输入法fcitx的问题

linux 中的环境变量一直是一个让人头庝的问题，很多安装程序出现问题要不是权限，要不就是环境变量不对了。

一些软件，例如wps、rstudio、foxitreader等有时会无法使用 fcitx 输入法，也就无法输入中文，原因是环境变量没有设定。

#### 解决办法

在启动脚本中写入
```
export XMODIFIERS="@im=fcitx"
export QT_IM_MODULE="fcitx"
```
重启就可以了。

需要注意的是，有些软件的启动脚本在`/usr/bin/`目录下，例如wps在`/usr/bin/wps 或 wpp 或 et`；而Foxitreader的在安装目录下，即`Foxitreader/Foxitreader.sh`
