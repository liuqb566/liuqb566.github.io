---
layout: post
title: "git push 需要密码问题"
date: 2017-11-3
category: github
tags: git
---

问题：

用git的时候突然遇到一个问题，每次`git push`都需要帐户密码验证。

原因：

git 有两种认证方式，SSH 和 HTTPS，建立本机密钥后，SSH认证方式不用再验证，而 HTTPS 每次都要验证。

解决办法：

修改本地库`.git/config`文件

```
[remote "origin"]
url = https://github.com/..../....git
>>>>改为
url = git@github.com:.../....git
```

参考：

http://blog.sina.com.cn/s/blog_5f8d04170101eidi.html

http://www.cppblog.com/deercoder/archive/2011/11/13/160050.html
