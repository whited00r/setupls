THEOS_DEVICE_IP = 192.168.1.19
GO_EASY_ON_ME = 1
include theos/makefiles/common.mk
ARCHS = armv7

BUNDLE_NAME = SetupLS
SetupLS_FILES = SetupLS.mm SetupLSViewManager.m SetupLSWelcomeView.m UIImage+StackBlur.m UIImage+Resize.m UIImage+LiveBlur.m SetupLSWelcomeScrollView.m SetupLSOTASettingView.m SetupActivationView.m
SetupLS_INSTALL_PATH = /Library/liblockscreen/Lockscreens
SetupLS_FRAMEWORKS = Foundation UIKit QuartzCore CoreGraphics Security

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"