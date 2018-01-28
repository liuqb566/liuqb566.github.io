---
layout: post
title: "基于gatk的snp calling--SLAF数据"
categories: snp-calling
tags: gatk
---

* content
{:toc}


++++++++++++++
项目开始时间：2017-11-22

执行人：Gossie

测序数据

技术：SLAF

平台：Illumina 2500

数据来自SLAF的clean data，用bwa mem比对，无read group，非sorted。
++++++++++++++++++

### PRE-PROCESSING

#### rawdata

##### QC

###### FastQC 查看rawdata质量

Number of Reads reads数目
Data Size 碱基数量
N of fq  reads中N碱基数目
N of fq  reads中N碱基数目
Q20 of fq  reads中质量值>=20的碱基所占的比例
Q30 of fq  reads中质量值>=30的碱基所占的比例
GC of fq reads的GC含量
Error of fq  reads的错误率
Discard Reads related to N and low qual N碱基和低质量的reads所占比例
Discard Reads related to Adapter  带接头的reads比例

##### 过滤低质量reads

1. 含有adaptor的reads: strimmomatic

2. 测序质量较低的碱基数占的比例过高的reads：strimmomatic、NGS QC Toolkit

3. 污染序列

4. N 的比例大于5%的reads

###### FastQC 查看cleandata质量

*因为拿到的cleandata所以没有进行质控*

#### Map to Reference

1、 先用`picard ValidateSamFile`，检查有没有格式错误
```
 ls SRR32031*|while read id;do java -jar ~/tools/program/picard.jar ValidateSamFile I=${id} MODE=SUMMARY; done
```

也可以用picard ViewSam 或者samtools view -H 查看头信息，后者更快。

2、用picard的`AddOrReplaceReadGroups`添加read group信息,同时排序

*最好比对的同时加上 RG*

脚本 picard_add_RG.sh:
```
#! /bin/bash
# 加表头，同时安按 coordinate 排序；ID、LB、PU、SM 都设为样本sra号
ls ~/workspace/snp-calling/samtools-space/NAU_unstored_bam/|while read id
do
sra=${id%%.*}
echo $sra
java -Xmx100g -jar ~/tools/program/picard.jar \
AddOrReplaceReadGroups \
I=../samtools-space/NAU_unstored_bam/$id \
O=${sra}_RG_sorted.bam \
SORT_ORDER=coordinate \
RGSM=$sra \
RGPU=$sra \
RGID=$sra \
RGLB=$sra \
RGPL=Illumina \
|| exit 0
done

```
由于耗时太长，遂改为`nohup java -Xmx2g ... &`,多进程并行运行。

简化测序（大约200M~300M），`-Xmx2g`参数，大约需要 80m

3、构建 bam 文件的索引

脚本`samtools-index.sh`:
```

#!/bin/bash

dic="/home/liuqibao/workspace/snp-calling/gatk-space"
bam_list="/home/liuqibao/workspace/snp-calling/gatk-space/bam_list.txt"
samtools="/home/liuqibao/tools/bin/samtools-1.6"

(cat $bam_list ||exit 0)|while read id
do
echo $dic'/'$id
nohup $samtools index ${dic}/${id} &
done
```

#### Mark Duplicates

因为是SLAF-seq，所以不做这一步

试了一下，出错误了，以后再说吧

#### Recalibrate Bases

对机器造成的错误进行重新校正

因为没有 dbSNP 所以没做

##### 构建reference

-R: GATK 需要一个index文件`.fai`和一个字典文件`.dict`作为reference genome

1、构建`.dict`文件：
```
java -jar ~/tools/program/picard.jar CreateSequenceDictionary R=~/workspace/database/Gossypium_hirsutum_v1.1_replace.fa O=NAU_replace.dict
```
2、构建`.fai`文件
```
nohup ~/tools/bin/samtools faidx ~/workspace/database/Gossypium_hirsutum_v1.1_replace.fa & #.fai 文件在参考基因组文件所在的文件夹下生成
mv Gossypium_hirsutum_v1.1_replace.fa.fai NAU_replace.fai
```
以前做过的话可以直接使用

##### Analyze patterns of covariation in the sequence dataset
```
java -jar GenomeAnalysisTK.jar \ 
    -T BaseRecalibrator \ 
    -R reference.fa \ 
    -I input_reads.bam \ 
    -L 20 \           #指定20号染色体
    -knownSites dbsnp.vcf \ 
    -knownSites gold_indels.vcf \ 
    -o recal_data.table 
```
参数：

-knownSites：已知变异位点。如果没有需要做多次迭代BQSR

（待补充）

### VARIANT DISCOVERY

经过前期的数据准备阶段，就可以进行SNP calling 了。

#### [Call variants with HaplotypeCaller](https://software.broadinstitute.org/gatk/documentation/article?id=2803)

尝试用 WDL 进行并行运算，但是发现对HC的并行似乎也仅是用多进程。

