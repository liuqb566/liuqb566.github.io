---
layout: post
title: “基于gatk的snp-calling流程中遇到的问题”
categories: snp-calling
tags: [gatk, snp-calling]
---

* content
{:toc}


### 关于deduplicate问题

在得到rawdata之后，一般都会用FastQC软件查看测序数据质量。在FastQC的检验指标中有一项duplicate sequence检验，在重测序的数据中，过多的duplicate sequence会降低数据质量，使下游分析结果的可靠性降低（eg. 影响snp位点频率等），所以，一般在snp-calling之前，很多软件都要求进行dedup步骤（eg. gatk的Best Pracices）。那么，是否所有的数据（eg. WGS、WES、RNAseq、CHIPseq、SLAFseq等）都需要dedup呢？

1、简化测序（GBS、RAD、SLAF等）的数据需要dedup么？
  
  **不需要**

  原因：

  1）简化测序的本质都是用酶切处理DNA样品，而不是像重测序一样用超声波打断，由于相同的限制性酶切位点，就会导致fragment起始和结束位置有很高的重复性。

  2）FastQC分析的是未比对到参考基因组的数据，检验duplicate的方法比较简单，仅分析每个文件的前100,000序列，而且，对于>75bp的reads只分析前50bp。

  这两个原因就造成FastQC在分析简化测序数据时，有很高的duplicate sequence。同时增加了区分echnical 和 biological duplicates的难度。

  FastQC[原文](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/3%20Analysis%20Modules/8%20Duplicate%20Sequences.html)：

     if you have a library where the sequence start points are constrained (a library constructed around restriction sites for example, or an unfragmented small RNA library) then the constrained start sites will generate huge dupliction levels which should not be treated as a problem, nor removed by deduplication. In these types of library you should consider using a system such as random barcoding to allow the distinction of technical and biological duplicates.

  所以对简化测序数据进行snp-calling时，*不进行dedup步骤*（eg. Picard 的MarkDuplicates）

