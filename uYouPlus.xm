#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import "Header.h"
#import "Tweaks/YouTubeHeader/YTVideoQualitySwitchOriginalController.h"
#import "Tweaks/YouTubeHeader/YTPlayerViewController.h"
#import "Tweaks/YouTubeHeader/YTWatchController.h"
#import "Tweaks/YouTubeHeader/YTIGuideResponse.h"
#import "Tweaks/YouTubeHeader/YTIGuideResponseSupportedRenderers.h"
#import "Tweaks/YouTubeHeader/YTIPivotBarSupportedRenderers.h"
#import "Tweaks/YouTubeHeader/YTIPivotBarRenderer.h"
#import "Tweaks/YouTubeHeader/YTIBrowseRequest.h"
#import "Tweaks/YouTubeHeader/YTCommonColorPalette.h"
#import "Tweaks/YouTubeHeader/ASCollectionView.h"
#import "Tweaks/YouTubeHeader/YTPlayerOverlay.h"
#import "Tweaks/YouTubeHeader/YTPlayerOverlayProvider.h"

// Tweak's bundle for Localizations support - @PoomSmart - https://github.com/PoomSmart/YouPiP/commit/aea2473f64c75d73cab713e1e2d5d0a77675024f
NSBundle *uYouPlusBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
 	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"uYouPlus" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:tweakBundlePath];
    });
    return bundle;
}
NSBundle *tweakBundle = uYouPlusBundle();

# pragma mark - Tweaks

// Workaround for https://github.com/MiRO92/uYou-for-YouTube/issues/12
%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)arg1 { %orig(nil); }
%end

// Workaround for https://github.com/MiRO92/uYou-for-YouTube/issues/94
%hook YTELMView
%new
- (id)entry {
  return nil;
}
%end

// Workaround for https://github.com/MiRO92/uYou-for-YouTube/issues/140
%hook YTLocalPlaybackController
%new
- (id)activeVideoController {
  return [self activeVideo];
}
%end

// YTClassicVideoQuality: https://github.com/PoomSmart/YTClassicVideoQuality
%hook YTVideoQualitySwitchControllerFactory
- (id)videoQualitySwitchControllerWithParentResponder:(id)responder {
    Class originalClass = %c(YTVideoQualitySwitchOriginalController);
    return originalClass ? [[originalClass alloc] initWithParentResponder:responder] : %orig;
}
%end

%hook YTInterstitialPromoEventGroupHandler
- (void)addEventHandlers {}
%end

%hook YTPromosheetEventGroupHandler
- (void)addEventHandlers {}
%end

%hook YTPromoThrottleController
- (BOOL)canShowThrottledPromo { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCap:(id)arg1 { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCaps:(id)arg1 { return NO; }
%end

%hook YTIShowFullscreenInterstitialCommand
- (BOOL)shouldThrottleInterstitial { return YES; }
%end

%hook YTSurveyController
- (void)showSurveyWithRenderer:(id)arg1 surveyParentResponder:(id)arg2 {}
%end

// Enable Shorts scroll bar - @level3tjg - https://reddit.com/r/jailbreak/comments/v29yvk/_/iasl1l0/
%hook YTReelPlayerViewController
- (BOOL)shouldEnablePlayerBar { return YES; }
%end

// Workaround for issue #54
%hook YTMainAppVideoPlayerOverlayViewController
- (void)updateRelatedVideos {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"relatedVideosAtTheEndOfYTVideos"] == NO) {}
    else { return %orig; }
}
%end 

// uYou's slide settings?
%hook FRPSliderCell
- (void)didMoveToWindow {
    %orig;
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        MSHookIvar<UILabel *>(self, "_lLabel").textColor = [UIColor whiteColor];
        MSHookIvar<UILabel *>(self, "_rLabel").textColor = [UIColor whiteColor];
        MSHookIvar<UILabel *>(self, "_cLabel").textColor = [UIColor whiteColor];
    }
}
%end

%hook YTInlineMutedPlaybackPlayerOverlayViewController
- (void)setPaidContentWithPlayerData:(id)data {
    if (hidePaidPromotionCard()) {}
    else { return %orig; }
}
%end

# pragma mark - IAmYouTube - https://github.com/PoomSmart/IAmYouTube/
%hook YTVersionUtils
+ (NSString *)appName { return YT_NAME; }
+ (NSString *)appID { return YT_BUNDLE_ID; }
%end

%hook GCKBUtils
+ (NSString *)appIdentifier { return YT_BUNDLE_ID; }
%end

%hook GPCDeviceInfo
+ (NSString *)bundleId { return YT_BUNDLE_ID; }
%end

%hook OGLBundle
+ (NSString *)shortAppName { return YT_NAME; }
%end

%hook GVROverlayView
+ (NSString *)appName { return YT_NAME; }
%end

%hook OGLPhenotypeFlagServiceImpl
- (NSString *)bundleId { return YT_BUNDLE_ID; }
%end

%hook SSOConfiguration
- (id)initWithClientID:(id)clientID supportedAccountServices:(id)supportedAccountServices {
    self = %orig;
    [self setValue:YT_NAME forKey:@"_shortAppName"];
    [self setValue:YT_BUNDLE_ID forKey:@"_applicationIdentifier"];
    return self;
}
%end

%hook NSBundle
- (NSString *)bundleIdentifier {
    NSArray *address = [NSThread callStackReturnAddresses];
    Dl_info info = {0};
    if (dladdr((void *)[address[2] longLongValue], &info) == 0)
        return %orig;
    NSString *path = [NSString stringWithUTF8String:info.dli_fname];
    if ([path hasPrefix:NSBundle.mainBundle.bundlePath])
        return YT_BUNDLE_ID;
    return %orig;
}
- (id)objectForInfoDictionaryKey:(NSString *)key {
    if ([key isEqualToString:@"CFBundleIdentifier"])
        return YT_BUNDLE_ID;
    if ([key isEqualToString:@"CFBundleDisplayName"] || [key isEqualToString:@"CFBundleName"])
        return YT_NAME;
    return %orig;
}
%end
%end

// iOS 16 uYou crash fix - @level3tjg: https://github.com/qnblackcat/uYouPlus/pull/224
%group iOS16
%hook OBPrivacyLinkButton
%new
- (instancetype)initWithCaption:(NSString *)caption
                     buttonText:(NSString *)buttonText
                          image:(UIImage *)image
                      imageSize:(CGSize)imageSize
                   useLargeIcon:(BOOL)useLargeIcon {
  return [self initWithCaption:caption
                    buttonText:buttonText
                         image:image
                     imageSize:imageSize
                  useLargeIcon:useLargeIcon
               displayLanguage:[NSLocale currentLocale].languageCode];
}
%end
%end

# pragma mark - ctor
%ctor {
    %init;
    if (![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"relatedVideosAtTheEndOfYTVideos"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"relatedVideosAtTheEndOfYTVideos"]; 
    }
    if (@available(iOS 16, *)) {
       %init(iOS16);
    }
}
