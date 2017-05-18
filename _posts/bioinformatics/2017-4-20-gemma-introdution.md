---
layout: post
title: "gemma 简单使用"
date: 2017-4-20
categories: bioinformatics
tag: 使用手册
---

* content
{:toc}

GEMMA 要求基因型文件不能有缺失值，因此，SNP 要先 impute。
虽然有表型缺失的个体不会用于 LMM 或者 BSLMM 分析，但是所有个体仍全部用于计算相关矩阵，所以相关矩阵的结果仍是 n x n 的矩阵。
### 1. 安装

gemma 安装很简单，直接下载二进制可执行文件就行，不用解压，不用编译。
最好再给它执行权限，`chmod a+x gemma`。
这已经足够 45,000 的样本的分析，如果你的数据更大，可以使用编译安装。

### 2. 输入文件格式

GEMMA 需要四个主要的输入文件，包括基因型、表型、相关矩阵和协变量（可选）。
基因型和表型文件可以是两种格式，都是 PLINK binary ped 格式或者都 BIMBAM 格式。不可混用。

### 2.1 PLINK Binary PED 格式

GEMMA 识别基因型型和表型的 PLINK binary ped 文件格式.
该格式需要三个文件：*.bed, *.bim, *.bam，所有文件都有相同的前缀。
用户可以用 PLINK 将标准 ped 文件转换成 binary ped 文件：
命令：
```
plink --file [file_prefix] --make-bed --out [bedfile_prefix]
```
对于 *.fam 文件，GEMMA 仅读取第二列（individual id）和第六列（phenotype）.
用户可以定义其它列作为 phenotype 列，使用 ‘-n [num]' 参数，'-n 1' 使用原始的第六列作为 phenotypes，'-n 2' 使用第七列，以此类推。
GEMMA 用 0/1 编码等位基因。
*.bim 文件的第 5 列是 minor allele ，编码为 1；第 6 列为 major allele ，编码为 0.
因此，第 5 列的 minor allele 是效应基因。

GEMMA 将按照提供的方式读入表型，’-9‘ 和 'NA' 作为缺失表型。

#### 2.2 BIMBAM 文件格式

