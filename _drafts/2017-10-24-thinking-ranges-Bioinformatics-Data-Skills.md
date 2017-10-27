---
layout: post
title:  "学习ranges思想"
categories: 笔记
tags:bioinformatics
---

* content
{:toc}


---
第9章提到要建立range思想，在此简单记录。

**range: 某个染色体序列上有start position和end position的一段特定单链，一个基因是一个range，一个read也是一个range。**

###寻找overlapping ranges

1> 理解不同类型的overlaps，思考对一个特定的任务，哪种类型最合适，是最重要的。
overlaps的类型有：
- any
- within
- start
- end
- equal  
其中 any 和 within 最常用

2> 为了减少比对次数，提高效率，首先要先对subjet sequence排序,称为interval tree。

###寻找最近的ranges，并计算距离
###Run Length Encoding and Views  
为了节约内存，对覆盖度进行编码，不好理解，看原文。

