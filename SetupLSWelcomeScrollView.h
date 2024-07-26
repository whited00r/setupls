#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SetupLSWelcomeScrollView : UIScrollView{ //Super long names
	
}
@property (nonatomic, assign) BOOL touchedThis;
-(SetupLSWelcomeScrollView*)initWithFrame:(CGRect)frame;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end