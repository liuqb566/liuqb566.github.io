---
layout: post
title: "从 NCBI 或者 EBI 下载数据"
categorites: bioinformatices
tag: 数据上传下载
---

* content
{:toc}


### 1. 用迅雷下载（慢）

不会迅雷的请百度

### 2. 用 wget 下载（慢）

1. NCBI
在 NCBI 中双端测序和单端测序都是一个压缩的 ’.sra' 文件
```
for i in $(cat list.txt);do wget ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/`echo $i | cut -c 1-6`/$i/$i.sra;done
```
2. EBI

EBI 的目录结构比较特别，注意匹配
EBI 的双端测序是两个 ‘.gzipp’ 文件
```
for i in $(cat list.txt);do wget ftp://fasp.sra.ebi.ac.uk:/vol1/fastq/`echo $i | cut -c 1-6`/00`echo $i|cut -c 10`/$i/* ;done
```

### 3. 用 aspera 下载（推荐）

aspera 的下载速度非常快，能达到几十上百兆/秒

Aspera的用法：
ascp [参数] 目标文件 目的地址

Aspera的常用参数：
-T
不进行加密。若不添加此参数，可能会下载不了。
-i string
输入私钥，安装 aspera 后有在目录 ~/.aspera/connect/etc/ 下有几个私钥，使用 linux 服务器的时候一般使用 asperaweb_id_dsa.openssh 文件作为私钥。
--host=string
ftp的host名，NCBI的为ftp-private.ncbi.nlm.nih.gov；EBI的为fasp.sra.ebi.ac.uk。
--user=string
用户名，NCBI的为anonftp，EBI的为era-fasp。
--mode=string
选择模式，上传为 send，下载为 recv。
-l string
设置最大传输速度，比如设置为 200M 则表示最大传输速度为 200m/s。若不设置该参数，则一般可达到10m/s的速度，而设置了，传输速度可以更高。
-L /dir
生成报告
-K2
错误后重新启动

1. NCBI

```
~/ascp -QT -l 300m -i ~/asperaweb_id_dsa.openssh anonftp@ftp-private.ncbi.nlm.nih.gov:/sra/sra-instant/reads/ByRun/sra/SRR/SRR169/SRR169$i/SRR169$i.sra ./
```

2. EBI
```
~/ascp -QT -l 300m -i /home/liuqibao/asperaweb_id_dsa.openssh era-fasp@fasp.sra.ebi.ac.uk:/vol1/fastq/SRR158/005/SRR1580695/SRR1580695_1.fastq.gz ./
```
注意：可能需要加绝对路径，前面`~/`不能少，否则会报错：key passpares


# aspera 批量下载
批量下载：整理成下面的格式黏贴在文本SRR_Download_List_file_list.txt 中：

```
/sra/sra-instant/reads/ByRun/sra/SRR/SRR689/SRR689250/SRR689250.sra

/sra/sra-instant/reads/ByRun/sra/SRR/SRR893/SRR893046/SRR893046.sra

nohup ~/ascp  -i  ~/asperaweb_id_dsa.putty --mode recv --host ftp-private.ncbi.nlm.nih.gov --user anonftp   --file-list  SRR_Download_List_file_list.txt ./ &
```
### 4. prefech 下载

NCBI 的 sratoolkit 中的 prefech 也可以下载 sra， 不过我没用过。
