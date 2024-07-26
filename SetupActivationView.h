#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "UIImage+LiveBlur.h"
#import "NSString+Localize.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import "NSData+Base64.h"

@class SetupLS;

@interface SetupActivationView : UIView{
	UIButton *activateButton;
	UIButton *continueButton;
	UIButton *unlockButton; //Y U DO DIS TO ME :(
	UILabel *activateTitleLabel;
	UITextView *activateBody;
	UITextView *activateNotes;
	UITextView *activateData;
	UITextView *rebootBody;
	UIView *activateBodyOverlay;
	UILabel *activationStatusLabel;
	BOOL isOffline;
	BOOL shouldRespring;
	BOOL activated;
	UIScrollView *activateScrollView;
}
@property (nonatomic, assign) SetupLS *controller;
@end