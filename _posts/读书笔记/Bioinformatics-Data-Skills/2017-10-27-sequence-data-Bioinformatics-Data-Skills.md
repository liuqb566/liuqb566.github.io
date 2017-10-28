---
layout: post
title: "Bioinformatics Data Skills Chapter 10"
categories: 笔记
tag: bioinformatics
---

* content
{:toc}


### The FASTA Format

1. 格式  

~~~~
>ENSMUSG00000020122|ENSMUST00000138518              #第一行，ID信息等，以“>”开头
CCCTCCTATCATGCTGTCAGTGTATCTCTAAATAGCACTCTCAACCCCCGTGAACTTGGTTATTAAAAACATGCCCAAAGTCTGGGAGCCAGGGCTGCAGGGAAATACCACAGCCTCAGTTCATCAAAACAGTTCATTGCCCAAAATGTTCTCAGCTGCAGCTTTCATGAGGTAACTCCAGGGCCCACCTGTTCTCTGGT    #第二行，序列
>ENSMUSG00000020122|ENSMUST00000125984
GAGTCAGGTTGAAGCTGCCCTGAACACTACAGAGAAGAGAGGCCTTGGTGTCCTGTTGTCTCCAGAACCCCAATATGTCTTGTGAAGGGCACACAACCCCTCAAAGGGGTGTCACTTCTTCTGATCACTTTTGTTACTGTTTACTAACTGATCCTATGAATCACTGTGTCTTCTCAGAGGCCGTGAACCACGTCTGCAAT
~~~~

2. 缺点

没有非常标准的ID格式，在用正则提取的时候容易出现问题。

### The FASTQ Format

FASTQ 格式是在 FASTA 格式上的扩展，增加了每个碱基的质量得分。  

1. 格式  

~~~~
@DJB775P1:248:D0MDGACXX:7:1202:12362:49613              #以“@”开头，信息行
TGCTTACTCTGCGTTGATACCACTGCTTAGATCGGAAGAGCACACGTCTGAA    #序列
+                                                       #“+”表示序列结束
JJJJJIIJJJJJJHIHHHGHFFFFFFCEEEEEDBD?DDDDDDBDDDABDDCA    #每个碱基得分
@DJB775P1:248:D0MDGACXX:7:1202:12782:49716
CTCTGCGTTGATACCACTGCTTACTCTGCGTTGATACCACTGCTTAGATCGG
+
IIIIIIIIIIIIIIIHHHHHHFFFFFFEECCCCBCECCCCCCCCCCCCCCCC
~~~~

2. 缺点  

`@`既是信息行的开头，又可以是碱基等分的质量字母，在提取的时候容易出错

### Nucleotide Codes

### Base Qualities

由于每个碱基的质量得分由 ASCⅡ 值表示, 早期不同的平台用的编码范围不同，现在都趋于用 Sanger 方法。

FASTQ quality schemes (adapted from Cock et al., 2010 with permission)  
|--------------------------------------+----------------------+-------+-------------------+-------------------|
|Name                                  |ASCII character range |Offset |Quality score type |Quality score range|
|:-------------------------------------+:--------------------:+:-----:+:-----------------:+:-----------------:|
|Sanger, Illumina (versions 1.8 onward)|33–126                |33     |PHRED              |0–93               |
|Solexa, early Illumina (before 1.3)   |59–126                |64     |Solexa             |5–62               |
|Illumina (versions 1.3–1.7)           |64–126                |64     |PHRED              |0–62               |
|--------------------------------------+----------------------+-------+-------------------+-------------------|

#### 换算  
1. Sanger quality score -> PHRED quality scores  
**PHRED = Sanger quality score - 33**  

2. PHRED quality score ->  P value the base is correct  
$$P = 10^{ - Q/10 }$$

3. P value -> qualities(Q)  
$$Q = -10{\log}_{10}P$$

---------------
> run a program, compare output to original data, run a program, compare output, and so on.
