!/bin/bash
#########################################################################
# File Name: install_zabbix_db_es.sh
# Author: www.linuxea.com
# Email: usertzc@gmail.com
# Version:
# Created Time: 2019年05月04日 星期六 17时37分47秒
#########################################################################

	zabbix_base_init(){
		mkdir /data/zabbix -p && cd /data/zabbix
		curl -Lk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_server/graphfont.TTF -o /data/zabbix/graphfont.ttf
		wget https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/zabbix_server/docker_zabbix_server-timescaledb/docker-compose.yaml
		docker-compose pull			
	}
	timescaledb_install(){
		mkdir /data/zabbix/postgresql/data -p 
		chown -R 70 /data/zabbix/postgresql/data
		docker-compose  up -d timescaledb
		sleep 30
		sed -i 's/max_connections.*/max_connections = 120/g' /data/zabbix/postgresql/data/postgresql.conf
		docker rm -f  timescaledb
		docker-compose  up -d timescaledb
	}
  
	elasticsearch_install(){
		mkdir /data/zabbix/elasticsearch/{data,logs} -p
		chown -R 1000.1000 /data/zabbix/elasticsearch/
		docker-compose  up -d elasticsearch
		sleep 30
		if [ `ss -lt|grep 5432|wc -l` = 1 ];then 
			echo -e "start configure elasticsearch index\n"
			curl -sLk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/elasticsearch/6.1.4/elasticsearch |bash
			sleep 3
			curl -sLk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/elasticsearch/6.1.4/elasticsearch-pipeline | bash
			sleep 3
			curl -sLk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/elasticsearch/6.1.4/elasticsearch-template | bash
			sleep 3
			curl -sLk https://raw.githubusercontent.com/marksugar/zabbix-complete-works/master/elasticsearch/6.1.4/elasticsearch_template | bash
			sleep 3
			curl http://127.0.0.1:9200/_cat/indices?v
		else
			echo "elasticsearch is not runing"
		fi
	}
zabbix_base_init
timescaledb_install	
elasticsearch_install
docker-compose -f docker-compose.yaml up -d