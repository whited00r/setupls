#import "SetupLSViewManager.h"
#import "SetupLS.h"
@implementation SetupLSViewManager

-(id)init{
	self = [super init];
	if(self){

		CGRect screenFrame = [[UIScreen mainScreen] bounds]; //Get the screen size


if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
{
     screenHeight = screenFrame.size.width;
    screenWidth = screenFrame.size.height;    
}
else{
      screenWidth = screenFrame.size.width;
    screenHeight = screenFrame.size.height;
}
		viewsDict = [[NSMutableDictionary alloc] init];




	}
	return self;
}

-(void)loadUp{
		SetupLSWelcomeView *welcomeView = [[SetupLSWelcomeView alloc] initWithFrame:CGRectMake(0,0,screenWidth, screenHeight)];
		welcomeView.controller = self.controller;
    	[viewsDict addObject:welcomeView forKey:@"setupls.welcomeView"];



        SetupActivationView *activationView = [[SetupActivationView alloc] initWithFrame:CGRectMake(0,0,screenWidth, screenHeight)];
        activationView.controller = self.controller;
        [viewsDict addObject:activationView forKey:@"setupls.activationView"];
}


-(void)changeToNextView{

}

-(void)changeToPreviousView{

}

-(void)layoutSubviews:(int)orientation{
for (NSString* key in viewsDict) {
  id view = [viewsDict objectForKey:key];
  [view layoutSubviews:orientation];
}
}

-(void)changeToViewWithID:(NSString *)viewID{
	if([viewsDict objectForKey:viewID]){
		[self transitionToNewView:[viewsDict objectForKey:viewID]];
	}

}

-(void)transitionToNewView:(UIView *)newView{
	if(newView == currentView){
		NSLog(@"SETUPLSDEBUG: New view is current view! ");
		return;
	}

	newView.alpha = 0.0;
	[self.controller.view addSubview:newView];
	[self.controller.view bringSubviewToFront:self.controller.blurOverlay]; //bring the blur to the front!
	if(!self.controller.blurOverlay.image) [UIImage prepareSnapshotOfView:newView forSnapshotHolderView:self.controller.blurOverlay];

	[UIView animateWithDuration:0.25
                      delay:0.0
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                     self.controller.blurOverlay.alpha = 1.0f;
                      
                 }
                 completion:^(BOOL finished){
                  
                     if(currentView) [currentView removeFromSuperview];
                     newView.alpha = 1.0;

                     [UIView animateWithDuration:0.25
                      delay:0.0
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                     self.controller.blurOverlay.alpha = 0.0f;
                      
                 }
                 completion:^(BOOL finished){
                  
                     currentView = nil;
                     currentView = newView;
                     self.controller.blurOverlay.image = [[UIImage liveSnapshotOfScreen] fastBlurWithQuality:4 interpolation:4 blurRadius:15];
                     //[UIImage prepareSnapshotOfView:newView forSnapshotHolderView:self.controller.blurOverlay];//Blur out the old view for next time?
                 }];
                 }];
}


@end