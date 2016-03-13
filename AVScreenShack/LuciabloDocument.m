
/*
     File: AVScreenShackDocument.m
 Abstract: Document, owns session, screen capture input, and movie file output
  Version: 2.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "LuciabloDocument.h"

#import <AVFoundation/AVFoundation.h>
#import "OpenCVOutput.h"
#import "DiabloBot.h"
#import "CapturePreviewView.h"
#import "MouseClicker.h"

@interface LuciabloDocument () <DiabloGameAdapter, CapturePreviewViewDelegate>

@property (weak) IBOutlet NSView *captureView;



- (IBAction)startRecording:(id)sender;
- (IBAction)stopRecording:(id)sender;
- (IBAction)setDisplayAndCropRect:(id)sender;

@end


@implementation LuciabloDocument
{
    CGDirectDisplayID           display;
    AVCaptureMovieFileOutput    *captureMovieFileOutput;
    NSMutableArray              *shadeWindows;
    NSTimer                     *gameWindowCropTimer;
    
    OpenCVOutput *output;
    DiabloBot *diabloBot;
    MouseClicker *clicker;
}

#pragma mark Capture


- (BOOL)setCropToGameWindow {
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);

    for (NSMutableDictionary* entry in (__bridge NSArray*)windowList)
    {
        NSString* ownerName = [entry objectForKey:(id)kCGWindowOwnerName];
        NSInteger ownerPID = [[entry objectForKey:(id)kCGWindowOwnerPID] integerValue];
        if ([ownerName isEqualToString:@"Pixelmator"] && [entry[(id)kCGWindowName] hasPrefix:@"Untitled"]) {
            CGRect diabloWindowRect;
            NSDictionary *windowRectDict = entry[(id)kCGWindowBounds];
            diabloWindowRect.origin.x = [windowRectDict[@"X"] floatValue];
            diabloWindowRect.origin.y = [windowRectDict[@"Y"] floatValue];
            diabloWindowRect.size.height = [windowRectDict[@"Height"] floatValue];
            diabloWindowRect.size.width = [windowRectDict[@"Width"] floatValue];
            diabloWindowRect.origin.y = CGDisplayPixelsHigh(CGMainDisplayID()) - diabloWindowRect.origin.y-diabloWindowRect.size.height;
            self.captureScreenInput.cropRect = diabloWindowRect;
            self.captureScreenInput.scaleFactor = 0.3;
//            NSLog(@"%f %f %f %f", diabloWindowRect.origin.x,diabloWindowRect.origin.y, diabloWindowRect.size.width, diabloWindowRect.size.height);
            break;
        }
    }
    CFRelease(windowList);
    return YES;
}

- (BOOL)createCaptureSession:(NSError **)outError
{
    /* Create a capture session. */
    self.captureSession = [[AVCaptureSession alloc] init];
	if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetHigh])
    {
        /* Specifies capture settings suitable for high quality video and audio output. */
		[self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    }
    
    /* Add the main display as a capture input. */
    display = CGMainDisplayID();
    self.captureScreenInput = [[AVCaptureScreenInput alloc] initWithDisplayID:display];
    
    
    

    [self setCropToGameWindow];
    
    if ([self.captureSession canAddInput:self.captureScreenInput]) 
    {
        [self.captureSession addInput:self.captureScreenInput];
    } 
    else 
    {
        return NO;
    }
    
    /* Add a movie file output + delegate. */
    captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [captureMovieFileOutput setDelegate:self];
    if ([self.captureSession canAddOutput:captureMovieFileOutput]) 
    {
        [self.captureSession addOutput:captureMovieFileOutput];
    } 
    else 
    {
        return NO;
    }
	
	/* Register for notifications of errors during the capture session so we can display an alert. */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionRuntimeErrorDidOccur:) name:AVCaptureSessionRuntimeErrorNotification object:self.captureSession];
    
    output = [[OpenCVOutput alloc] initWithCaptureSession:self.captureSession ];

    [output showWindow];
    
    diabloBot.gameAdapter = self;
    return YES;
}

/*
 AVCaptureVideoPreviewLayer is a subclass of CALayer that you use to display 
 video as it is being captured by an input device.
 
 You use this preview layer in conjunction with an AV capture session.
 */
-(void)addCaptureVideoPreview
{
    /* Create a video preview layer. */
	AVCaptureVideoPreviewLayer *videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    
    /* Configure it.*/
	[videoPreviewLayer setFrame:CGRectMake(0, 0, _captureScreenInput.cropRect.size.width, _captureScreenInput.cropRect.size.height)];
	[videoPreviewLayer setAutoresizingMask:kCALayerHeightSizable|kCALayerWidthSizable];
    videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    videoPreviewLayer.contentsGravity = kCAGravityBottomLeft;
    videoPreviewLayer.backgroundColor = [NSColor redColor].CGColor;
    self.captureView.frame = CGRectMake(self.captureView.frame.origin.x, self.captureView.frame.origin.y, videoPreviewLayer.frame.size.width, videoPreviewLayer.frame.size.height);
    /* Add the preview layer as a sublayer to the view. */
    [self.captureView layer].layoutManager  = [CAConstraintLayoutManager layoutManager];
    [self.captureView layer].contentsGravity = kCAGravityResizeAspect;
    [self.captureView layer].autoresizingMask = kCALayerHeightSizable | kCALayerWidthSizable;

    [[self.captureView layer] addSublayer:videoPreviewLayer];
    /* Specify the background color of the layer. */
	[[self.captureView layer] setBackgroundColor:[NSColor greenColor].CGColor];

}

/*
 An AVCaptureScreenInput's minFrameDuration is the reciprocal of its maximum frame rate.  This property
 may be used to request a maximum frame rate at which the input produces video frames.  The requested
 rate may not be achievable due to overall bandwidth, so actual frame rates may be lower.
 */
