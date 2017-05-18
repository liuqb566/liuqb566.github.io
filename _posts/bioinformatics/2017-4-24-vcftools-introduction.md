---
layout: post
title: "## vcftools 的简单使用"
date: 2017-4-24
categories: bioinformatics
tag: 使用手册
---

* content
{:toc}


vcftools 是用于 VCF 和 BCF 格式的遗传变异数据的工具包。
它的功能主要有数据统计、运行数据计算、数据过滤、数据转换。

### 1. 安装
```
git clone https://github.com/vcftools/vcftools.git
cd vcftools
./autogen.sh
./configure
make
make install
```
如果是非 root 用户，可以使用：`./configure prefix='Your path'

### 2. 使用

```
vcftools [ --vcf FILE | --gzvcf FILE | --bcf FILE] [ --out OUTPUT PREFIX ] [ FILTERING OPTIONS ] [ OUTPUT OPTIONS ]
```
#### 2.1. 基本参数：
- 输入文件参数：
--vcf <输入文件>：输入文件可以是 VCF 格式 v4.0、v4.1 和 v4.2。’-‘ 用于标准输入
--gzvcf <输入文件>： 读入 gzipped 压缩文件
--bcf <输入文件>：读入 BCF2 文件。
- 输出文件参数：
--out <输出文件>：所有输出文件的文件名前缀。如果忽略，默认为 ’out.'
--stdout
-c：输出为标准输出
-temp <temp_文件>：将 vcftools 产生的所有临时文件输入到指定目录。

#### 2.2. 位点过滤参数：

- 位置过滤
--chr <chromosome> 
--not-chr <chromosome>

匹配或者不匹配某条染色体。可能多次使用该参数，以设定多条染色体。

--from-bp <integer> 
--to-bp <integer>

设定碱基的位置范围，仅与 `--chr` 结合使用。可以只使用一个。

--positions <filename> 
--exclude-positions <filename>

使用或者不使用文件中的某些位置的碱基。输入文件的每行用 `\t` 制表符分隔，允许加注释行，用 ‘#’ 开头。 

--positions-overlap <filename> 
--exclude-positions-overlap <filename>

排除或者不排除文件中与参考等位基因重叠的碱基。

--bed <filename> 
--exclude-bed <filename>


Include or exclude a set of sites on the basis of a BED file. Only the first three columns (chrom, chromStart and chromEnd) are required. The BED file is expected to have a header line. A site will be kept or excluded if any part of any allele (REF or ALT) at a site is within the range of one of the BED entries.

--thin <integer>

Thin sites so that no two sites are within the specified distance from one another.

--mask <filename> 
--invert-mask <filename> 
--mask-min <integer>

These options are used to specify a FASTA-like mask file to filter with. The mask file contains a sequence of integer digits (between 0 and 9) for each position on a chromosome that specify if a site at that position should be filtered or not. 
An example mask file would look like:
```
>1 
0000011111222... 
>2 
2222211111000...
```
In this example, sites in the VCF file located within the first 5 bases of the start of chromosome 1 would be kept, whereas sites at position 6 onwards would be filtered out. And sites after the 11th position on chromosome 2 would be filtered out as well. 
The "--invert-mask" option takes the same format mask file as the "--mask" option, however it inverts the mask file before filtering with it. 
And the "--mask-min" option specifies a threshold mask value between 0 and 9 to filter positions by. The default threshold is 0, meaning only sites with that value or lower will be kept.

- 位点过滤

--snp <string>

包含一个 SNP 位点，如 dbSNP 的 rsID。可以使用多次。

--snps <filename> 
--exclude <filename>

使用或者不使用文件中给出的 SNPs。文件包含一列 SNP IDs （如 dbSNP rsIDs），每行一个，不需要表头。

- 变异类型过滤
--keep-only-indels 
--remove-indels

使用或者不使用一个 indel。indel 表示任何与参考等位基因长度不同的变异。

- FILTER flag 过滤
--remove-filtered-all

根据 vcf 文件中的 FILTER flag 过滤，除了 PASS。

--keep-filtered <string> 
--remove-filtered <string>

使用或者不使用 FILTER flag 标记的所有位点。可以多次使用该参数。

- 根据 INFO 过滤

--keep-INFO <string> 
--remove-INFO <string>

- 根据 ALLELE 过虑

--maf <float> ：过滤大于等于该 MAF 的位点
--max-maf <float>：过滤小于等于该 MAF 的位点。

--non-ref-af <float> 
--max-non-ref-af <float> 
--non-ref-ac <integer> 
--max-non-ref-ac <integer>

--non-ref-af-any <float> 
--max-non-ref-af-any <float> 
--non-ref-ac-any <integer> 
--max-non-ref-ac-any <integer>

--mac <integer> ：过滤最小等位基因 count 数大于等位该参数的位点
--max-mac <integer>：过滤最小等位基因 count 数小于等于该参数的位点

--min-alleles <integer> 
--max-alleles <integer>

过滤等位基因数小于或者大于该参数的位点，可以结合使用，例如，`vcftools --vcf file1.vcf --min-alleles 2 --max-alleles 2` 过滤只有两个等位基因的位点。

- 根据基因型数值过滤

--min-meanDP <float> 
--max-meanDP <float>

根据测序深度过滤

--hwe <float>：哈迪-温伯格平衡

Assesses sites for Hardy-Weinberg Equilibrium using an exact test, as defined by Wigginton, Cutler and Abecasis (2005). Sites with a p-value below the threshold defined by this option are taken to be out of HWE, and therefore excluded.

--max-missing <float>：根据缺失数据比例过滤

Exclude sites on the basis of the proportion of missing data (defined to be between 0 and 1, where 0 allows sites that are completely missing and 1 indicates no missing data allowed).

--max-missing-count <integer> 

Exclude sites with more than this number of missing genotypes over all individuals.

--phased

Excludes all sites that contain unphased genotypes.

- 杂项过滤
--minQ <float>：根据 Quality 值过滤

#### 2.3. 样本过滤参数

--indv <string> 
--remove-indv <string>

使用或者不使用某样本，可以多次使用该参数。

--keep <filename> 
--remove <filename>

使用或者移除的文件中所列的本亲。样本 ID （与 VCF 表头相同）每个一行。如果同时使用两参数，`--keep` 先于 `--remove` 运行。如果使用了多个文件，先保留所有 ’--keep‘ 文件中的样本，再删除其中 ’--remove‘ 所有文件中的样本。

--max-indv <integer>: Randomly thins individuals so that only the specified number are retained.

#### 2.4. 基因型过滤参数

--remove-filtered-geno-all

Excludes all genotypes with a FILTER flag not equal to "." (a missing value) or PASS.

--remove-filtered-geno <string>

Excludes genotypes with a specific FILTER flag.

--minGQ <float>

Exclude all genotypes with a quality below the threshold specified. This option requires that the "GQ" FORMAT tag is specified for all sites.

--minDP <float> 
--maxDP <float>

Includes only genotypes greater than or equal to the "--minDP" value and less than or equal to the "--maxDP" value. This option requires that the "DP" FORMAT tag is specified for all sites.

#### 2.5. 输出参数
- 输出等位基因统计
-freq 
--freq2

输出带有后缀 ’.frq‘ 文件中的每个位点的等位基因频率。第二选项禁止所有关于等位基因信息的输出。

--counts 
--counts2

输出带有后缀 '.frq.count' 文件中的原始等位基因 counts 数。第二个选项禁止所有关于等位基因信息的输出。

--derived

For use with the previous four frequency and count options only. Re-orders the output file columns so that the ancestral allele appears first. This option relies on the ancestral allele being specified in the VCF file using the AA tag in the INFO field.

- 输出深度统计

--depth

Generates a file containing the mean depth per individual. This file has the suffix ".idepth".

--site-depth

Generates a file containing the depth per site summed across all individuals. This output file has the suffix ".ldepth".

--site-mean-depth

Generates a file containing the mean depth per site averaged across all individuals. This output file has the suffix ".ldepth.mean".

--geno-depth

Generates a (possibly very large) file containing the depth for each genotype in the VCF file. Missing entries are given the value -1. The file has the suffix ".gdepth".

- 输出 LD 统计

--hap-r2

Outputs a file reporting the r2, D, and D’ statistics using phased haplotypes. These are the traditional measures of LD often reported in the population genetics literature. The output file has the suffix ".hap.ld". This option assumes that the VCF input file has phased haplotypes.

--geno-r2

Calculates the squared correlation coefficient between genotypes encoded as 0, 1 and 2 to represent the number of non-reference alleles in each individual. This is the same as the LD measure reported by PLINK. The D and D’ statistics are only available for phased genotypes. The output file has the suffix ".geno.ld".

--geno-chisq

If your data contains sites with more than two alleles, then this option can be used to test for genotype independence via the chi-squared statistic. The output file has the suffix ".geno.chisq".

--hap-r2-positions <positions list file> 
--geno-r2-positions <positions list file>

Outputs a file reporting the r2 statistics of the sites contained in the provided file verses all other sites. The output files have the suffix ".list.hap.ld" or ".list.geno.ld", depending on which option is used.

--ld-window <integer>

This optional parameter defines the maximum number of SNPs between the SNPs being tested for LD in the "--hap-r2", "--geno-r2", and "--geno-chisq" functions.

--ld-window-bp <integer>

This optional parameter defines the maximum number of physical bases between the SNPs being tested for LD in the "--hap-r2", "--geno-r2", and "--geno-chisq" functions.

--ld-window-min <integer>

This optional parameter defines the minimum number of SNPs between the SNPs being tested for LD in the "--hap-r2", "--geno-r2", and "--geno-chisq" functions.

--ld-window-bp-min <integer>

This optional parameter defines the minimum number of physical bases between the SNPs being tested for LD in the "--hap-r2", "--geno-r2", and "--geno-chisq" functions.

--min-r2 <float>

This optional parameter sets a minimum value for r2, below which the LD statistic is not reported by the "--hap-r2", "--geno-r2", and "--geno-chisq" functions.

--interchrom-hap-r2 
--interchrom-geno-r2

Outputs a file reporting the r2 statistics for sites on different chromosomes. The output files have the suffix ".interchrom.hap.ld" or ".interchrom.geno.ld", depending on the option used.

- OUTPUT TRANSITION/TRANSVERSION STATISTICS

--TsTv <integer>

Calculates the Transition / Transversion ratio in bins of size defined by this option. Only uses bi-allelic SNPs. The resulting output file has the suffix ".TsTv".

--TsTv-summary

Calculates a simple summary of all Transitions and Transversions. The output file has the suffix ".TsTv.summary".

--TsTv-by-count

Calculates the Transition / Transversion ratio as a function of alternative allele count. Only uses bi-allelic SNPs. The resulting output file has the suffix ".TsTv.count".

--TsTv-by-qual

Calculates the Transition / Transversion ratio as a function of SNP quality threshold. Only uses bi-allelic SNPs. The resulting output file has the suffix ".TsTv.qual".

--FILTER-summary

Generates a summary of the number of SNPs and Ts/Tv ratio for each FILTER category. The output file has the suffix ".FILTER.summary".

- 输出核酸多态性统计

--site-pi

Measures nucleotide divergency on a per-site basis. The output file has the suffix ".sites.pi".

--window-pi <integer> 
--window-pi-step <integer>

Measures the nucleotide diversity in windows, with the number provided as the window size. The output file has the suffix ".windowed.pi". The latter is an optional argument used to specify the step size in between windows.

- 输出 FST 统计

--weir-fst-pop <filename>

This option is used to calculate an Fst estimate from Weir and Cockerham’s 1984 paper. This is the preferred calculation of Fst. The provided file must contain a list of individuals (one individual per line) from the VCF file that correspond to one population. This option can be used multiple times to calculate Fst for more than two populations. These files will also be included as "--keep" options. By default, calculations are done on a per-site basis. The output file has the suffix ".weir.fst".

--fst-window-size <integer> 
--fst-window-step <integer>

These options can be used with "--weir-fst-pop" to do the Fst calculations on a windowed basis instead of a per-site basis. These arguments specify the desired window size and the desired step size between windows.

- 输出其它统计

--het

Calculates a measure of heterozygosity on a per-individual basis. Specfically, the inbreeding coefficient, F, is estimated for each individual using a method of moments. The resulting file has the suffix ".het".

--hardy

Reports a p-value for each site from a Hardy-Weinberg Equilibrium test (as defined by Wigginton, Cutler and Abecasis (2005)). The resulting file (with suffix ".hwe") also contains the Observed numbers of Homozygotes and Heterozygotes and the corresponding Expected numbers under HWE.

--TajimaD <integer>

Outputs Tajima’s D statistic in bins with size of the specified number. The output file has the suffix ".Tajima.D".

--indv-freq-burden

This option calculates the number of variants within each individual of a specific frequency. The resulting file has the suffix ".ifreqburden".

--LROH

This option will identify and output Long Runs of Homozygosity. The output file has the suffix ".LROH". This function is experimental, and will use a lot of memory if applied to large datasets.

--relatedness

This option is used to calculate and output a relatedness statistic based on the method of Yang et al, Nature Genetics 2010 (doi:10.1038/ng.608). Specifically, calculate the unadjusted Ajk statistic. Expectation of Ajk is zero for individuals within a populations, and one for an individual with themselves. The output file has the suffix ".relatedness".

--relatedness2

This option is used to calculate and output a relatedness statistic based on the method of Manichaikul et al., BIOINFORMATICS 2010 (doi:10.1093/bioinformatics/btq559). The output file has the suffix ".relatedness2".

--site-quality

Generates a file containing the per-site SNP quality, as found in the QUAL column of the VCF file. This file has the suffix ".lqual".

--missing-indv

Generates a file reporting the missingness on a per-individual basis. The file has the suffix ".imiss".

--missing-site

Generates a file reporting the missingness on a per-site basis. The file has the suffix ".lmiss".

--SNPdensity <integer>

Calculates the number and density of SNPs in bins of size defined by this option. The resulting output file has the suffix ".snpden".

--kept-sites

Creates a file listing all sites that have been kept after filtering. The file has the suffix ".kept.sites".

--removed-sites

Creates a file listing all sites that have been removed after filtering. The file has the suffix ".removed.sites".

--singletons

This option will generate a file detailing the location of singletons, and the individual they occur in. The file reports both true singletons, and private doubletons (i.e. SNPs where the minor allele only occurs in a single individual and that individual is homozygotic for that allele). The output file has the suffix ".singletons".

--hist-indel-len

This option will generate a histogram file of the length of all indels (including SNPs). It shows both the count and the percentage of all indels for indel lengths that occur at least once in the input file. SNPs are considered indels with length zero. The output file has the suffix ".indel.hist".

--hapcount <BED file>

This option will output the number of unique haplotypes within user specified bins, as defined by the BED file. The output file has the suffix ".hapcount".

--mendel <PED file>

This option is use to report mendel errors identified in trios. The command requires a PLINK-style PED file, with the first four columns specifying a family ID, the child ID, the father ID, and the mother ID. The output of this command has the suffix ".mendel".

--extract-FORMAT-info <string>

Extract information from the genotype fields in the VCF file relating to a specfied FORMAT identifier. The resulting output file has the suffix ".<FORMAT_ID>.FORMAT". For example, the following command would extract the all of the GT (i.e. Genotype) entries:

vcftools --vcf file1.vcf --extract-FORMAT-info GT

--get-INFO <string>

This option is used to extract information from the INFO field in the VCF file. The <string> argument specifies the INFO tag to be extracted, and the option can be used multiple times in order to extract multiple INFO entries. The resulting file, with suffix ".INFO", contains the required INFO information in a tab-separated table. For example, to extract the NS and DB flags, one would use the command:

vcftools --vcf file1.vcf --get-INFO NS --get-INFO DB

- 输出 VCF 格式

--recode 
--recode-bcf

These options are used to generate a new file in either VCF or BCF from the input VCF or BCF file after applying the filtering options specified by the user. The output file has the suffix ".recode.vcf" or ".recode.bcf". By default, the INFO fields are removed from the output file, as the INFO values may be invalidated by the recoding (e.g. the total depth may need to be recalculated if individuals are removed). This behavior may be overriden by the following options. By default, BCF files are written out as BGZF compressed files.

--recode-INFO <string> 
--recode-INFO-all

These options can be used with the above recode options to define an INFO key name to keep in the output file. This option can be used multiple times to keep more of the INFO fields. The second option is used to keep all INFO values in the original file.

--contigs <string>

This option can be used in conjuction with the --recode-bcf when the input file does not have any contig declarations. This option expects a file name with one contig header per line. These lines are included in the output file.

- 输出其它格式

--012

This option outputs the genotypes as a large matrix. Three files are produced. The first, with suffix ".012", contains the genotypes of each individual on a separate line. Genotypes are represented as 0, 1 and 2, where the number represent that number of non-reference alleles. Missing genotypes are represented by -1. The second file, with suffix ".012.indv" details the individuals included in the main file. The third file, with suffix ".012.pos" details the site locations included in the main file.

--IMPUTE

This option outputs phased haplotypes in IMPUTE reference-panel format. As IMPUTE requires phased data, using this option also implies --phased. Unphased individuals and genotypes are therefore excluded. Only bi-allelic sites are included in the output. Using this option generates three files. The IMPUTE haplotype file has the suffix ".impute.hap", and the IMPUTE legend file has the suffix ".impute.hap.legend". The third file, with suffix ".impute.hap.indv", details the individuals included in the haplotype file, although this file is not needed by IMPUTE.

--ldhat 
--ldhat-geno

These options output data in LDhat format. This option requires the "--chr" filter option to also be used. The first option outputs phased data only, and therefore also implies "--phased" be used, leading to unphased individuals and genotypes being excluded. The second option treats all of the data as unphased, and therefore outputs LDhat files in genotype/unphased format. Two output files are generated with the suffixes ".ldhat.sites" and ".ldhat.locs", which correspond to the LDhat "sites" and "locs" input files respectively.

--BEAGLE-GL 
--BEAGLE-PL

These options output genotype likelihood information for input into the BEAGLE program. The VCF file is required to contain FORMAT fields with "GL" or "PL" tags, which can generally be output by SNP callers such as the GATK. Use of this option requires a chromosome to be specified via the "--chr" option. The resulting output file has the suffix ".BEAGLE.GL" or ".BEAGLE.PL" and contains genotype likelihoods for biallelic sites. This file is suitable for input into BEAGLE via the "like=" argument.

--plink 
--plink-tped 
--chrom-map

这些参数输出 PLINK PED 格式，产生两个文件，’.ped' 和 '.map‘。仅双等位基因位点会被输出。具体请看 PLINK 说明文件。
注意：第一个选项对大数据集很慢。用户可以作用 ’--chr‘ 参数分割文件，或者使用 ‘--plink-tped’ 参数输出 PLINK 转置格式的文件，后缀为 '.tped' 和 ‘.tfam'。
For usage with variant sites in species other than humans, the --chrom-map option may be used to specify a file name that has a tab-delimited mapping of chromosome name to a desired integer value with one line per chromosome. This file must contain a mapping for every chromosome value found in the file.

#### 2.6. 比较参数

These options are used to compare the original variant file to another variant file and output the results. All of the diff functions require both files to contain the same chromosomes and that the files be sorted in the same order. If one of the files contains chromosomes that the other file does not, use the --not-chr filter to remove them from the analysis.

DIFF VCF FILE

--diff <filename> 
--gzdiff <filename> 
--diff-bcf <filename>

These options compare the original input file to this specified VCF, gzipped VCF, or BCF file. These options must be specified with one additional option described below in order to specify what type of comparison is to be performed. See the examples section for typical usage.

DIFF OPTIONS

--diff-site

Outputs the sites that are common / unique to each file. The output file has the suffix ".diff.sites_in_files".

--diff-indv

Outputs the individuals that are common / unique to each file. The output file has the suffix ".diff.indv_in_files".

--diff-site-discordance

This option calculates discordance on a site by site basis. The resulting output file has the suffix ".diff.sites".

--diff-indv-discordance

This option calculates discordance on a per-individual basis. The resulting output file has the suffix ".diff.indv".

--diff-indv-map <filename>

This option allows the user to specify a mapping of individual IDs in the second file to those in the first file. The program expects the file to contain a tab-delimited line containing an individual’s name in file one followed by that same individual’s name in file two with one mapping per line.

--diff-discordance-matrix

This option calculates a discordance matrix. This option only works with bi-allelic loci with matching alleles that are present in both files. The resulting output file has the suffix ".diff.discordance.matrix".

--diff-switch-error

This option calculates phasing errors (specifically "switch errors"). This option creates an output file describing switch errors found between sites, with suffix ".diff.switch".