参考：[gatk](https://gatkforums.broadinstitute.org/gatk/discussion/7685/gbs-data-and-duplicates-marking)

2、RNA-seq数据需要dedup么？

至少通过gatk无法分辨是over-lappling还是technial造成的duplicate。

gatk[原文](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/3%20Analysis%20Modules/8%20Duplicate%20Sequences.html):

  In RNA-Seq libraries sequences from different transcripts will be present at wildly different levels in the starting population. In order to be able to observe lowly expressed transcripts it is therefore common to greatly over-sequence high expressed transcripts, and this will potentially create large set of duplicates. This will result in high overall duplication in this test, and will often produce peaks in the higher duplication bins. This duplication will come from physically connected regions, and an examination of the distribution of duplicates in a specific genomic region will allow the distinction between over-sequencing and general technical duplication, but these distinctions are not possible from raw fastq files. 

3、 CHIP-seq 需要dedup么？

  同RNA-seq

4、WES需要dedup么？

### 关于bam文件问题

1、没有read group信息

  1）什么是read group？
    
    read group并没有一个明确的定义，但是应用中，一个read group指来自一个测序仪的一个lane产生的所有reads集。简单的说，一个生物样本的一个库，在一个flowcell的一条lane上测序，来自这个lane上的所有reads，就是一个read group。似乎它的关键就是一条lane上产生的所有reads就是一个group。

  2) read group 的作用？

    picard 和 gatk 的一些命令中会用到。

  3) 如何添加read group

    最好的办法是，在用bwa mem进行比对的时候，用`-R`参数添加read group。

    通过`samtools view -H sample.bam|grep '@RG'`查看有无read group信息

    如果比对的时候没有添加，之后，可以用picard的`AddOrReplaceReadGroups`进行添加

  4) read group 中tag的含义

    - ID=Read group identifire：决定每个read属于哪个read group，所以每个read group的ID是唯一的。在Illumina数据中，read group ID由fowcell+lane的名字和数字组成。在`BQSR`命令中：ID是区分技术批次效应（technical batch effects）的最基本的因素；因此，在数据处理中，例如 Base quality score recalibration，一个read group被认为是仪器的一个独立的run，所以假定他们有相同的error model. BaseRecalibrateor命令使用这个组分

    - PU=Platform Unit： PU由三部分组成{FLWCELL_BARCODE}.{LANE}.{SAMPLE_BARCODE}. 虽然GATK不需要PU变个组分，但是在Base recalibration中，如果PU这个组分存在，那么它的优先级高于ID。用于BaseRecalibrator命令，作为四个协变量中的一个，用于error model.
    
    - SM=Sample GATK：将有相同SM的所有read groups作为同一个样本的测序数据，这也是VCF文件中，sample column这一列的表头，它的作用是用来区分不同的样本。所以，SM设定正确至关重要。对于混池测序，要使用池的名字而不是每个样本的名字。
    - PL=Platform/technology used to prodeuce the read： 测序平台，可选值{ILLUMINA, SOLID, LS454, HELICOS, PACBIO}
    - LB=DNA prparation library identifier： 如果相同的DNA 库在多个lanes上测序，MarkDuplicates命令使用LB组分确定哪些read groups可能含有分子重复。仅MarkDuplicates使用这个组分。如果有两份相同的材料，取决你是的实验设计来使用相同或者不同的LB。一般如果来自同一个试管的库就设为相同的LB，反之，不同。

  5)建库方式方式引起的read group差异
  
    1）最简单的，一个样本一个库一个lane。
  
    2）mutipexing 方式
  
      （A）risk-spreading类型：多个样本混合在一起，在多个lanes中测序。一般大基因组、重测序用。可以避免某个lane的问题影响全部数据。
  
        假设有16个样本，每8个样本混在一起，分成2份，每份在1个lanes中测序。那么有（16x2=32个ID）、（16个SM）、（16个LB）、（4个PU）
  
        假设有16个样本，每个样本建了2个库，每8个样本混在一起，每个库在2个lanes中测序。那么有(16x2x2=64个ID）、（16个SM）、（16x2=32个LB）
  
      （B）cost-savingodga：多个样本混合成一个库在一个lane中测序。一般核酸浓度较小的简化测序、RNA-seq等会用。
        
        假设有16个样本，每8个样本混在一起，在1个lanes中测序。那么有（8x2x=16个ID）、（16个SM）、（16个LB）、
  
        貌似PU的设置比较随意，如果想将lanes间的差异作为协变量就精确到lanes水平，即{FLOWCELL}.[LANE]，例如A；如果想将样本间的差异作为协变量，即{FLOWCELL}.[LANE].[SAMPLE]，例如B。
  
  拿到数据最好先看一个fastq、sam/bam的表头信息

  参考：[Read groups](https://gatkforums.broadinstitute.org/gatk/discussion/6472/read-groups)、[illumina测序化学原理](http://www.cnblogs.com/think-and-do/p/6638157.html)

2、没有indexed、sorted
  
  - AddOrReplaceReadGroups：能同时添加readgroup、coordinate sort和index a BAM
  -SortSam: 能Coordinate sort、index
  - BuildBamIndex：Index一个coordinate-sortted BAM

### 关于non-diploid问题

通常，大多数GATK tools不关心倍性。但是，在variant calling时，程序需要知道样本是几倍体，以执行最适合的计算方法。

#### 倍性相关的功能

从3.3版本开始，HaplotypeCaller和GenotypeGVCFs都可以处理非二倍体生物（无论是单倍体还是异源多倍体）。

对于HaplotypeCaller，需要用`-ploidy`参数指定样本是**几倍体**。HC每次仅能处理一个ploidy，所以如果想处理不同ploidies的不同染色体，需要独立运行他们。好消息是，你可以在运行结束后合并结果。

-ERC GVCF workfow的CombineGVCFs和GenotypeGVCFs都可以处理多倍体。

#### ploidy需要注意的地方

> 1. Native variant calling in haploid or polyploid organisms.
> 2. Pooled calling where many pooled organisms share a single barcode and hence are treated as a single "sample".
> 3. Pooled validation/genotyping at known sites.

对于正常组织的倍性，仅正常设定`-ploidy`参数就可以。在混池测序的实验中，`-plidy`参数设定为每个barcoded样本的染色体数目。即，`(Ploidy per individual) * (Individuals in pool)`。

#### 重要的限制

一些变异注释不适用于多倍体。
>In particular, InbreedingCoeff will not be annotated on non-diploid calls. Annotations that do work and are supported in non-diploid use cases are the following: `QUAL`, `QD`, `SB`, `FS`, `AC`, `AF`, and Genotype annotations such as `PL`, `AD`, `GT`, etc.

要注意高倍体callingrqy基本准确度的限制。在**混池**或者**高倍体**中calling 稀有变异是困难的，因为稀有变异与测序错误几乎分辨不出来。

参考：[ Can I use GATK on non-diploid organisms?](https://software.broadinstitute.org/gatk/documentation/topic?name=faqs)

### Base recalibration 问题

#### [没有好的SNP database怎么办](https://software.broadinstitute.org/gatk/documentation/topic.php?name=methods-and-workflows)

BQSR将每个与参考基因组不匹配的都作为机器测序错误。真正的多态性造成的与参考基因不匹配是正确合理，所以不应该进行碱基质量计数。可以使用已知的多态性位点数据库（dbSNP），让程序跳过这些多态性位点的计数。如果没有dbSNP，那么这些多态性位点就会变的完全不可用，因为这些碱基的质量得分就远远低于它实际作为多态性位点应有的得分。那就很可能在过滤的时候将这些真实的多态性位点过滤掉。

如果不是自认为测序质量很低，或者物种中有非常多的SNP，就
如果没有dbSNP，可以自己bootstrap一个known SNP数据库：

- 先对所有的原始数据做一个不经过BQSR的的SNP calling
- 然后过滤出**最高**可信度的SNPs，将之作为known SNPs，进行BQSR
- 最后，做一个有BQSR的SNP calling。

第三步和第二步可以重复进行多次，直到**收敛**。

#### Bootstrap 问题

[一个例子](https://gatkforums.broadinstitute.org/gatk/discussion/8281/confused-about-bootstrapping-a-set-of-known-sites-for-base-recalibration#latest)

> SampleA.bam + SampleB.bam + HaplotypeCaller --> raw1.vcf
> raw1.vcf + VariantFiltration --> knownsites1.vcf
> knownsites1.vcf + SampleA.bam + SampleB.bam + BaseRecalibrator --> recalibration_table1
> recalibration_table1 + SampleA.bam + SampleB.bam + HaplotypeCaller (with -BQSR) --> raw2.vcf
> raw2.vcf + VariantFiltration --> knownsites2.vcf
> knownsites2.vcf + SampleA.bam + SampleB.bam + BaseRecalibrator --> recalibration_table2
> 
> At this point I could run AnalyzeCovariates on recalibration_table1 (before) and recalibration_table2 (after) and get an idea of how my data is behaving, right? If I don't see any convergence then I continue I follows:
> 
> recalibration_table2 + SampleA.bam + SampleB.bam + HaplotypeCaller (with -BQSR) --> raw3.vcf
> raw3.vcf + filtering --> knownsites3.vcf
> knownsites3.vcf + SampleA.bam + SampleB.bam + BaseRecalibrator --> recalibration_table3
> 
> I can then check this recalibration table with AnalyzeCovariates and see if it converged or not. If it converged I can follow the BaseRecalibration steps detailed in the Best Practices (using the last set of knownsites I generated). Am I understanding correctly?

**关键点**

1、不断的用新产生的‘known SNP’对*原始*bam文件进行校准
2、不断秩代，一直到到前一个校准效应与后一个校准效应差别不大，即收敛。
参考：[Recommended protocol for bootstrapping HaplotypeCaller and BaseRecalibrator outputs?](https://gatkforums.broadinstitute.org/firecloud/discussion/comment/28256#Comment_28256)


### 关于reference fasta 问题

参考：[(howto) Prepare a reference for use with BWA and GATK](https://gatkforums.broadinstitute.org/gatk/discussion/2798/howto-prepare-a-reference-for-use-with-bwa-and-gatk)

GATk 使用两个文件作为参考文件：

- `.dict`：一个含有contig的名字和大小的字典
- `.fai`：fasta的index文件

**注意**：Picard 和 smatools 处理contig 名字中*空格*的方法不同。建议避免在contig名字中使用空格。

#### 创建 .dict 文件

用picard的`CreateSequenceDictionary`创建`.dict`文件
```
java -jar ~/tools/program/picard.jar CreateSequenceDictionary R=~/workspace/database/Gossypium_hirsutum_v1.1_replace.fa O=NAU_replace.dict
 head -n 3 NAU_replace.dict 

 @HD     VN:1.5
 @SQ     SN:1    LN:99884700     M5:12e28e0311e760f4fcee0d72006a2ab3     UR:file:/home/liuqibao/workspace/database/Gossypium_hirsutum_v1.1_replace.fa
 @SQ     SN:2    LN:83447906     M5:8c578a1af12657fa12427cf7f9048498     UR:file:/home/liuqibao/workspace/database/Gossypium_hirsutum_v1.1_replace.fa
```
#### 创建index文件（`.fai`）

用samtools的`faidx`命令创建fasta index文件
```
nohup ~/tools/bin/samtools faidx ~/workspace/database/Gossypium_hirsutum_v1.1_replace.fa & #.fai生成在参考基因组文件夹下
 head -n 5 NAU_replace.fai 

 1       99884700        3       99884700        99884701
 2       83447906        99884707        83447906        83447907
 3       100263045       183332617       100263045       100263046
 4       62913772        283595666       62913772        62913773
 5       92047023        346509442       92047023        92047024
```
**注意**:`.dict`、`.fai`文件需要跟`.fa`文件在同一文件夹下

### [Apply hard filters to a call set](https://gatkforums.broadinstitute.org/gatk/discussion/2806/howto-apply-hard-filters-to-a-call-set)

(待补充)

### [怎样使用`-L`参数](https://software.broadinstitute.org/gatk/documentation/article.php?id=4133)

`-L`（`--intervals`）参数，允许你限定在特定区域进行分析，而不是全基因组水平。

`-L`的作用：
  - whole genome analysis：不需要intervals，但是可以让分析速度更快。
  - whole exome analysis：需要提供capture targets的列表（例如genes/exons)。
  - Small targeted experiment：必须提供targeted intervals
  - Troubleshooting：可以用一个特定的区间检验参数，或者创建一个data snippet。

重要提示：

  无论你最终用`-L`参数作什么，都需要记住：对一个输出bam或者VCF文件的工具来说，输出文件仅包含`-L`参数指定的区域。更确切的说，不建议对输出bam文件的工具使用`-L`参数，因为这样做会忽略输出文件中的一些数据。

例子：

  （见原文）

### Bug

1、Log4j2 问题

v3.8 存在bug，估计快出v4 了，所以 GATK team 也懒得管了

暂时通过添加`-jdk_deflater`和 `-jdk_inflater` 来解决

### 并行机制

(https://software.broadinstitute.org/gatk/documentation/article.php?id=1988)

有两种主要的并行机制：

#### 1、Multi-threading options

GATK 中的多线程有两个控制参数`-nt`和`nct`，可以联合使用这些参数，因为它们在不同的计算级别上起作用：

- -nt/--num_threads：控制发送给处理器的**data threads**的数量（**machine**水平）
- -nct/--num_cpu_threads_per_data_thread：控制分配给每个**data threads**的**CPU threads**的数量（**core**水平）

例如，`-nt 4 -ntc 8` 表示使用 4 个 data threads，每个 data threads 使用 8 个核（core），共使用了 32 个核。

由于分析的本质和怎样处理数据，所以并不是所有 GATK 工具都能使用这些参数。即使在一个多少步骤的流程里面，每个工具使用的参数也可能不一样。

##### multi-threading 中的内存

每个 **data thread** 需要给予正常情况下单次运行的所有内存。

所以，如果你运行一个正常需要 2Gb 内存的程序，如果你使用 `-nt 4`，那么多线程运行就需要 8Gb 的内存。

相反，CPU threads 会分享分配给它们的 "mother" data thread 的内存，所以你不必担心基于你使用的 CPU threads 的内存分配。

#### 2、Scatter-gather

1、Scatter-gather 与 multithreading 的区别？

multithreading 是将一个命令行中某个程序（program，例如GATk）的指令集在一个processor中运行（应该分享内存）；而 Scatter-gather 是分别独立运行不同的程序（program），然后收集结果。(似乎不分享内存)

#### 3、并行运算在主要 GATK 工具中的应用

不是所有的工具都支持并行模式。每种工具可用的并行模式部分取决于工具遍历数据的方式，还取决于执行的分析的性质。

[参考](https://software.broadinstitute.org/gatk/documentation/topic?name=faqs)

**注意**：理论上 HaplotypeCaller 支持 `-nct` 参数，但是有报告说它不是非常稳定（可能会崩溃，但是如果没有崩溃，产生的结果是没有问题的）。建议不要在 HC 中使用该选项；如果使用，后果自行负责。
|-----|----------|------------------|----|----|---|
|Tool |Full name |Type of traversal |NT  |NCT |SG|
|-----|----------|------------------|----|----|---|
|RTC |RealignerTargetCreator  |RodWalker |\+ |\- |\-|
|-----|----------|------------------|----|----|---|
|IR  |IndelRealigner  |ReadWalker  |\- |\- |\+|
|-----|----------|------------------|----|----|---|
|BR  |BaseRecalibrator  |LocusWalker |\- |\+ |\+|
|-----|----------|------------------|----|----|---|
|PR  |PrintReads  |ReadWalker  |\- |\+ |\-|
|-----|----------|------------------|----|----|---|
|RR  |ReduceReads |ReadWalker  |\- |\- |\+|
|-----|----------|------------------|----|----|---|
|HC  |HaplotypeCaller |ActiveRegionWalker  |\- |(\+) |\+|
|-----|----------|------------------|----|----|---|
|UG  |UnifiedGenotyper  |LocusWalker |\+ |\+ |\+|
|-----|----------|------------------|----|----|---|

NT：data multithreading；NCT：CPU multithreading；SG：scatter-gather；
#### 4、推荐参数

以下仅为 GATK 团队自己的经验设定，请根据自己的需要自行调整。

|------|---|----|----|-----|----|---|
|Tool  |RTC |IR  |BR  |PR  |RR  |HC  |UG|
|------|---|----|----|-----|----|---|
|Available modes |NT  |SG  |NCT,SG  |NCT |SG  |NCT,SG  |NT,NCT,SG|
|------|---|----|----|-----|----|---|
|Cluster nodes |1 |4 |4 |1 |4 |4 |4 / 4 / 4|
|------|---|----|----|-----|----|---|
|CPU threads (-nct)  |1 |1 |8 |4-8 |1 |4 |3 / 6 / 24|
|------|---|----|----|-----|----|---|
|Data threads (-nt)  |24  |1 |1 |1 |1 |1 8 / 4 / 1|
|------|---|----|----|-----|----|---|
|Memory (Gb) |48  |4 |4 |4 |4 |16  |32 / 16 / 4|
|------|---|----|----|-----|----|---|

### HC 运行机制

#### 1、参考基因组

参考基因组的 scaffolds 数目会严重影响 HC 的性能。GATK 设计的时候没有考虑处理大量 contigs 的问题（例如，多于几百的contigs）。

在 Gossypium_hirsutum_v1.1.fa（南农）版本基因组中，有 288273 个 scaffolds；实验结果表明，如果除去这些 scaffolds （仅用26条染色体，~1.3G），在默认参数下会节约 6~8 个小时。


当然这个完全除去不太可能，GATK team 建议将 [scaffolds 人为组成几个大的 contigs][1]，不过要注意不要太长，因为GATK不能处理 [512M][2] 以上的 contigs；另一种方法是**过滤**掉过短的 scaffolds，例如《Asymmetric subgenome selection and cis-regulatory divergence during cotton domestication》过滤掉了 小于 1000bp 的 scallolds.

[1]: https://gatkforums.broadinstitute.org/wdl/discussion/4774/snp-calling-using-pooled-rna-seq-data
[2]: https://gatkforums.broadinstitute.org/gatk/discussion/7504/more-512m-chromosome-problem-in-gatk

#### 2、遍历（traversal）

这里也比较费时间

#### 3、计算 active region

有一个 pairHMM 算法，可以提高速度。但是，需要处理器支持 AVX 指令集。

#### 样本太多，产生了太多的 gVCF 文件

进行群 calling（`GenotypeGVCFs`）时，最好 gVCF 文件的数量最好少于 200 个左右（当然也不是绝对，300 也可以，但是会消耗大量内存）；如果 gVCF 文件太多，在以用`CombineGVCFs`命令将适量 gVCF 合并成一个。

CombineGVCFs 无法使用多线程运行，一个缩短运行时间的方法是用 `-L` 参数分别对染色体进行合并。也可以使用 bzip 等进行压缩，以减少空间占用.

**注意**：gVCF 文件的列表文件名称后缀**必须**是**.list**

实验脚本：combinegvcfs.sh

#### 用 GenotypeGVCFs 进行 calling

如果样本量不多（小于300）可以直接进行 SNP calling。

`GenotypeGVCFs` 程序可以用 `-nt` 参数并行运算，但是会消耗更多内存，要合理安排。

脚本：GenotypeGVCFs.sh

### Apply hard filters to a call set

VQSR 更好，hard-filtering 较差。但是 VQSR 需要有大量的变异和已知的正确的变异位点（known snp）进行机器学习。没办法，变异较少或者非模式物种还是用 hard-filtering 吧。比没有强。。。

过滤参数的选择比较困难。gatk team 给了一些参考，但是还需要结合自己的实际情况。

有时间再画图比较。

对没有 known SNP 的文件进行 hard filter

参考：

[Understanding and adapting the generic hard-filtering recommendations](https://gatkforums.broadinstitute.org/gatk/discussion/6925/understanding-and-adapting-the-generic-hard-filtering-recommendations)

[I am unable to use VQSR (recalibration) to filter variants](https://gatkforums.broadinstitute.org/gatk/discussion/3225/i-am-unable-to-use-vqsr-recalibration-to-filter-variants)

[(howto) Apply hard filters to a call set](https://gatkforums.broadinstitute.org/gatk/discussion/2806/howto-apply-hard-filters-to-a-call-set/p1)
