---
layout: post
title: "fastqc 软件的简单使用和结果解读"
date: 2017-4-26
categories: bioinformatics
tag: 使用手册
---

* content
{:toc}


### 简单使用

fastqc 是一个高能量测序数据 QC 分析工具。
作用命令：
```
fastqc seqfile1 seqfile2 ... seqfileN
fastqc fastqc [-o output dir] [--(no)extract] [-f fastq|bam|sam] [-c contaminant file] seqfile1 .. seqfileN
```
options：
-o：将结果输出到指定文件夹。注意，文件夹必须已存在，程序不会自己创建文件夹。
--casava：输入数据为 casava 数据
--nano：输入数据为 naopore 序列数据，fast5 格式。
--extract：输出文件不压缩，默认为压缩
--noextract：压缩输出文件，如果在非交互式界面建议这样做。
-f：强制指定输入文件格式，默认自动识别。可用格式有：bam,sam,bam_mapped,sam_mapped,fastq
-t：多线程控制。注意，每个线程需要 250M 内存，请合理使用。32 位的系统不能多于 6 个线程。
-c：污染物选项，非默认选项
-a：接头文件，非默认选项
-l：自定义评估标准，也可以删除某些评估项目。
-k: 调节 kmers 设定某特定短序列的长度，范围 2-10，默认 7.
-q：沉默模式，仅报告错误，不输出标准输出
-d：设置存储产生图片时的临时文件的文件夹，默认 /temp

### 结果

#### 基础统计

- Filename
- File type：常规碱基还是 colorspace 序列，后者需要转换为常规碱基。
- Encoding：Q 值的 ASCII 编码版本
- Total Sequences：有两个值，一个实际值，一个估计值，目前来说一样，软件还没找到好的估计方法。
- Filtered Sequences：在 Casava 模式下运行时过滤的 flag 序列数，这项结果不在上一项 Total Sequences中，也不在以后的分析中
- Sequence Length：显示最长和最短 read 长度，如果所有长度一致，只显示一个值。
- %GC：所有序列所有碱基的 %GC。

#### 每个碱基的测序质量

![](../image/fastqc_image/per_base_sequence_content.png)
1. Summary
展示 FastQ 文件每个位置每个碱基的质量范围。箱线图
- 中间的红线是中位数
- 蓝线是平均数

y 轴代表质量分数，前景分为不同的颜色：
- 绿色：非常好
- 橘色：合格
- 红色：很差。
一般测序的质量会随测序长度逐渐降低。

2. Warning
碱基下四分位数小于 10，或者中位数小于 25.

3. Failure

碱基下四分位数质量小于 5，或者中位数小于 20.

4. 揭示 warnings 的常见原因

最常见的原因是随测序的进行，质量逐渐下降。
通常可以通过软件剪掉一部分碱基。
没有去接头。
另一个原因有可能是因为测序过程中，run 短暂的出现问题，可以通过比较每个 tile 的质量图查看错误类型。可以考虑先 amsking 碱基，再比对。
如果 read 长度不一，可能会报错，因为某个碱基的覆盖度可能很低，下一步分析前，你需要查看哪些序列出了问题。

### Per Sequence Quality Scores

![](../image/fastqc_image/per_sequence_quality.png)

1. Summary
每条 read 的质量分数。通常由于测序机器原因，总有部分 reads 质量不好，但应该只占一小部分。
如果一个 run 中的测序结果有明显的一部分质量较低，可能是系统原因，可能是某个 flowcell 的问题。

y 轴：reads 数
x 轴：质量

2. Warning

平均值小于 27（=0.2% 错误率）

3. Failure

均值小于 20（=1% 错误率）

4. 常见原因

This module is generally fairly robust and errors here usually indicate a general loss of quality within a run. For long runs this may be alleviated through quality trimming. If a bi-modal, or complex distribution is seen then the results should be evaluated in concert with the per-tile qualities (if available) since this might indicate the reason for the loss in quality of a subset of sequences.

### Per Base Sequence Content

![](../image/fastqc_image/per_base_sequence_content.pn)

1. Summary

reads 的每个位置的每种碱基比例。
y 轴：百分比
x 轴：read 位置

在随机库中，理想结果为 4 各碱基比率相同（25%），为一条直线。
值得注意的是，一些类型的库碱基比例会出现偏差，通常是在 read 的开始位置。这是由于系统原因造成的，包括 RNA-seq。虽然这是一个技术偏差，而且也不会对下游分析造成影响，但是，本模块还是会给出警告。

2. Warnning

任何位置 A 和 T，或者 G 和 C 的差异大于 10%

3. Failure

任何位置 A 和 T，或者 G 和 C 的差异大小 20%

4. 常见原因

