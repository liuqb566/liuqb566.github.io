---
layout: post
title: Ubuntu通过用wifi上网
categories: Linux
tags: [wifi, internet]
---

最近折腾了一下用命令行在Ubuntu上连接wifi。网上基本有三种方法（工具）：ifconfig、wpa_supplicant、nmcli。我推荐用nmcli，因为这个最简单嘛。。。

- ifconfig  ps:WPE加密可用

- wpa_supplicant  ps: WPA/WPA2 加密可用

- nmcli

nmcli 是NetworkManager自带的命令行工具,以下命令是基于"nmcli tool, version 1.2.4".

1. 重启`sudo service network-manager restart
2. 管理wifi

```
# 打开/关闭wifi

$ sudo nmcli networking on/off

# 列出可用的热点

$ sudo nmcli device wifi

*  SSID           MODE   CHAN  RATE       SIGNAL  BARS  SECURITY
*  B-LINK_B639A8  Infra  1     54 Mbit/s  56      ▂▄▆_  WPA2
   NR-DEBUG       Infra  1     54 Mbit/s  14      ▂___  WPA2

# 连接热点
$ sudo nmcli device wifi connect B-LINK_B639A8 password ...... ifname wlp8so    ps: nmcli最贴心的一点就是可以自动补全，所以你不必亲自输入全部名称

# 断开热点
$ sudo nmcli device disconnect wlp8s0

# 查看状态
$ sudo nmcli device status

DEVICE  TYPE      STATE        CONNECTION
wlp8s0  wifi      connected    B-LINK_B639A8 4
enp7s0  ethernet  unavailable  --
lo      loopback  unmanaged    --

# 查看连接信息
$ sudo nmcli device show wlp8so
```
