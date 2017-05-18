---
layout: post
title: "R 语言查看可安装的包"
categories: bioinformatics
tag: R
---

* content
{:toc}


available.packages()可以查看自己的机器可以安装哪些包！


R语言里面的包其实是很简单的，因为它自带了一个安装函数install.packages()基本上可以解决大部分问题！

但是如果出问题也是蛮复杂的，因为要考虑的东西很多:

首先你的R语言安装在什么机器什么？（linux(ubuntu?centos?),window,mac）
其次你的R是什么版本:(3.1 ? 3.2 ?  http://www.bio-info-trainee.com/1307.html )
然后你的安装器是什么版本？（主要针对于bioconductor包的安装）
然后你的联网方式是什么？https ？http ？
最后你选择的R包镜像是什么？
我们首先要知道自己的R包安装到了什么地方?
```
  .libPaths()
 [1] "C:/Users/jmzeng/Documents/R/win-library/3.1"
 [2] "C:/Program Files/R/R-3.1.0/library"
```
 这样可以直接进入这些目录去看看有哪些包，每个包都会有一个文件夹！

 其次你可以用installed.packages()查看你已经安装了哪些包
```
  colnames(installed.packages())
[1] "Package"               "LibPath"               "Version"
[4] "Priority"              "Depends"               "Imports"
[7] "LinkingTo"             "Suggests"              "Enhances"
[10] "License"               "License_is_FOSS"       "License_restricts_use"
[13] "OS_type"               "MD5sum"                "NeedsCompilation"
[16] "Built"
```
     最后你可以用available.packages()可以查看自己的机器可以安装哪些包！
```
     ####

     ap <- available.packages()
     > dim(ap)

     [1] 7662   17
```
     可以得到你现在所要能够安装的包！！包共有哪些资源！！！
```
See also Names of R's available packages,
?available.packages.
Alternatively, the list of available packages can be seen in a browser for CRAN, CRAN (extras), Bioconductor, R-forge and RForge.
```
