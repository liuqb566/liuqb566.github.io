---
layout: post
title: "edgeR：用户使用手册"
categories: bioinformatics
tag: 使用手册
---

* content
{:toc}


## 第 一 章

### 简介

#### 1.1 使用范围

edgeR 主要用来分析 read 的表达差异，数据可以来自各个平台，如 RNA-seq、ChIP-seq、CRISR-Cas9 、SAGE-seq等。
edgeR 提供两各方法进行统计分析：
- 经典 edgeR：分析多组实验的精确统计方法
- glm edgeR：适合任何复杂的多因子实验的一般线性模型方法（glm）；这部分功能的名字以 ’glm‘ 标识
edgeR 的功能是基于经验贝叶斯方法的，它可以用于基因、外显子、转录本或者 tag 水平。

#### 1.2 引用

#### 1.3 如何获得帮助

#### 1.4 Quick start

edgeR 提供了很多分析方法。通常，建议使用 glm 流程，因为它非常灵活。
在 glm 框架在有两种检测方法：似然比检测和准似然比 F-test。

这个例子用了 4 个RNA-seq 库，分为两组，counts 是排好序的，保存在文件中，基因符号位于一列，命名为 Symbol。

```
x <- read.delim("TableOfCounts.txt',row.names='Symbol') # 读入数据，也可以用 read.table 等，或者在 R 中手动构建数据框。
group <- factor(c(1,1,2,2)) # 分组
y <- DGEList(counts=x,group=group) # x 是包含 counts 的列，group 参数为分组；DGEList 是 edgeR 的数据结构
y <- calcNormFactors（y）#标准化
design <- model.matrix(~ group)
y <- estimatedisp（y，design）

```

准似然比 F-test：
```
fit <- glmQLFit(y,design)
qlf <- glmQLFTest(fit,coef=2)
topTags(qlf)
```

似然比检测：
```
fit <- glmFit(y,design)
lrt <- glmLRT(fit,coef=2)
topTags(lrt)
```


## 第 二 章

### 功能概括

#### 2.1 术语

为了简单起见，以下内容将基因组 feature 统称为 ’genes‘，其实它可以是转录本、外显子等等。

#### 2.2 将 read 比对到基因组上

featureCounts 和 htseq 都是可行的。

#### 2.3 产生 read counts 的列表

edgeR 的输入文件要求是列表，每行是一个 genes ，每列是一个库（样本）。
注意：edgeR 应该使用实际的 read counts ，不建议使用预测的转录本丰度（例如 RPKM、FPKM）

#### 2.4 从一个文件中读入 counts

如果 counts 列表已经在一个文件中，那么需要读入它。
如果不同样本的数据存储在不同文件中，那么你需要单个读入并整合它们，readDGE 函数可以实现这个功能。这些文件需要两列，一列代表 gene 名字，一列代表 counts 数。

#### 2.5 DGEList 数据类

edgeR 的数据存储在名为 DGEList 的对象中。
可以用 readDGE 直接构造，如果 counts 列表已经作为矩阵或者数据框输入，用 x 表示，那么：
```
y <- DGEList(counts=x)
```

可以同时加入分组因子：
```
group <- c(1,1,2,2)
y <- DGEList(coutns=x,group=group)
```

DGEList 对象的主要组成是一个 counts 矩阵，包括所有的 counts，一个 samples 信息的数据框，和一个可选的包含 genes 注释信息的数据框。

#### 2.6 过滤

根据经验，如果 genes 在所有条件下的所有样本都没有表达，那么就应该过滤掉。
通常一个基因的 counts 为 5——10 才认为它表达了。
用户应该使用 count-per-million（CPM）指标过滤而不是直接过滤，因为直接过滤没有考虑库的大小。
命令：
```
keep <- rowSums(cpm(y)>1) >= 2
y <- y[keep,,keep.lib.sizes=FALSE]
```
CPM 为 1 代表在最小的样本中，count 为 6——7。
因为每组至少有两个样本，所以要求至少在 2 个库中表达（>=2）。
这确保如果基因仅在 group 2 中的所有样本表达会保留下来。
建议过滤后重新计算库的大小，尽管它的影响非常小。
命令：
```
y$sample$lib.size <- colSums(y$counts)
```

