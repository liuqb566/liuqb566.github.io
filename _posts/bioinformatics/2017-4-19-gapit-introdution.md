---
layout: post
title: "gapit：用户使用手册"
categories: bioinformatics
tag: 使用手册
---

* content
{:toc}


## GAPIT 的简单使用

GAPIT 2 是基于 R 语言的基因组关联和预测的整合工具包，提供了多种方法用于 GWAS 分析，包括 GLM、MLM、CMLM、P3D、EMMA等。
对于包含大量 SNPs 的大数据集，可以通过将基因型文件分隔成多个文件进行分析，例如，每个染色体一个文件。
GAPIT 的输入文件可以是 HapMap 格式，也可以是 EMMA 需要的 numerical 格式。

### 1. 安装

GAPIT 的需要几个 R 的依赖包，安装比较简单，具体请看[使用手册](http://zzlab.net/GAPIT/)，不再赘述。
```
source("http://www.bioconductor.org/biocLite.R")
biocLite("multtest")
install.packages("gplots")
install.packages("LDheatmap")
install.packages("genetics")
install.packages("ape")
install.packages("EMMREML")
install.packages("scatterplot3d")
```
### 2. 使用

以下包在每次使用前需要重新加载
```
library(multtest)
library(gplots)
library(LDheatmap)
library(genetics)
library(ape) # required for as.phylo
library(EMMREML)
library(compiler) #required for cmpfun
library("scatterplot3d")

source("http://www.zzlab.net/GAPIT/emma.txt")           # 这两个脚本也可以下载到本地，通过本地路径加载
source("http://www.zzlab.net/GAPIT/gapit_functions.txt")
```

可以下载官网提供的数据进行练习

```
setwd("/myGAPIT") # 设定工作目录，结果文件将输出到该目录
```

#### 2.1. 基本应用

基本应用需要两个文件（表型数据文件和基因型文件）和一个参数主成分的个数（`PCA.total`）；GAPIT 会自动计算 K 矩阵（VanRaden 方法）；用默认的聚类算法（平均）和 group kinship type（Mean）进行 GWAS 分析。

```
# 输入文件
myY  <- read.table("mdp_traits.txt", head = TRUE)
myG <- read.delim("mdp_genotype_test.hmp.txt", head = FALSE)

# 运行 GAPIT
myGAPIT <- GAPIT(
Y=myY,
G=myG,
PCA.total=3,
)
```

#### 2.2. Enhanced Compression

在这个用法中，你可以指定其它的聚类算法（`kinship.cluster` 参数控制），kinship summary statistic（‘kinship.group’ 参数）。
默认 ‘kinship.cluster='average'、'kinship.group='Mean'。
a specific range group numbers（即，k 矩阵的维度）可以通过’group.from','group.to','group.by' 三个参数指定。
（好吧，我承认没看懂。。。）
```
#Step 1: Set data directory and import files
myY <- read.table("mdp_traits.txt", head = TRUE)
myG <- read.table("mdp_genotype_test.hmp.txt", head = FALSE)
#Step 2: Run GAPIT
myGAPIT <- GAPIT(
Y=myY,
G=myG,
PCA.total=3,
kinship.cluster=c("average", "complete", "ward"),
kinship.group=c("Mean", "Max"),
group.from=200,
group.to=1000000,
group.by=10
)
```
#### 2.3. 用户输入的 K 矩阵和协变量

本用法假设用户提供了 K 矩阵和协变量文件。
你可以使用第三方软件产生的 K 矩阵或协变量（如，PCs 等）。
当用这种方法输入 PCs 时，参数 ‘PCA.total’ 应该设为 0 （默认），否则会出错。

```
#Step 1: Set data directory and import files
myY <- read.table("mdp_traits.txt", head = TRUE)
myG <- read.table("mdp_genotype_test.hmp.txt", head = FALSE)
myKI <- read.table("KSN.txt", head = FALSE)
myCV <- read.table("Copy of Q_First_Three_Principal_Components.txt", head = TRUE)
#Step 2: Run GAPIT
myGAPIT <- GAPIT(
Y=myY,
G=myG,
KI=myKI,
CV=myCV
)
```

#### 2.4. 基因组预测

Genomic prediction 不用进行 GWAS，所以需要关闭 GWAS 功能，参数为‘SNP.test=FALSE’。
```
#Step 1: Set data directory and import files
myY <- read.table("mdp_traits.txt", head = TRUE)
myKI <- read.table("KSN.txt", head = FALSE)
#Step 2: Run GAPIT
myGAPIT <- GAPIT(
Y=myY,
KI=myKI,
PCA.total=3,
SNP.test=FALSE
)
```

#### 2.5. 多基因型文件

在本用法中，来自用法 1 的 HapMap 基因型数据集被分割成多个基因型文件，每个文件对应一个染色体。
这个用法适用于在 R 中处理基因型文件太大的情况。
所有的基因型文件有一个通用名和一个扩展名，还有一个特定的序列号（例，'mdp_genotype_chr1.hmp.txt','mdp_genotype_chr2.hmp.txt',...）。
用‘file.from' 和 ’file.to‘ 参数声明开始和结束文件。
通常文件名（如，'mdp_genotype+chr'）和 扩展文件名（如，'hmp.txt'）通过 ’file.G' 和 'file.Ext.G' 参数传递给 GAPIT。
当没有提供 'file.path' 参数时，GAPIT 尝试从当前目录查找文件。

```
#Step 1: Set data directory and import files
myY <- read.table("mdp_traits.txt", head = TRUE)
#Step 2: Run GAPIT
myGAPIT <- GAPIT(
Y=myY,
PCA.total=3,
file.G="mdp_genotype_chr",
file.Ext.G="hmp.txt",
file.from=1,
file.to=10,
file.path="C:\\myGAPIT\\"
)
```

#### 2.6. Numeric Genotype Format

在本用法中，基因型数据集是用的不同的格式，numerical 格式。
需要两个基因型文件。
一个文件包含基因型数据（'GD'，参数），另一个文件包含染色体和每个 SNP 的碱基对位置（'GM'，参数）。
```
#Step 1: Set data directory and import files
myY <- read.table("mdp_traits.txt", head = TRUE)
myGD <- read.table("mdp_numeric.txt", head = TRUE)
myGM <- read.table("mdp_SNP_information.txt" , head = TRUE)
#Step 2: Run GAPIT
myGAPIT <- GAPIT(
Y=myY,
GD=myGD,
GM=myGM,
PCA.total=3
)
```
#### 2.7. 多个文件的 Numeric genotype Format

在本用法中，用法 6 的 numeric genotype 数据集被分割成多个基因型文件。
基因型文件的通用名和扩展名通过 'file.GD' 和 ‘file.Ext.GD' 参数传递给 GAPIT。
基因型 map 文件的通用名和扩展名通过 'file.GM' 和 ’file.Ext.GM' 参数传递给 GAPIT。
```
#Step 1: Set data directory and import files
myY <- read.table("mdp_traits.txt", head = TRUE)
#Step 2: Run GAPIT
myGAPIT <- GAPIT(
Y=myY,
PCA.total=3,
file.GD="mdp_numeric",
file.GM="mdp_SNP_information",
file.Ext.GD="txt",
file.Ext.GM="txt",
file.from=1,
file.to=3,
)
```

#### 2.8. 用部分 SNPs （Fractional SNPs）计算 Kinship 和 PCs

选取总 SNPs 的部分进行计算可以节省计算时间，更重要的是它的结果类似。
fraction 可以通过 ‘Ratio’ 参数控制。
取样是随机的。
以下用的是 ’SNP.fraction=0.6',总 SNPs 为 3093.

```
#Step 1: Set data directory and import files
myY <- read.table("mdp_traits.txt", head = TRUE)
#Step 2: Run GAPIT
myGAPIT <- GAPIT(
Y=myY,
PCA.total=3,
file.GD="mdp_numeric",
file.GM="mdp_SNP_information",
file.Ext.GD="txt",
file.Ext.GM="txt",
file.from=1,
file.to=3,
SNP.fraction=0.6
)
```

#### 2.9. 节省内存

如果样本量很大，读入整个基因型数据集是很难的。
GPAIT 每次只载入一部分片段（fragment）。
默认 fragment 大小是 512 SNPs。
这个数字可以通过 ‘file.fragment' 参数进行控制。
这个例子是用的 'file.fragment=128'

```
#Step 1: Set data directory and import files
myY <- read.table("mdp_traits.txt", head = TRUE)
#Step 2: Run GAPIT
myGAPIT <- GAPIT(
Y=myY,
PCA.total=3,
file.GD="mdp_numeric",
file.GM="mdp_SNP_information",
file.Ext.GD="txt",
file.Ext.GM="txt",
file.from=1,
file.to=3,
SNP.fraction=0.6,
file.fragment = 128
)
```

#### 2.10. 模型选择

群体结构相关性的程度随性状的改变而改变。
因此，在 GWAS 中，选择的完整的 PCs 并不是必须的。
GAPIT 可以通过通过基于贝叶斯信息评价的（BIC）的模型选择，寻找最合适的 PCs 数量。
参数为 ‘Model.selection=TRUE'
输出文件 '.BIC.Model.Selection.Results.csv'
```

myY <- read.table("mdp_traits.txt", head = TRUE)
myG <- read.table("mdp_genotype_test.hmp.txt", head = FALSE)
#Step 2: Run GAPIT
myGAPIT <- GAPIT(
Y=myY,
G=myG,
PCA.total=3,
Model.selection = TRUE
)
```

#### 2.11. SUPER

GAPIT 也提供了 SUPER GWAS 方法，它提取 SNPs 的小数据集用于 FaST-LMM。
```
#Step 1: Set data directory and import files
myCV <- read.table("Copy of Q_First_Three_Principal_Components.txt", head = TRUE)
myY <- read.table("mdp_traits.txt", head = TRUE)
myG <- read.table("mdp_genotype_test.hmp.txt" , head = FALSE)
#Step 2: Run GAPIT
myGAPIT_SUPER <- GAPIT(
Y=myY[,c(1,2)],
G=myG,
#KI=myKI,
CV=myCV,
#PCA.total=3,
sangwich.top="MLM", #options are GLM,MLM,CMLM, FaST and SUPER
sangwich.bottom="SUPER", #options are GLM,MLM,CMLM, FaST and SUPER
LD=0.1,
)
```

### 3. 数据

所有的输入数据都应该被保存在 ’\t‘ 分割的 text 文件中，建议 taxa 安字母表排序。

#### 3.1 表型数据

多个性状可以放在一个文件中。
第一列为 ’taxa‘ （样本），其它列为表型数据。（’\t‘ 分割）
缺失数据用 ’NaN‘ 或者 ’NA‘。
```
myY <- read.table("mdp_traits.txt", head = TRUE)
head（myY）
  Taxa EarHT dpoll   EarDia
  1   811 59.50   NaN      NaN
  2  4226 65.50  59.5 32.21933
  3  4722 81.13  71.5 32.42100
  4 33-16 64.75  64.5      NaN
  5 38-11 92.25  68.5 37.89700
  6  A188 27.50  62.0 31.4190
```

#### 3.2 基因型数据

GWAS 需要基因型数据，基因组预测可不用。
基因型数据的数据格式可以用 HapMap 格式或者 numeric 格式。

##### 3.2.1 HapMap 格式

HapMap 格式 SNP 信息（染色体及位置）和每个 taxa 的基因型保存在一个文件中。
具体格式自行 google
例子
```
myG <- read.table("mdp_genotype_test.hmp.txt", head = FALSE)
```

##### 3.2.2 numeric 格式

numeric 格式有两个文件，一个包含基因型数据信息，一个包含 SNP 位置信息。
两个文件的排序应该相同。
例子
```
myGD <- read.table("mdp_numeric.txt", head = TRUE)
myGM <- read.table("mdp_SNP_information.txt", head = TRUE)
```
格式转换:HapMap -> numeric
```
myG <- read.table("mdp_genotype_test.hmp.txt", head = FALSE) myGAPIT <- GAPIT(G=myG, output.numerical=TRUE)
myGD= myGAPIT$GD
myGM= myGAPIT$GM
```

#### 3.3 Kinship

K 矩阵在 GAPIT 中称之为 ’KI'。
第一列为样本名，其余为相关矩阵，没有表头。
例子：
```
myKI <- read.table("KSN.txt", head = FALSE)
```

#### 3.4 协变量

在 GAPIT 中，协变量文件叫 ‘CV’，包含群体结构信息（Q 矩阵）或者 PCs。
例子
```
myCV <- read.table("mdp_population_structure.txt", head = TRUE)
```

#### 3.5 通过文件名输入基因型文件

见第二部分，多基因型文件

#### 3.6 其它 GAPIT 参数

### 4. 结果

GAPIT 产生的结果保存为两种格式。
所有的表格结果保存为 .csv 文件，所有的图形保存为 .pdf 文件。






