#import "SetupLSOTASettingView.h"
#import "SetupLS.h"



@implementation SetupLSOTASettingView

-(id)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if(self){
		self.backgroundColor = [UIColor clearColor];
		
		self.userInteractionEnabled = TRUE;
		NSFileManager *fileManager= [NSFileManager defaultManager];
		if([fileManager fileExistsAtPath:@"/var/mobile/Library/Mercury/com.greyd00r.plist"]){
			otaDict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Mercury/com.greyd00r.plist"];
		}


		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width / 2) - 160,20, 320, 40)];
		titleLabel.textAlignment = UITextAlignmentCenter;
		[titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:24]];
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.text = NSLocalizedBundleString(@"OTA_SETTING_HEADER", nil);
		[self addSubview:titleLabel];
		//[aboutHeader release];

	    aboutOTATextView = [[UITextView alloc] initWithFrame:CGRectMake((frame.size.width / 2) - 160, titleLabel.frame.origin.y + 25, 320, 60)];
	    aboutOTATextView.backgroundColor = [UIColor clearColor];
	    aboutOTATextView.textColor = [UIColor blackColor];
	    aboutOTATextView.font = [UIFont fontWithName:@"Helvetica" size:16];
	    aboutOTATextView.userInteractionEnabled = FALSE;
	    aboutOTATextView.textAlignment = UITextAlignmentCenter;
	    aboutOTATextView.text = NSLocalizedBundleString(@"OTA_SETTING_BODY", nil);
	    [self addSubview:aboutOTATextView];
	    //[aboutTextView release];



	    otaGroupImage = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width /2) - 35,aboutOTATextView.frame.origin.y + 80,75, 100)];

	    otaGroupImage.image = [UIImage imageWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle/SlothNoFez.png"];
	    [self addSubview:otaGroupImage];
	    //[otaGroupImage release];

	    UIView *otaGroupBackground = [[UIView alloc] initWithFrame:CGRectMake(0,otaGroupImage.frame.origin.y + 115, frame.size.width, 45)];
	    otaGroupBackground.backgroundColor = [UIColor colorWithRed:62.0/255.0 green:78.0/255.0 blue:86.0/255.0 alpha:1.0];

	    [self addSubview:otaGroupBackground];
	    [otaGroupBackground release];

 	stableButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[stableButton addTarget:self 
           action:@selector(stablePressed)
 forControlEvents:UIControlEventTouchDown];
[stableButton setTitle:NSLocalizedBundleString(@"OTA_SETTING_STABLE_HEADER", nil) forState:UIControlStateNormal];
[stableButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
[stableButton setTitleColor:[UIColor colorWithRed:0.0 green:50.0/255.0 blue:200.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
stableButton.frame = CGRectMake((frame.size.width / 2) - ((frame.size.width / 2)),otaGroupImage.frame.origin.y + 120, frame.size.width / 2, 40);
stableButton.font = [UIFont fontWithName:@"Arial" size:24];
stableButton.alpha = 1.0; //Only show this when an OTA option has been chosen!
[stableButton setBackgroundImage:nil forState:UIControlStateNormal];
[self addSubview:stableButton];


 	betaButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[betaButton addTarget:self 
           action:@selector(betaPressed)
 forControlEvents:UIControlEventTouchDown];
[betaButton setTitle:NSLocalizedBundleString(@"OTA_SETTING_BETA_HEADER", nil) forState:UIControlStateNormal];
[betaButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
[betaButton setTitleColor:[UIColor colorWithRed:0.0 green:50.0/255.0 blue:200.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
betaButton.frame = CGRectMake((frame.size.width / 2),otaGroupImage.frame.origin.y + 120, frame.size.width / 2, 40);
betaButton.font = [UIFont fontWithName:@"Arial" size:24];
betaButton.alpha = 1.0; //Only show this when an OTA option has been chosen!
[betaButton setBackgroundImage:nil forState:UIControlStateNormal];
[self addSubview:betaButton];



	    otaOptionTextView = [[UITextView alloc] initWithFrame:CGRectMake((frame.size.width / 2) - 150,otaGroupImage.frame.origin.y + 160, 300, 140)];
	    otaOptionTextView.backgroundColor = [UIColor clearColor];
	    otaOptionTextView.textColor = [UIColor blackColor];
	    otaOptionTextView.font = [UIFont fontWithName:@"Arial" size:14];
	    otaOptionTextView.userInteractionEnabled = TRUE;
	    otaOptionTextView.textAlignment = UITextAlignmentCenter;
	    otaOptionTextView.text = NSLocalizedBundleString(@"OTA_SETTING_BETA_BODY", nil);
	    otaOptionTextView.alpha = 0.0;
	    [self addSubview:otaOptionTextView];
	    //[aboutSetupTextView release];

otaOptionTextViewOverlay = [[UIView alloc] initWithFrame:otaOptionTextView.frame];
[otaOptionTextViewOverlay setBackgroundColor:[UIColor whiteColor]];
[otaOptionTextViewOverlay setUserInteractionEnabled:NO];
[self addSubview:otaOptionTextViewOverlay];

NSArray *colors = [NSArray arrayWithObjects:
                   (id)[[UIColor colorWithWhite:0 alpha:1] CGColor],
                   (id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                   nil];

CAGradientLayer *layer = [CAGradientLayer layer];
[layer setFrame:otaOptionTextViewOverlay.bounds];
[layer setColors:colors];
[layer setStartPoint:CGPointMake(0.0f, 1.0f)];
[layer setEndPoint:CGPointMake(0.0f, 0.6f)];
[otaOptionTextViewOverlay.layer setMask:layer];
otaOptionTextViewOverlay.alpha = 0.0;




 	continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[continueButton addTarget:self 
           action:@selector(continuePressed)
 forControlEvents:UIControlEventTouchDown];
[continueButton setTitle:NSLocalizedBundleString(@"CONTINUE_SETUP", nil) forState:UIControlStateNormal];
[continueButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
[continueButton setTitleColor:[UIColor colorWithRed:0.0 green:50.0/255.0 blue:200.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
continueButton.frame = CGRectMake((frame.size.width / 2) - 160,frame.size.height - 40, 320, 40);
continueButton.font = [UIFont fontWithName:@"Arial" size:24];
continueButton.alpha = 0.0; //Only show this when an OTA option has been chosen!
[continueButton setBackgroundImage:nil forState:UIControlStateNormal];
[self addSubview:continueButton];
	   
		
		
		
	}

	return self;
}


-(void)layoutSubviews{
	[super layoutSubviews];
otaOptionTextView.editable = FALSE;


}

-(void)stablePressed{
	[UIView transitionWithView:otaGroupImage
                  duration:0.4f
                   options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^{
                  otaGroupImage.image = [UIImage imageWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle/RegalSloth.png"];
                } completion:nil];

[UIView animateWithDuration:0.25
                      delay:0.0
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                    	stableButton.userInteractionEnabled = FALSE;
                    	stableButton.alpha = 0.3;
                    	betaButton.userInteractionEnabled = TRUE;
                    	betaButton.alpha = 1.0;
                		otaOptionTextView.alpha = 0.0;
						otaOptionTextViewOverlay.alpha = 0.0;
						
						continueButton.alpha = 1.0;
                 }
                 completion:^(BOOL finished){
                 	otaOptionTextView.text = NSLocalizedBundleString(@"OTA_SETTING_STABLE_BODY", nil);
                 	[UIView animateWithDuration:0.25
                      delay:0.0
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                      	otaOptionTextView.alpha = 1.0;
						otaOptionTextViewOverlay.alpha = 1.0;

                 }
                 completion:nil];
                 }];

if(otaDict) [otaDict setObject:@"http://ota.grayd00r.com/stable" forKey:@"sourceURL"];


}

-(void)betaPressed{

[UIView transitionWithView:otaGroupImage
                  duration:0.4f
                   options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^{
                  otaGroupImage.image = [UIImage imageWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle/TestSloth.png"];
                } completion:nil];

[UIView animateWithDuration:0.25
                      delay:0.0
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                        betaButton.userInteractionEnabled = FALSE;
                    	betaButton.alpha = 0.3;
                    	stableButton.userInteractionEnabled = TRUE;
                    	stableButton.alpha = 1.0;
                        otaOptionTextView.alpha = 0.0;
						otaOptionTextViewOverlay.alpha = 0.0;
						
						continueButton.alpha = 1.0;
                 }
                 completion:^(BOOL finished){
                 	otaOptionTextView.text = NSLocalizedBundleString(@"OTA_SETTING_BETA_BODY", nil);
                 	[UIView animateWithDuration:0.25
                      delay:0.0
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                      	otaOptionTextView.alpha = 1.0;
						otaOptionTextViewOverlay.alpha = 1.0;

                 }
                 completion:nil];
                 }];
if(otaDict) [otaDict setObject:@"http://ota.grayd00r.com/beta" forKey:@"sourceURL"];
}

-(void)continuePressed{
	if(otaDict) [otaDict writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/Mercury/com.greyd00r.plist"] atomically:YES];
	[self.controller.vManager changeToNextView];
	[self.controller.controller unlock];
}


@end
