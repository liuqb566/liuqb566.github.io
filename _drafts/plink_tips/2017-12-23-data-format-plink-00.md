---
layout: post
title: "Plink 小技巧之格式转换"
categories: NGS
tags: Plink
---

* content
{:toc}


## PED 格式

vcftools 可以将 vcf 格式转换成 PED 格式，但是会丢失数据，也可以转换为 .tped 格式。

PED 格式包含两个文件：.ped 和 .map 文件

### .ped 文件

格式：
> The PED file is a white-space (space or tab) delimited file: the first six columns are mandatory:
> Family ID
> Individual ID
> Paternal ID
> Maternal ID
> Sex (1=male; 2=female; other=unknown)
> Phenotype 

默认：
> -9 missing 
> 0 missing
> 1 unaffected
> 2 affected

### .map 文件

格式：
> By default, each line of the MAP file describes a single marker and must contain exactly 4 columns:
> chromosome (1-22, X, Y or 0 if unplaced)  #染色体需要用数字表示
> rs# or snp identifier
> Genetic distance (morgans)
> Base-pair position (bp units)

**注意**: 标记数量和顺序要与 .ped 文件一致。

## Transposed filesets

PED 的转置格式
````
PED/FAM files
<---- normal.ped ---->                  <--- normal.map --->
1 1 0 0 1  1  A A  G T                  1  snp1   0  5000650
2 1 0 0 1  1  A C  T G                  1  snp2   0  5000830
3 1 0 0 1  1  C C  G G
4 1 0 0 1  2  A C  T T
5 1 0 0 1  2  C C  G T
6 1 0 0 1  2  C C  T T

would be represented as TPED/TFAM files:
<------------- trans.tped ------------->      <- trans.tfam ->
1 snp1 0 5000650 A A A C C C A C C C C C      1  1  0  0  1  1
1 snp2 0 5000830 G T G T G G T T G T T T      2  1  0  0  1  1
                                              3  1  0  0  1  1
                                              4  1  0  0  1  2
                                              5  1  0  0  1  2
                                              6  1  0  0  1  2
```
用途：
1. 如果 SNPs 数量远大于 individuals 数量（GNS基本如此），导致文件太宽（文本处理时，对行的处理比对列处理简单），可以进行转换。
2. 在此基础上可以容易的变为 hapmap 格式（hapmap 格式 也每个基因型一列，每个 individual 一行）

转换命令：
- vcf -> tped
```
vcftools --gzvcf file.vcf.gz --plink-tped --out file
```

- ped -> tped
```
plink --nowed --file input.prefix --transpose --recode --tab -out output.prefix
```
此过程默认不会对 SNP 进行过滤；`--tab` 可以让使 genotype 以 \t 分隔，alleles 以空格分隔。

## Long-format filesets

格式：
> three text files:
> a LGEN file containing genotypes (5 columns, one row per genotype)
> a MAP file containing SNPs (4 columns, one row per SNP)
> a FAM file containing individuals (6 columns, one row per person)

## Binary PED files

PED 的二进制格式，比较省内存

格式：
> plink.bed      ( binary file, genotype information )
> plink.fam      ( first six columns of mydata.ped ) 第6行以后为表型，可以改动
> plink.bim      ( extended MAP file: two extra cols = allele names)

命令：
```
plink --file input.prefix --make-bed -out output.prefix
```
参考：[Basic usage / data formats](http://zzz.bwh.harvard.edu/plink/data.shtml#ped)
