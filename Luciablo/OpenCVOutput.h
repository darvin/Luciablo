//
//  OpenCVOutput.h
//  AVScreenShack
//
//  Created by Sergei Klimov on 3/11/16.
//
//

#import <Foundation/Foundation.h>
#import "PropCoords.h"

@class AVCaptureSession;
@interface OpenCVOutput : NSObject
- (id)initWithCaptureSession:(AVCaptureSession *)session;
- (void)showWindow;

- (int)highlightRect:(PRect *)rect;
- (int)highlightPoint:(PPoint *)point;
@end