- (float)maximumScreenInputFramerate
{
	Float64 minimumVideoFrameInterval = CMTimeGetSeconds([self.captureScreenInput minFrameDuration]);
	return minimumVideoFrameInterval > 0.0f ? 1.0f/minimumVideoFrameInterval : 0.0;
}

/* Set the screen input maximum frame rate. */
- (void)setMaximumScreenInputFramerate:(float)maximumFramerate
{
	CMTime minimumFrameDuration = CMTimeMake(1, (int32_t)maximumFramerate);
    /* Set the screen input's minimum frame duration. */
	[self.captureScreenInput setMinFrameDuration:minimumFrameDuration];
}

/* Add a display as an input to the capture session. */
-(void)addDisplayInputToCaptureSession:(CGDirectDisplayID)newDisplay cropRect:(CGRect)cropRect
{
    /* Indicates the start of a set of configuration changes to be made atomically. */
    [self.captureSession beginConfiguration];
    
    /* Is this display the current capture input? */
    if ( newDisplay != display ) 
    {
        /* Display is not the current input, so remove it. */
        [self.captureSession removeInput:self.captureScreenInput];
        AVCaptureScreenInput *newScreenInput = [[AVCaptureScreenInput alloc] initWithDisplayID:newDisplay];
        
        self.captureScreenInput = newScreenInput;
        if ( [self.captureSession canAddInput:self.captureScreenInput] )
        {
            /* Add the new display capture input. */
            [self.captureSession addInput:self.captureScreenInput];
        }
        [self setMaximumScreenInputFramerate:[self maximumScreenInputFramerate]];
    }
    /* Set the bounding rectangle of the screen area to be captured, in pixels. */
    [self.captureScreenInput setCropRect:cropRect];
    
    /* Commits the configuration changes. */
    [self.captureSession commitConfiguration];
}


/* Informs the delegate when all pending data has been written to the output file. */
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (error) 
    {
        [self presentError:error];
		return;
    }
    
    [[NSWorkspace sharedWorkspace] openURL:outputFileURL];
}

- (BOOL)captureOutputShouldProvideSampleAccurateRecordingStart:(AVCaptureOutput *)captureOutput
{
	// We don't require frame accurate start when we start a recording. If we answer YES, the capture output
    // applies outputSettings immediately when the session starts previewing, resulting in higher CPU usage
    // and shorter battery life.
	return NO;
}

#pragma mark NSDocument

/* Initializes a AVScreenShackDocument document. */
- (id)initWithType:(NSString *)typeName error:(NSError **)outError
{
    self = [super initWithType:typeName error:outError];
    
    if (self) 
    {

        BOOL success = [self createCaptureSession:outError];
        if (!success) 
        {
            return nil;
            
        }
        gameWindowCropTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(setCropToGameWindow) userInfo:nil repeats:YES];
        
        diabloBot = [[DiabloBot alloc] init];
        clicker = [[MouseClicker alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionRuntimeErrorNotification object:self.captureSession];
    [gameWindowCropTimer invalidate];
}

- (NSString *)windowNibName
{
    
	return @"LuciabloDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
	
    [self addCaptureVideoPreview];

    /* Start the capture session running. */
    [self.captureSession startRunning];

	[[aController window] setContentBorderThickness:75.f forEdge:NSMinYEdge];
	[[aController window] setMovableByWindowBackground:NO];
}

/* Called when the document is closed. */
- (void)close
{
    /* Stop the capture session running. */
    [self.captureSession stopRunning];
    
    [super close];
}

/* AVScreenShackDocument does not support saving. */
-(BOOL)isDocumentEdited
{
    return NO;
}



- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	// Do nothing
}

- (void)captureSessionRuntimeErrorDidOccur:(NSNotification *)notification
{
	NSError *error = [notification userInfo][AVCaptureSessionErrorKey];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert setMessageText:[error localizedDescription]];
    NSString *informativeText = [error localizedRecoverySuggestion];
    informativeText = informativeText ? informativeText : [error localizedFailureReason]; // No recovery suggestion, then at least tell the user why it failed.
    [alert setInformativeText:informativeText];
    
    [alert beginSheetModalForWindow:[self windowForSheet]
                      modalDelegate:self
                     didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo:NULL];
}


#pragma mark - CaptureViewDelegate

- (void)caputurePreview:(CapturePreviewView *)cp wasClickedAtPoint:(PPoint *)point {
    NSLog(@"Clicked: %f %f", point.x, point.y);
    
    CGRect cropRect = _captureScreenInput.cropRect;
    
    CGPoint screenOffset = [point cgpointInFieldOfSize:cropRect.size];
    CGFloat baseY =  CGDisplayPixelsHigh(CGMainDisplayID()) - cropRect.origin.y;
    CGFloat baseX = cropRect.origin.x;
    CGPoint screenPoint = CGPointMake(baseX+screenOffset.x, baseY-screenOffset.y);
    NSLog(@"POINT: %f %f", screenPoint.x, screenPoint.y);
    [clicker clickInPoint:screenPoint];
}
- (void)caputurePreview:(CapturePreviewView *)cp wasDraggedFrom:(PPoint *)from to:(PPoint *)to {
    NSLog(@"Dragged: %f %f > %f %f", from.x, from.y,  to.x, to.y);
    
    [output drawRect:[PRect rectFrom:from to:to]];
}

#pragma mark -DiabloGameProvider

- (void)hoverMouseAtPoint:(CGPoint)point {
    
}
- (void)clickMouseAtPoint:(CGPoint)point {
    
}

- (void)hoverMouseAtPoint:(CGPoint)point readTooltipInRect:(CGRect *)rect completion:(void (^)(NSString *string))completion {
    
}


@end
