---
layout: post
title: Ubuntu设置静态IP
categories: Linux
tags: internet
---

## 手动设置 Ubuntu 16.10 的网卡

最近新换了一个环境，需要手动设置 ip 地址上网，所以搞了一下！

1. 查看网卡名

```
ip addr
```
我的有线网卡为：enp7s0
无线网卡为：wlp8s0
**一定要看好网卡名字！！！**

2. 手动设置 ip
```
sudo vi /etc/network/interfaces

以下为输出

# interfaces(5) file used by ifup(8) and ifdown(8)
auto lo
iface lo inet loopback

# 以下为后来添加
auto enp7s0
iface enp7s0 inet static
address 192.168.56.42
netmask 255.255.255.0
gateway 192.168.56.254

# dns-nameserver 210.33.60.1
dns-nameserver 202.107.200.69
```

3. 重启
```
sudo /etc/init.d/networking restart
sudo resolvconf -u    #重启 dns，否则无法解析域名
```

4. 备用
如果还是无法解析域名，可以试试：
```
vi /etc/resolvconf/resolv.conf.d/base

以下为输出

nameserver 210.33.60.1
nameserver 202.107.200.69

```
刷新配置文件
```
sudo resolvconf -u
```

补：
用了几天突然 DNS 又不行了，做了以下修改：
```
sudo vi /etc/resolv.conf

# 添加以下内容：
nameserver 210.33.60.1 #或者其它 DNS 地址
```
重启
```
sudo /etc/init.d/networking restart
sudo resolvconf -u    #重启 dns，否则无法解析域名
```
