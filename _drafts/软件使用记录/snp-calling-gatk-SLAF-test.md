---
layout: post
title: "基于gatk的snp calling--SLAF数据-test"
categories: snp-calling
tags: gatk
---

* content
{:toc}


测序数据
```
SRR3203168.bam  SRR3203174.bam  SRR3203175.bam
```
数据来自SLAF的clean data，用bwa mem比对，无read group，非sorted。

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

```
java -jar ~/tools/program/picard.jar AddOrReplaceReadGroups I=./SRR3203175.bam O=SRR3203175_RG_sort.bam RGID=SRR3203175 RGLB=SRR3203175 RGPL=illumina RGPU=HAN4AADXX.2 RGSM=SRR3203175 SORT_ORDER=coordinate
#SORT_ORDER=coordinate 会先按染色体排序，再按位置（position）排序
```

加read groups后，头信息会多出一行`@RG     ID:SRR3203175   LB:SRR3203175   PL:illumina     SM:SRR3203175   PU:HAN4AADXX.2`，reads 中也添加`RG：Z`的flag。


#### Mark Duplicates

因为是SLAF-seq，所以不做这一步

试了一下，出错误了，以后再说吧

#### Recalibrate Bases

对机器造成的错误进行重新校正

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

