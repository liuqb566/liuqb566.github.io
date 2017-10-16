---
layout: post
title: linux下通过校园网认证
categories: Linux
tags: internet
---

## 用 wget 或者 curl 在 linux 上通过 web 认证

一般校园网都会设置网关，每个人用帐号密码通过 web 认证进行上网。这在图形界面很容易，因为网页会自动跳转到认证界面。但是，如果在服务器的纯命令行界面，该如何通过 web 认证呢？这里推荐两种方法：curl 和 wget。

### 1. 查看完整的认证过程

这是最重要的一步！！！
大部分的 web 认证都是基于 form 的认证方式，也就是你浏览器通过一个 form ，把用户名和密码 post 给服务器。
所以 form 的格式是最重要的，不同的学校，可能会有所不同，因此，你应该先通过查看登陆界面的源码，了解你的 form data 和 Request URL。

### 2. 认证

1. wget 方式
```
wget --post-data="username=abc&password=123456&pwd=123456&secret=true" --save-cookies=webcookie.txt --keep-session-cookies http://10.0.0.252/webAuth/ # 将登陆信息存储成 cookies，以便下次使用
wget --load-cookies=webcookie.txt http://10.0.0.252/webAuth # 直接用载入 cookies，进行认证
wget --post-data="username=abc&password=123456&pwd=123456&secret=true" http://10.0.0.252/webAuth/ # 直接使用帐号密码登陆
```

如时登陆不成功，请先检查 form data 和 URL 是否格式正确！！！

2. curl 方式

```
curl --data "username=liuqibao&password=666666&pwd=666666&secret=true" http://10.0.0.252/webAuth/
```

最后再说一遍，一定要看清 form data 和 Request URL 的格式！！！
