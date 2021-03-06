//
//  OpenCVOutput.m
//  AVScreenShack
//
//  Created by Sergei Klimov on 3/11/16.
//
//


#import "OpenCVOutput.h"


#undef check

#include <opencv2/core/core.hpp>        // Basic OpenCV structures (cv::Mat, Scalar)
#include <opencv2/imgproc/imgproc.hpp>  // Gaussian Blur
#include <opencv2/videoio/videoio.hpp>
#include <opencv2/highgui/highgui.hpp>  // OpenCV window I/O
#include <algorithm>

using namespace std;
using namespace cv;
const char* WIN_UT = "Under Test";
const char* WIN_RF = "Reference";

/*
Mat src, src_gray;
Mat dst, detected_edges;

int edgeThresh = 1;
int lowThreshold;
int const max_lowThreshold = 100;
int ratio = 3;
int kernel_size = 3;

void CannyThreshold(int, void*)
{
    cvtColor( src, src_gray, CV_BGR2GRAY );

    /// Reduce noise with a kernel 3x3
    blur( src_gray, detected_edges, cv::Size(3,3) );
    
    /// Canny detector
    Canny( detected_edges, detected_edges, lowThreshold, lowThreshold*ratio, kernel_size );
    
    /// Using Canny's output as a mask, we display our result
    dst = Scalar::all(0);
    dst.create(src.rows, src.cols, src.type());
    src.copyTo( dst, detected_edges);
    imshow( WIN_UT, dst );
}
*/

@implementation OpenCVOutput {
    NSTimer *frameShowTimer;
    VideoCapture *captRefrnc;
    NSMutableDictionary *highlights;
    NSMutableDictionary *highlightsExpires;
    int lastHighlightID;
    Mat currentFrame;
}
- (id)initWithCaptureSession:(AVCaptureSession *)session {
    if (self=[super init]) {
        
        highlights = [[NSMutableDictionary alloc] init];
        highlightsExpires =[[NSMutableDictionary alloc] init];
        captRefrnc = new VideoCapture();
        captRefrnc->open((char *)(__bridge void *)session, 0);
        if (!captRefrnc->isOpened())
        {
            NSLog(@"Could not open reference ");
        }

    }
    return self;
}

- (void)updateFrame {
    if (captRefrnc!=NULL) {
        Mat frameReference, orig, origTranspose;
        
        *captRefrnc >> orig;

        
        if (orig.rows>0&&orig.cols>0) {
            origTranspose = orig.t();
            
            cv::flip(origTranspose, frameReference, 0);

            double angle = 0;
            double scale = 1;

            currentFrame = Mat::zeros( frameReference.rows*scale, frameReference.cols*scale, frameReference.type() );
            /// Compute a rotation matrix with respect to the center of the image
            cv::Point center = cv::Point( 0, 0);
            Mat rot_mat( 2, 3, CV_32FC1 );
            rot_mat = getRotationMatrix2D( center, angle, scale );
            warpAffine( frameReference, currentFrame, rot_mat, currentFrame.size() );

            
            [self highlightInCurrentFrame];
            imshow(WIN_RF, currentFrame);
//            src = frameWarp;
//            CannyThreshold(0,NULL);
        }

    }

}

- (void)hideWindow {
    [frameShowTimer invalidate];
}
- (void)showWindow {
    // Windows
    namedWindow(WIN_RF, WINDOW_AUTOSIZE);
//    namedWindow(WIN_UT, WINDOW_AUTOSIZE);
//    createTrackbar( "Min Threshold:", WIN_UT, &lowThreshold, max_lowThreshold );

    frameShowTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateFrame) userInfo:nil repeats:YES];

}

- (int)highlightRect:(PPoint *)rect {
    return [self highlightObj:rect];
}

- (int)highlightPoint:(PPoint *)point {
    return [self highlightObj:point];
}

- (int)highlightObj:(id)obj {
    lastHighlightID++;
    
    highlights[@(lastHighlightID)] = obj;
    
    highlightsExpires[@(lastHighlightID)] = [NSDate dateWithTimeIntervalSinceNow:0.9];
    return lastHighlightID;

}

- (void)highlightInCurrentFrame {
    NSDate *now = [NSDate date];
    [highlightsExpires enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSDate *  _Nonnull expireDate, BOOL * _Nonnull stop) {
        if ([expireDate compare:now]==NSOrderedAscending) {
            [highlightsExpires removeObjectForKey:key];
            [highlights removeObjectForKey:key];
        }
    }];
    [highlights enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id highlight, BOOL * _Nonnull stop) {
        if ([highlight isKindOfClass: [PRect class]]) {
            PRect *rect = highlight;
            cv::Rect cvRect = [self cvRectFromRect:rect];
//            NSLog(@"opencv drawing : %d %d > %d %d", cvRect.tl().x, cvRect.tl().y, cvRect.br().x, cvRect.br().y);
            rectangle( currentFrame, cvRect.tl(), cvRect.br(), Scalar( 0, 55, 255 ), +1, 4 );

        } else if ([highlight isKindOfClass:[PPoint class]]) {
            circle(currentFrame, [self cvPointFromPoint:highlight], 3, Scalar( 0, 55, 255 ), +1, 4 );
        }

    }];
}

- (PPoint *)pointFromCVPoint:(cv::Point)cvPoint {
    
}

- (cv::Point)cvPointFromPoint:(PPoint *)point {
    CGPoint scaledPoint = [point cgpointInFieldOfSize:CGSizeMake(currentFrame.cols, currentFrame.rows)];
    return cv::Point(scaledPoint.x, currentFrame.rows- scaledPoint.y);
}

- (PRect *)rectFromCVRect:(cv::Rect)cvRect {
    
}

- (cv::Rect)cvRectFromRect:(PRect *)rect {
    CGRect scaledRect = [rect cgrectInFieldOfSize:CGSizeMake(currentFrame.cols, currentFrame.rows)];
    return cv::Rect(scaledRect.origin.x, currentFrame.rows- scaledRect.origin.y-scaledRect.size.height, scaledRect.size.width, scaledRect.size.height);

}

- (void)saveScreenshotToPath:(NSString *)path {
    imwrite([path UTF8String], currentFrame);
}

@end
