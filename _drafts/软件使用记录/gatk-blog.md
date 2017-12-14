---
layout: post
title: "流程搭建之 gatk"
categories: blog
tags: gatk
---

* content
{:toc}


## gatk安装

系统版本：ubuntu

gatk：3.8-0

依赖环境：java 1.8

### java 1.8 安装

1. 下载

用wget下载没有成功，所以用浏览器下载的，可能是下载前需要接受一个协议的原因

2. 安装

```
tar zxvf jdk-8u151-linux-x64.tar.gz

#添加环境变量
export JAVA_HOME=/usr/lib/jvm/jdk1.7.0_60  ## 这里要注意目录要换成自己解压的jdk 目录
export JRE_HOME=${JAVA_HOME}/jre  
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib  
export PATH=${JAVA_HOME}/bin:$PATH  

source .bashrc

java -version
```

### gatk 3.8 安装

```
tar jxvf GenomeAnalysisTK-3.8-0.tar.bz2 
```
解压可用

### gatk 使用

#### BaseRecalibrator

参考：[Base Quality Score Recalibration (BQSR)](https://software.broadinstitute.org/gatk/documentation/topic.php?name=methods-and-workflows)

Variant calling 算法非常依赖于read上每个碱基的质量得分。这些质量得分是机器错误的估计。但是，由于系统技术错误等的影响，导致机器产生的分数过高或者过低。Base quality score recalibration(BQSR)是一个修正这些质量得分的程序。

BQSR 有两个关键步骤：
1. 用数据和已知变异构建错误模型。
2. 基于错误模型进行碱基质量得分修正。

官方强烈建议要做，但是可选的步骤：包括再建模一次和对recalibration过程产生的效应进行可视化。这对QC过程很有用。

BQSR 可以进行协变量建模，并产生重新校正表。它仅对不在dbSNP中的位点进行操作（？），假设所有看到的所有reference mismatches是错误的，表明碱基质量很差。BQSR 根据用户指定的协变量（RG、reported quality score、cycle、context）产生一个表格。假设有很多数据，就可以根据每个位点给定的协变量计算先验概率。

BQSR包中的工具按测序时序列合成的顺序，对比对好的BAM文件进行重新打分。重新校准后，输出的BAM文件的每条read的QUAL区域的质量得分更加精准，更加接近它错配参考基因的真实概率。

命令：
```
java -jar GenomeAnalysisTK.jar \
   -T BaseRecalibrator \
   -R reference.fasta \
   -I my_reads.bam \
   -knownSites latest_dbsnp.vcf \
   -o recal_data.table
```
参数：

- -T

++++++++++
有人说这一步不用做了，因为现在测序质量提高了。再研究
+++++++++++



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

推荐使用bwa mem程序进行比对，比对的时候需要加`-R`参数，添加read group信息；之后，按**coordinate**顺序进行排序，建议使用picard进行排序，因为samtools的sort程序不会添加已排序的flag，而这是下游分析需要的。

1、 先用`picard ValidateSamFile`，检查有没有格式错误
```
 ls SRR32031*|while read id;do java -jar ~/tools/program/picard.jar ValidateSamFile I=${id} MODE=SUMMARY; done

out:
To get help, see http://broadinstitute.github.io/picard/index.html#GettingHelp
20:42:28.700 INFO  NativeLibraryLoader - Loading libgkl_compression.so from jar:file:/home/liuqibao/tools/program/picard.jar!/com/intel/gkl/native/libgkl_compression.so
[Wed Nov 15 20:42:28 CST 2017] ValidateSamFile INPUT=SRR3203174.bam MODE=SUMMARY    MAX_OUTPUT=100 IGNORE_WARNINGS=false VALIDATE_INDEX=true INDEX_VALIDATION_STRINGENCY=EXHAUSTIVE IS_BISULFITE_SEQUENCED=false MAX_OPEN_TEMP_FILES=8000 VERBOSITY=INFO QUIET=false VALIDATION_STRINGENCY=STRICT COMPRESSION_LEVEL=5 MAX_RECORDS_IN_RAM=500000 CREATE_INDEX=false CREATE_MD5_FILE=false GA4GH_CLIENT_SECRETS=client_secrets.json USE_JDK_DEFLATER=false USE_JDK_INFLATER=false
[Wed Nov 15 20:42:28 CST 2017] Executing as liuqibao@bio302-ubuntu on Linux 3.13.0-113-generic amd64; Java HotSpot(TM) 64-Bit Server VM 1.8.0_151-b12; Deflater: Intel; Inflater: Intel; Picard version: 2.14.1-SNAPSHOT


## HISTOGRAM    java.lang.String
Error Type      Count
ERROR:MISSING_READ_GROUP        1
WARNING:RECORD_MISSING_READ_GROUP       6222832
...
...
```
显示数据没有read group

也可以用picard ViewSam 或者samtools view -H 查看头信息，后者更快。

2、用picard的`AddOrReplaceReadGroups`添加read group信息,同时排序

```
java -jar ~/tools/program/picard.jar AddOrReplaceReadGroups I=./SRR3203175.bam O=SRR3203175_RG_sort.bam RGID=SRR3203175 RGLB=SRR3203175 RGPL=illumina RGPU=HAN4AADXX.2 RGSM=SRR3203175 SORT_ORDER=coordinate
#SORT_ORDER=coordinate 会先按染色体排序，再按位置（position）排序
```

加read groups后，头信息会多出一行`@RG     ID:SRR3203175   LB:SRR3203175   PL:illumina     SM:SRR3203175   PU:HAN4AADXX.2`，reads 中也添加`RG：Z`的flag。

排序后，头信息会多一行`@HD     VN:1.5  SO:coordinate`

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
head -n 3 NAU_replace.dict
@HD     VN:1.5
@SQ     SN:1    LN:99884700     M5:12e28e0311e760f4fcee0d72006a2ab3     UR:file:/home/liuqibao/workspace/database/Gossypium_hirsutum_v1.1_replace.fa
@SQ     SN:2    LN:83447906     M5:8c578a1af12657fa12427cf7f9048498     UR:file:/home/liuqibao/workspace/database/Gossypium_hirsutum_v1.1_replace.fa
```
2、构建`.fai`文件
```
nohup ~/tools/bin/samtools faidx ~/workspace/database/Gossypium_hirsutum_v1.1_replace.fa & #.fai 文件在参考基因组文件所在的文件夹下生成
mv Gossypium_hirsutum_v1.1_replace.fa.fai NAU_replace.fai
head -n 5 NAU_replace.fai

1       99884700        3       99884700        99884701
2       83447906        99884707        83447906        83447907
3       100263045       183332617       100263045       100263046
4       62913772        283595666       62913772        62913773
5       92047023        346509442       92047023        92047024
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

但是由于mapping和测序的人为错误，最大的难题是平衡敏感性（最大程度减少假阴性）vs 特异性（最大程序减少假阳性）。由于很难在一步中解决这个问题，所以分两步走：variant calling和variant filtering。第一步是为了最大化敏感性，第二步是为了进行一个可以自定义的特异性。

对**DNA**来说，为了进行群体比较，variant calling步骤又分为了两步（单样本calling，然后合并基因型）。这个工作包括在GVCF模式下，独立对每个样本运行Haplotypecaller，生产GVCF格式的中间文件，然后合并多个样本的GVCF，生产一个多样本VCF文件，就可以进行过滤了。

最终分析结果与传统的joint calling（群calling?)结果相同，但是它的规模更好同时解决了所谓的**N+1 曾是**。这同样适用于小群体甚至单样本。

