//
//  PropCoords.h
//  AVScreenShack
//
//  Created by Sergei Klimov on 3/12/16.
//
//

#import <Foundation/Foundation.h>

@interface PPoint : NSObject
@property float x;
@property float y;

+ (instancetype)pointFromCGPoint:(CGPoint)point inFieldOfSize:(CGSize)size;
- (CGPoint)cgpointInFieldOfSize:(CGSize)size;
@end


@interface PRect : NSObject
@property PPoint *p1;
@property PPoint *p2;
+ (instancetype)rectFromCGRect:(CGRect)rect inFieldOfSize:(CGSize)size;
- (CGRect)cgrectInFieldOfSize:(CGSize)size;
+ (instancetype)rectFrom:(PPoint *)from to:(PPoint *)to;

@end