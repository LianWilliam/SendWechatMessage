# SendWechatMessage
# CentOS 7 端口异常监控微信通知教程

## 环境要求

- CentOS 系统的内核版本高于 3.10 
- 需要Linux服务器能够访问外网

### 1. 注册一个企业微信

   ```shell
#注册地址 https://work.weixin.qq.com/wework_admin/register_wx?from=wxmp_register
   ```

![](https://ws1.sinaimg.cn/large/73087adegy1fytdlcpjxxj20rh0go0tw.jpg)

注册后登录到企业微信后台，登录网址：https://work.weixin.qq.com/wework_admin/loginpage_wx

登录后创建应用：

![](https://ws1.sinaimg.cn/large/73087adegy1fyte6cewruj20vy0fq0ty.jpg)

![1546497879591](C:\Users\ADMINI~1\AppData\Local\Temp\1546497879591.png)

创建完成后找到自己创建的企业微信记录下面三个信息，参考如下：

![1546498129868](C:\Users\ADMINI~1\AppData\Local\Temp\1546498129868.png)

**AgentId：1000002** （从企业微信后台，应用与小程序>应用>打开自己创建的应用获取）

**Secret：hKUplQ_rg5ergPHxf4J1zlY9iHc4AiqCvXTMkY-5-b3**

**corpid：wwe5fea335f047ec7b**（从企业微信后台，我的企业最下方获取企业ID）

**user：ZhangSan**（从企业微信后台，通讯录查看人员详情获取帐号字段）



### 2. 安装依赖命令jq

```shell
#安装CentOS依赖命令jq，可以去https://github.com/stedolan/jq下载最新版本，以1.6为例
wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x ./jq
cp jq /usr/bin
```

### 3. 下载监控脚本

   ```shell
#参考我的博客下载
https://whrd.work/archives/centos-7-duan-kou-yi-chang-jian-kong-wei-xin-tong-zhi-jiao-cheng
#或直接从我的github上下载对应的脚本
https://github.com/LianWilliam/SendWechatMessage
   ```

### 4.修改脚本配置

```shell
#修改下载的脚本中的配置，对应章节1.中对应的四个参数到脚本中

#从企业微信后台，应用与小程序>应用>打开自己创建的应用获取
agentld=1000002
#从企业微信后台，应用与小程序>应用>打开自己创建的应用获取
corpsecret="hKUplQ_rg5ergPHxf4J1zlY9iHc4AiqCvXTMkY-5-b3"
#从企业微信后台，我的企业最下方获取企业ID
corpid="wwe5fea335f047ec7b"
#从企业微信后台，通讯录查看人员详情获取帐号字段
user="ZhangSan"

#需要监控端口列表,应用名称或描述以及端口号，以冒号隔开，需要监控多个以换行分隔
port="
nginx:80
mysql:3306
"

#修改后上传到Linux服务器后台如下位置：
/root/send_wechat_message.sh
#给执行权限
chmod +x /root/send_wechat_message.sh
```



### 5. 配置定时任务

   ```shell
#在CentOS 7中创建一个定时任务如下：
crontab -e

#加入以下行,意思为每半小时执行一次脚本监控端口状态，根据自己的要求修改
*/30 * * * * sh /root/send_wechat_message.sh >/root/send_wechat_message.log 2>&1

#crontab用法参考https://tool.lu/crontab/
   ```



### 6.设置微信接受，不需要安装企业微信接受消息

注册后登录到企业微信后台，找到邀请关注字段，扫描这个二维码关注，以后就可以直接使用微信接受消息

![](https://ws1.sinaimg.cn/large/73087adegy1fytln0fd4bj20wp0gj0uo.jpg)

![1546513448618](C:\Users\ADMINI~1\AppData\Local\Temp\1546513448618.png)