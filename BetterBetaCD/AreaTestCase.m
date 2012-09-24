//only run on the simulator
#include "TargetConditionals.h"
#if !TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <SenTestingKit/SenTestingKit.h>
#import "Area.h"

@interface AreaTestCase : SenTestCase {
	
}

@end

@implementation AreaTestCase

- (void)testAreaName
{
//	Area *area = [[Area alloc] init];
	
	
	
	
    NSString *string1 = @"test";
    NSString *string2 = @"test";
    STAssertEquals(string1,
                   string2,
                   @"FAILURE");
    NSUInteger uint_1 = 4;
    NSUInteger uint_2 = 4;
    STAssertEquals(uint_1,
                   uint_2,
                   @"FAILURE");
}




@end
#endif
