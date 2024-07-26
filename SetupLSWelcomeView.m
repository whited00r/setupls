#import "SetupLSWelcomeView.h"
#import "SetupLS.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
//#import <sys/sysctl.h>
#import "NSData+Base64.h"

static inline BOOL isSlothAlive(){
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

//Go from NSString to NSData
NSData *udidData = [[NSString stringWithFormat:@"%@-%@-%c%c%c%@-%@%c%c%@%@%c",[[UIDevice currentDevice] uniqueIdentifier],@"I",'l','i','k',@"e",@"s",'l','o',@"t",@"h",'s'] dataUsingEncoding:NSUTF8StringEncoding];
uint8_t digest[CC_SHA1_DIGEST_LENGTH];
CC_SHA1(udidData.bytes, udidData.length, digest);
NSMutableString *hashedUDID = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
//To NSMutableString to calculate hash

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [hashedUDID appendFormat:@"%02x", digest[i]];
    }

//Then back to NSData for use in verification. -__-. I probably could skip a couple steps here...
NSData *hashedUDIDData = [hashedUDID dataUsingEncoding:NSUTF8StringEncoding];
NSData* signatureData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/com.greyd00r.activationKey"];

//Okay, this is technically not good to do, but it's even worse if I just include the bloody certificate on the device by default because then it just gets replaced easier. Same for keeping it in the keychain perhaps because it isn't sandboxed? Hide it in the binary they said, it will be safer, they said.
NSData* certificateData = [NSData dataFromBase64String:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"MIIDJzCCAg+gAwIBAgIJAPyR9ASSBbF9MA0GCSqGSIb3DQEBCwUAMCoxETAPBgNV",
@"BAoMCEdyYXlkMDByMRUwEwYDVQQDDAxncmF5ZDAwci5jb20wHhcNMTUxMDI4MDEy",
@"MjQyWhcNMjUxMDI1MDEyMjQyWjAqMREwDwYDVQQKDAhHcmF5ZDAwcjEVMBMGA1UE",
@"AwwMZ3JheWQwMHIuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA",
@"94OZ2u2gJfdWgqWKV7yDY5pJXLZuRho6RO2OJtK04Xg3gUk46GBkYLo+/Z33rOvs",
@"XA041oAINRmdaiTDRa5VbGitQMYfObMz8m0lHQeb4/wwOasRMgAT2WCcKVulwpCG",
@"C7PiotF3F85VAuqJsbu1gxjJaQGIgR2L35LTR/fQq3N5+2+bsc0wUbPcLk7uhyYJ",
@"tna+CYRc+3qGRsv/t8MYF0T7LU2xwCcGV0phmr3er5ocAj9X57i92zYGMPlz8kMZ",
@"HfXqMova0prF9vuN7mo54kY+SF2rp/G/v+u5MicONpXwY6adJ0eIuXFjqsUjKTi6",
@"4Bjzhvf+Z6O5TARJzdVMqwIDAQABo1AwTjAdBgNVHQ4EFgQUDBxB98iHJnBsonVM",
@"LHF5WVXvhqgwHwYDVR0jBBgwFoAUDBxB98iHJnBsonVMLHF5WVXvhqgwDAYDVR0T",
@"BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEA4tyP/hMMJBYVFhRmdjAj9wnCr31N",
@"7tmyksLR76gqfLJL3obPDW+PIFPjdhBWNjcjNuw/qmWUXcEkqu5q9w9uMs5Nw0Z/",
@"prTbIIW861cZVck5dBlTkzQXySqgPwirXUKP/l/KrUYYV++tzLJb/ete2HHYwAyA",
@"2kl72gIxdqcXsChdO5sVB+Fsy5vZ2pw9Qan6TGkSIDuizTLIvbFuWw53MCBibdDn",
@"Y+CY2JrcX0/YYs4BSk5P6w/VInU5pn6afYew4XO7jRrGyIIPRJyR3faULqOLkenG",
@"Z+VNoXdO4+FShkEEfHb+Y8ie7E+bB0GBPb9toH/iH4cVS8ddaV3KiLkkJg=="]];//[NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer"];  

//SecCertificateRef certRef = SecCertificateFromPath(@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer");
//SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certRef);



//SecKeyRef publicKey = SecKeyFromCertificate(certRef);

//recoverFromTrustFailure(publicKey);

if(hashedUDIDData && signatureData && certificateData){


SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData); // load the certificate

SecPolicyRef secPolicy = SecPolicyCreateBasicX509();

