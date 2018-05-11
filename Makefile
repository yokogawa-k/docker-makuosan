SHELL := /bin/bash

.PHONY: default
default: help

.PHONY: help help-common
help: help-common

help-common:
	@grep -E '^[a-zA-Z0-9\._-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m %-30s\033[0m %s\n", $$1, $$2}'

.PHONY: test
test: env-up show-members show-status sync-newfile-test sync-delete-file-test env-down ## makuosan のテストを実行

.PHONY: build
build: ## docker イメージの build
	docker-compose build

.PHONY: env-up
env-up:
	docker-compose up -d

.PHONY: env-down
env-down:
	docker-compose down

.PHONY: show-members
show-members:
	$(call yellowecho,"makuoasan members の一覧表示")
	docker-compose exec node01 msync --members

.PHONY: show-status
show-status:
	$(call yellowecho,"makuoasan status の表示")
	docker-compose exec node01 msync --status

.PHONY: sync-newfile-test
sync-newfile-test:
	$(call yellowecho,"dummy file の生成")
	docker-compose exec node01 touch /var/www/foo
	$(call yellowecho,"ファイル同期の dry-run を実行")
	docker-compose exec node01 msync -rn -l9 --sync
	$(call yellowecho,"ファイル同期を実行")
	docker-compose exec node01 msync -r -l9 --sync
	$(call yellowecho,"ファイル存在を実行")
	docker-compose exec node02 ls -l /var/www/

.PHONY: sync-delete-file-test
sync-delete-file-test:
	$(call yellowecho,"dummy file の削除")
	docker-compose exec node01 rm -fv /var/www/foo
	$(call yellowecho,"ファイル同期の dry-run を実行")
	docker-compose exec node01 msync -rn -l9 --delete --sync
	$(call yellowecho,"ファイル同期を実行")
	docker-compose exec node01 msync -r -l9 --delete --sync
	$(call yellowecho,"ファイルが無いことを実行")
	docker-compose exec node02 ls -l /var/www/

define yellowecho
      @tput -T xterm setaf 3
      @echo $1
      @tput -T xterm sgr0
endef
