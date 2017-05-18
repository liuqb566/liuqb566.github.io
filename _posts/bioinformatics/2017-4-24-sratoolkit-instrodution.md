---
layout: post
title: "sratoolkit 工具的简单使用"
date: 2017-4-24
categories: bioinformatics
tag: 使用手册
---


sratoolkit 是 NCBI 的一个工具包，它包含很多数据格式转换的功能：
- Frequently Used Tools:
fastq-dump: Convert SRA data into fastq format

prefetch: Allows command-line downloading of SRA, dbGaP, and ADSP data

sam-dump: Convert SRA data to sam format

sra-pileup: Generate pileup statistics on aligned SRA data

vdb-config: Display and modify VDB configuration information

vdb-decrypt: Decrypt non-SRA dbGaP data ("phenotype data")

- Additional Tools:
abi-dump: Convert SRA data into ABI format (csfasta / qual)

illumina-dump: Convert SRA data into Illumina native formats (qseq, etc.)

sff-dump: Convert SRA data to sff format

sra-stat: Generate statistics about SRA data (quality distribution, etc.)

vdb-dump: Output the native VDB format of SRA data.

vdb-encrypt: Encrypt non-SRA dbGaP data ("phenotype data")

vdb-validate: Validate the integrity of downloaded SRA data

但是我常用的只有 fastq-dump 功能，就量将 sra 格式的压缩数据转换为 fastq 格式，我想大部分人也只用这个功能（都是被 NCBI 逼的！！）

### 1. 安装
sratools 的安装很简单，直接下载适合你版本的包，解压可用，不用编译，为了方便也可以放到环境变量下
我的系统是 Ubuntu，所以：
```
wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.8.2-1/sratoolkit.2.8.2-1-ubuntu64.tar.gz
tar zxvf sratoolkit.*
```
所有的工具都在 sratoolkit 的 /bin 目录下

### 2. fastq-dump 的使用

```
fastq-dump [options] <path/file> [<path/file> ...]
fastq-dump [options] <accession>
```
使用比较简单，需要注意的是对于单端测序和双端测序，软件给了不同的参数。

--split-file：将文件分为两个部分，后缀为相应数字。
--split-3: 将文件分为三个部分，'*_1.fastaq' 和 ’*_2.fastq‘ 对双端测序数据是必有的，如果有未配对的数据，会放在 ’*。fastq‘ 文件中。

所以，我的理解是，测序质量较好的话，对于双端测序，这两个参数产生的结果一样，‘--split-3’ 没有产生未配对文件。
在 biostar 上也有一些解释：
--split-3 will output 1,2, or 3 files: 1 file means the data is not paired. 2 files means paired data with no low quality reads or reads shorter than 20bp. 3 files means paired data, but asymmetric quality or trimming.  in the case of 3 file output, most people ignore <file>.fastq . this is a very old formatting option introduced for phase1 of 1000genomes.  before there were many analysis or trimming utilities and SRA submissions  always contained all reads from sequencer. back then nobody wanted to throw anything away. you might want to use --split-files instead. that will give only 2 files for paired-end data. or not bother with text output and access the data directly using sra ngs apis.
