---
layout: article
title: "配置Git Push策略"
date: 2013-07-30 17:42
tags: ["Git"]
---

我发现大部分人都没有配置过Git Push的策略, 但Git目前给出的默认策略并不是一个友好的机制。


先来看一下所有的Git Push的策略

- nothing 什么都不干（估计只是测试用的）
- matching 本地所有的分支都Push上去, 只是默认的机制
- upstream/tracking 当本地分支有upstream（也就是有对应的远程分支）时Push到对应的远程分支
- simple 和upstream一样, 但不允许将本地分支提交到远程不一样名字的分支
- current 把当前的分支Push到远程的同名分支

Git 1.x的默认策略是`matching`, 在Git 2.0之后`simple`会成为新的默认策略。另外`tracking`是`upstream`的别名, 但已经被标记为deprecated。

`matching`不友好之处在于我们的大部分情况都是同步本地的当前分支到远程，你会看到一长串的本地Branch（如果你本地有二三十个的话那就被刷屏了）。如果除了当前分支外的其他分支有新的内容的话，你会看到好多push fail的提示。

`simple`这个选项是非常安全的选项, 至少能阻止新手误操作覆盖远程分支, 所以Git会在2.0时将其作为默认策略。

大部分情况我们想要做的只是Push当前的分支, 那么最适合的就是upstream。我们可以通过`git config`去配置采用`upstream`策略。具体的设置命令如下

```shell
git config --global push.default upstream
```

*注* 本文发布时最新的Git是1.8.3.x

参考

- http://git-scm.com/docs/git-config
- https://www.kernel.org/pub/software/scm/git/docs/git-push.html
- http://stackoverflow.com/questions/948354/git-push-current-branch
