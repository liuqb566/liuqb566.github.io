---
layout: post
title: "流程搭建之 samtools 使用记录"
categories: blog
tags: samtools
---

* content
{:toc}


### 安装 samtools

系统： Ubuntu
samtools version：1.6
bcftools version：1.6
htslib version: 1.6

```
cd samtools-1.x    # and similarly for bcftools and htslib
./configure --prefix=/where/to/install
make
make install
```

### 简介

samtools 可以转换sam/bam格式，排序，合并，建索引，检索reads区域等。

支持管道符。

### samtools 使用之 view

用途：转换格式，及浏览文件信息

常用选项：

- -b：输出 BAM 格式
- -S：输入 SAM 格式，新版本可以自动识别格式
- -u：输出非压缩的BAM格式，在管道命令中比较有用，可以节省压缩/解压缩的时间
- -h：输出文件中包含头信息
- -H：仅输出头信息
- -o：输出文件的名字
- -@：压缩时可以使用多线程
- -f：仅输出指定flag的比对，可用flag的十六位整数表示，如：`0x` (i.e. /^0x[0-9A-F]+/) or in octal by beginning with `0` (i.e. /^0[0-7]+/).
- -F：过滤掉指定flag的比对

### samtools 使用之 flagstat

用途：根据flag信息，提取统计质控、比对情况信息

用法：`samtools flagstat [in.bam|in.sam|in.cram]`

结果：
```
5233992 + 0 in total (QC-passed reads + QC-failed reads)
0 + 0 secondary     多比对情况下，二次比对reads数（对于将哪一次比对判断为二次比对是随机的）
2460 + 0 supplementary    chimeric alignment 产生的非representative alignment，可以通过 samtools view -F 进行过滤
0 + 0 duplicates
5176304 + 0 mapped (98.90% : N/A) 总比对率
5231532 + 0 paired in sequencing  PE reads
2615766 + 0 read1
2615766 + 0 read2
4764008 + 0 properly paired (91.06% : N/A) 双端同时比对到一条sequence上，且间隔小于一定的阈值
5152854 + 0 with itself and mate mapped
20990 + 0 singletons (0.40% : N/A)          仅一端比对上的reads
164296 + 0 with mate mapped to a different chr    某个 reads 与其配对的reads比对到不同染色体上
56877 + 0 with mate mapped to a different chr (mapQ>=5)    比对质量>5。如果比对质量很好，有时也可以用
```
------------
2017-11-5
------------

### 多样本比对结果的整合重塑

脚本

```
#! /bin/python3
#python version:>3.0
# reshape alignmet state file from 'samtools flagstate' to read easily
# the last cmd line is 'for i in *bam;do echo $i >>SLAF_alignment_stat.txt;samtools-1.6 flagstat $i >>SLAF_alignment_stat.txt;done' and the result like:
#-----
#SRR3203168.bam
#5233992 + 0 in total (QC-passed reads + QC-failed reads)
#0 + 0 secondary
#2460 + 0 supplementary
#0 + 0 duplicates
#5176304 + 0 mapped (98.90% : N/A)
#5231532 + 0 paired in sequencing
#2615766 + 0 read1
#2615766 + 0 read2
#4764008 + 0 properly paired (91.06% : N/A)
#5152854 + 0 with itself and mate mapped
#20990 + 0 singletons (0.40% : N/A)
#164296 + 0 with mate mapped to a different chr
#56877 + 0 with mate mapped to a different chr (mapQ>=5)
#SRR3203174.bam
#-----
#This also is the input file for the scripts
#History
#2017-11-5 v1 gossie

import re
with open('SLAF_alignment_stat.txt','r') as stat_f:
     print("runs","total_reas","secondary","supplementary","duplicates","total_mapped","total_mapped_ratio","paired_reads","read1","read2","properly_mapped","properly_ratio","itself_and_mate_mapped","singletons_mapped","singletons_mapped_ratio","mapped_to_dif_chr","dif_chr_mapQ<5",sep='\t')
     for line in stat_f:
         line=line.strip()
         if line.endswith('bam'):
             runs=line[0:-4]
         elif 'total' in line:
             total_reads=re.split(r'[\s\+\(]',line)[0]
         elif 'secondary' in line:
             sec_reads=line.split()[0]
         elif 'supplementary' in line:
             sup_reads=line.split()[0]
         elif 'duplicates' in line:
             dup_reads=line.split()[0]
         elif 'mapped' in line and 'N/A' in line:
             mapped_reads=re.split(r'[\s\(]',line)[0]
             total_ratio=re.split(r'[\s\(]',line)[5]
         elif 'paired in sequencing' in line:
             paired_total=line.split()[0]
         elif 'read1' in line:
             read1=line.split()[0]
         elif 'read2' in line:
             read2=line.split()[0]
         elif 'properly' in line:
             pro_reads=re.split(r'[\s\(]',line)[0]
             pro_ratio=re.split(r'[\s\(]',line)[6]
         elif 'itself and mate' in line:
             itself_mate_reads=line.split()[0]
         elif 'singletons' in line:
             singletons_reads=line.split()[0]
             singletons_ratio=re.split(r'[\s\(]',line)[5]
         elif 'chr' in line and 'mapQ' not in line:
             map_dif_chr=line.split()[0]
         elif 'mapQ' in line:
             mapQ_dif_chr=line.split()[0]
             print(runs,total_reads,sec_reads,sup_reads,dup_reads,mapped_reads,total_ratio,paired_total,read1,read2,pro_reads,pro_ratio,itself_mate_reads,singletons_reads,singletons_ratio,map_dif_chr,mapQ_dif_chr,sep='\t')
```

