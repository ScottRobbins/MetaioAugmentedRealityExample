//
//  WebViewController.h
//  MetaioAugmentedRealityExample
//
//  Created by Samuel Scott Robbins on 10/22/14.
//  Copyright (c) 2014 Scott Robbins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
{
    NSString *url;
}

@property (nonatomic, strong) NSString *url;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)doneButtonPressed:(id)sender;

@end
