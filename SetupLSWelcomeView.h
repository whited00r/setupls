#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "UIImage+LiveBlur.h"

#import "SetupLSWelcomeScrollView.h"
#import "NSString+Localize.h"

@class SetupLS;
@interface SetupLSWelcomeView : UIView <UIScrollViewDelegate>{
	SetupLSWelcomeScrollView *scrollView;
	UIView *contentView;
	UILabel *slideLabel;
	UITextView *aboutTextView;
	UIView *aboutContentView;
	UIImageView *aboutImageHeader;
	bool hasSnapshot;
	bool canceledTimer;
	UILabel *gdLabel;
	UIImageView *versionImage;
	UILabel *gdVersionLabel;
	UILabel * unlockShadeLabel;
	UILabel* unlockLabel;
	UILabel* aboutHeader;
	UITextView * aboutSetupTextView;
	UIButton *continueButton;

}
@property (nonatomic, assign) UIImageView *blurredImageView;
@property (nonatomic, assign) SetupLS *controller;
@end