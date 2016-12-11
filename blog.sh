#! bin/bash

# Program;
#	this progam is used to push blog.
# history;
# 	2016-12-11 gossie first release

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

 cd ~/github/liuqb566.github.io || exit 0  

# checkout branch to source
git checkout source || exit 0 

# build,add and commit
 jekyll build || echo 0
 git add -A
 read -p 'Please input the information about this commit:' info
 git commit -m '$info'

 # cp _sit to another dir
 rm -rf /tmp/site/*
 cp -r -a ./_site/* /tmp/site/

