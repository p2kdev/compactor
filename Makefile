export THEOS_PACKAGE_SCHEME=rootless
export TARGET = iphone:clang:13.7:13.0

THEOS_DEVICE_IP = 192.168.86.30

PACKAGE_VERSION=$(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

export ARCHS=arm64 arm64e

TWEAK_NAME = Compactor

Compactor_FILES = Tweak.xm
Compactor_FRAMEWORKS = Foundation UIKit
Compactor_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
