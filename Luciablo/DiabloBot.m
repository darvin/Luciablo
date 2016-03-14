//
//  DiabloBot.m
//  AVScreenShack
//
//  Created by Sergei Klimov on 3/11/16.
//
//

#import "DiabloBot.h"
#import "PropCoords.h"

#import <Functional.m/NSArray+F.h>

@implementation DiabloBot {
    NSMutableDictionary *_interfaceDimenstions;
}
- (instancetype) init {
    if (self= [super init]) {
        [self loadDimensions];
    }
    return self;
}

- (PPoint *)interfacePointForName:(NSString *)name {
    return _interfaceDimenstions[name];
}

- (PRect *)interfaceRectForName:(NSString *)name {
    return _interfaceDimenstions[name];
}

- (void)loadDimensions {
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"DiabloInterfaceDimensions" ofType:@"plist"]];
    
    [plist enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, NSString*  _Nonnull obj, BOOL * _Nonnull stop) {
        NSArray *splitValue = [obj componentsSeparatedByString:@";"];
        assert(splitValue.count==2||splitValue.count==4);
        NSArray *coords = [splitValue map:^id(NSString *value) {
            return @([value floatValue]);
        }];
        if (coords.count==2) {
            _interfaceDimenstions[key]=PPointMake([coords[0] floatValue], [coords[1] floatValue]);
        } else if (coords.count==4){
            _interfaceDimenstions[key]=PRectMake([coords[0] floatValue], [coords[1] floatValue],[coords[2] floatValue], [coords[3] floatValue]);

        }
    }];
}
- (void) tick {
    
}
@end