#### 2.7 标准化

##### 2.7.1 标准化仅对样本特异化影响是必须的

edgeR 比较的两个环境下样本的表达水平的相关改变，而不是直接比较表达水平的绝对值。这简化了技术的影响。
例如，edgeR 不会考虑 genes 长度的影响，因为它与每个样本的 read counts 的影响相关。（即，通过比较表达水平的改变，已经修正过了）

##### 2.7.2 测序深度

edgeR 通过不同库的大小修正测序深度对差异表达分析的影响，这部分已经考虑进 fold-change 或者 P-value 中。

##### 2.7.3 RNA 组成

RNA 组成是第二重要的技术因素。
当少量的基因在一个样本中高差异表达，而在另一个样本中没有时，这个因素的影响会很大。
通过寻找库大小的比例因子，它可以最小化样本基因的 log-fold changes，calcNormFactors 函数标准化 RNA组成。
默认使用 TMM 方法估计比例因子。

当两两样本间差异表达的基因被确定不会超过一半时，TMM 方法是大多数 RNA-seq 推荐的方法。
TMM 标准化的命令：
```
y <- calcNormFactors(y)
```

##### 2.7.4 GC 含量

##### 2.7.4 基因长度

##### 2.7.6 基于模型的标准化，而不是转化

注意：edgeR 需要的的原始的 read counts，不是转化后的，如 RPKM 或者 FPKM 值。

##### 2.7.7 Pseudo-counts

经典的 edgeR 函数 estimateCommonDisp 和 exactTest 产生一个 pseudo-counts 矩阵作为输出的一部分。

#### 2.8 负二项模型

##### 2.8.1 简介

##### 2.8.2 生物变异的影响（BCV）

##### 2.8.3 计算 BCVs

##### 2.8.4 Quasi negative binomial

#### 2.9 两组或多组的成对比较（经典方法）

##### 2.9.1 计算离散度

离散度为生物变异系数（BCV）的平方。
edgeR 对单因素实验使用 qCML（the quantile-adjusted conditional maximum likelihood）方法。

仅当是单因素实验设计的时候才能使用 qCML 方法，不适于多因素实验设计。

一次性计算 common dispersion 和 tagwise dispersion：
```
y <- estimateDisp（y）
```

计算 common dispersion：
```
y <- estimateCommaonDisp（y）
```

计算 tagwise disperson：
```
y <- estimateTagwiseDisp(y)
```

注意：如果独立计算，需要先计算 common dispersion，再计算 tagwise disperson。

##### 2.9.2 DE genes 检测

精确检测是基于 qCML 方法的，仅适用于单因素实验。
```
et <- exactTest(y)
topTags(et)
```

#### 2.10 更复杂的实验（glm 功能）

##### 2.10.1 一般线性模型（GLMs）

##### 2.10.2 计算离散度

对于多因素实验，edgeR CR 方法计算离散度，它通过一个设计矩阵拟合 GLM 模型来考虑多因素影响。

一次性计算 common dispersion、trended dispersion 和 tagwise dispersion 的命令：
```
y <- estimateDisp(y,design)
```

计算 common dispersion：
```
y <- estimateGLMCommonDisp(y, design)
```

计算 trendedDisp（y，design）
```
y <- estimateGLMTrendedDisp（y，design）
```

计算 tagwise dispersion：
```
y <- estimateGLMTagwiseDisp（y，design）
```

注意：需要先计算 common dispersion 或者 trended dispersion，再计算 tagwise dispersion。
在多因素实验中，强烈建议使用 tagwise dispersion 方法。

##### 2.10.3 DE genes 检验

