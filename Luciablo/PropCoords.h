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
-(instancetype) initWithX:(float)x Y:(float)y;
+ (instancetype)pointFromCGPoint:(CGPoint)point inFieldOfSize:(CGSize)size;
- (CGPoint)cgpointInFieldOfSize:(CGSize)size;
@end


@interface PRect : NSObject
@property PPoint *p1;
@property PPoint *p2;
-(instancetype) initWithX:(float)x Y:(float)y width:(float)width height:(float)height;
+ (instancetype)rectFromCGRect:(CGRect)rect inFieldOfSize:(CGSize)size;
- (CGRect)cgrectInFieldOfSize:(CGSize)size;
+ (instancetype)rectFrom:(PPoint *)from to:(PPoint *)to;

@end


PPoint *PPointMake(float x, float y);
PRect *PRectMake(float x, float y, float width, float height);

