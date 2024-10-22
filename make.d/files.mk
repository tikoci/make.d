
.PHONY: tools-files
tools-files: add-git add-fossil add-restic add-rsync

.PHONY: add-rsync
add-rsync: /usr/bin/rsync
.PRECIOUS: /usr/bin/rsync
/usr/bin/rsync:
	$(call apk_add, rsync rsync-doc)

.PHONY: add-git
add-git: /usr/bin/git

.PHONY: add-fossil
add-fossil: /usr/bin/fossil
.PRECIOUS: /usr/bin/fossil
/usr/bin/fossil:
	$(call apk_add, fossil fossil-bash-completion)

.PHONY: add-rustic
# todo: not wired up to /app nor make.d specific config, just installs
add-restic: /usr/bin/rustic

.PHONY: fossil-init
fossil-init: /usr/bin/fossil
	fossil new --project-name "make.d" --project-desc "maked.home.arpa" /app/repo.fossil --user root
	fossil open -f /app/repo.fossil --user root
	fossil add /app
	fossil commit -m 'default-configuration' --no-warnings --user root

.PHONY: git-commit
git-commit: /app/.git/HEAD
	git status
	git add --all
	git commit -m "make.d changes `date`"
	git status

.PHONY: git-init
git-init: /usr/bin/git
	mkdir -p /app \
	&& cd /app \
	&& git init --initial-branch=local \
	&& git add --all \
	&& git config --global user.name "make.d git" \
	&& git config --global user.email "make.d@tikoci.github.io" \
	&& git commit -m "default-configuration"

.PRECIOUS: /usr/bin/rustic
/usr/bin/rustic:
	$(call apk_add_testing, rustic rustic-bash-completion)

.PRECIOUS: /usr/bin/git
/usr/bin/git:
	$(call apk_add, git git-doc git-bash-completion gitui)

.PRECIOUS: /app/.git/HEAD
/app/.git/HEAD: init-git