```
group <- factor（c（1，1，2，2，3，3））
design <- model.matrix(~group)
fit <- glmFit(y,design)
```

拟合函数有三个参数，第一个 group 1 扩基准水平。
第二个和第三个是 2 vs 1 和 3 vs 1 差异

比较 2 vs 1:
```
lrt.2vs1 <- glmLRT(fit, coef=2)
topTags(lrt.2vs1)
```

比较 3 vs 1:
```
lrt.3vs1 <- glmLRT(fit, coef=3)
```

比较 3 vs 2:
```
lrt.3vs2 <- glmLRT(fit, contrast=c(0,-1,1)) # contrast 参数需要一个零假设的统计检验，coefficient3——coefficient2 等于 0
```

寻找三个组都有的差异：
```
lrt <- glmLRT(fit,coef=2:3)
topTags(lrt)
```

也可以用 QL F-test 检验。
代码略。

#### 2.11 如果没有重复怎么办

不推荐没有重复的实验，但是实在没有重复时，可以考虑以下选项：
1. 用描述性统计分析，包括 MDS plot 和 fold changes 分析。
2. 根据你的实验和相似数据，选择合适的离散度，用于 exactTest 或者 glmFit。对于人类等（可能是自由交配的物种）控制较好的实验，可以选择 BCV = 0.4；遗传上相同的模式生物（可能是指自交的生物，如植物）可以选择 BCV = 0.4；技术重复为 0.01.

```
bcv <- 0.2
counts <- matrix(rnbinom(40,size=1/bcv^2),20,2)
y <- DGEList(counts=counts,group=1:2)
et <- exactTest(y,dispersion=bcv^2)
```

注意:P-value 和显著基因的数量对离散度的选择非常敏感，对于没有控制的数据、没有考虑批次影响等等，可以实际使用更大的离散度。
然而，选择一个假设的离散度总比忽略生物学变异好。

3. 通过从线性模型移除一个或更多因子，来创造残差自由度。具体见原文。
4. 如果存在大量的没有 DE 的转录本，可以用它们来检测离散度。
例如，找一个在所有处理环境中都没有表达差异的基因作为 housekeeping （管家基因），通过它计算离散度。
首先，创建一个数据的 copy ，将所有处理视为一个组：
```
y1 <- y
y1$samples$grouop <- 1
```

然后计算来自 housekeeping 基因的离散度，所有的库视为一组：
```
y0 <- estimateCommonDisp(y1[housekeeping,1])
```

然后将它插入所有数据对象：
```
y$sommon.dispersion <- y0$common.dispersion
et <- exactTest(y)
```
注意：需要大量的控制转录本，至少有几十个，理想是数百个

#### 2.12 表达差异高于 fold-change 阈值

#### 2.13 GO 和 pathway 分析

#### 2.14 Gene set testing

#### 2.15 clustering, heatmaps 等

#### 2.16 可变剪接

#### 2.17 CRISPR-Cas9 tkg shRNA-seq screen 分析

## 第 三 章 特异性实验设计

#### 3.1 简介

本章主要概括设计矩阵，比较一些经典的实验设计

#### 3.2 两组或多组

##### 3.2.1 引言

##### 3.2.2 经典方法

经典 edgeR 方法进行组间的成对比较。
```
group <- factor(c('A','A','B','B','C','C'))
et <- exactTest(y,pair=c('A','B')) # B vs A
topTags(et)
et <- exactTest(y,pair=c('A','C')) # C vs A
et <- exactTest(y, pair=c('C','B')) # B vs C
et <- exactTest(y, pair=c(3,2)) # 用数字表示，等同于 B vs C
```
具体细节见原文

#### GLM 方法

GLM 方法允许多个组的比较。
GLM 方法需要一个设计矩阵，可以用 model.matrix 函数构造，也可以手动构造。
```
design <- model.matrix(~0+group,data=y$samples)
colnames(design) <- levels(y$samples$group)
```


