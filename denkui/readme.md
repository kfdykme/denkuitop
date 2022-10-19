---
title: ReadMe
date: 8/26/2022, 4:09:35 PM
tags:
- readme

---

# 低蜂使用说明

**低蜂**是一个尝试简化日常工作需求的文本编辑器，包含了：

- *markdown*  支持简单的markdown语法编辑 
- *rss*       支持订阅rss信息流
- *历史记录*   本地保存文件编辑记录

-------------------

[TOC]

## Markdown简介
Markdown 是一种轻量级的标记语言，可用于在纯文本文档中添加格式化元素。Markdown 由 John Gruber 于 2004 年创建，如今已成为世界上最受欢迎的标记语言之一。

1.专注于文字内容；
2.纯文本，易读易写，可以方便地纳入版本控制；
3.语法简单，没有什么学习成本，能轻松在码字的同时做出美观大方的排版。

## 为什么要使用 Markdown？
当你可以通过按下界面中的按钮来设置文本格式时，为什么还要使用 Markdown 来书写呢？使用 Markdown 而不是 word 类编辑器的原因有：

- Markdown 无处不在。StackOverflow、CSDN、掘金、简书、GitBook、有道云笔记、V2EX、光谷社区等。主流的代码托管平台，如 GitHub、GitLab、BitBucket、Coding、Gitee 等等，都支持 Markdown 语法，很多开源项目的 README、开发文档、帮助文档、Wiki 等都用 Markdown 写作。

- Markdown 是纯文本可移植的。几乎可以使用任何应用程序打开包含 Markdown 格式的文本文件。如果你不喜欢当前使用的 Markdown 应用程序了，则可以将 Markdown 文件导入另一个 Markdown 应用程序中。这与 Microsoft Word 等文字处理应用程序形成了鲜明的对比，Microsoft Word 将你的内容锁定在专有文件格式中。

- Markdown 是独立于平台的。你可以在运行任何操作系统的任何设备上创建 Markdown 格式的文本。

- Markdown 能适应未来的变化。即使你正在使用的应用程序将来会在某个时候不能使用了，你仍然可以使用文本编辑器读取 Markdown 格式的文本。当涉及需要无限期保存的书籍、大学论文和其他里程碑式的文件时，这是一个重要的考虑因素。

> [以上摘自: https://markdown.com.cn](https://markdown.com.cn/intro.html#%E4%B8%BA%E4%BB%80%E4%B9%88%E8%A6%81%E4%BD%BF%E7%94%A8-markdown%EF%BC%9F)

## Markdown 语法介绍

### 标题

不同数量的`#`可以完成不同的标题，如下：

#### 四级标题

##### 五级标题

###### 六级标题

### 字体

粗体、斜体、粗体和斜体，删除线，需要在文字前后加不同的标记符号。如下：

**这个是粗体**

*这个是斜体*

***这个是粗体加斜体***

### 列表

- 第一项
- 第二项
- 第三项

#### 待办列表

第一行加上`[TODO]`或者`[DONE]`
- 吃饭 [DONE]
- 睡觉
- 打豆豆


### 引用区块

> 引用区块

### 代码块
``` cpp
#include <stdio.h>

int main(void) {
    printf("hello lowbee");
}
```

### 链接
`[链接名称](链接地址)`

[bing](https://www.bing.com/)


### 图片

`![alt 属性文本](图片地址)`

![/Users/chenxiaofang/Documents/tupia.png](https://img1.baidu.com/it/u=729938845,709425648&fm=253&fmt=auto&app=138&f=JPEG?w=977&h=500)

## RSS 简介

> RSS（英文全称：RDF Site Summary 或 Really Simple Syndication），中文译作简易信息聚合，也称聚合内容，是一种消息来源格式规范，用以聚合多个网站更新的内容并自动通知网站订阅者。使用 RSS 后，网站订阅者便无需再手动查看网站是否有新的内容，同时 RSS 可将多个网站更新的内容进行整合，以摘要的形式呈现，有助于订阅者快速获取重要信息，并选择性地点阅查看 
> 
> -- [维基百科 RSS](https://zh.wikipedia.org/wiki/RSS)

### 如何在低蜂中使用rss

点击新建按钮，添加有效的rss地址，然后点击添加到列表即可

## 其他相关

有`bug`或者有`文本编辑相关的功能建议`都可以[联系我](mailto:wim.k.f@live.com)