最好的过滤变异集的方法是使用VQSR，它使用机器学习的方法对可能为真的变异进行鉴别注释分析。

这种复杂方法的缺点是，它需要一个大的变异集（callset）（最小30外显子，如果可能最好多于一个基因组）和一个可度可靠的known variants。

这让它很难应用在小实验、RNAseq 实验和non-mode物种（研究较少的生物？）中；对它们来说，通常必须手动进行hard filtering。

#### call variants

在过去，variant callers 有专有的工具进行SNPs或者Indels calling，或者一个工具可以作两个工作，但是要用不同的模型。

> The HaplotypeCaller is capable of calling SNPs and indels simultaneously via local de-novo assembly of haplotypes in an active region。

当程序发现有变异信号的区域的时候，程序会忽略存在的mapping信息，并完全重新组装这个区域。

这让HaplotypeCaller在传统工具难call的区域更精确，例如当包含相似的不同变异的时候。

这也让HaplotypeCaler比基于位置的callers在calling indels时更好。

HC 可以处理非二倍体，也可以处理混池数据。**注意**，譔算法不适于极端等位基因频率（相对于倍性），所以不建议用于somatic（癌症）变异检测。这个检测可以用MuTect代替。

#### [Call variants with HaplotypeCaller](https://software.broadinstitute.org/gatk/documentation/article?id=2803)

