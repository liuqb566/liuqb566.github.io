---
layout: post
title: "gemma 使用记录"
categories: blog
tags: gemma
---

* content
{:toc}


++++++++++++
版本：Version 0.94.1

标记：355 份陆地棉材料 SLAF-seq 数据（宿）

性状：SPAD（2016，2017），浓度（2017）
+++++++++++

### 输入文件

#### genotype 文件

可以用比较多的输入类型，这是用的 plink 格式：

过滤，并转换成 bed 格式。
```
pink --file ms_0.4_NAU --maf 0.05 --geno 0.4 --recode --make-bed --out 355_virous_ms/355_ms_0.4 --noweb
```
- 355_ms_0.4.bim
- 355_ms_0.4.bed
- 355_ms_0.4.fam：gemma 仅读取第 2 行（材料 id）和第 6 行（性状）

#### phenotype 文件

> For the \*.fam file, GEMMA only reads the second column (individual id) and the sixth column (phenotype). One can specify a different column as the phenotype column by using "-n [num]", where "-n 1" uses the original sixth column as phenotypes, and \-n 2" uses the seventh column, and so on and so forth.

缺失值使用：-9 或者 NA

### 计算相关矩阵

```
./gemma -bfile [prefix] -gk [num] -o [prefix]
```
- -gk：不同的类型，一般用 1
- -bfile：输入 bed 文件

注意：用 genotype 计算相关矩阵。**相关矩阵的计算不依赖于具体的 phenotype，但是如果表型值有缺失，会在计算的时候剔除相关材料，所以可以用任意不含缺失值的表型数据计算相关矩阵，对于同一套 genotype ，可以用一个相关矩阵**

### Association Tests with Multivariate Linear Mixed Models

```
./gemma -bfile [prefix] -k [filename] -lmm [num] -n [num1] [num2] [num3] -o [prefix]
```
- -bfile：bed 格式 genotype
- -k：相关矩阵
- -lmm：检测方法。默认 `1`，Wald test。
- -n：表型。可以指定多个表型，进行多表型效应分析。也可以仅指定一个表型，此时与单变量混合线性模型一样。

为了用 `-n` 参数方便循环，在此使用多变量混合线性模型进行检测，但是仅指定一个变量（实际同单变量混合线性模型相同）

**注意**: 似乎 -n 的最大为 46（即一个 .fam 文件中最多放 46 个性状），多了就无法识别了。

### 分析步骤

#### phenotype & genotype 合并

脚本：add_phe_to_fam.sh

### 运行 gemma

脚本：gemma_run.sh

### 将结果整理成 CMplot 格式，画 mahttan 图

脚本：/home/liuqibao/workspace/scripts/gwas-pipline/gemma_based/transform_gemma_result_to_cmplot_formate.sh

### 用 CMplot 包画 mahttan、QQplot、SNP 标记密度

脚本：CMPlot_manhattan.R
