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
+ (instancetype)rectFromCGRect:(CGRect)rect inFieldOfSize:(CGSize)size {
    PPoint *resorigin = [PPoint pointFromCGPoint:rect.origin inFieldOfSize:size];
    PPoint *ressize = [PPoint pointFromCGPoint:CGPointMake(rect.size.width, rect.size.height) inFieldOfSize:size];
    PRect * res= [[self alloc] init];
    res.x = resorigin.x;
    res.y = resorigin.y;
    res.width = ressize.x;
    res.height = ressize.y;
    return res;
}
- (CGRect)cgrectInFieldOfSize:(CGSize)size {
    return CGRectMake(self.x*size.width, self.y*size.height, self.width*size.width, self.height*size.height);
}

@end
