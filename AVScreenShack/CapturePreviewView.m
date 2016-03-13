//
//  CapturePreviewView.m
//  AVScreenShack
//
//  Created by Sergei Klimov on 3/11/16.
//
//

#import "CapturePreviewView.h"
#import <AVFoundation/AVFoundation.h>

@implementation CapturePreviewView

- (AVCaptureVideoPreviewLayer*)captureLayer {
    CALayer *captureLayer = nil;
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
            captureLayer = layer;
            break;
        }
    }
    return captureLayer;
}
- (CGPoint)pointInCaptureLevelCoords:(NSPoint)point {



    NSPoint root_point = [self convertPointToBase:point];
    CGPoint layer_point = [self.layer convertPoint: NSPointToCGPoint(root_point) toLayer:[self captureLayer]];
    return layer_point;
}



- (CGPoint)pointOfCaptureLayerInInputCoords:(CGPoint)pointLayer {

    AVCaptureScreenInput *input =[self captureLayer].session.inputs[0];
    CGRect cropRect = [input cropRect];
    CGSize layerSize = [self captureLayer].frame.size;
    CGFloat scale = cropRect.size.width/layerSize.width;
    return CGPointMake(pointLayer.x*scale, pointLayer.y*scale);
    
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];

    if ([theEvent type]==NSRightMouseDown) {
        if ([self.delegate respondsToSelector:@selector(caputurePreview:wasClickedAtPoint:)])
            [self.delegate caputurePreview:self wasClickedAtPoint:[self pointOfCaptureLayerInInputCoords:[self pointInCaptureLevelCoords:mouseLoc]]];
        
        return;
    }

}
- (void)mouseDown:(NSEvent *)theEvent {
    
    
    BOOL keepOn = YES;
    BOOL isInside = YES;
    NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
//    NSLog(@"down %f, %f", mouseLoc.x,mouseLoc.y);


    
    CGPoint from = [self pointInCaptureLevelCoords:mouseLoc];
    CGPoint to = [self pointInCaptureLevelCoords:mouseLoc];

    CALayer *overlay = [[CALayer alloc] init];
    overlay.frame = CGRectMake(from.x, from.y, to.x-from.x, to.y-from.y);

    [[self captureLayer] addSublayer:overlay];
    overlay.backgroundColor = [NSColor purpleColor].CGColor;
    overlay.opacity = 0.3;
    overlay.zPosition = 1000;
    while (keepOn) {
        theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask |
                    NSLeftMouseDraggedMask];
        mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        isInside = [self mouse:mouseLoc inRect:[self bounds]];
        to = [self pointInCaptureLevelCoords:mouseLoc];
        overlay.frame = CGRectMake(from.x, from.y, to.x-from.x, to.y-from.y);

        switch ([theEvent type]) {
            case NSLeftMouseDown:
                break;
            case NSLeftMouseDragged:
//                NSLog(@"drag %f, %f", mouseLoc.x,mouseLoc.y);
                break;
            case NSLeftMouseUp:
                if (isInside) {
//                    NSLog(@"up %f, %f", mouseLoc.x,mouseLoc.y);

                };
                keepOn = NO;
                break;
            default:
                /* Ignore any other kind of event. */
                break;
        }
        

        
    };
    [overlay removeFromSuperlayer];
    
    if ([self.delegate respondsToSelector:@selector(caputurePreview:wasDraggedFrom:to:)])
        [self.delegate caputurePreview:self wasDraggedFrom:from to:to];

    return;
}
@end
