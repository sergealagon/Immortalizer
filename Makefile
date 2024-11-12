TARGET := iphone:clang:16.5:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Immortalizer

Immortalizer_FILES = Tweak.xm Immortalizer.m CustomToastView.m 
Immortalizer_FRAMEWORKS = UIKit CoreGraphics
Immortalizer_PRIVATE_FRAMEWORKS = UIKitCore FrontBoardServices BackBoardServices FrontBoard
Immortalizer_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += ImmortalizerPrefs
SUBPROJECTS += ImmortalizerCC
include $(THEOS_MAKE_PATH)/aggregate.mk