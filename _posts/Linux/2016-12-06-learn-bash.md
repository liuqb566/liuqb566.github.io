---
layout: post
title: 认识与学习bash
categories: Linux
tag: 鸟哥的Linux私房菜
---

* content
{:toc}


### Bash shell 的内建命令：type

    type [-tpa] name

### 指令的下达

如果指令串太长，用反斜杠`\[Enter]`换行。

### Shell 的变量功能

#### 影响 bash 环境操作的变量

+ PATH
+ HOME
+ MAIL
+ SHELL
+ ...

#### 变量的取用与设定：echo，变量设定规则，unset

+ 变数的取用：echo
```
echo $HOME    
echo $PATH    
myname=Liuqb " 设定一个变量  
```

+ 变量的设定规则

> 1. 以`=`号结
2. 等号两边不能有空格
3. 只能是英文字母与数字，但开头不能是数字。
4. 变量内容若有空格符可使用双引号`“`或单引号`‘`连接。
>> - 双引号内的特殊字符如`$`能保持原有特性。
>> - 单引号内的特殊字符仅为一般纯文本。

> 5. 可用跳脱字符`\`将特殊符号转义
> 6. 扩增变量
     `eg. PATH="PATH":/home/bin`
> 7. 取消变量：unset
     `eg. unset myname`

***

1. 如何进入目前核心扩模块目录？
```
cd /lib/modules/`uname -r`/kernel  
cd /lib/modules/$(uname -r)/kernel
```

**反引号（`）后的命令会先执行，`uname -r`先获得核心版本号，然后`cd`进入kernel目录**

2. 小技巧：如何将一个常去的工作目录简化？

如进入一个目录，需`cd github/liuqb566.io/_draft`可以用以下命令：
```
work="~/github/liuqb566.io/_draft"  
cd $work
```

**`work`变量可以在`bash`的配置文件中直接指定**  
**ps:** 也可以用`alias`别名重新映射一串常用命令。

***

#### 环境变量的功能

1. 用`env`观察环境变量与常见环境变量说明
    env

2. 用`set`观察所有变量（含**环境变量**与**自定义变量**）
    set

3. `export`：自定义变量转成环境变量

#### 影响显示结果的语系变量 (locale)

    locale -a

#### 变量的有效范围

#### 变量键盘读取、数组与宣告： read, array, declare

- `read`

```
[root@www ~]# read [-pt] variable
选项与参数：
-p ：后面可以接提示字符！
-t ：后面可以接等待的『秒数！』
```

- `declare / typeset`

```
[root@www ~]# declare [-aixr] variable
选项与参数：
-a ：将后面名为 variable 的变量定义成为数组 (array) 类型
-i ：将后面名为 variable 的变量定义成为整数数字 (integer) 类型
-x ：用法与 export 一样，就是将后面的 variable 变成环境变量；
-r ：将变量设定成为 readonly 类型，该变量不可被更改内容，也不能 unset
```

- 数组 (array) 变量类型

- 与文件系统及程序的限制关系：`ulimit`

#### 变量内容的删除、取代与替换

#### 命令别名

- 命令别名设定：`alias`，`unalias`

    alias lm='ls -al | more'
    
***

命令别名是**新创一个新的指令， 你可以直接下达该指令**的，至于变量则需要使用类似`echo `指令才能够呼叫出变量的内容！
***

#### 路径与指令搜寻顺序

>1. 以相对/绝对路径执行指令，例如`/bin/ls `或`./ls `；
2. 由`alias`找到该指令来执行；
3. 由`bash`内建的`builtin`指令来执行；
4. 透过`$PATH`这个变量的顺序搜寻到的第一个指令来执行。

#### bash 的进站与欢迎讯息：`/etc/issue`,`/etc/motd`
```
man issue
man mingetty 
man mingetty 
```

`/etc/issue.net`是 telnet 这个远
程登录程序用的。当我们使用 telnet 连接到主机时，主机的登入画面就会显示`/etc/issue.net`而不是`/etc/issue`！

#### bash 的环境配置文件

#### 数据流重导向

