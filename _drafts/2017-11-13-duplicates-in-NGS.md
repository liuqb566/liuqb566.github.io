---
layout: post
title: "关于NGS数据的duplication问题"
categories: 
tags:
---

* content
{:toc}


参考：[Libraries can contain technical duplication](https://sequencing.qcfail.com/articles/libraries-can-contain-technical-duplication/)、[How PCR duplicates arise in next-generation sequencing](http://www.cureffi.org/2012/12/11/how-pcr-duplicates-arise-in-next-generation-sequencing/)、[用泊松分布解释 NGS 测序数据的 duplication 问题](http://www.jianshu.com/p/1e6189f641db)、[试论NGS数据的Duplication问题](http://www.biotrainee.com/thread-1382-1-1.html)

测序数据分析的假设条件是每条测序的序列（sequence）来自于原始样本的不同生物学片段（biological fragment，即生物体内合成的，而非PCR或者其他技术导致的错误的、多余的片段）。在此基础上进统计分析得到换P值才是可信的。

### 1. 什么是duplicate 数据

duplicat 指一个序列的多个拷贝，测序得到的reads的起始和终止位置一样，只要起点、终点或者起点与终点之间的序列，三者中有一个不同，就不算duplicate。又分为生物学重复（Biological duplication）和技术重复（Technical duplication）。

1. Biological duplication：是生物核酸序列内正常存在的，染色体上的多拷贝基因、转录组中转录本表达水平的不同等，这些重复序列是我们需要的，不需要剔除。
2. Technical duplication：由于人为因素（包括人工和机器处理样本的过程）造成的、非生物自行合成的序列重复。

### 2. duplicate 来源

1、cluster generation过程

1）来源一个biological fragment 的多个PCR拷贝都被flowcell 捕获，导致生成多个相同的cluster，这是Technical duplication的主要原因。由于为了防止DNA降解或者细胞量不足造成的DNA深度过低，也为了使flowcell能尽量捕获全部的fragment，PCR过程又是可避免的。

2）cluster 扩增过程中，一个cluster中的片段扩增到另一个cluster点上，产生两个相邻的相同 cluster。

3）一个fragment的两条互补链形成独立的cluster，某些流程会将之视为duplicates。

2、光信号捕获过程

如果一个cluster的荧光亮点形状奇特，也有可能被作为两个cluster处理。这种情况的flag会记录在fastq文件中。

### 3. duplicate 的影响

1. biological duplicate 是生物体内自然产生的，代表了生物染色体的复杂性，也是我们实验需要的。

2. technial duplicate 是人为产生的，一个是会扩大或缩小真实变异的频率，从而造成假阳性或假阴性结果（即，PCR bias);另一方面，它也会扩大超声波挂断造成的碱基颠换及PCR过程中错配碱基的频率。

### 4. duplicate 处理

鉴别与剔除Technical duplication 的难点是，如果两个reads比对到相同的位置，你不能简单的把它们当作Technical duplication，因为还有可能是Biological duplication，尤其在RNA-seq和多倍物种中。

。。。。

（具体处理方法有空再研究）


由于需要PCR扩增以增加片段与接头的连接数量，所以PCR duplicates 是不可避免的。而起始材料较少或者超声波破碎过程中产生了较小的fragment等，都会过多的PCR duplicates。所以提高建库质量，降低PCR循环数，是减少duplicate的关键。


### 5. 相关软件

最常用的是：
- samtools: rmdup
- picard: MarkDuplicates

有评论说，picard 的MarkDuplicates相比效果更好，特别对于双端测序数据，因为它更严格？
