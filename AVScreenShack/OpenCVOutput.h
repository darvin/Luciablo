//
//  OpenCVOutput.h
//  AVScreenShack
//
//  Created by Sergei Klimov on 3/11/16.
//
//

#import <Foundation/Foundation.h>
@class AVCaptureSession;
@interface OpenCVOutput : NSObject
- (id)initWithCaptureSession:(AVCaptureSession *)session;
- (void)showWindow;
@end
