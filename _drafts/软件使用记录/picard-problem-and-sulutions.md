---
layout: post
title: "picard 使用中的问题"
categories: snp-calling
tags: picard
---

* content
{:toc}


### [常见问题](http://broadinstitute.github.io/picard/faq.html)
1. 排序的时候用时过长或者内存消耗太大怎么办？

  每个线程默认使用2G内存，可以用java -Xmx参数调节（例如，-Xmx2g），picard参数MAX_RECORDS_IN_RAM 可以设定写磁盘前，内存 records 数量。

  通常对SortSam命令来说，假设~100bp的reads，对`-Xmx`参数的每GB，设定`MAX_RECORDS_IN_RAM`为250,000reads

2. MarkDuplicates 命令工作原理？

  另立一节说明

3. MarkDuplicates 耗时过长，是有错误么？

  不一定。MarkDuplicates 非常耗内存。
  At Broad, we run MarkDuplicates with 2GB Java heap (java -Xmx2g) and 10GB hard memory limit. Some example run times:

  An 8.6GB file (63M records) took about 1 hours

  A 20GB file (133M records) took about 2.5 hours

  Increasing the amount of RAM allocated to MarkDuplicates (the -Xmx value) will improve the speed somewhat. Note that if you have a hard memory limit, this needs to be increased also. One workaround for large datasets involves marking duplicates for different libraries independently and subsequently merging the marked files.

4. MarkDuplicates 和 samtools rmdup 之间的区别是什么？

  最大的区别是 Samtools rmdup 不会剔除染色体间重复（interchromosomal duplicates）
  
  其次MarkDuplicates仅对重复数据做flag，不会直接剔除。

  据说，pair end 用MarkDuplicates更好。

5. picard SortSam 与 samtools sort 之间的区别

  Samtools sort 不会在头文件内标明这是排序过的文件，这就会使一些Picard tools认为文件没有被排序。在Picard tools（CollectAlignmentSummaryMetrics, MarkDuplicates, MergeSamFiles)有个`ASSUME_SORTED`参数，如果`ASSUME_SORTED=ture`，程序将会假设输入的SAM或BAM是提前排好序的。

  建议使用Picard的`SortSam`代替Samtools的sort进行排序。

  可以使用Picard的`ViewSam`查看header信息，编辑header信息，然后用`ReplaceSamHeader`创建新的BAM文件。`ReplaceSamHeader`的缺点是创建新的BAM文件，而不会在原文件上编辑。

  无论用哪种方法，都建议，在分析前，用`ValidateSamFile`检验BAM/SAM文件

6. Picard可以使用标准输入/输出么？

  可以。仔细看说明

7. SAM/BAM文件中，参考序列的长度有什么限制?
  
  一个BAM index 格式对单参考序列的限制为512MB

### 
