//
//  CapturePreviewView.h
//  AVScreenShack
//
//  Created by Sergei Klimov on 3/11/16.
//
//

#import <Cocoa/Cocoa.h>
#import "PropCoords.h"

@class CapturePreviewView;
@protocol CapturePreviewViewDelegate <NSObject>
- (void)caputurePreview:(CapturePreviewView *)cp wasClickedAtPoint:(PPoint*)point;
- (void)caputurePreview:(CapturePreviewView *)cp wasDraggedFrom:(PPoint *)from to:(PPoint *)to;
@end
@interface CapturePreviewView : NSView
@property (weak) IBOutlet id<CapturePreviewViewDelegate> delegate;
@end
