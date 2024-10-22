
.PHONY: tools-cloud
tools-cloud: add-aws-cli

.PHONY: add-aws-cli
# todo: skip+warn on armv7 - no AWS SDK 
add-aws-cli:
ifeq ($(UNAME_MACHINE),armv7l)
	$(warning skipping 'aws-cli' package on $(UNAME_MACHINE))
else
	$(call apk_add aws-cli aws-cli-doc aws-cli-bash-completion)
endif
