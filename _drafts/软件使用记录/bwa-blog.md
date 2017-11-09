---
layout: post
title: 流程搭建之 bwa 安装使用记录
categories: blog
tags: [bwa, bioinformatics]
---

* content
{:toc}


#### 安装 bwa

系统：Ubuntu
bwa 版本：bwa-0.7.15

命令
```
wget https://sourceforge.net/projects/bio-bwa/files/bwa-0.7.15.tar.bz2/downloa://sourceforge.net/projects/bio-bwa/files/bwa-0.7.15.tar.bz2 

bzip2 -d bwa-0.7.15.tar.bz2
tar xvf bwa-0.7.15.tar
cd bwa-0.7.15
make
```
------
2017.10.27

#### bwa 使用引言

bwa 有三个比对算法：BWA-bachtrack，BWA-SW和BWA-MEM。这三种算法适用的reads长度不同。

- BWA-bachtrack：适用于70-100bp
- BWA-SW: 适用于70bp-1Mb，当gaps比较多的时候BWA-SW更敏感一些。
- BWA-MEM: 最新开发的算法，更快速准确，适用于70-1Mb，而且在70-100bp的比对上比BWA-backtrack好。

#### 使用脚本命令
```
#! /bin/bash

for i in  `ls ~/SLAF-seq/data/raw-data/`
do
sra=$(echo $i|cut -c 1-10)
echo $sra
#Decompresison of sra one by one
fastq-dump --split-3 -O fastq-data/ ~/SLAF-seq/data/raw-data/$i || exit 0
ls fastq-data
bwa-0.7.15 mem -t 40 NAU_v1.1_replace_chr ./fastq-data/${sra}_1.fastq ./fastq-data/${sra}_2.fastq >${sra}.sam && ls -lh ${sra}.sam || exit 0
samtools view -Sb -o ${sra}.bam ${sra}.sam ||exit 0
rm ${sra}.sam
rm ./fastq-data/*
done
```
bwa 可以使用多线程，但是不知道可不可以批量比对？单个样本比对太慢了，1 G的双端测序比对到2.5G的基因组上要30~40分钟。

磁盘读取速读太慢也是问题。

-----
2017.11.2

#### 改进速度

1. 单个比对太慢，即使多线程也很慢，由于一些原因，必须加快比对速度。
2. 前提条件，内存足够，cpu性能足够，但是利用率过低，推测可能是 I/O 瓶颈。
3. 硬盘不足，无法一次性解压。

笨办法：

将sra文件分到多个文件夹中，对多个文件夹运行脚本。

结果：

速度提升，cpu利用率提高。

疑问：

难道开多线程和多个进程同时进行不一样么？对磁盘读取方式不同？

-----
2017.11.4
