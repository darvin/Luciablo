//
//  CapturePreviewView.h
//  AVScreenShack
//
//  Created by Sergei Klimov on 3/11/16.
//
//

#import <Cocoa/Cocoa.h>
@class CapturePreviewView;
@protocol CapturePreviewViewDelegate <NSObject>
- (void)caputurePreview:(CapturePreviewView *)cp wasClickedAtPoint:(CGPoint)point;
- (void)caputurePreview:(CapturePreviewView *)cp wasDraggedFrom:(CGPoint)from to:(CGPoint)to;
@end
@interface CapturePreviewView : NSView
@property (weak) IBOutlet id<CapturePreviewViewDelegate> delegate;
@end
