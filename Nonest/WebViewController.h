//
//  WebViewController.h
//  Nonest
//
//  Created by 細田 大志 on 2014/04/12.
//  Copyright (c) 2014年 細田 大志. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic ,strong) NSString *noteguid;

@end
