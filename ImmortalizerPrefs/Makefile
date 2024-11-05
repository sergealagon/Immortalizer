TARGET := iphone:clang:16.5:14.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ImmortalizerPrefs

ImmortalizerPrefs_FILES = IPBRootListController.m
ImmortalizerPrefs_FRAMEWORKS = UIKit
ImmortalizerPrefs_PRIVATE_FRAMEWORKS = Preferences
ImmortalizerPrefs_INSTALL_PATH = /Library/PreferenceBundles
ImmortalizerPrefs_CFLAGS = -fobjc-arc
ImmortalizerPrefs_EXTRA_FRAMEWORKS = AltList

include $(THEOS_MAKE_PATH)/bundle.mk
