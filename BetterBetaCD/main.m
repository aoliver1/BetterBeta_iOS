//
//  main.m
//  BetterBetaCD
//
//  Created by Andrew Oliver on 5/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	int retVal = UIApplicationMain(argc, argv, nil, @"BetterBetaCDAppDelegate");

  //  int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