So，自己写脚本：
```

#!/bin/bash
#参考基因组文件夹下需要有 .dic 和 .fai 文件

gatk="/home/liuqibao/tools/program/GenomeAnalysisTK-3.8-0-ge9d806836/GenomeAnalysisTK.jar"
tmpdir="/home/liuqibao/workspace/snp-calling/gatk-space/tmp/"
refgenome="/home/liuqibao/workspace/database/Gossypium_hirsutum_v1.1_replace.fa"
bam_list="/home/liuqibao/workspace/snp-calling/gatk-space/bam_72_121.txt"
bam_dir="/home/liuqibao/workspace/snp-calling/gatk-space/bam_RG_sorted"

(cat $bam_list ||exit 0)|while read id
do
sample=${id%%.*} ||exit 0
echo $sample
nohup \
java -Djava.io.tmpdir=${tmpdir} -jar ${gatk} \
-T HaplotypeCaller \
-ERC GVCF \
-R ${refgenome} \
-I ${bam_dir}/${id} \
-o ${sample}_rawLikelihoods.g.vcf \
1>${sample}.gvcf.log 2>&1 \
&
done
```
要计算好内存和CPU的使用，对于简化测序的数据（ref：2.4G，BAM：200~300M）大约最多使用 10G 内存；HC 一般使用至少1个核，但是最高峰会多用一点。

由于服务器配制（80core，1TRAM），所以同时运行了70~80个文件。

**第一次错误终止**：第一次运行使用默认 `tmp/` 文件，结果报错无法写入 tmp 文件，有 60 多个程序终止运行，猜测可能是默认 tmp 文件磁盘太小

**第二次错误终止**：第二次运行使用参数 `-Djava.io.tmpdir=` 参数自定义 tmp 文件夹（所有 bam 文件产生的 schedule 都放在同一 tmp 文件夹下），结果仍然有39 个文件报错无法写入 tmp 文件夹。查看发现现有 22 个运行中的程序产生的 ~4,000,000 个 schedule 文件，可能在程序运行过程中不断产生大量的 schedule（估计 参考基困组 contigs 越多，schedule 越多）。猜测可能同一文件夹下 shcedule 太多，导致程序读取错误或者 I/O 等待时间太长。尝试将每个 bam 文件产生的 schedule 放在不同的文件夹。
```

#!/bin/bash

#注意都用绝对路径
#gatk：GenomeAnalysisTK.jar
#tmpdir：临时文件目录。
#regeneme：参考基因组文件。同文件夹下要有 .dic 和 .fai 文件
#bam_list：需要运行的 bam 文件列表，每行一个；注意计算好同时运行多少个，以免系统崩溃。bam 文件需要加RG，按cocordination排序，构建索引(格式：name.bam.bai)
#bam_dir：bam 文件和其索引文件的文件夹

Realse:
	V1: 使用默认参数
	V2: 指定临时目录，尝试修复 tmp 目录无法写入问题。
	V3: 指定临时目录，为每个程序建立独立临时存储目录。修复 tmp 目录无法写入问题。

#####################################
#2017-11-28	V3	Gossie      #
####################################

gatk="/home/liuqibao/tools/program/GenomeAnalysisTK-3.8-0-ge9d806836/GenomeAnalysisTK.jar"
tmpdir="/home/liuqibao/workspace/snp-calling/gatk-space/tmp/"
refgenome="/home/liuqibao/workspace/database/Gossypium_hirsutum_v1.1_replace.fa"
bam_list="/home/liuqibao/workspace/snp-calling/gatk-space/bam_162_201.txt"
bam_dir="/home/liuqibao/workspace/snp-calling/gatk-space/bam_RG_sorted"

(cat $bam_list ||exit 0)|while read id
do
sample=${id%%.*} ||exit 0
echo $sample

mkdir ${tmpdir}/${sample} ||exit 0
nohup \
java -Djava.io.tmpdir=${tmpdir}/${sample} -jar ${gatk} \
-T HaplotypeCaller \
-ERC GVCF \
-R ${refgenome} \
-I ${bam_dir}/${id} \
-o ${sample}_rawLikelihoods.g.vcf \
1>${sample}.gvcf.log 2>&1 \
&& rm -r ${tmpdir}/${sample} \
&
done
```
参数可以指定其他代替字符，如例子中的[] 结果没有再出现类似错误。

............一个多星期之后所有的样本终于跑完了.................

#### 合并 gVCF 文件

如果有太多的样本，需要先将多个 g.vcf 文件合并成一个文件（~200个），有利于下步的运行

经实验，多个gvcf文件同时合并非常慢（好几天），且很耗内存。

所以，最终决定先将 2 个 gvcf 文件合并成一个，并使用 -Xmx 参数控制内存。(每个进程分配 5g 内存)

**注意**: CombineGVCFs 可以接受压缩后的 gvcf 文件，但是必须使用 bgzip 压缩，用 tabix 作索引
```
bgzip test.g.vcf
tabix -p vcf test.g.vcf.gz
```
................4 天后第一次合并完成......................
太太太太太慢了，公司不可能如此耗费资源。它们肯定过滤了一些很小的 scaffolds，可能只保留了 >1Kb 的 scaffolds

Sun Dec 24 19:14:37 CST 2017 开始第二轮合并，仍然每两个 gvcf 文件合并在一起，每个进程分配 10g 内存。

Tue Dec 26 21:59:42 CST 2017 第二轮合并结束。用时 2 天

Sun Jan 28 08:27:26 CST 2018 经过三轮合并，call snp 时间仍太长，一个位点 4~5 天。不现实，决定过滤过小的 scaffold 重新做，可以尝试 gatk4
