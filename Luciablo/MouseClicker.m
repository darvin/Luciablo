//
//  MouseClicker.m
//  AVScreenShack
//
//  Created by Sergei Klimov on 3/11/16.
//
//

#import "MouseClicker.h"

@implementation MouseClicker
- (void)clickInPoint:(CGPoint)clickPoint {
    float duration = 0.1;
    
    
    CGEventRef click_down = CGEventCreateMouseEvent(
                                                    NULL, kCGEventLeftMouseDown,
                                                    clickPoint,
                                                    kCGMouseButtonLeft
                                                    );
    
    CGEventRef click_up = CGEventCreateMouseEvent(
                                                  NULL, kCGEventLeftMouseUp,
                                                  clickPoint,
                                                  kCGMouseButtonLeft
                                                  );
    
    CGEventPost(kCGHIDEventTap, click_down);
    sleep(duration);
    CGEventPost(kCGHIDEventTap, click_up);
    
    // Release the events
    CFRelease(click_down);
    CFRelease(click_up);
}
@end
