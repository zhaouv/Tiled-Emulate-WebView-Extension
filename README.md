# Tiled-Emulate-WebView-Extension

Tiled未引入QT的webview的相关的部分, 此处实现一个效果类似webview的插件, 借助html的界面来编辑Tiled的内容

核心思路是利用浏览器的app模式把编辑界面做成弹窗, 然后运行一个server, 通过标准输入输出或者xhr通信来实现内容的传递

## 文件结构

目前假设插件脚本放在 `工程/extensions` 目录  
server和html放在 `工程/webview` 目录  
界面入口是 `工程/webview/webview.html` 文件

## 使用

把文件放到对应位置后在控制台`var ret=tiled.webview_edit('content to edit')`  

提供给其他插件使用, 例如再编写如下插件:  
(假设项目的每个地图a.tmx, 对应一个a.json存放一些事件)  
```js
tiled.registerAction('EditEvent',function(action) {
  let name=tiled.activeAsset.fileName.replace(/\.tmx$/,'.json')
  let x=tiled.activeAsset.selectedArea.boundingRect.x
  let y=tiled.activeAsset.selectedArea.boundingRect.y

  let file = new TextFile(name, TextFile.ReadOnly);
  let fileContent=editedFile.readAll();
  editedFile.close();

  let data = JSON.parse(fileContent)
  let key = x+','+y
  data[key]=tiled.webview_edit(data[key])
  let editedFileContent=JSON.stringify(data)

  let editedFile = new TextFile(name, TextFile.WriteOnly);
  editedFile.write(editedFileContent);
  editedFile.commit();

})
```
在"编辑-首选项-键盘"中给这个Action绑定一个快捷键  
用"矩形选择"选中一个点. 然后执行对应快捷键, 就可以在网页中处理对应的数据  

## windows实现

追求轻量级, 尽量让用户不需要安装任何东西  
浏览器使用msedge, server使用powershell, 这两个都是windows自带的  

> 第一次运行可能会提示 cmd/vbs 的安全性

## 其他平台

mac 有python和safari可做  
linux 一般会有装python, 但firefox不支持app模式  
这两个平台之后再考虑

## server

+ GET *  
  提供静态服务  
+ GET /quit  
  关闭服务器  
+ POST /submit  
  Tiled发送待编辑内容, 并触发一次弹窗  
+ POST /query 和 GET /query  
  Tiled取编辑结果  
+ POST /fetch 和 GET /fetch  
  网页取待编辑的内容  
+ POST /push  
  网页推送编辑后的内容  

## webview

示例的网页包含webview.html tiled.js是网页文件, 其他是server以及辅助文件

更改后的网页仍建议引入tiled.js, 其中在`unload`事件会发送cancel的指令  
否者直接关掉网页会导致Tiled被冻结的状态无法解除  
