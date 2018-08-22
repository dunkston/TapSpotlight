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
	fakeHomeBar = [[FakeHomeBarWindow alloc] initWithFrame:
		CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 35,
		[[UIScreen mainScreen] bounds].size.width, 35)];

	fakeHomeBar.opaque = NO;
	fakeHomeBar.windowLevel = UIWindowLevelStatusBar;
	fakeHomeBar.backgroundColor = [UIColor colorWithWhite: 1 alpha: 0.001];
	fakeHomeBar.alpha = 0.011;
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