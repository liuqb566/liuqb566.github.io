---
layout: post
title: "faststructure 的简单使用"
date: 2017-6-21
categories: bioinformatics
tag: 使用手册
---

*content
{:toc}


[faststructure](http://rajanil.github.io/fastStructure/) 比 structure 的计算速度更快，适合数据量较大的群体结构计算。

### 1. 安装

faststructure 是基于 python 的脚本软件，首先需要一些 python 包
1. Numpy
2. Scipy
3. Cython
4. GNU Scientific Library

前 3 建议用 pip 安装。
gsl（GNU Scientific Library）需要下载安装：
```
wget http://mirrors.ustc.edu.cn/gnu/gsl/gsl-latest.tar.gz
cd gsl-2.4
sudo ./configure
sudo make 
sudo make install
```
fastStruce 的安装按官网步骤，没难点。

### 2. 使用

1. 血缘关系计算
```
python structure.py

Here is how you can use this script

Usage: python structure.py
-K <int>   (number of populations) # 注意 K 是大写
--input=<file>   (/path/to/input/file)
--output=<file>   (/path/to/output/file)
--tol=<float>   (convergence criterion; default: 10e-6)
--prior={simple,logistic}   (choice of prior; default: simple)
--cv=<int>   (number of test sets for cross-validation, 0 implies no CV step; default: 0)
--format={bed,str} (format of input file; default: bed)
--full   (to output all variational parameters; optional)
--seed=<int>   (manually specify seed for random number generator; optional)
```

最主要的参数有三个：
- -K：手动设定群体数
- --input：plink bed格式
- --output：输出文件名

例：`python structure.py -K 3 --input=genotypes --output=genotypes_output`

2. 选择合适的 K 值

chooseK.py 脚本用于选择合适的 K 值。
首先自己写循环计算 K=1~10，输出文件前缀假设为 testout_simple
命令：
```
$ python chooseK.py --input=test/testoutput_simple
```

3. 可视化

distruct.py 脚本用于可视化

```
 python distruct.py

 Here is how you can use this script

 Usage: python distruct.py
-K <int>  (number of populations)
--input=<file>  (/path/to/input/file; same as output flag passed to structure.py)
--output=<file>   (/path/to/output/file)
--popfile=<file>  (file with known categorical labels; optional)
--title=<figure title>  (a title for the figure; optional)
```
参数：
- -K：合适的 K 值
- --input：structure.py 的输出文件位置
- --output：输出文件，格式可以为.svg .pdf .jpg等
- --popfile：可以对分组使用不同的标签，每个样本一个标签，样本顺序要与 map 文件中的样本顺序相同。

例：
```
python distruct.py -K 5 --input=test/testoutput_simple --output=test/testoutput_simple_distruct.svg
```
