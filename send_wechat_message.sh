#!/bin/bash

######################################################
# Name          : send_wechat_message.sh
# Description   : function :Send a warning message to WeChat
# Author        : lww_work@163.com
######################################################
# VERSION		DATE		DESCRIPTION
# 0.1		2019-01-03		initial
######################################################

#------------------------以下变量需要自行修改-----------------------------------
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
#------------------------以上变量需要自行修改-----------------------------------

#保存信息内容变量
message=$1
#curl -s 静默模式，就是不显示错误和进度
A=`curl -s https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$corpid\&corpsecret=$corpsecret`
#解析json格式 并获取access_token值
token=`echo $A | jq -c '.access_token'`
#去除变量值两边的双引号
token=${token#*\"}
token=${token%*\"}
#请求地址
URL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$token"
script_name=`basename $0`

function log_echo
{
    echo "`date \"+%Y-%m-%d %H:%M:%S\"`|$1|$2"
	# example
	# log_echo "INFO" "Drop CPS database users \"${name}\" successfully."
	# log_echo "WARN" "Drop CPS database \"${name}\" failed."
	# log_echo "ERROR" "Please use root or Oracle to execute this script." 
}

function helpinfo
{
	echo "
	Usage:./${script_name} \"Send Message\"
						  
		Version: 0.1"
}

if [ $# -eq 1 ];then
	log_echo "INFO" "Send Message \"$1\" to WeChat."
elif [ $# -ge 2 ];then
	helpinfo
	exit
else
	echo "" >/dev/null
fi

function SendMessage()
{
	#发送的JSON内容解释
	#http://qydev.weixin.qq.com/wiki/index.php 企业号开发者中心
	#text消息JSON格式如下：
	#{
	#   "touser": "UserID1|UserID2|UserID3",			成员ID列表，多个以|分隔，@all则向所有成员发送
	#   "toparty": " PartyID1 | PartyID2 ",				部门ID列表
	#   "totag": " TagID1 | TagID2 ",				标签ID列表
	#   "msgtype": "text",						消息类型
	#   "agentid": 1,						企业应用的id
	#   "text": {							
	#       "content": "Holiday Request For Pony(http://xxxxx)"	消息内容最长不超过2048个字节，微信提醒上显示20个字
	#   },
	#   "safe":0							表示是否是保密消息，0表示否，1表示是，默认0 
	#}
	
	#保存信息内容变量
	msg=$1
	
	for I in $user;
	do
		#发送的JSON内容
		JSON="{\"touser\": \"$I\",\"msgtype\": \"text\",\"agentid\": \"$agentld\",\"text\": {\"content\": \"$msg\"},\"safe\":0 }"
		#以POST的方式请求
		log_echo "INFO" "发送消息内容：检查${port_name}服务 ${test_port}端口异常，请及时处理"
		echo "发送消息内容：检查${port_name}服务 ${test_port}端口异常，请及时处理" > /tmp/request.txt
		echo "请求命令：" >> /tmp/request.txt
		echo "curl -sd $JSON $URL" >> /tmp/request.txt
		echo "返回Response：" >> /tmp/request.txt
		curl -sd "$JSON" "$URL" >> /tmp/request.txt
		echo -e "\n" >> /tmp/request.txt
		
		cat /tmp/request.txt |grep -iw ok >/dev/null
		if [ $? -eq 0 ];then
			log_echo "INFO" "消息发送成功"
		else
			log_echo "ERROR" "消息发送失败，`cat /tmp/request.txt`"
			log_echo "ERROR" "消息发送失败 `cat /tmp/request.txt`" >>/var/log/send_wechat_message.log
		fi
		
		#echo -e "\n"
	done
}

function MonitorPort()
{	

	for i in $port;
	do
		#截取端口
		test_port=`echo $i |awk -F : '{print $2}'`
		#截取应用或描述
		port_name=`echo $i |awk -F : '{print $1}'`
		#通过lsof命令查看端口是否启用
		lsof -i:$test_port >/dev/null
		if [ $? -eq 0 ];then
			log_echo "INFO" "检查${port_name}服务 \"${test_port}\" 端口正常"
		else
			log_echo "ERROR" "检查${port_name}服务 \"${test_port}\" 端口异常，准备发送微信消息"
			log_echo "ERROR" "检查${port_name}服务 \"${test_port}\" 端口异常，准备发送微信消息" >>/var/log/send_wechat_message.log
			#调用函数发送微信消息通知
			SendMessage "检查${port_name}服务 ${test_port}端口异常，请及时处理"
		fi
	done
}

function main
{
	#脚本直接手工执行测试
	if [ ! X"$message" = X""  ];then
		SendMessage "${message}"
		exit 0
	fi
	
	#监控调用
	MonitorPort
}

main "$@"




