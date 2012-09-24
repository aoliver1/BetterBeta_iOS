//
//  WebViewController.m
//  BetterBetaCD
//
//  Created by Andrew Oliver on 7/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

@synthesize webView, beta, loadingView;

- (void)loadView {
	webView = [[UIWebView alloc]  initWithFrame:[UIScreen mainScreen].applicationFrame]; 
	NSString * pathString = beta.path;
	
	NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:pathString]];
	[webView setDelegate:self];
	[webView loadRequest:request];
	
	self.title = beta.name;
	UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 150, 224, 125)];
	imageView.image = [UIImage imageNamed:@"loading.png"];

	self.loadingView = imageView;
	[imageView release];
	
//	loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(toggleLoading:) userInfo:nil repeats:YES];	
	
	[self.navigationController setToolbarHidden:YES];
	self.view = webView;
	[self.view addSubview:self.loadingView];
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
	//[loadingTimer invalidate];
	loadingView.alpha = 0.0;
}
- (void)toggleLoading:(NSTimer*)theTimer {
	
	[UIView beginAnimations:nil context:NULL];
	if(self.loadingView.alpha == 1.0)
		loadingView.alpha = 0.0;
	else
		loadingView.alpha = 1.0;
	[UIView setAnimationDuration:0.25];
	[UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
}

- (void)dealloc {
	
	[webView release];
	[beta release];
	[super dealloc];
	
}


@end
