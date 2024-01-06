export ARCHS = arm64
export TARGET = iphone:clang:14.5:12.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NotificationTester
NotificationTester_FILES = Tweak.xm
NotificationTester_FRAMEWORKS = UIKit BulletinBoard
NotificationTester_LIBRARIES = sqlite3
NotificationTester_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += notificationtesterprefs

include $(THEOS_MAKE_PATH)/aggregate.mk
