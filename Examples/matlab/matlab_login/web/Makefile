include $(BUILD_HARNESS)/makerules/sandbox_root.mk

COMPONENT := matlab_login
UI_NAME := matlab_login
PROFILE_FILE := $(UI_NAME).profile.js

# Do not trigger JavaScript builds when the following files/folders are modified
# These are derived files and will cause build churn
BUILD_TRIGGER_FILE_EXCLUDES_LIST := toolbox/matlab/matlab_login/web/matlab_login/LoginServiceIdentifiers.js

GENERATE_JS_SUPPORTING_FILES = 1
include $(JAVASCRIPT_BUILD_HARNESS)/makefiles/build_javascript.mk
 
define POST_DOJO_BUILD
rm -rf $(RELEASE_DIR)/$(UI_NAME)/nls

endef
 
define CLEAN_FILES
 
endef
