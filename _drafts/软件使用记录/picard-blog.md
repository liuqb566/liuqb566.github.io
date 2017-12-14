---
layout: post
title: "流程搭建之picard"
categories: blog
tags: picard
---

* content
{:toc}


Picard 是一个处理HTS数据和格式的命令工具集。


## picard 安装

系统：Ubuntu

版本：picard 2.14.1

依赖环境：java 1.8

```
wget https://github.com/broadinstitute/picard/releases/download/2.14.1/picard.jar

java -jar picard.jar
```

## [picard 使用](http://broadinstitute.github.io/picard/)

### 命令格式：
```
java jvm-args -jar picard.jar PicardToolName \
  OPTION1=value1 \
    OPTION2=value2
```

- jvm-args：java 的参数，例如Picard大多数命令被设计运行在2G的JVM下，所以可以通过`-Xmx2g`参数设定内存为2G。

- PicardToolName：指定运行的tool的名字。需要紧跟在 picard.jar后。

- Options：各种通用或者tools特异的参数。例如，`INPUT=my_data/input.bam`，需要注意的是文件需要包括其**路径**，无论是相对路径，还是绝对路径。

标准参数（通用）：
- --help：显示某个tool的特定参数
- --stdhelp：显示某个tool的特定参数，和所有通用参数
- --version
- MAX_RECORDS_IN_RAM(Integer)：设定对SAM排序时，写入内存的数据量，越大越耗内存，写入磁盘的次数越少，运行速度越快。默认值:500000
- REFERENCE_SEQUENCE(File)：参考序列。默认值：null

### tools简介

- AddCommentsToBam：不能对SAM格式使用
- AddOrReplaceReadGroups：增加或者替换BAM文件的read groups。如果用samtools生成的bam没有头文件可以使用这个命令。
- BaitDesigner
- BamToBfq
- BamIndexStats
- BedToIntervalList
- BuildBamIndex
- CalculateReadGroupChecksum

- CollectAlignmentSummaryMetrics: 统计比对质量
- CollectBaseDistributionByCycle
- CollectGcBiasMetrics: 统计GC含量
- CollectHiSeqXPfFailMetrics
- CollectHsMetrics
- CollectIlluminaBasecallingMetrics
- CollectIlluminaLaneMetrics
- CollectInsertSizeMetrics
- CollectJumpingLibraryMetrics
- CollectMultipleMetrics
- CollectOxoGMetrics
- CollectQualityYieldMetrics：统计reads过滤情况
- CollectRawWgsMetrics：统计碱基过滤、比对过滤、覆盖度等信息。
- CollectTargetedPcrMetrics
- CollectRnaSeqMetrics
- CollectRrbsMetrics
- CollectSequencingArtifactMetrics
- CollectVariantCallingMetrics
- CollectWgsMetrics
- CollectWgsMetricsWithNonZeroCoverage

- CompareMetrics
- CompareSAMs:比较'.sam'和'.bam'文件。
- ConvertSequencingArtifactToOxoG
- CreateSequenceDictionary
- DownsampleSam：随机提取SAM或BAM的一部分。
- ExtractIlluminaBarcodes
- EstimateLibraryComplexity：评估unique reads数量
- FastqToSam: 将Fastq格式转换为非比对的BAM or SAM 格式，即uBAM格式。譔格式包含read group信息
- FifoBuffer
- FindMendelianViolations

- CrosscheckFingerprints
- ClusterCrosscheckMetrics
- CheckFingerprint

- FilterSamReads： 从SAM or BAM 中抽提read
- FilterVcf：过滤vcf

- FixMateInformation：Verify mate-pair information between mates and fix if needed.
- GatherBamFiles
- GatherVcfs
- GenotypeConcordance

- VCF Output:
- IlluminaBasecallsToFastq: Generate FASTQ file(s) from Illumina basecall read data.
- IlluminaBasecallsToSam：Transforms raw Illumina sequencing data into an unmapped SAM or BAM file.
- CheckIlluminaDirectory
- CheckTerminatorBlock
- LiftOverIntervalList
- LiftoverVcf
- MakeSitesOnlyVcf：Reads a VCF/VCF.gz/BCF and removes all genotype information from it while retaining all site level information。

- MarkDuplicates：鉴别duplicate reads
- MarkDuplicatesWithMateCigar

- MeanQualityByCycle

- MergeSamFiles：Merges multiple SAM and/or BAM files into a single file. This tool is used for combining SAM and/or BAM files from different runs or read groups。
- MergeVcfs

- NormalizeFasta
- PositionBasedDownsampleSam
- ExtractSequences
- QualityScoreDistribution
- Note on base quality score options
- RenameSampleInVcf

- ReorderSam
- ReplaceSamHeader：替换SAM或者BAM文件的头文件。
- RevertSam
- RevertOriginalBaseQualitiesAndAddMateCigar
- SamFormatConverter：Convert a BAM file to a SAM file, or SAM to BAM
- SamToFastq

- ScatterIntervalsByNs
- SetNmMdAndUqTags

- SortSam：SAM or BAM排序
- SortVcf

- SplitSamByLibrary
- UmiAwareMarkDuplicatesWithMateCiga
- UpdateVcfSequenceDictionary
- VcfFormatConverter：Converts VCF to BCF or BCF to VCF

- MarkIlluminaAdapters

- SplitVcfs：Splits SNPs and INDELs into separate files.
- ValidateSamFile: 用于检验SAM格式文件，如SAM/BAM文件的格式是否正确，这在检查其它工具的生成文件时很有用，比对错误的比对、错误的flag值等。

- ViewSam

- VcfToIntervalList