进行单样本分析

1、确定分析的基本参数

如果不自己设定参数，程序将会使用默认值。但是，建议还是自己设定，这样会更好的理解结果。

- Genotyping mode（`--genotyping_mode`)

  这个参数指定程序怎样确定用于genotyping的alternate alleles。在默认的`DISCOVERY`模式，“ the program will choose the most likely alleles out of those it sees in the data.”。在`GENOTYPE_GIVEN_ALLELES`模式，“, the program will only use the alleles passed in from a VCF file (using the -alleles argument).”。如果你仅对一个样本是否有你感兴趣的基因型并且不关心其它基因型，这个参数比较有用。

++++++++++++
- Emission confidence threshold（`-stand_emit_conf`）

> This is the minimum confidence threshold (phred-scaled) at which the program should emit sites that appear to be possibly variant.

  程序处理可能存在变异的位点的最小可信域值。
+++++++


- Calling confidence threshold（`-stand_call_conf`)

  > This is the minimum confidence threshold (phred-scaled) at which the program should emit variant sites as called. If a site's associated genotype has a confidence score lower than the calling threshold, the program will emit the site as filtered and will annotate it as LowQual. This threshold separates high confidence calls from low confidence calls。

  这是的术语“called”和“filtered”的含义与通常认为的含义不同。在GATK中，“called“表示位点通过了**可以进行**calling的可信域值的检验；而”filtered“，在GATK中，表示一个位点**没有**通过过滤检验（与通常认为的含义正好相反），也就是位点**被过滤掉了**。这意味着过滤工具会将从 callset 中**剔除**低可信度的 calls，而不是仅仅标记它。所以一定要结合相关的软件和背景来解释这两术语。


官网说从v3.7开始，这`-stand_emit_conf`参数不再使用了。因为之前的模型太烂，所以使用了新的模型计算质量得分（新人来了，推翻了旧人的理论）。同时,`-stand_call_conf`还在用，但是默认值也从 30 降到了10. 还增加了一个没看懂的`-newQual`，但是默认关闭，可能以后会默认开启。
2、Call variants your sequence data

CML：
```
java -jar GenomeAnalysisTK.jar \ 
    -T HaplotypeCaller \ 
    -R reference.fa \ 
    -I preprocessed_reads.bam \  
    -L 20 \ 
    --genotyping_mode DISCOVERY \ 
    -stand_emit_conf 10 \ 
    -stand_call_conf 30 \ 
    -o raw_variants.vcf 
```

- -L: 表明仅对数据的一个子集运行命令（这是是人类的20号染色体）。

HC 产生的结果对低可信度的calls比较宽松，必须用VASR或者hard-filtering再进行质控，才能得到高质量的calle set。
