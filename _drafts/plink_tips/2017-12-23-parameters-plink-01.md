---
layout: post
title: "Plink 小技巧之参数"
categories: NGS
tags: Plink
---

* content
{:toc}


实用参数：
### 文件输入/出
以下参数可以在的任何命令中使用

- --file: PED format
- --bfile: BED format
- --tfile: TPED format

- --out: prefix for output;default, plink

- --recode: output NEW PED format file
- --recode12: As above, with 1/2 alleles

- --make-bed: output BED format file

- --tab: 默认情况下以**空格**分隔所有列；此参数可以使 genotypes 间用 tab 分隔，alleles 间用**空格**分隔

### 统计/过滤

|--------------------------|--------------------|----------------------|
|Feature                   |As summary statistic| As inclusion criteria|
|--------------------------|--------------------|----------------------|
|Missingness per individual|--missing           |--mind N              |
|--------------------------|--------------------|----------------------|
|Missingness per marker    |--missing           |--geno N              |
|--------------------------|--------------------|----------------------|
|Allele frequency          |--freq              |--maf N               |
|--------------------------|--------------------|----------------------|
|Hardy-Weinberg equilibrium|--hardy             |--hwe N               |
|--------------------------|--------------------|----------------------|
|Mendel error rates        |--mendel            |--me N M              |
|--------------------------|--------------------|----------------------|

**注意**：第三列的意思是 exclude 没有通过检验的 SNP
