---
layout: post
title: "二代测序的数据格式"
categories: NGS
tag: 数据格式
---

* content
{:toc}


### [转][]二代测序数据辨（之一）：Clean Data
[1]: http://garification.blog.163.com/blog/static/1741330252014624114724457/

### 一、二代测序数据的4种表达法。

二代测序、个人全基因组测序高大上，既高端也复杂，操作流程复杂，检验结果也复杂，连检验结果的解读也复杂。别的不说，仅仅搞清楚二代测序数据本身，就不是一件简单的事。同一个样本进行同一次测序，出来的同一套数据，经过不同的加工，就形成了4种说法。它们之间的差别和关系，不是每一个人都能搞清楚的，有必要辨析一番。

1. 原始数据（Raw data）：一次测序产生的全部原始数据。理论上，它们应该是没有经过任何过滤的，无论好坏。

2. PF数据（PF data）：在测序过程中，Illumina内置软件根据每个测序片段（read，通常每个片段长100个碱基）前25个碱基的质量决定该read是保留还是抛弃。如果没有达到质控标准，则该read的全部碱基都被抛弃；达到标准、保留下来的数据叫做PF data。 PF代表pass filtering。

3. Q30数据（Q30 data）：Illumina内置软件根据统一设定的标准来评判碱基识别结果的可靠性，为每个碱基给予一个质量评分（QV）。PF data里质量评分>=30分的数据称为Q30 data。 Q30的意思是该碱基的可靠性为99.9%。Q30数据通常占PF数据的80%左右。视样本质量、操作水平、试剂质量、仪器状态的不同，这一比例有很大波动。

4. 干净数据（Clean data。数据还有不干净的？）：某些实验室根据其自身的判断标准，在PF data的基础上，进一步删除质量不好的reads后得到的数据。常见的删除动作有：去接头、去N含量高的reads、去质量评分低的reads、去掉每个read的最后几个碱基，等等。 



### 二、国际标准是什么？
Clean data是国内叫法；PF data是来自Illumina的概念，是广为接受的国际通行标准。

PF算法实质上是选取每个测序片段（read）前25个碱基的质量来代表整条片段的质量，从而决定该片段的去留。Illumina之所以这样做，而不是逐个检查整条片段所有碱基的质量，一方面是为了节省电脑资源，不致于花费太多时间进行运算，拖累测序进程，另一方面也是在大量测序数据的统计结果基础上选择的平衡点，只要前25个碱基是正常的，后75个碱基出问题的概率比较小。

一次测序实验完成，测序仪上展示的数据量和%Q30都是以PF数据为基础的。只要对数据质量有足够信心，就不会对PF数据再进行加工，可以直接把PF数据交给客户，进行下游的生物信息学分析。

### 三、为什么要clean data?

 如果二代测序实验成功，则PF data已经是质量比较好的数据，没有必要进一步加工。从基本原理来讲，任何形式的加工过滤，毫无例外都会引入额外的偏差(bias)，严重的时候会导致生物信息学分析结论失真。

 把PF数据加工成“干净数据”，原因有多种，其中常见的原因之一是使用山寨的试剂（非Illumina原厂正版试剂）构建文库，测序质量不尽如人意，Q30比例不高。在采用同种技术、同种平台的情况下，文库构建的质量是决定测序质量的关键。只要去掉质量差的数据，就可以提高Q30比例，可是这样做法目的性太强，难免让人心里打鼓。

 让我们来具体分析为了获得clean data所做的4种常见动作是否有必要，及其潜在副作用。

#### 1、去接头。

 使用正版试剂、按标准流程进行操作，接头序列是不会被测出来的，这是因为测序引物的结合位点位于接头的3'端，测序测到的第一个碱基就是插入片段的未知碱基，因此不需要去接头。

 在以下两种特殊情况下，需要去接头（adaptor），或者去标签（barcode）：

 一是自己合成寡核苷酸、自配文库构建试剂，这类设计通常把barcode安排在接头的3'端后面，而测序引物的结合位点仍然在接头的3'端，导致测序一开始测到的就是barcode序列，标签测完了之后才是插入片段的未知序列。在这种情况下，完成demultiplexing之后，标签序列完成了使命，就要把标签序列删除。

 二是文库的插入片段太短，测序片段长度（通常是100碱基）大于插入片段长度，导致插入片段被测通，一直测到下游接头的部分或者全部序列。在这种情况下，要删除下游的接头序列。

 插入片段太短，除了改变打断条件，增加插入片段长度以外，有些种类的样本比如small RNA本身就很短。小RNA的长度只有20几个碱基，测序试剂的包装是50碱基和100碱基两种，都长于小RNA；另外，如果小RNA样本数量少，凑不满一张FC，就要与其他样本一起测序，为了将就同一张FC上的其他样本，往往就对小RNA进行2x100碱基的测序。在这种情况下，去接头是必要的。

 去接头和去标签，对测序数据本身不造成影响。

#### 2、去含N多的测序片段。

 一个测序片段里如果有很多碱基无法识别（用N表示），提示测序质量不高，或者测序过程中遭遇到问题，需要严肃对待，通过故障排除找到根本原因，针对性地采取必要措施进行改正。删除这些片段，只是使数据看起来比较漂亮，治标不治本。

#### 3、去质量评分低的片段。

 PF算法本身去除的就是质量评分低的片段。如果要在PF之后再来一次“PF”，那就提示测序质量没有达到正常水准，实乃不得已而为之。

#### 4、去末端一定数目的碱基。

 随着测序读长的增加，酶活性下降，荧光强度也在下降，因此测序数据质量逐渐降低乃是自然趋势，片段末端的碱基质量低于片段前端的。

 即使存在这样的问题，只要样本质量、试剂质量、操作技能和仪器性能等有保障，在厂家承诺的片段长度范围内，%Q30是完全能够达到指标的，并不需要人为去掉末端碱基。