有以下几个常见原因：
1> Overrepresented sequences：如接头或者 rRNA
2> Biased fragmentation：由于系统的随机选择偏差，导致每个 run 的前 12bp 可能有偏差。
3> Biased composition libraries: 一些库的组成有偏差，比如经过了亚硫酸钠处理等，虽然对这个库很正常，但是模块会给出警告。
4> 如果库已过了去接头处理，可能会引起虚假的偏差，因为已经比对需要的接头已经去除了。

### Per Sequence GC 含量
![](../image/fastqc_image/per_sequence_gc_content.png )

1. Summary
每条 read 的 GC 含量分布与正常分布的比较
y 轴：read 数
x 轴：GC%

2. Warning

15% reads 有偏差

3. Failure

30% 的 reads 有偏差。

4. 常见原因

由于污染或者系统误差造成。

### Per Base N Content

![](../image/fastqc_image/per_base_n_content.png)

1. Summary

如果不能识别某位置是什么碱基，会标为 N
该模块统计每个位置 N 的比例
y 轴：位置
x 轴：N 比例
正常情况下为一条直线，可能在末端有时会有突起。

2. Warning

> 5%

3. Failure

> 20%

4. 常见原因

一个最可能的原因是某个位置的覆盖度比较低。
在测序质量很好的背景下有少部分位置发生高的 N 含量，可能是因为序列的组成有偏差，可以在 per-base-sequence-content 结果中查看。

### Sequence Length Distribution
![../image/fastqc_image/sequence_length_distribution.png]
1. Summary
x 轴：reads 长度
y 轴：reads 数

2. Warning
长度不一
3. Failure
有长度为 0 
4. 常见原因
有些平台的 reads 长度就量不一样，不用管它。

### Duplicate Sequences
1[](../image/fastqc_image/duplication_levels.png)

1. Summary
一个低的 duplication 表明覆盖度较高，但是过高的 duplication 表明有富集偏差（如，PCR 过量扩增）。
y 轴：duplicated reads 数
x 轴：duplication 次数
无重复 reads 数为 100%
为了减少内存占用，仅对前100,000条不重复序列进行统计。
为了简化结果形式，对于多于10次重复的序列会人为地将其重复次数设定为10，因此结果图像上曲线会显示一个小的翘尾。
对于>75bp的序列，将其截短为前50bp进行统计，因相对而言长序列会包含较多测序错误而倾向于产生过多的统计重复。

2. Warning
非唯一序列大于 20%
3. Failure
非唯一序列大于 50%
4. 常见原因
一般有两个原因：技术重复（PCR 扩增）、生物重复（不同拷贝）

### Overrepresented Sequences

1. Summary
为了优化运算仅对前100,000条序列进行运算，将重复比例在所有序列中的占比>0.1%的结果进行列表输出，并且对其与常见的测序实验中使用的adapter等序列进行比对，比对时要求一致性长度>20p且无任何错配。

对于>75bp的序列，将其截短为前50bp进行比对
2. Warning
重复序列大于 0.1%
3. Failure
重复序列大于 1%
4. 常见原因

### Adapter Content

1. Summary

接头序列统计
2. Warning
任何序列出现在 5% 的 reads 中
3. Failure
任何序列出现在 10% 的 reads 中

### Kmer Content

1. Summary
overrepresented sequence 并不总是有效，例如：
1）如低质量的长 reads，由于随机的测序错误会降低过表达序列统计数
2）如果小片段序列在不同的位置出现也不会以被统计到

Kmer意为连指定长度为K的连续碱基
此部分的Kmer默认为连续7个碱基组成的一个单元，即任意一个碱基与其后相连的六个碱基构成了一个Kmer。
按read的位点逐一统计每一个位点的所有Kmer的情况，并在结果图中给出了前六个过表达的Kmer及其在read上的位点分布情况。
如果某k个bp的短序列在reads中大量出现，其频率高于统计期望的话，fastqc将其记为over-represente

2. Warninn

p < 0.01

3. Failure

P < 10^5

4. 常见原因

### Per Tile Sequence Quality
![](../image/fastqc_image/per_tile_quality.png )
1. Summary
该模块展示 Illumina 测序的每个 flowcell tile 的结果，这样就可以直接看到是哪个 tile 的测序有问题。
冷色表示该 tile 的质量大于等于相应 run 的平均质量，热色系表示小于平均质量。总之，越蓝越好，越红越差。
y 轴：tile 编号
x 轴：read 位置

产生的问题可能是由于暂时性问题，如有气泡，或者长时间的问题，如 flowcell 的壁上有污迹。

2. Warning
Phred score 低于均值的有 2 个
3. Failure
Phred score 低于均值的有 5 个
4. 常见原因

