---
layout: post
title: "SAM 格式简介及 samtools 工具的常用命令"
date: 2017-4-8
categories: bioinformatics
tag: 使用手册；数据格式
---

* content
{:toc}


最近在做 RNA-seq 的时候，发现很多差异分析软件需要对 sam 文件进行排序，所以决定再研究一个 sam 格式。

#### SAM 格式定义

SAM  是序列比对的格式标准，是 sanger 制定的，它以制表符 `\t` 为分割符。
完整的 sam 文件分为两个主要部分，注释信息（header section）和比对结果部分（alignment），比对结果是必须的，而注释信息是可忽略的。
注释信息以 `@` 开头，用不同的标签（tag）表示不同的信息，例如： 
- @HD：符合标准的版本、对比序列的排列顺序
- @SQ：参考序列说明
- @RG：比对上的 reads 说明
- @PG：使用说明
- @Co：任意的说明信息

比对结果，每行表示一个 segment 的比对信息，共被 `\t` 分为 11 个字段和一个可靠字段，其顺序是固定的
1. QNAME：比对片段或者基因的编号
2. FLAG：平台比对情况的数字表示
3. RNAM：参考序列的名字，即，染色体号，无法比对用 `*` 表示
4. position：read 比对到参考序列上，第一个碱基的位置，无法比对，则为 0
5. 比对质量分数
6. 匹配上的碱基数
...

#### samtools 工具的常用命令

samtools 的新旧版本用法有些不同，此处用的 V1.4。

一、view

view 命令主要用于将 sam 格式转换成 bam 格式，只有转换成 bam 后才能对文件进行操作，例如排序、提取。

```
samtools view [options] bam/sam
```
options：
-o：输出文件的名字
-b：输出 BAM 格式；默认输出 SAM 格式
-h：设定输出 sam 文件时带 header 信息；默认输出 sam 不带 header 信息
-H：仅输出头文件信息
-S：输入文件是 sam 文件；默认输入文件是 bam 文件，新版本自动检测，可忽略该参数
-u：耗费磁盘空间，节约时间；需要 -b 参数

例如：
```
samtools view -bS abc.sam > abc.bam #将 sam 转换成 bam
samtools view -T genome.fasta -h input.sam > input.h.sam 根据 fasta 文件，将 header 加入到 sam 或 bam 文件
samtools view -H input.bam > header.sam # 仅输出 header 文件
```

二、sort

sort 命令是对 bam 文件进行排序

```
samtools sort [options] input.bam 
```
options:
-@：线程数
-m：每个线程的最大内存
-n：根据 read 的名字（QNAME）排序，而不是染色体坐标排序；默认通过最左边的坐标排序。
-o：排序后的输出文件名；默认 samtools 基于 -o 文件的扩展名深度选择一个格式（如 .bam)；如果格式无法推测，则需要指定 -O
-O：指定输出格式 sam/bam/cram；

例如：
```
samtools sort -@ 8 -o output.sorted.bam input.sam #输入 sam 文件，输出排好序的 bam 文件。
```
注意：旧版本无法排序的同时转换格式，所以需要先用 view 转换格式，再用 sort 排序

samtools 的命令还有很多，等用到的时候继续补充
