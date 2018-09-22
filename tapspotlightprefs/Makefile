include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TapSpotlightPrefs
TapSpotlightPrefs_FILES = TSPRootListController.m
TapSpotlightPrefs_INSTALL_PATH = /Library/PreferenceBundles
TapSpotlightPrefs_FRAMEWORKS = UIKit
TapSpotlightPrefs_PRIVATE_FRAMEWORKS = Preferences
TapSpotlightPrefs_LIBRARIES = sparkapplist

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/TapSpotlightPrefs.plist$(ECHO_END)
