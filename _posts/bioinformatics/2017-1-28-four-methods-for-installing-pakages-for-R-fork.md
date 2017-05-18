4种R包安装方式
第一种方式，当然是R自带的函数直接安装包了，这个是最简单的，而且不需要考虑各种包之间的依赖关系。

对普通的R包，直接install.packages()即可，一般下载不了都是包的名字打错了，或者是R的版本不够，如果下载了安装不了，一般是依赖包没弄好，或者你的电脑缺少一些库文件，如果实在是找不到或者下载慢，一般就用repos=来切换一些镜像。
```
  install.packages("ape")  ##直接输入包名字即可
 Installing package into ‘C:/Users/jmzeng/Documents/R/win-library/3.1’
 (as ‘lib’ is unspecified)  ##一般不指定lib，除非你明确知道你的lib是在哪里
 trying URL 'http://mirror.bjtu.edu.cn/cran/bin/windows/contrib/3.1/ape_3.4.zip'
 Content type 'application/zip' length 1418322 bytes (1.4 Mb)
 opened URL   ## 根据你选择的镜像，程序会自动拼接好下载链接url
 downloaded 1.4 Mb

 package ‘ape’ successfully unpacked and MD5 sums checked  ##表明你已经安装好包啦

 The downloaded binary packages are in  ##程序自动下载的原始文件一般放在临时目录，会自动删除
  C:\Users\jmzeng\AppData\Local\Temp\Rtmpy0OivY\downloaded_packages
  ```
  对于bioconductor的包，我们一般是
```
  source("http://bioconductor.org/biocLite.R") ##安装BiocInstaller

  #options(BioC_mirror=”http://mirrors.ustc.edu.cn/bioc/“) 如果需要切换镜像
  biocLite("ggbio")

  或者直接BiocInstaller::biocLite('ggbio') ## 前提是你已经安装好了BiocInstaller
```
  某些时候你还需要卸载remove.packages("BiocInstaller") 然后安装新的

  第二种方式，是直接找到包的下载地址，需要进入包的主页
```
  packageurl <- "http://cran.r-project.org/src/contrib/Archive/ggplot2/ggplot2_0.9.1.tar.gz"
  packageurl <- "http://cran.r-project.org/src/contrib/Archive/gridExtra/gridExtra_0.9.1.tar.gz"
  install.packages(packageurl, repos=NULL, type="source")
  #packageurl <- "http://www.bioconductor.org/packages/2.11/bioc/src/contrib/ggbio_1.6.6.tar.gz"
  #packageurl <- "http://cran.r-project.org/src/contrib/Archive/ggplot2/ggplot2_1.0.1.tar.gz"
  install.packages(packageurl, repos=NULL, type="source")
```
  这样安装的就不需要选择镜像了，也跨越了安装器的版本！

  第三种是，先把包下载到本地，然后安装：
```
   download.file("http://bioconductor.org/packages/release/bioc/src/contrib/BiocInstaller_1.20.1.tar.gz","BiocInstaller_1.20.1.tar.gz")
   ##也可以选择用浏览器下载这个包
   install.packages("BiocInstaller_1.20.1.tar.gz", repos = NULL)
   ## 如果你用的RStudio这样的IDE，那么直接用鼠标就可以操作了
   或者用choose.files()来手动交互的选择你把下载的源码BiocInstaller_1.20.1.tar.gz放到了哪里。
   这种形式大部分安装都无法成功，因为R包之间的依赖性很强！
```
   第四种是：命令行版本安装
```
    如果是linux版本，命令行从网上自动下载包如下：
    sudo su - -c \
    "R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')\""
    如果是linux，命令行安装本地包，在shell的终端
    sudo R CMD INSTALL package.tar.gz
```
    window或者mac平台一般不推荐命令行格式，可视化那么舒心，何必自讨苦吃
