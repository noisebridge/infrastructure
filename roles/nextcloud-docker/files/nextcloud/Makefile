db-shell:
	docker exec -it nextcloud_db /bin/bash

start:
	docker-compose up -d

stop:
	docker-compose down

dump-db:
	docker exec nextcloud_db mysqldump --all-databases > nextcloud-mariadb-dump.sql
