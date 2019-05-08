#!/bin/bash
set -eux

# Check if user exists
if ! id -u ${APACHE_RUN_USER} > /dev/null 2>&1; then
	echo "The user ${APACHE_RUN_USER} does not exist, creating..."
	groupadd --gid ${APACHE_RUN_GROUP_ID} ${APACHE_RUN_GROUP}
	useradd --uid ${APACHE_RUN_USER_ID} --gid ${APACHE_RUN_GROUP_ID} ${APACHE_RUN_USER}
fi

# Install Aria2 on first run
if [ ! -e /var/www/html/dweb/index.html ];  then
	echo "[Aria2 fresh install]"
	chmod 777 -R /var/www
	chmod 777 -R /user-files
	unzip /master.zip -d /var/www/html/
	mkdir -p /var/www/html/dweb
	mkdir -p /var/www/html/filerun
	cp -r /var/www/html/AriaNg-DailyBuild-master/* /var/www/html/dweb/
	rm -rf /var/www/html/AriaNg-DailyBuild-master

	# exec /install-aria2-ui.sh

	downloadPath='/user-files/superuser/dl'

	basePath='/var/www/html/dweb/aria2'

	mkdir -p $downloadPath $basePath

	file1=$basePath/aria2.s

	file2=$basePath/aria2.log

	touch $file1 $file2

	configFile=$basePath/aria2.conf

	configTpl="
	continue=true \n

	daemon=true \n

	dir=$downloadPath \n

	enable-rpc=true \n

	file-allocation=none \n

	force-sequential=true \n

	input-file=$file1 \n

	log=$file2 \n

	log-level=notice \n

	max-concurrent-downloads=3 \n

	max-connection-per-server=5 \n

	parameterized-uri=true \n

	rpc-allow-origin-all=true \n

	rpc-listen-all=true \n

	rpc-save-upload-metadata=true \n

	save-session=$file1 \n

	save-session-interval=30 \n

	split=2 \n
	"

	echo -e $configTpl>$configFile

	comTpl="
	#!/bin/sh \n
	CONF=$configFile \n
	\n
	case \"\$1\" in \n
	start) \n
		echo \"Starting aria2c service\" \n
		aria2c --conf-path=\$CONF -D \n
		echo \"done !\" \n
		;; \n
	stop) \n
		echo \"Stopping aria2c service\" \n
		killall -w aria2c \n
		echo \"done !\" \n
		;; \n
	restart) \n
		echo \"Restarting aria2c service\" \n
		killall -w aria2c \n
		aria2c --conf-path=\$CONF -D \n
		echo \"done !\" \n
		;; \n
	*) \n
		echo \"\$0 {start|stop|restart}\" \n
		;; \n
	esac \n
	exit
	"

	echo -e $comTpl>/etc/init.d/aria2

	chmod +x /etc/init.d/aria2

	service aria2 start

	update-rc.d aria2 defaults
fi

# Install FileRun on first run
if [ ! -e /var/www/html/filerun/index.php ];  then
	echo "[FileRun fresh install]"
	unzip /filerun.zip -d /var/www/html/filerun/
	cp /autoconfig.php /var/www/html/filerun/system/data/
	chown -R ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} /var/www/html
	chown -R ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} /user-files
	mysql_host="${FR_DB_HOST:-mysql}"
	mysql_port="${FR_DB_PORT:-3306}"
	/wait-for-it.sh $mysql_host:$mysql_port -t 120 -- /import-db.sh
fi

exec "$@"
