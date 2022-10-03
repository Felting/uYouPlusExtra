TARGET = iphone:clang:latest:13.0
uYouPlus_USE_FLEX = 0
uYouPlus_USE_FISHHOOK = 0
ARCHS = arm64
MODULES = jailed
FINALPACKAGE = 1
CODESIGN_IPA = 0

TWEAK_NAME = uYou 2.1
DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube

uYou_INJECT_DYLIBS = Tweaks/uYou/Library/MobileSubstrate/DynamicLibraries/uYou.dylib
uYou_FILES =
uYou_IPA = ./tmp/Payload/YouTube.app
uYou_FRAMEWORKS = UIKit Security
uYou_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
        @echo -e "==> \033[1mMoving tweak's bundle to Resources/...\033[0m"
        @mkdir -p Resources/Frameworks/Alderis.framework && find .theos/obj/install/Library/Frameworks/Alderis.framework -maxdepth 1 -type f -exec cp {} Resources/Frameworks/Alderis.framework/ \
        @cp -R Tweaks/uYou/Library/Application\ Support/uYouBundle.bundle Resources/
