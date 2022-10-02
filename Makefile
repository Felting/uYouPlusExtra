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
