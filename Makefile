DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TapSpotlight
TapSpotlight_FILES = TapSpotlight.xm

include $(THEOS_MAKE_PATH)/tweak.mk

export COPYFILE_DISABLE = 1

after-install::
	install.exec "killall -9 SpringBoard"