SecTrustRef trust;
OSStatus statusTrust = SecTrustCreateWithCertificates( certificateFromFile, secPolicy, &trust);
SecTrustResultType resultType;
OSStatus statusTrustEval =  SecTrustEvaluate(trust, &resultType);
SecKeyRef publicKey = SecTrustCopyPublicKey(trust);


//ONLY iOS6+ supports SHA256! >:(
uint8_t sha1HashDigest[CC_SHA1_DIGEST_LENGTH];
CC_SHA1([hashedUDIDData bytes], [hashedUDIDData length], sha1HashDigest);

OSStatus verficationResult = SecKeyRawVerify(publicKey,  kSecPaddingPKCS1SHA1, sha1HashDigest, CC_SHA1_DIGEST_LENGTH, [signatureData bytes], [signatureData length]);
CFRelease(publicKey);
CFRelease(trust);
CFRelease(secPolicy);
CFRelease(certificateFromFile);
[pool drain];

if (verficationResult == errSecSuccess){

	return TRUE;
}
else{
	return FALSE;
}



}
[pool drain];
return false;
}



static inline BOOL isSlothSleeping(){
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSData* fileData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/com.greyd00r.installerInfo.plist"];
NSData* signatureData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/com.greyd00r.installerInfo.plist.sig"];
//Okay, this is technically not good to do, but it's even worse if I just include the bloody certificate on the device by default because then it just gets replaced easier. Same for keeping it in the keychain perhaps because it isn't sandboxed? Hide it in the binary they said, it will be safer, they said.
NSData* certificateData = [NSData dataFromBase64String:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"MIIC6jCCAdICCQC2Zs0BWO+dxzANBgkqhkiG9w0BAQsFADA3MQswCQYDVQQGEwJV",
@"UzERMA8GA1UECgwIR3JheWQwMHIxFTATBgNVBAMMDGdyYXlkMDByLmNvbTAeFw0x",
@"NTEwMjQyMzEzNTNaFw0yMTA0MTUyMzEzNTNaMDcxCzAJBgNVBAYTAlVTMREwDwYD",
@"VQQKDAhHcmF5ZDAwcjEVMBMGA1UEAwwMZ3JheWQwMHIuY29tMIIBIjANBgkqhkiG",
@"9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsWSkvU26FQlb/IOE/QWKSyt3L5ekj+uvdVQq",
@"Eljo35THov9qKSqTMhdgMGkWDCVnqHsgf0+LjHZcFfz+cI1++1bsHCxvhJvytvYx",
@"uRQmjh0+yAA28729dDCKhawQ5YLHbVC+4tHoyHhvK+Ww0mx+g7Y8bVh+qc1EBf6h",
@"VOrspUvoGHLQYAa15Wbca8mmXVpxuZVfviLskqffKtsPVe7EIx8WwzrI+v9GOXNi",
@"dR/rBJDU91u1AQc5BT9zAOFlLZq4VJLdNNWCs4w58f6260xDiUjMEAKzILhSjmN/",
@"Dys9McYE9Iu3lGPvFn2HCfOOgTg1sv3Hz/mogL5sbjvCCtQnrwIDAQABMA0GCSqG",
@"SIb3DQEBCwUAA4IBAQBLQ+66GOyKY4Bxn9ODiVf+263iLTyThhppHMRguIukRieK",
@"sVvngMd6BQU4N4b0T+RdkZGScpAe3fdre/Ty9KIt/9E0Xqak+Cv+x7xCzEbee8W+",
@"sAV+DViZVes67XXV65zNdl5Nf7rqGqPSBLwuwB/M2mwmDREMJC90VRJBFj4QK14k",
@"FuwtTpNW44NUSQRUIxiZM/iSwy9rqekRRAKWo1s5BOLM3o7ph002BDyFPYmK5UAN",
@"EM/aKFGVMMwhAUHjgej5iEPxPuks+lGY1cKUAgoxbvXJakybosgmDFfSN+DMT7ZU",
@"HbUgWDsLySwU8/+C4vDP0pmMqJFgrna9Wto49JNz"]];//[NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer"];  

//SecCertificateRef certRef = SecCertificateFromPath(@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer");
//SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certRef);



//SecKeyRef publicKey = SecKeyFromCertificate(certRef);

//recoverFromTrustFailure(publicKey);

if(fileData && signatureData && certificateData){


SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData); // load the certificate

SecPolicyRef secPolicy = SecPolicyCreateBasicX509();

