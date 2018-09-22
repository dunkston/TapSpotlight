#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import <SparkAppList.h>
#import <objc/runtime.h>

//Load Preferences
@interface NSUserDefaults (TapSpot)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end
//Pref Locations
static NSString *nsDomainString = @"/var/mobile/Library/Preferences/com.midnight.tapspotpref.plist";
static NSString *nsNotificationString = @"com.midnight.tapspotpref.plist/post";

//prefs
static BOOL enableBlacklist;
static BOOL showBar;
static int width;
static int height;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSNumber *eBlack = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enableBlacklist" inDomain:nsDomainString];
	NSNumber *shBar = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"showBar" inDomain:nsDomainString];
	NSNumber *wid = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"width" inDomain:nsDomainString];
	NSNumber *hei = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"height" inDomain:nsDomainString];


// Define default state of preferences
	enableBlacklist = (eBlack)? [eBlack boolValue]:NO;
	showBar = (shBar)? [shBar boolValue]:NO;
	width = (wid)? [wid floatValue]:1;
	height = (hei)? [hei floatValue]:1;
}

@interface AXSpringBoardServer
	+ (id)server;
	- (void)revealSpotlight;
@end

@interface FakeHomeBarWindow : UIWindow
@end

@implementation FakeHomeBarWindow : UIWindow
@end

FakeHomeBarWindow *fakeHomeBar;

static void initFakeHomeBar() {
	fakeHomeBar = [[FakeHomeBarWindow alloc] initWithFrame:  //Height
		CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 35,
		[[UIScreen mainScreen] bounds].size.width/width, height)];
		//Width
	fakeHomeBar.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height);
	fakeHomeBar.opaque = NO;
	fakeHomeBar.windowLevel = UIWindowLevelStatusBar;
	if(!showBar){
		fakeHomeBar.backgroundColor = [UIColor colorWithWhite: 1 alpha: 0.001];
		fakeHomeBar.alpha = 0.011;
	}else{
		fakeHomeBar.backgroundColor = [UIColor redColor];
		fakeHomeBar.alpha = 1;
	}

	fakeHomeBar.rootViewController = [[UIViewController alloc] init];

	[fakeHomeBar makeKeyAndVisible];

	UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]
		initWithTarget: [UIScreen mainScreen]
		action: @selector(openSpotlight)];
	doubleTapGesture.numberOfTapsRequired = 2;
	[fakeHomeBar addGestureRecognizer: doubleTapGesture];
	[doubleTapGesture release];
}

%hook UIStatusBarWindow

	- (void)layoutSubviews {
		%orig;
		initFakeHomeBar();
}

%end


//Check if app is black listed. Currently use SBHomeGestureSettings because I know I can check current application from here.
%hook SBHomeGestureSettings
-(BOOL)isHomeGestureEnabled{
	SBApplication *frontApp = [(SpringBoard*)[UIApplication sharedApplication]     _accessibilityFrontMostApplication];
	if (frontApp != nil) {
		//Disable in blacklisted apps
			NSString *currentAppDisplayID = [frontApp bundleIdentifier];
			NSLog(@"HIBERT %@", currentAppDisplayID);
			if([SparkAppList doesIdentifier:@"com.midnight.tapspotpref.plist" andKey:@"excludedApps" containBundleIdentifier:currentAppDisplayID]){
				fakeHomeBar.hidden = YES;
			}else{
				//enable everywhere else
				fakeHomeBar.hidden = NO;
			}

	}else{
		//On SB
		fakeHomeBar.hidden = NO;
	}
	return %orig;
}
%end

%hook UIScreen

	- (void)_setInterfaceOrientation:(NSInteger)arg1 {
			%orig;
			fakeHomeBar.hidden = arg1 != 1;

	}

	%new

	- (void)openSpotlight {
		[(AXSpringBoardServer *)[%c(AXSpringBoardServer) server] revealSpotlight];
	}

%end

%ctor{
  notificationCallback(NULL, NULL, NULL, NULL, NULL);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
    NULL,
    notificationCallback,
    (CFStringRef)nsNotificationString,
    NULL,
    CFNotificationSuspensionBehaviorCoalesce);
}
// Lets tapping through view, but lags device

// @interface AXSpringBoardServer
// 	+ (id)server;
// 	- (void)revealSpotlight;
// @end

// static BOOL isPortrait;
// static BOOL doubleTapStarted;

// static void checkPoint(CGPoint point) {
// 	if(isPortrait && point.y >= [[UIScreen mainScreen] bounds].size.height - 35)
// 		[NSTimer scheduledTimerWithTimeInterval: 0.5
// 		    target: [UIScreen mainScreen]
// 		    selector: @selector(openSpotlight)
// 		    userInfo: nil
// 			repeats: NO];
// 	else doubleTapStarted = NO;
// }

// @interface UIScreen ()
// 	- (void)openSpotlight;
// @end

// %hook UIStatusBarWindow

// 	- (UIView *)hitTest:(CGPoint)arg1 withEvent:(UIEvent *)arg2 {
// 		checkPoint(arg1);
// 		return %orig;
// 	}

// %end

// %hook UIScreen

// 	- (void)_setInterfaceOrientation:(NSInteger)arg1 {
// 		%orig;		isPortrait = arg1 == 1;
// 	}

// 	%new

// 	- (void)openSpotlight {
// 		if(doubleTapStarted) {
// 			[(AXSpringBoardServer *)[%c(AXSpringBoardServer) server] revealSpotlight];
// 			doubleTapStarted = NO;
// 		}
// 		doubleTapStarted = YES;
// 	}

// %end
