---
layout: post
title: "WDL 使用中遇到的问题"
categories: snp-calling
tags: WDL
---

* content
{:toc}


### 1、本地化问题

cromwell 会将所有的需要的输入文件（包括需要的程序、序列）都本地化到 `cromwell-executions` 文件夹中。

#### 1、路径

建议所有的文件都用**绝对路径**，相对路径有时会出问题。

#### 2、本地化策略

默认使用顺序：

- hard-link
- soft-link
- copy：会很耗硬盘

也可以通过自定义 configure 文件或者在命令行中添加参数，由于 cromwell 的文件都已经打包好了，所以在命令行中添加参数比较简单：
```
java -Dbackend.shared-filesystem.localization.0=hard-link
```
或者

```
java -Dfilesystems.local.localization="newOrder" ...
```
（不知道有什么区别？？？）
[参考1](https://github.com/broadinstitute/cromwell#configuring-cromwell)
[参考2](https://github.com/broadinstitute/cromwell/issues/1070)
[参考3](https://gatkforums.broadinstitute.org/wdl/discussion/8115/avoid-copying-input-files)
[Cromwell](https://cromwell.readthedocs.io/en/develop/)
