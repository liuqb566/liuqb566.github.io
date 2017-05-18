---
layout: post
title: "Cuffdiff v2.1.1 的简单使用"
date: 2017-4-7
categories: bioinformatics
tag: 使用手册
---

* content
{:toc}


Cuffdiff 是 Cufflinks 组装套件里的一个程序，用于 RNA-seq 的表达差异分析。
Cuffdiff 对误差的矫正使用 β 负二项分布 = 泊松分布（技术误差）+ γ 分布（生物学重复误差）+ β 分布（多重比较分配误差）
Cuffdiff 2.0及之前与之后的版本差别较大，本次用的版本是 V 2.1.1

cufflinks 的输入文件是 sam/bam 格式，并且要求文件格式必须排好序。
cuffdiff 的输入文件要求:
如果有 header 信息，aligment 的染色体排序要与 header 中一致。（header 好像是按 位置信息进行排序的）；如果没有 SQ record 或没有 header 信息，需要按先按染色体排序，再按位置排序。

实例：
我用 hisat2 --dta-cufflinks 比对，用 cuffdiff 分析，遇到的排序错误。虽然产生的文件里有 header 信息，但是 header 信息与 aligment 的染色体排序不一致。我想到两种解决办法，
一个是对 sam 重新按位置排序
```
samtools sort -o sorted.bam input.sam # 不要 `-n` 参数，它是按 read name 排序
```
另一个方法是直接删除 header 信息，进行排序，它的好处是可以用 shell 的 sort 命令进行排序
```
sort -k 3,3 -k 4,4n input.sam > sorted.sam
或
sort -nk 4 input.sam > sorted.sam
```

```
cuffdiff [options]*
```

options:
-o：输出文件夹目录
-L：给每个样本或环境一个标签，用逗号隔开；默认：q1，q2，....
-T：按样品顺序比对，而不是两两比对；即 第二个和第一个比，第三个和第二个比
-b：后跟 genome.fa 文件
-u：使比对 multi-reads 使更精确

例如：
```
cuffdiff -p 8 -o diff.out -b genome.fa -u gene.gtf/gff -L lable1,lable2,lable3... sample1.sam sample2.sam sample3.sam...
# 样本组数应与标签数一致，不同组用空格分隔，同一组内重复样本用逗号分隔
```
cuffdiff v2 也可以分析无生物学重复的实验，参数是 `--dispersion-method blind`，不过即使不加，如果没有设置重复，软件自己也会检测。一个问题是，只有当差异基因比较少时可以使用，如果差异基因比较多就检测不到差异了，因为它会使用所有的样本的平均值做离散度分析

