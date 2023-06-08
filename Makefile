TARGET = iphone:clang:15.5:14.0
ARCHS = arm64
MODULES = jailed
FINALPACKAGE = 1
CODESIGN_IPA = 0

TWEAK_NAME = uYou
DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube

uYouPlus_INJECT_DYLIBS = Tweaks/uYou/Library/MobileSubstrate/DynamicLibraries/uYou.dylib .theos/obj/YouPiP.dylib .theos/obj/YouTubeDislikesReturn.dylib
uYouPlus_IPA = tmp/Payload/YouTube.app
uYouPlus_FRAMEWORKS = UIKit Security

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += Tweaks/YouPiP Tweaks/Return-YouTube-Dislikes
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	@echo -e "==> \033[1mMoving tweak's bundle to Resources/...\033[0m"
        @cp -R Tweaks/YouPiP/layout/Library/Application\ Support/YouPiP.bundle Resources/
        @cp -R Tweaks/Return-YouTube-Dislikes/layout/Library/Application\ Support/RYD.bundle Resources/
	@cp -R Tweaks/uYou/Library/Application\ Support/uYouBundle.bundle Resources/
	@echo -e "==> \033[1mChanging the installation path of dylibs...\033[0m"
