#import "SetupLSWelcomeScrollView.h" 


@implementation SetupLSWelcomeScrollView

-(SetupLSWelcomeScrollView*)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if(self){
		_touchedThis = FALSE;
	}
	return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

// If not dragging, send event to next responder
	NSLog(@"SetupLSWelcomeScrollView - touchesBegan");
	self.touchedThis = TRUE;
  if (!self.dragging){ 
    //[self.nextResponder touchesBegan: touches withEvent:event]; 
  }
  else{
    [super touchesBegan: touches withEvent: event];
  }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{

// If not dragging, send event to next responder
    if (!self.dragging){ 
     [self.nextResponder touchesMoved: touches withEvent:event]; 
   }
   else{
     [super touchesMoved: touches withEvent: event];
   }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
NSLog(@"SetupLSWelcomeScrollView - touchesBegan");
  // If not dragging, send event to next responder
self.touchedThis = FALSE;
   if (!self.dragging){ 
    // [self.nextResponder touchesEnded: touches withEvent:event]; 
   }
   else{
     [super touchesEnded: touches withEvent: event];
   }
}
@end