---
layout: post
title: ‘R软件中安装package的方法’
date: 2017-2-10
categories: R
tag: R
---

* content
{:toc}


### 一、安装package的同种方法

1. R自带的安装工具，网络安装

```
install.packages('包名字‘，lib='指定安装网址，可以默认'）
```

2. R自带的安装工具，本地安装,**需自己下载好信赖包**

- 在R程序内执行本地安装

```
install.packages('包的本地绝对路径')
```

- 在shell中安装

```
R CMD INSTALL 包的绝对路径
```

3.Bioconductor安装

```
source("http://bioconductor.org/biocLite.R")
biocLite("包的名字“）
```

4. 安装github上的包

- 通过debtools包安装

```
install.packages("devtools")
library(devtools)
install_github("开发者/包的名字”）
```

-通过githubinstall包安装

```
install.packages("githubinstall")
library(githubinstall)
githubinstall("包的名字“）
```
`githubinstall()`会从Github仓库中搜索相应的R包，并询问你是否安装。而且，它支持模糊搜索，会自动纠正包的名字。

githubinstall包提供了若干有用的函数，都是以gh开头，可以自行查看。

ps:
- 卸载包：`remove.packages("包的名字”）`; 
- 更新包:`update.packages()`;
- 查看已安装的包：`installed.packages()`

### 二、查看自己的电脑可以安装哪些包

`available.packages()`可以查看

```
ap <- available.packages()
dim(ap) #计数
grep('包名字’，rownames(ap)) #查看想安装的包是否存在于正在使用的R仓库里
“包名字” %in% rownames(ap)
available.packages(contriburl="仓库地址“）#查看其它仓库的包
```

### 三、关于安装路径

1. 查看安装路径 `.libPaths()`
2. 更改默认安装路径
```
.libPaths('/yourlibrary')
.libPaths(c('/yourlibrary1','/yourlibrary2')
```
3. 安装包的时候指定路径

`install.packages('包',lib='路径')

4. 安装包的时候指定路径

`install.packages('包',lib='路径')

5. 加载包的时候指定路径

`library('包',lib.loc='路径')
