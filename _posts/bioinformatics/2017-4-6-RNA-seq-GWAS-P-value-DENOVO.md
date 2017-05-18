---
layout: post
title: "组学分析中的阈值问题"
date: 2017-4-6
categories: bioinformatics
tag: 阈值
---


1. 关键问题：如何正确估计误差方差的范围？
2. 预期数量是多少？符合什么分布？标准差是多少？
3. 多重检验矫正方法

- Bonferroni 法，最简单、严厉。-- Pvale
- FDR：比较宽松，将假/真阳性比例控制在一定范围。-- q value ，也叫 adjust p value
- P value：对一次检验负责，一次假阳性率
- Q value：对所有检验区别，假阳性所占比例
- p value --> Q value：BH 算法

FDR 的取值

- 常见 0.1%、1%、5%等
- 最宽松为 25%

eg. 接受 Q value = 0.24，对应原始 P = 0.08

- P value，对单次检测负责
对于该 pathway，假阳性的概率仍为 8%
- Q value，对所有检验负责
若接受该 pathway，以及比这个 pathway 阈值更低的所有 pathway（共 84 个），则所有 判断为阳性的 pathway 中有 20 个是错误的，但是我们知道到底哪个是错误的，当然 P 值越高，错误的概率越大。
PDR 计算：R 语言：P.adjsut
Storey：更精确估计的方法
