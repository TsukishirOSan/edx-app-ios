//
//  OEX_LocalizedStringTests.m
//  edXVideoLocker
//
//  Created by Jotiram Bhagat on 06/03/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "OEXLocalizedString.h"
@interface OEX_LocalizedStringTests : XCTestCase

@end

@implementation OEX_LocalizedStringTests

-(void)testOEXLocalizedStringPlural{

    NSInteger downloadingCount=4;
    
    NSString * localizedString=[NSString stringWithFormat:OEXLocalizedStringPlural(@"VIDEOS_DOWNLOADING", downloadingCount, nil), downloadingCount];
    
    NSString *expectedResult=[NSString stringWithFormat:@"%ld videos downloading",(long)downloadingCount];
    XCTAssert([localizedString isEqualToString:expectedResult],@"Localized string in not correct");
    
}

@end