详见[使用手册](http://zzz.bwh.harvard.edu/plink/data.shtml)

#### 2.3 相关性矩阵文件格式

两种方法，使用原始相关矩阵，或者使用原始相关矩阵的特征值和特征微量。

##### 2.3.1 原始矩阵格式

用户可以通过 ’-km [num]' 参数选择使用哪种格式，即：
-km 1：PLINK binary ped 格式的第一种；或者 BIMPAM 格式；
-km 2: PLINK binary ped 格式的第二种（id id value）

##### 2.3.2 特征值和特征向量格式

详见原文

#### 2.4 协变量文件格式（可选）

#### 2.5 Beta/Z 文件

#### 2.6 分类文件

#### 2.7 LD Score 文件

### 3. 运行 GEMMA

#### 3.1 一个 GWAS 例子的小数据集

该数据集在 GEMMA 的源文件中，可以在官网下载，也可以在 GitHub 下载。

#### 3.2 SNP 过滤器

软件提供了几个 SNP 过滤器。

多态性：没有多态性的 SNPs 不会用于分析。
缺失值：‘-miss [num]' 参数调节，默认 5%。例，’-miss 0.1'
最小等位基因频率：‘-maf [num]' 参数调节，默认 1%。例，'-maf 0.05'
Correlation with any covariate：’-r2 [num]‘ 调节，默认 0.9999。例，’-r2 0.999999
哈迪——温勃格平衡：‘-hww [num]’ 参数调节。例，‘-hwe 0.001’，将过滤 hwe 的 p 值小于 0.001 的 SNPs。

以上阈值计算基于分析的个体（即，个体没有缺失的表型和没有缺失的协变量）。
因此，如果所有的个体都有缺失表型，那么没有 SNP 会被分析，输出矩阵为空。

#### 3.3 用线性模型进行关联检验

##### 3.3.1 基本应用

用 PLINK bed 格式或者 BIMBAM 格式进行线性模型关联分析的基本应用：
```
./gemma -bfile [prefix] -lm [num] -o [prefix]
./gemma -g [filename] -p [filename] -a [filename] -lm [num] -o [prefix]
```

-lm：指定用哪种频数检验
  -lm 1：Wald test
  -lm 2: likelihood ratio test
  -lm 3：score test
  -lm 4: 以上三种检验
-bfile [prefix]: PLINK binary ped file 前缀
-g [filename]：BIMBAM mean genotype 文件名
-p [filename]：BIMBAM 表型文件名
-a [filename]：可选，BIMBAM SNP 注释文件名
-o [prefix] ：输出文件前缀

注意：与线性混合模型不同，该分析不需要相关性矩阵

###### 3.3.2 详细信息

对二进制性状，用户可以将对照组标记为 0 ，实验组标记为 1，然后通过把二进制化的对照实验标签当作数量性状，跟据以上方法用线性混合模型拟合数据。

##### 3.3.3 输出文件

共有两个输出文件，都在当前目录下的文件夹中。
‘preix.log.txt' 文件有一些关于运行参数和计算时间的细节信息。除此之外，还包含 PBE 检测和它的标准误。
’prefix.assoc.txt' 文件包含结果。例如：
```
chr rs ps n_mis n_obs allele1 allele0 af beta se p_wald
1 rs3683945 3197400 0 1410 A G 0.443 -1.586575e-01 3.854542e-02 4.076703e-05
1 rs3707673 3407393 0 1410 G A 0.443 -1.563903e-01 3.855200e-02 5.252187e-05
1 rs6269442 3492195 0 1410 A G 0.365 -2.349908e-01 3.905200e-02 2.256622e-09
1 rs6336442 3580634 0 1410 A G 0.443 -1.566721e-01 3.857380e-02 5.141944e-05
1 rs13475700 4098402 0 1410 A C 0.127 2.209575e-01 5.644804e-02 9.497902e-05
```
这 11 行是：染色体、SNP id、碱基对在染色体上的位置、相应 SNP 的缺失个体数量、相应 SNP 的无缺个体数量、最小等位基困、最大等位基因、等位基因频率、beta 检测、beta 标准误、Wald 检验的 P 值。

#### 3.4 估计来自基因型的相关性矩阵

##### 3.4.1 基本应用

```
./gemma -bfile [prefix] -gk [num] -o [prefix]
./gemma -g [filename] -p [filename] -gk [num] -o [prefix]
````
-gk [num]: 估计哪种相关性矩阵：
  -gk 1: centered relatedness matrix, 默认
  -gk 2: standardized relatedness matrix
-bfile [prefix]: PLINK binary ped file prefix
-g [filename]: 见 3.3
-p [filename]:  见 3.3
-o [prefix]: 见 3.3

注意：BIMBAM mean genotype 文件可以用 gzip 压缩格式

##### 3.4.2 详细信息

较低的最小等位基因频率趋于较大的效应：standardized genotype atrix
SNP 的效应大小不依赖于最小等位基因频率：ecntered genotype matrix

##### 3.4.3 输出文件

#### 3.5 进行相关矩阵的 Eigen-Decomposition

##### 3.5.1 基本应用

```
./gemma -bfile [prefix] -k [filename] -eigen -o [prefix]
./gemma -g [filename] -p [filename] -k [filename] -eigen -o [prefix]
```
-b：见前文
-g：见前文
-p：见前文
-k [filename]：相关矩阵文件名

注意：BIMBAM mean genotype/相关矩阵文件格式可以是 gzip 压缩格式

##### 3.5.2 详细信息

##### 3.5.3 输出文件

#### 3.6 单变量线性混合模型的关联检验

##### 3.6.1 基本应用

```
./gemma -bfile [prefix] -k [filename] -lmm [num] -o [prefix]
./gemma -g [filename] -p [filename] -a [filename] -k [filename] -lmm [num] -o [prefix]
```
-lmm：指定用哪种频数检验
  -lmm 1：Wald test
  -lmm 2: likelihood ratio test
  -lmm 3：score test
  -lmm 4: 以上三种检验
-bfile [prefix]: PLINK binary ped file 前缀
-g [filename]：BIMBAM mean genotype 文件名
-p [filename]：BIMBAM 表型文件名
-a [filename]：可选，BIMBAM SNP 注释文件名
-o [prefix] ：输出文件前缀
-k [filename]：相关矩阵文件名

为检测基因-环境的交互作用，你可以加 ’-gxe [filename]’ 参数。
注意：‘-k [filename]’ 可以用 ‘-d [filename]’ （特征值文件）和 ‘-u [filename]’ （特征向量文件）所代替。

##### 3.6.2 详细信息

##### 3.6.3 输出文件

见前文

#### 3.7 多变量线性混合模型的关联检验

##### 3.7.1 基本应用

```
./gemma -bfile [prefix] -k [filename] -lmm [num] -n [num1] [num2] [num3] -o [prefix]
./gemma -g [filename] -p [filename] -a [filename] -k [filename] -lmm [num] -n [num1] [num2] [num3] -o [prefix]
```

-lmm：指定用哪种频数检验
  -lmm 1：Wald test
  -lmm 2: likelihood ratio test
  -lmm 3：score test
  -lmm 4: 以上三种检验
-n [num1] [num2] [num3]: 表型文件中哪些表型用于关联
-bfile [prefix]: PLINK binary ped file 前缀
-g [filename]：BIMBAM mean genotype 文件名
-p [filename]：BIMBAM 表型文件名
-a [filename]：可选，BIMBAM SNP 注释文件名
-o [prefix] ：输出文件前缀
-k [filename]：相关矩阵文件名

为检测基因-环境的交互作用，你可以加 ’-gxe [filename]’ 参数。
注意：‘-k [filename]’ 可以用 ‘-d [filename]’ （特征值文件）和 ‘-u [filename]’ （特征向量文件）所代替。

##### 3.7.2 详细信息

建议表型的数量小于 10 个。
当表型的一小部分缺失的时候，用户可以在关联前推测缺失值:
```
./gemma -bfile [prefix] -k [filename] -predict -n [num1] [num2] [num3] -o [prefix]
./gemma -g [filename] -p [filename] -a [filename] -k [filename] -predict -n [num1] [num2] [num3] -o [prefix]
```

##### 3.7.3 输出文件

见前文

#### 3.8 Fit a Bayesian Sparse Linear Mixed Model（BSLMM）

##### 3.8.1 基本应用

```
./gemma -bfile [prefix] -bslmm [num] -o [prefix]
./gemma -g [filename] -p [filename] -a [filename] -bslmm [num] -o [prefix]

```
-bslmm [num]：
  -bslmm 1: a standard linear BSLMM，使用 MCMC
  -bslmm 2: a ridge regression/GBLUP，使用 standard non-MCMC 方法。最快
  -bslmm 3: a probit BSLMM，使用 MCMC。最慢

##### 3.8.2 详细信息

注意：拟合 BSLMM 需要大量内存（例，4000 个体，400，000 SNPs，20 GB 内存），因为软件会存储整个基因型矩阵到内存中。
foat 版本（gemmaf）可以在不会缺失太大精度的情况下节省一半的内存。

GEMMA 默认不需要用户提供相关性矩阵，它会自动计算，你也可以通过 ‘-k [filename]’ 自己提供。
在拟合 BSLMM 的时候，GEMMA 不需要协变量文件，然而，用户可以用 BIMBAM mean genotype 文件存储协变量，用 ‘-notsnp’ 参数使用它们。

使用基于 MCMC 的方法时，用户可以通过 ‘-w [num]’ 选择 burn-in iterations 的数量，‘-s [num]’ 选择 sampling iterations 的数量。
此外，用户可以使用 ‘-smax [num]’ 选择用于模型的最大 SNPs 数量（即，有加性效应的 SNPs），probit BSLMM 很需要，因为它的计算负担重。
为了平衡计算精度和计算时间，用户可以自己决定使用这些参数。

###### 3.8.3 输出文件

共有 5 个输出文件，位于当前目录的输出文件夹下。
prefix.log.txt：
prefix.hyp.txt：
prefix.param.txt：
prefix.bv.txt：一列育种值
prefix.gamma.txt：

#### 3.9 用来自 BSLMM 的输出文件预测表型

##### 3.9.1 基本应用

```
./gemma -bfile [prefix] -epm [filename] -emu [filename] -ebv [filename] -k [filename] -predict [num] -o [prefix]
./gemma -g [filename] -p [filename] -epm [filename] -emu [filename] -ebv [filename] -k [filename] -predict [num] -o [prefix]
```
-predict [num]: 预测值需要用正态累积分布函数（CDF）额外转换
  -predict 1: 获得预测值
  -predict 2: 获得预测值，用 CDF 将它们转换成概率大小。仅拟合 probit BSLMM 时用。
-epm [filename]：来自 BSLMM 的 prefix.param.txt
-emu [filename]: prefix.log.txt from BSLMM
-ebv [filename]: prefix.bv.txt from BSLMM
-k [filename]: 相关性矩阵

##### 3.9.2 详细信息

使用拟合 BSLMM 中的同一个表型文件和基因型文件。
如果用户使用默认矩阵进行拟合 BSLMM，那么在第二步不需要提供 ‘-bev’ 和 ‘-k'。

##### 3.9.3 输出文件

在当前目录的输出文件夹下有两个输出文件。
prefix.log.txt:
prefix.prdt.txt:有一列所有个体的预测值

#### 3.10 相关性矩阵的方差分量估计

###### 3.10.1 基本应用

```
./gemma -p [filename] -k [filename] -n [num] -vc [num] -o [prefix]
./gemma -p [filename] -mk [filename] -n [num] -vc [num] -o [prefix]
```
-vc: 作用哪种估计方式：
  -vc 1: 默认，使用 HE regression
  -vc 2: REML AI 算法
-n [num]: 使用表型的哪一列，默认 1

##### 3.10.2 详细信息

默认 REML AI 算法的方差分量估计限制为正，用户可以在 ’-vc 2‘ 上用 ’-noconstrain‘。
HE regression 没有限制

##### 3.10.3 输出文件

#### 3.11 Summary Statistics 的方差分量估计

##### 3.11.1 基本应用

```
./gemma -beta [filename] -bfile [prefix] -vc 1 -o [prefix]
./gemma -beta [filename] -g [filename] -p [filename] -a [filename] -vc 1 -o [prefix]
```
-vc 1: MQS-HEW
-beta [filename]: beta 文件名

##### 3.11.4 详细信息

##### 3.11.3 输出文件


