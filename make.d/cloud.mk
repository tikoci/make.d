
.PHONY: tools-cloud
tools-cloud: add-aws-cli

.PHONY: add-aws-cli
# todo: skip+warn on armv7/6 - no AWS SDK 
add-aws-cli:
ifeq (,$(findstring armv,$(UNAME_MACHINE)))
	$(call apk_add aws-cli aws-cli-doc aws-cli-bash-completion)
else
	$(warning skipping 'aws-cli' package on $(UNAME_MACHINE))
endif