- standard output 与 standard error output

> 1. 标准输入 (stdin) ：代码为 0 ，使用`<`或`<<`；
2. 标准输出 (stdout)：代码为 1 ，使用`>`或`>>`；
3. 标准错误输出(stderr)：代码为 2 ，使用`2>`或`2>>`；

- `/dev/null`垃圾桶黑洞装置与特殊写法

写入同一个档案的特殊语法:`2>&1`或`&>`.

- standard input:`<`与`<<`

将原本需要由键盘输入的数据，改由档案内容来取代。

```
利用 cat 指令来建立一个档案的简单流程
[root@www ~]# cat > catfile
testing
cat file test
<==这里按下 [ctrl]+d 来离开
```
```
用 stdin 取代键盘的输入以建立新档案的简单流程
[root@www ~]# cat > catfile < ~/.bashrc
```
**`<< `结束输入**我要用`cat`直接将输入的讯息输出到`catfile`中， 且当由键盘输入 `eof`时，该次输入就结束:
```
[root@www ~]# cat > catfile << "eof"
> This is a test.
> OK now stop
> eof <==输入这关键词，立刻就结束而不需要输入 [ctrl]+d
```

#### 命令执行的判断依据:`;` `&&` `||`

- `cmd;cmd`(不考虑指令相关性的连续指令下达)
- `$?`(指令回传值）与`&&`或`||`

> **若前一个指令执行的结果为正确，在 Linux 底下会回传一个`$? = 0`的值。**  
>> cmd1 && cmd2   
1. 若 cmd1 执行完毕且正确执行($?=0)，则开始执行 cmd2。
2. 若 cmd1 执行完毕且为错误 ($?≠0)，则 cmd2 不执行。  
>> cmd1 || cmd2  
1. 若 cmd1 执行完毕且正确执行($?=0)，则 cmd2 不执行。
2. 若 cmd1 执行完毕且为错误 ($?≠0)，则开始执行 cmd2。

#### 管线命令 (pipe)

**管线命令`|`仅能处理经由前面一个指令传来的正确信息，也就是 standard output 的信息，对于 stdandard error 并没有直接处理的能力。**

> 1. 管线命令仅会处理 standard output，对于 standard error output 会予以忽略
2. 管线命令必须要能够接受来自前一个指令的数据成为 standard input 继续处理才行。

1. 撷取命令:`cut`,`grep`  
一般来说，撷取讯息通常是针对 **一行一行** 来分析的,并不是整篇讯息分析.
> `cut`:这个指令可以将一段讯息的某一段给他『切』出来～ 处理的讯息是以
『行』为单位.

 ```
[root@www ~]# cut -d'分隔字符' -f fields <==用于有特定分隔字符
[root@www ~]# cut -c 字符区间 <==用于排列整齐的讯息
选项与参数：
-d ：后面接分隔字符。与 -f 一起使用；
-f ：依据 -d 的分隔字符将一段讯息分割成为数段，用 -f 取出第几段的意思；
-c ：以字符 (characters) 的单位取出固定字符区间；
```

 ```
范例一：[root@www ~]# echo $PATH | cut -d ':' -f 5
# 如同上面的数字显示，我们是以『: 』作为分隔，因此会出现 /usr/local/bin
```
```
# 那么如果想要列出第 3 与第 5 呢？，就是这样：
[root@www ~]# echo $PATH | cut -d ':' -f 3,5
```
```
范例二：将 export 输出的讯息，取得第 12 字符以后的所有字符串
[root@www ~]# export
declare -x HISTSIZE="1000"
declare -x INPUTRC="/etc/inputrc"
declare -x KDEDIR="/usr"
declare -x LANG="zh_TW.big5"
.....(其他省略).....
```
```
# 注意看，每个数据都是排列整齐的输出！如果我们不想要『declare -x 』时， 就得这么做：
[root@www ~]# export | cut -c 12-
HISTSIZE="1000"
INPUTRC="/etc/inputrc"
KDEDIR="/usr"
LANG="zh_TW.big5"
.....(其他省略).....
# 知道怎么回事了吧？用 -c 可以处理比较具有格式的输出数据！
# 我们还可以指定某个范围的值，例如第 12-20 的字符，就是 cut -c 12-20 等等！
```
```
范例三：用 last 将显示的登入者的信息中，仅留下用户大名
[root@www ~]# last
root pts/1 192.168.201.101 Sat Feb 7 12:35 still logged in
root pts/1 192.168.201.101 Fri Feb 6 12:13 - 18:46 (06:33)
root pts/1 192.168.201.254 Thu Feb 5 22:37 - 23:53 (01:16)
# last 可以输出『账号/终端机/来源/日期时间』的数据，并且是排列整齐的
[root@www ~]# last | cut -d ' ' -f 1
# 由输出的结果我们可以发现第一个空白分隔的字段代表账号，所以使用如上指令：
# 但是因为 root pts/1 之间空格有好几个，并非仅有一个，所以，如果要找出
# pts/1 其实不能以 cut -d ' ' -f 1,2 喔！输出的结果会不是我们想要的。
```

`cut`主要的用途在于将『同一行里面的数据进行分解！』最常使用在分析一些数据或文字数据的时候！这是因为有时候我们会以某些字符当作分割的参数，然后来将数据加以切割，以取得我们所需要的数据。
 
2. `grep`:`cut`是将一行讯息当中，取出某部分我们想要的，而`grep`则是分析一行讯息,若当中有我们所需要的信息，就将该行拿出来。

```
root@www ~]# grep [-acinv] [--color=auto] '搜寻字符串' filename
选项与参数：
-a ：将 binary 档案以 text 档案的方式搜寻数据
-c ：计算找到 '搜寻字符串' 的次数
-i ：忽略大小写的不同，所以大小写视为相同
-n ：顺便输出行号
-v ：反向选择，亦即显示出没有 '搜寻字符串' 内容的那一行！
--color=auto ：可以将找到的关键词部分加上颜色的显示喔！
```

#### 排序命令：`sort`，`wc`，`uniq`

1. sort

`sort`可以依据不同的数据型态来排序，此外，排序的字符与**语系的编码**有关，因此，如果您需要排序时，建议使用**LANG=C** 来让语系统一，数据排序比较好一些。

```
[root@www ~]# sort [-fbMnrtuk] [file or stdin]
选项与参数：
-f ：忽略大小写的差异，例如 A 与 a 视为编码相同；
-b ：忽略最前面的空格符部分；
-M ：以月份的名字来排序，例如 JAN, DEC 等等的排序方法；
-n ：使用『纯数字』进行排序(默认是以文字型态来排序的)；
-r ：反向排序；
-u ：就是 uniq ，相同的数据中，仅出现一行代表；
-t ：分隔符，预设是用 [tab] 键来分隔；
-k ：以那个区间 (field) 来进行排序的意思
```
```
eg. /etc/passwd 内容是以 : 来分隔的，我想以第三栏来排序，该如何？
# 默认以文字排序
[root@www ~]# cat /etc/passwd | sort -t ':' -k 3
# 加 -n 以数字排序
cat /etc/passwd | sort -t ':' -k 3 -n
```
```
利用 last ，将输出的数据仅取账号，并加以排序
[root@www ~]# last | cut -d ' ' -f1 | sort
```

2. uniq：用于将重复的行删除只显示一个
``` 
[root@www ~]# uniq [-ic]
选项与参数：
-i ：忽略大小写字符的不同；
-c ：进行计数
```
```
eg. 使用 last 将账号列出，仅取出账号栏，进行排序后仅取出一位；并统计次数
[root@www ~]# last | cut -d ' ' -f1 | sort | uniq -c
```

3. wc:可以计算输出的讯息的整体数据

```
[root@www ~]# wc [-lwm]
选项与参数：
-l ：仅列出行；
-w ：仅列出多少字(英文单字)；
-m ：多少字符；
```
```
那个 /etc/man.config 里面到底有多少相关字、行、字符数？
[root@www ~]# cat /etc/man.config | wc
141 722 4617
# 输出的三个数字中,分别代表：行、字数、字符数
```

4. tee: 双向重导向，tee 会同时将数据流分送到档案去与屏幕 (screen)；而输出到屏幕的，其实就是 stdout.
```
[root@www ~]# tee [-a] file
选项与参数：
-a ：以累加 (append) 的方式，将数据加入 file 当中！ 
```

#### 字符转换命令：`tr`,`col`,`join`,`paste`,`expand`

1. tr:可以用来删除一段讯息当中的文字，或者是进行文字讯息的替换！
```
[root@www ~]# tr [-ds] SET1 ...
选项与参数：
-d ：删除讯息当中的 SET1 这个字符串；
-s ：取代掉重复的字符！
```
```
范例一：将 last 输出的讯息中，所有的小写变成大写字符：
[root@www ~]# last | tr '[a-z]' '[A-Z]'
# 事实上，没有加上单引号也是可以执行的，如：『last | tr [a-z] [A-Z] 』
```
```
范例二：将 /etc/passwd 输出的讯息中，将冒号 (:) 删除
[root@www ~]# cat /etc/passwd | tr -d ':'
```

2. col:
```
[root@www ~]# col [-xb]
选项与参数：
-x ：将 tab 键转换成对等的空格键
-b ：在文字内有反斜杠 (/) 时，仅保留反斜杠最后接的那个字符
```

3. join: 两个档案当中，有 "相同数据" 的那一行，加在一起
```
[root@www ~]# join [-ti12] file1 file2
选项与参数：
-t ：join 默认以空格符分隔数据，并且比对『第一个字段』的数据，
如果两个档案相同，则将两笔数据联成一行，且第一个字段放在第一个！
-i ：忽略大小写的差异；
-1 ：这个是数字的 1 ，代表『第一个档案要用那个字段来分析』的意思；
-2 ：代表『第二个档案要用那个字段来分析』的意思。
```
**在使用`join`之前，你所需要处理的档案应该要事先经过排序 `sort` 处理！
否则有些比对的项目会被略过**

4. paste:相对于`join`必须要比对两个档案的数据相关性，`paste`就直接** 将
两行贴在一起，且中间以 [tab] 键隔开**

```
[root@www ~]# paste [-d] file1 file2
选项与参数：
-d ：后面可以接分隔字符。预设是以 [tab] 来分隔的！
- ：如果 file 部分写成 - ，表示来自 standard input 的资料的意思。
```

5. expand:将 [tab] 按键转成空格键

```
[root@www ~]# expand [-t] file
选项与参数：
-t ：后面可以接数字。一般来说，一个 tab 按键可以用 8 个空格键取代。
我们也可以自行定义一个 [tab] 按键代表多少个字符。
```

6. split：分割命令可以将一个大档案，依据档案大小或行数来分割，就将大档案分割成为小档案。

```
[root@www ~]# split [-bl] file PREFIX
选项与参数：
-b ：后面可接欲分割成的档案大小，可加单位，例如 b, k, m 等；
-l ：以行数来进行分割。
PREFIX ：代表前导符的意思，可作为分割档案的前导文字。
```
```
范例一：我的 /etc/termcap 有七百多 K，若想要分成 300K 一个档案时？
[root@www ~]# cd /tmp; split -b 300k /etc/termcap termcap
[root@www tmp]# ll -k termcap*
-rw-r--r-- 1 root root 300 Feb 7 16:39 termcapaa
-rw-r--r-- 1 root root 300 Feb 7 16:39 termcapab
-rw-r--r-- 1 root root 189 Feb 7 16:39 termcapac
# 那个档名可以随意取的啦！我们只要写上前导文字，小档案就会以
# xxxaa, xxxab, xxxac 等方式来建立小档案的！
```
```
范例二：如何将上面的三个小档案合成一个档案，档名为 termcapback
[root@www tmp]# cat termcap* >> termcapback
# 很简单吧？就用数据流重导向就好啦！简单！
```
```
范例三：使用 ls -al / 输出的信息中，每十行记录成一个档案
[root@www tmp]# ls -al / | split -l 10 - lsroot
[root@www tmp]# wc -l lsroot*
10 lsrootaa
10 lsrootab
6 lsrootac
26 total
```

**重点在那个`-`！一般来说，如果需要 stdout/stdin 时，但偏偏又没有档案有的只是 - 时，那么那个`-`就会被当成 stdin 或 stdout。**

7. xargs:参数代换

x 是加减乘除的乘号，args 则是 arguments (参数)的意思，所以说，这个玩意儿就是在产生某个指令的参数的意思！** xargs 可以读入 stdin 的数据，并且以空格符或断行字符作为分辨，将 stdin 的资料分隔成为 arguments 。** 因为是以空格符作为分隔，所以，如果有一些档名或者是其他意义的名词内含有空格符的时候， xargs 可能就会误判了。

```
[root@www ~]# xargs [-0epn] command
选项与参数：
-0 ：如果输入的 stdin 含有特殊字符，例如 `, \, 空格键等等字符时，这个 -0 参
数可以将他还原成一般字符。这个参数可以用于特殊状态！
-e ：这个是 EOF (end of file) 的意思。后面可以接一个字符串，当 xargs 分析
到这个字符串时，就会停止继续工作！
-p ：在执行每个指令的 argument 时，都会询问使用者的意思；
-n ：后面接次数，每次 command 指令执行时，要使用几个参数的意思。
当 xargs 后面没有接任何的指令时，默认是以 echo 来进行输出！
```
```
范例一：将 /etc/passwd 内的第一栏取出，仅取三行，使用 finger 这个指令将
每个账号内容秀出来
[root@www ~]# cut -d':' -f1 /etc/passwd |head -n 3| xargs finger
# 后的结果。在这个例子当中，我们利用 cut 取出账号名称，用 head 取出三个账号,最后则是由 xargs 将三个账号的名称变成 finger 后面需要的参数！
```
```
范例三：将所有的 /etc/passwd 内的账号都以 finger 查阅，但一次仅查阅五个
账号
[root@www ~]# cut -d':' -f1 /etc/passwd | xargs -p -n 5 finger
```
```
范例四：同上，但是当分析到 lp 就结束这串指令？
[root@www ~]# cut -d':' -f1 /etc/passwd | xargs -p -e'lp' finger
finger root bin daemon adm ?...
# 仔细与上面的案例做比较。也同时注意，那个 -e'lp' 是连在一起的，中间没有
空格键。
# 上个例子当中，第五个参数是 lp 啊，那么我们下达 -e'lp' 后，则分析到 lp
# 这个字符串时，后面的其他 stdin 的内容就会被 xargs 舍弃掉了！
```
**会使用 xargs 的原因是， 很多指令其实并不支持管线命令，因此我们可以透过 xargs 来提供该指令引用 standard input 之用！**

```
范例五：找出 /sbin 底下具有特殊权限的档名，并使用 ls -l 列出详细属性
[root@www ~]# find /sbin -perm +7000 | ls -l
 # 因为 ll (ls) 并不是管线命令,所以仅列出root所在目录档案
[root@www ~]# find /sbin -perm +7000 | xargs ls -l
-rwsr-xr-x 1 root root 70420 May 25 2008 /sbin/mount.nfs
-rwsr-xr-x 1 root root 70424 May 25 2008 /sbin/mount.nfs4
-rwxr-sr-x 1 root root 5920 Jun 15 2008 /sbin/netreport
```

8. 减号`-`的用途：

在管线命令当中，常常会使用到前一个指令的 stdout 作为这次的stdin ，某些指令需要用到文件名 (例如 tar) 来进行处理时，该 stdin 与 stdout 可以利用减号 "-" 来替代。

`[root@www ~]# tar -cvf - /home | tar -xvf -`
> 将`/home`里面的档案打包，但打包的数据不是纪录到档案，而是传送到stdout； 经过管线后，将`tar -cvf - /home`传送给后面的`tar -xvf -`。后面的这个`-`则是取用前一个指令的 stdout， 因此，就不需要使用 file 了！




