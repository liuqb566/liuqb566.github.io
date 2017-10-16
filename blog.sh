#! bin/bash

# Program;
#	this progam is used to push blog.
# history;
# 	2017-10-16 gossie V2

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

 cd ~/workspace/liuqb566.github.io || exit 0  

# checkout branch to source
git checkout source || exit 0 

# build,add and commit
 jekyll build || echo 0
 git add -A
 read -p 'Please input the information about this commit:' info
 git commit -m '$info'

 #checkout branch to master and checkout files of _site of source to master
 git checkout master || exit 0
 rm -r *
 git checkout source _site ||exit 0
 mv _site/* .
 rm -r _site

 #add and commit
 git add -A
 read -p 'Please input the information about this commit:' info
 git commit -m '$info' || exit 0

 # push
 git push --all ||exit 0
 
 echo "All is ok!"

 


