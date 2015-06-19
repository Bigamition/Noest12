//
//  WebViewController.m
//  Nonest
//
//  Created by 細田 大志 on 2014/04/12.
//  Copyright (c) 2014年 細田 大志. All rights reserved.
//

#import "WebViewController.h"
#import "EvernoteUserStore.h"
#import "EvernoteNoteStore.h"
#import "ENMLUtility.h"


@interface WebViewController ()

@property (nonatomic,assign) NSInteger currentNote;
@property (nonatomic,strong) UIActivityIndicatorView* activityIndicator;
@property (nonatomic,strong) NSArray* noteList;
@property (weak, nonatomic) IBOutlet UITextView *textView;

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
    CGRect viewRect = self.webView.frame;
    [self.activityIndicator setFrame:CGRectMake(viewRect.size.width/2, viewRect.size.height/2, 20, 20)];
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.webView addSubview:self.activityIndicator];
    //[self getNote];
    [self loadCurrentNote];
}

- (void)appendText:(NSString *)text {
    self.textView.text = [NSString stringWithFormat:@"%@\n%@", self.textView.text, text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) loadCurrentNote {
    [[self activityIndicator] startAnimating];
    
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


@end
