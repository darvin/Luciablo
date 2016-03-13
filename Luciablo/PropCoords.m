//
//  PropCoords.m
//  AVScreenShack
//
//  Created by Sergei Klimov on 3/12/16.
//
//

#import "PropCoords.h"

@implementation PPoint
+ (instancetype)pointFromCGPoint:(CGPoint)point inFieldOfSize:(CGSize)size {
    PPoint *res = [[self alloc] init];
    
    res.x = point.x / size.width;
    res.y = point.y / size.height;
    return res;
}
- (CGPoint)cgpointInFieldOfSize:(CGSize)size {
    return  CGPointMake(size.width*self.x, size.height*self.y);
}
@end



@implementation PRect

+ (instancetype)rectFrom:(PPoint *)from to:(PPoint *)to {
    //fixme
    
    PRect * res= [[self alloc] init];
    res.p1 = from;
    res.p2 = to;
    return res;

}
+ (instancetype)rectFromCGRect:(CGRect)rect inFieldOfSize:(CGSize)size {
    PRect * res= [[self alloc] init];
    res.p1 = [PPoint pointFromCGPoint:rect.origin inFieldOfSize:size];
    res.p2 = [PPoint pointFromCGPoint:
              CGPointMake(rect.size.width+ rect.origin.x,
                        rect.size.height+ rect.origin.y) inFieldOfSize:size];
    return res;
}
- (CGRect)cgrectInFieldOfSize:(CGSize)size {
    
    CGRect rect = CGRectStandardize(
            CGRectMake(
                       self.p1.x*size.width,
                       self.p1.y*size.height,
                       (self.p2.x - self.p1.x)*size.width,
                       (self.p2.y - self.p1.y)*size.height
                       ));
    
    return rect;
}

@end