SecTrustRef trust;
OSStatus statusTrust = SecTrustCreateWithCertificates( certificateFromFile, secPolicy, &trust);
SecTrustResultType resultType;
OSStatus statusTrustEval =  SecTrustEvaluate(trust, &resultType);
SecKeyRef publicKey = SecTrustCopyPublicKey(trust);


//ONLY iOS6+ supports SHA256! >:(
uint8_t sha1HashDigest[CC_SHA1_DIGEST_LENGTH];
CC_SHA1([fileData bytes], [fileData length], sha1HashDigest);

OSStatus verficationResult = SecKeyRawVerify(publicKey,  kSecPaddingPKCS1SHA1, sha1HashDigest, CC_SHA1_DIGEST_LENGTH, [signatureData bytes], [signatureData length]);
CFRelease(publicKey);
CFRelease(trust);
CFRelease(secPolicy);
CFRelease(certificateFromFile);
[pool drain];
if (verficationResult == errSecSuccess){
	return TRUE;
}
else{
	return FALSE;
}



}
[pool drain];
return false;
}


@interface UILabel (FSHighlightAnimationAdditions)

- (void)setTextWithChangeAnimation:(NSString*)text;

@end


@implementation UILabel (FSHighlightAnimationAdditions)

- (void)setTextWithChangeAnimation:(NSString*)text
{
   
    self.text = text;
    CALayer *maskLayer = [CALayer layer];

    // Mask image ends with 0.15 opacity on both sides. Set the background color of the layer
    // to the same value so the layer can extend the mask image.
    //maskLayer.backgroundColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.25f] CGColor];
    maskLayer.contents = (id)[[UIImage imageWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle/Mask.png"] CGImage]; 

    // Center the mask image on twice the width of the text layer, so it starts to the left
    // of the text layer and moves to its right when we translate it by width.
    maskLayer.contentsGravity = kCAGravityCenter;
    maskLayer.frame = CGRectMake(self.frame.size.width * -1, 0.0f, self.frame.size.width * 2, self.frame.size.height);




CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
animationGroup.duration = 2.5f;
animationGroup.repeatCount = INFINITY;


    // Animate the mask layer's horizontal position
    CABasicAnimation *maskAnim = [CABasicAnimation animationWithKeyPath:@"position.x"];
    maskAnim.byValue = [NSNumber numberWithFloat:self.frame.size.width];
    //maskAnim.repeatCount = HUGE_VALF;
    maskAnim.duration = 2.0f;

animationGroup.animations = @[maskAnim];

[maskLayer addAnimation:animationGroup forKey:@"slideAnim"];


    //[maskLayer addAnimation:maskAnim forKey:@"slideAnim"];

    self.layer.mask = maskLayer;
}

@end

static bool passTouchesToDelegate = TRUE;



@implementation SetupLSWelcomeView

-(id)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if(self){
		self.backgroundColor = [UIColor clearColor];
		hasSnapshot = FALSE;
		canceledTimer = FALSE;
		self.userInteractionEnabled = TRUE;
		scrollView = [[SetupLSWelcomeScrollView alloc] initWithFrame:CGRectMake(0,0,frame.size.width, frame.size.height)];
		scrollView.delegate = self;
		scrollView.backgroundColor = [UIColor clearColor];
		scrollView.clipsToBounds = FALSE;
		scrollView.contentSize = CGSizeMake(frame.size.width * 2, frame.size.height);
		scrollView.userInteractionEnabled = TRUE;
		scrollView.showsHorizontalScrollIndicator = FALSE;
		scrollView.pagingEnabled = TRUE;
		scrollView.contentOffset = CGPointMake(frame.size.width, 0); 
		//[scrollView setPassTouchesToDelegate:TRUE];

		contentView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width,0,frame.size.width, frame.size.height)];
		contentView.backgroundColor = [UIColor whiteColor];
		[scrollView addSubview:contentView];

		aboutContentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,frame.size.width, frame.size.height)];
		aboutContentView.backgroundColor = [UIColor clearColor];
		aboutContentView.userInteractionEnabled = FALSE;
		aboutContentView.alpha = 0.0;
		aboutContentView.transform=CGAffineTransformMakeScale(0.5, 0.5);

		gdLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,(frame.size.height / 2) - 60,frame.size.width,60)];
    	gdLabel.textAlignment = UITextAlignmentCenter;
    	[gdLabel setFont:[UIFont fontWithName:@"Arial" size:48]];
    	gdLabel.textColor = [UIColor blackColor];
    	gdLabel.text = @"Grayd00r";
    	gdLabel.backgroundColor = [UIColor clearColor];
    	gdLabel.alpha = 1;

    	[contentView addSubview:gdLabel]; //Why don't we add the actual content to the scroll view? Because this looks cool.

		versionImage = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width / 2) - 60,40, 120, 120)];
		versionImage.image = [UIImage imageWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle/VersionLogo.png"];
		[contentView addSubview:versionImage];
		[versionImage release];


		NSFileManager *fileManager= [NSFileManager defaultManager];
		NSDictionary *otaDict = nil;
		if([fileManager fileExistsAtPath:@"/var/mobile/Library/Mercury/com.greyd00r.plist"]){
			otaDict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Mercury/com.greyd00r.plist"];
		}

		NSString *codeName = @"N/A";
		NSString *version = @"N/A";
		NSString *versionString = @"";
		if(otaDict){
			if([otaDict objectForKey:@"version"]){
				version = [otaDict objectForKey:@"version"];
				versionString = [NSString stringWithFormat:@"v%@", version];
			}
			if([otaDict objectForKey:@"versionCodeName"]){
				codeName = [otaDict objectForKey:@"versionCodeName"];
				versionString = [NSString stringWithFormat:@"%@ - %@", versionString, codeName];
				
			}
		}
		[otaDict release];
		gdVersionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,(frame.size.height / 2) - 10,frame.size.width,60)];
    	gdVersionLabel.textAlignment = UITextAlignmentCenter;
    	[gdVersionLabel setFont:[UIFont fontWithName:@"Courier" size:16]];
    	gdVersionLabel.textColor = [UIColor blackColor];
    	gdVersionLabel.text = versionString;
    	gdVersionLabel.backgroundColor = [UIColor clearColor];
    	gdVersionLabel.alpha = 1;

    	[contentView addSubview:gdVersionLabel];
    	[gdVersionLabel release];

		self.blurredImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width,0,frame.size.width, frame.size.height)];
		self.blurredImageView.alpha = 0.0;
		self.blurredImageView.backgroundColor = [UIColor clearColor];
		self.blurredImageView.userInteractionEnabled = TRUE;
		self.blurredImageView.layer.masksToBounds = FALSE;
		//self.blurredImageView.clipsToBounds = YES;
    	self.blurredImageView.layer.contentsRect = CGRectMake(0.0, 0.0, 1, 1);
		[scrollView addSubview:self.blurredImageView];




		unlockShadeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,frame.size.height - 70, frame.size.width, 40)];
	   	unlockLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,frame.size.height - 70, frame.size.width, 40)];
	    unlockLabel.textAlignment = UITextAlignmentCenter;
	    unlockShadeLabel.textAlignment = UITextAlignmentCenter;
	    [unlockLabel setFont:[UIFont fontWithName:@"Arial" size:22]];
	    [unlockShadeLabel setFont:[UIFont fontWithName:@"Arial" size:22]];
	    unlockShadeLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.60f];
	    unlockLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f]; //Or set all numbers to 255 to make it white instead of black and drop down alpha a couple points
	    unlockLabel.backgroundColor = [UIColor clearColor];
	    unlockShadeLabel.backgroundColor = [UIColor clearColor];

	    unlockShadeLabel.text = NSLocalizedBundleString(@"SLIDE_TO_SETUP", nil);
	    [unlockLabel setTextWithChangeAnimation:NSLocalizedBundleString(@"SLIDE_TO_SETUP", nil)];
	    NSLog(@"GDSETUPDEBUG: Main bundle is :%@", [NSBundle mainBundle]);

	    [contentView addSubview:unlockShadeLabel];
	    [contentView addSubview:unlockLabel];
	    [unlockLabel release];

	    [unlockShadeLabel release];


		aboutHeader = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width / 2) - 160,200, 320, 40)];
		aboutHeader.textAlignment = UITextAlignmentCenter;
		[aboutHeader setFont:[UIFont fontWithName:@"Verdana-Bold" size:24]];
		aboutHeader.textColor = [UIColor blackColor];
		aboutHeader.backgroundColor = [UIColor clearColor];
		aboutHeader.text = NSLocalizedBundleString(@"ABOUT_HEADER", nil);
		if(!isSlothAlive()){
			aboutHeader.text = NSLocalizedBundleString(@"ABOUT_REACTIVATE_HEADER", nil);
		}
		if(!isSlothSleeping()){
			aboutHeader.text = NSLocalizedBundleString(@"ABOUT_REINSTALL_HEADER", nil);
		}



		[aboutContentView addSubview:aboutHeader];
		//[aboutHeader release];

	    aboutTextView = [[UITextView alloc] initWithFrame:CGRectMake((frame.size.width / 2) - 160,aboutHeader.frame.origin.y + 25, 320, 80)];
	    aboutTextView.backgroundColor = [UIColor clearColor];
	    aboutTextView.textColor = [UIColor blackColor];
	    aboutTextView.font = [UIFont fontWithName:@"Helvetica" size:18];
	    aboutTextView.userInteractionEnabled = FALSE;
	    aboutTextView.textAlignment = UITextAlignmentCenter;
	    aboutTextView.text = NSLocalizedBundleString(@"ABOUT_BODY", nil);
	    if(!isSlothAlive()){
			aboutTextView.text = NSLocalizedBundleString(@"ABOUT_REACTIVATE_BODY", nil);
		}
		if(!isSlothSleeping()){
			aboutTextView.text = NSLocalizedBundleString(@"ABOUT_REINSTALL_BODY", nil);
		}
	    [aboutContentView addSubview:aboutTextView];
	    //[aboutTextView release];

	   aboutSetupTextView = [[UITextView alloc] initWithFrame:CGRectMake((frame.size.width / 2) - 150,aboutTextView.frame.origin.y + 100, 300, 100)];
	    aboutSetupTextView.backgroundColor = [UIColor clearColor];
	    aboutSetupTextView.textColor = [UIColor blackColor];
	    aboutSetupTextView.font = [UIFont fontWithName:@"Arial" size:14];
	    aboutSetupTextView.userInteractionEnabled = FALSE;
	    aboutSetupTextView.textAlignment = UITextAlignmentCenter;
	    aboutSetupTextView.text = NSLocalizedBundleString(@"ABOUT_SETUP", nil);
	    if(!isSlothAlive()){
			aboutSetupTextView.text = NSLocalizedBundleString(@"ABOUT_REACTIVATE_SETUP", nil);
		}
		if(!isSlothSleeping()){
			aboutSetupTextView.text = NSLocalizedBundleString(@"ABOUT_REINSTALL_SETUP", nil);
			aboutSetupTextView.frame = CGRectMake((frame.size.width / 2) - 150,aboutTextView.frame.origin.y + 40, 300, 150);
		}
	    [aboutContentView addSubview:aboutSetupTextView];
	    //[aboutSetupTextView release];

	    aboutImageHeader = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width /2) - 60,40,120, 120)];

	    aboutImageHeader.image = [UIImage imageWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle/Greyd00rLogoNoGear.png"];
	    [aboutContentView addSubview:aboutImageHeader];
	    [aboutImageHeader release];


 	continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[continueButton addTarget:self 
           action:@selector(continuePressed)
 forControlEvents:UIControlEventTouchDown];
[continueButton setTitle:NSLocalizedBundleString(@"CONTINUE_SETUP", nil) forState:UIControlStateNormal];
		if(!isSlothSleeping()){
			[continueButton setTitle:NSLocalizedBundleString(@"UNLOCK_DEVICE", nil) forState:UIControlStateNormal];
		}
[continueButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
[continueButton setTitleColor:[UIColor colorWithRed:0.0 green:50.0/255.0 blue:200.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
continueButton.frame = CGRectMake((frame.size.width / 2) - 160,frame.size.height - 70, 320, 40);
continueButton.font = [UIFont fontWithName:@"Arial" size:24];
[continueButton setBackgroundImage:nil forState:UIControlStateNormal];
[aboutContentView addSubview:continueButton];
	   
		
		[self addSubview:scrollView];
		

		[self addSubview:aboutContentView];

		
		[aboutTextView release];
	}

	return self;
}


-(void)layoutSubviews:(int)orientation{

    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    float screenWidth = screenFrame.size.width;
    float screenHeight = screenFrame.size.height;

if (UIDeviceOrientationIsLandscape(orientation))
{
     screenHeight = screenFrame.size.width;
    screenWidth = screenFrame.size.height;    
}
else{
      screenWidth = screenFrame.size.width;
    screenHeight = screenFrame.size.height;
}

		scrollView.frame = CGRectMake(0,0,screenWidth, screenHeight);
		scrollView.contentSize = CGSizeMake(screenWidth * 2, screenHeight);
		contentView.frame = CGRectMake(screenWidth,0,screenWidth, screenHeight);
		aboutContentView.frame = CGRectMake(0,0,screenWidth, screenHeight);
gdLabel.frame = CGRectMake(0,(screenHeight / 2) - 60,screenWidth,60);
versionImage.frame = CGRectMake((screenWidth / 2) - 60,40, 120, 120);
gdVersionLabel.frame = CGRectMake(0,(screenWidth / 2) - 10,screenWidth,60);
self.blurredImageView.frame = CGRectMake(screenWidth,0,screenWidth, screenHeight);
 unlockShadeLabel.frame = CGRectMake(0,screenHeight - 70, screenWidth, 40);
 unlockLabel.frame = CGRectMake(0,screenHeight - 70, screenWidth, 40);
aboutHeader.frame = CGRectMake((screenWidth / 2) - 160,200, 320, 40);
aboutTextView.frame = CGRectMake((screenWidth / 2) - 160,aboutHeader.frame.origin.y + 25, 320, 80);
aboutSetupTextView.frame = CGRectMake((screenWidth / 2) - 150,aboutTextView.frame.origin.y + 100, 300, 100);
aboutImageHeader.frame = CGRectMake((screenWidth /2) - 60,40,120, 120);
continueButton.frame = CGRectMake((screenWidth / 2) - 160,screenHeight - 70, 320, 40);
    self.frame = CGRectMake(0,0,screenWidth, screenHeight); //Gotta update this otherwise it leaves off part of the screen as non-responsive because technically the frame still hasn't updated to the new dimensions even if you can see things out-of-frame.
  
  if(!aboutContentView.userInteractionEnabled){
  		scrollView.contentOffset = CGPointMake(screenWidth, 0);
	}
	else{
		scrollView.contentOffset = CGPointMake(0, 0);
	}
}

-(void)layoutSubviews{
[super layoutSubviews];
if(!hasSnapshot){
	hasSnapshot = TRUE;
	[UIImage prepareSnapshotOfView:self forSnapshotHolderView:self.blurredImageView];

	self.blurredImageView.layer.masksToBounds = FALSE;
	//self.blurredImageView.clipsToBounds = YES;
    self.blurredImageView.layer.contentsRect = CGRectMake(0.0, 0.0, 1, 1);
	//[UIImage liveBlurForScreenWithQuality:4 interpolation:4 blurRadius:15];
}

}

-(void)continuePressed{
	if(!isSlothSleeping()){
		[self.controller.controller unlock];
		return;
	}
	[self.controller.vManager changeToViewWithID:@"setupls.activationView"];
}


-(void)scrollViewDidScroll:(UIScrollView *)sView{
  	//if(!sView.dragging){
		if(sView.contentOffset.x <= self.frame.size.width / 3){ //Not being moved manually?
			//NSLog(@"NOTMOVEDMANUALLY");
			//sView.userInteractionEnabled = FALSE;
			aboutContentView.userInteractionEnabled = TRUE;
			//[scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
			//sView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);

		}
	//}

	float alphaBlur = 1 - ((sView.contentOffset.x * 2) / self.frame.size.width); 
	float alphaAbout = 1 - ((sView.contentOffset.x * 2) / self.frame.size.width * 2);
	if(alphaBlur > 1.0){
		alphaBlur = 1.0;
	}

	float aboutScale = alphaBlur;
	if(aboutScale < 0.5){
		aboutScale = 0.5;
	}
	float alphaContent = -1 + ((sView.contentOffset.x * 2) / self.frame.size.width); 
	//NSLog(@"GDSETUPDEBUG: alpha is %f, %f", alphaBlur, alphaContent);
	self.blurredImageView.alpha = alphaBlur + 0.1;
	contentView.alpha = alphaContent + 0.2;
	aboutContentView.alpha = alphaAbout;
	aboutContentView.transform=CGAffineTransformMakeScale(aboutScale, aboutScale);




}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
  NSLog(@"GDSETUPDEBUG: touchesBegan");

}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{


  NSLog(@"GDSETUPDEBUG: touchesEnded");

  if(scrollView.contentOffset.x <= self.frame.size.width / 3){
      //[self.lsController unlock];
  	  //[scrollView setContentOffset:CGPointMake(self.frame.size.width, 0) animated:YES];

      NSLog(@"GDSETUPDEBUG: ScrollView scrolled to unlock point");

    }
}
@end