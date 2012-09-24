//
//  WebViewController.h
//  BetterBetaCD
//
//  Created by Andrew Oliver on 7/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Beta.h"

@interface WebViewController : UIViewController <UIWebViewDelegate>{
	UIWebView *webView;
	Beta * beta;
	UIImageView *loadingView;
	NSTimer * loadingTimer;
}
@property (nonatomic, retain) UIWebView * webView;
@property (nonatomic, retain) Beta* beta;
@property (nonatomic, retain) UIImageView *loadingView;

@end
