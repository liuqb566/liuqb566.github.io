---
layout: post
title: 用shadowsocks5科学上网
categories: Linux
tag: internet
---

为了在linux下实现chromium的翻墙，折腾的快崩溃了。

linux版本：Xubuntu 16.10
WM：awesome

1. 安装shadowsocks-qt5,一个界面版shadowsocks.

```
官方源没有，就安作者的吧
sudo add-apt-repository ppa:hzwhuang/ss-qt5
sudo apt-get update
sudo apt-get install shadowsocks-qt5
```

## ps：很容易安选项添好，要注意的是 local server type: 要选http（s）而不是socks5，因为chromium的代理不支持（任性。。。）

2. 命令行启动chromium，因为谷歌浏览器在linux上不支持图形界面设置代理
```
chromium-browser --proxy-server="http://127.0.0.1:1080"
```

3. 为了以后方便还可以将这条命令改个别名
```
vim .bashrc
alias gg='chromium-browser --proxy-server="http://127.0.0.1:1080"'
source .bashrc
```
现在就可以用chromium浏览google了。

4. 还有一个办法是为chromium装插件（等有精力再折腾吧）

5. 为terminal设置全局代理要到genpac等工具，以后再说吧

