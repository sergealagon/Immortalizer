TARGET := iphone:clang:13.7:14.0


include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ImmortalizerCC
ImmortalizerCC_BUNDLE_EXTENSION = bundle
ImmortalizerCC_FILES = ImmortalizerCC.m ImmortalizerCCMenu.m ../Localizer.m
ImmortalizerCC_CFLAGS = -fobjc-arc
ImmortalizerCC_FRAMEWORKS = UIKit 
ImmortalizerCC_PRIVATE_FRAMEWORKS = ControlCenterUIKit
ImmortalizerCC_INSTALL_PATH = /Library/ControlCenter/Bundles/

include $(THEOS_MAKE_PATH)/bundle.mk
