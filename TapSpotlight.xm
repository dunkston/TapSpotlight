@interface AXSpringBoardServer
	+ (id)server;
	- (void)revealSpotlight;
@end

UITapGestureRecognizer *doubleTapGesture;

%hook SBIconContentView

	- (void)layoutSubviews {
		doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openSpotlight:)];
		doubleTapGesture.numberOfTapsRequired = 2;
		[self addGestureRecognizer:doubleTapGesture];
		[doubleTapGesture release];

		%orig;
	}

	%new

	- (void)openSpotlight:(UITapGestureRecognizer *)sender {
		CGPoint touchLocation = [sender locationInView: nil];
		if(touchLocation.y >= 775) [(AXSpringBoardServer *)[%c(AXSpringBoardServer) server] revealSpotlight];
	}

%end