---
layout: post
title: "Ubuntu16 安装 R 语言 lme4"
categories: bioinformatics
tag: R
---

问题：在Ubuntu上为R语言安装‘lme4’的时候，提示无法安装‘nloptr’依赖包。
解决办法：
1. 先安装`nlop`：`sudo apt-get install libnlopt-dev`
2. 再安装`nloptr`：install.pakages('nloptr')

参考:[http://stackoverflow.com/questions/29716857/installing-nloptr-on-linux](http://stackoverflow.com/questions/29716857/installing-nloptr-on-linux)
