//
//  WebViewController.m
//  Nonest
//
//  Created by 細田 大志 on 2014/04/12.
//  Copyright (c) 2014年 細田 大志. All rights reserved.
//

#import "WebViewController.h"
#import "EvernoteNoteStore.h"
#import "ENMLUtility.h"


@interface WebViewController ()

@property (nonatomic,strong) UIActivityIndicatorView* activityIndicator;
@property (nonatomic,strong) NSArray* noteList;


@end

@implementation WebViewController
@synthesize noteguid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //CGRect viewRect = self.webView.frame;
    [self.activityIndicator setFrame:CGRectMake(150, 150, 20, 20)];
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.webView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    self.webView.delegate = self;
    if(noteguid != nil){
        [[EvernoteNoteStore noteStore] getNoteWithGuid:noteguid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *note) {
            ENMLUtility *utltility = [[ENMLUtility alloc] init];
            [utltility convertENMLToHTML:note.content withResources:note.resources completionBlock:^(NSString *html, NSError *error) {
                if(error == nil) {
                    [self.webView loadHTMLString:html baseURL:nil];
                    [[self activityIndicator] stopAnimating];
                    
                }
            }];
        } failure:^(NSError *error) {
            NSLog(@"Failed to get note : %@",error);
            [[self activityIndicator] stopAnimating];
        }];
    }
    
}

    //webviewを読み込んだ後に実行される
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //画像をデバイスに合ったレイアウトに変える
    NSString *css = @"img{max-width: 100%;} *{height:auto;}";
    
    // 追加適用するCSSを適用する為の
    // JavaScriptを作成します。
    NSMutableString *javascript = [NSMutableString string];
    [javascript appendString:@"var style = document.createElement('style');"];
    [javascript appendString:@"style.type = 'text/css';"];
    [javascript appendFormat:@"var cssContent = document.createTextNode('%@');", css];
    [javascript appendString:@"style.appendChild(cssContent);"];
    [javascript appendString:@"document.body.appendChild(style);"];
    
    
    // JavaScriptを実行します。
    [webView stringByEvaluatingJavaScriptFromString:javascript];

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
