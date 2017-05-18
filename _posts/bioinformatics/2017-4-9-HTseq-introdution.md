---
layout: post
title: "HTseq 简单使用"
date: 2017-4-9
categories: bioinformatics
tag: 使用手册
---

* content
{:toc}


HTseq 是进行基因 count 表达量分析的软件，可以根据来自多种比对软件的 SAM/BAM 比对结果文件和基因结构注释 GTF 文件计算基因水平的 Counts 表达量
HTseq 安装需要 python2.7 以上，还需要几个 python 包，也建议用 pip 安装。
注意：
1. 若安装自己目录，运行：`python setup.py install --user
2. 自动生成的 htseq 在 `~/.local/bin` 中

```
htseq-count [options] input.sam/bam genome.gtf > counts_out.txt
```
options:
-f：输入文件的格式，SAM/BAM；默认 sam。
-r：输入文件的排序方式，name/pos；默认 name。（需要用 samtools 对输入文件排序）
-s：设置是否是链特异性的，yes/no；默认 yes。（反人类的选项，一般情况是 no）
-a：忽略比对质量低于此值的比对结果；默认 10
-t：对指定的 feature（gtf/gff 第三列）进行表达量计算，而且忽略其它 ffeature；默认 exon
-i：设置 feature ID，由 gtf/gff 文件第 9 列标签决定，一般 gtf 为 gene_id, gff 为 ID；默认 gene_id
-m：表达量计算模式，三种，一般真核生物用 union，详细请看说明书；默认 union
-o：输出 sam 文件

注意事项：
1. 输入文件必须有 sam/bam 比对结果和 gtf/gff 参考基因
2. gtf/gff 文件不能包含可变剪接信息，否则 HTSeq 会认为每个可变剪接都是单独的基因，导致计算结果为 ambiguous，对基因的 count 计算错误。


