---
layout: post
title: 在linux下添加用户
categories: Linux
tags: command
---

## 在使用 useradd 命令时遇到的问题

useradd 是添加新用户的命令，具体参数不再详述。
这里主要记录一下遇到的一个小问题。
linux 版本：Ubuntu 16.04

### 问题1：没有家目录

原因：Ubuntu 系统中，使用 useradd 添加新用户需要使用 `-d` 参数指定用户目录，若用户目录不存在，同时用 `-m` 参数创建主目录。推测添加用户的老师当时没有加参数。
解决办法：没办法，找他新建主目录。

### 问题2：家目录下没有 .bashrc 文件

原因：不清楚
解决办法：从 `/etc/skel/` 中复制 `.bashrc` 和 `.profile` 到家目录

### 问题3：source 命令不管用，提示找不到文件

原因：没有使用完整路径，但是在大多数系统不需要完整路径就能用，不清楚具体原因。（让我想起了 aspera 也是这毛病，linux 就是任性）
解决办法：使用完整路径 `source ./.bashrc`

---
ps：
exec bash 命令会重启 shell，也就是你当前的 shell 正执行的命令会终止。
source .bashrc 可以在当前 shell 上更改配置。

