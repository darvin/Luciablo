//
//  DiabloBot.h
//  AVScreenShack
//
//  Created by Sergei Klimov on 3/11/16.
//
//

#import <Foundation/Foundation.h>
@protocol DiabloGameAdapter
- (void)hoverMouseAtPoint:(CGPoint)point;
- (void)clickMouseAtPoint:(CGPoint)point;

- (void)hoverMouseAtPoint:(CGPoint)point readTooltipInRect:(CGRect *)rect completion:(void (^)(NSString *string))completion;
@end

@interface DiabloBot : NSObject
@property (weak) id<DiabloGameAdapter>gameAdapter;
- (void)tick;
@end
