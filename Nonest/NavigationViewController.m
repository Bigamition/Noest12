//
//  NavigationViewController.m
//  Nonest
//
//  Created by 細田 大志 on 5/26/15.
//  Copyright (c) 2015 細田 大志. All rights reserved.
//

#import "NavigationViewController.h"
#import "SWRevealViewController.h"
#import "EvernoteSDK.h"


@interface NavigationViewController ()

@property BOOL statusbarHidden;
@property (nonatomic,strong) UIActivityIndicatorView* activityIndicator;
@property (nonatomic,strong) NSMutableArray* section1;
@property (nonatomic,strong) NSMutableArray* section2;



@end

@implementation NavigationViewController

@synthesize section1,section2;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    EvernoteSession *session = [EvernoteSession sharedSession];
    if (session.isAuthenticated) {
        [self listNotes];
        [self listTags];
    }
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.section1 == NULL) {
        [self listNotes];
        [self listTags];
    }
    
    
    
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return _statusbarHidden;
}

- (void)viewWillLayoutSubviews {
    _statusbarHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - Table view data source

- (void)listNotes {
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    [self.activityIndicator startAnimating];
    [noteStore listNotebooksWithSuccess:^(NSArray *notebooks) {
        [self.activityIndicator stopAnimating];
        self.notebooks = notebooks;
        //NSArrayではNSMutableArrayを使うことで可変になり繰り返しで連結が可能になる
        self.section1 = [NSMutableArray array];
        for ( EDAMNotebook* notebook in notebooks ) {
            [self.section1 addObject:notebook.name];
            
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error %@", error);
    }];
}

- (void)listTags {
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    [self.activityIndicator startAnimating];
    [noteStore listTagsWithSuccess:^(NSArray *Tags) {
        [self.activityIndicator stopAnimating];
        self.Tags = [Tags mutableCopy];
        self.section2 = [NSMutableArray array];
        for ( EDAMNotebook* Tag in Tags ) {
            [self.section2 addObject:Tag.name];
        }
        //アルファベット順
        self.sortedArray = [self.section2 sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"error %@", error);
    }];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    int count = 0;
    if (section == 0) {
        count = 1;
    }else if (section == 1) {
        count = (int)[self.section1 count];
    }else if (section == 2) {
        count = (int)[self.section2 count];
    }
    return count;
    
}

//headersectionの高さ
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0f;
}

-(CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0){
        return 40.0;  // １番目のセクションの行の高さを30にする
    }else if(indexPath.section == 1){
        return 40.0;  // それ以外の行の高さを50にする
    }else {
        return 30.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectitle  = [[UIView alloc] init];
    UILabel *label1 = [[UILabel alloc] init];
    //frameを設定しないと表示されない
    label1.frame = CGRectMake(0, 0, 280, 25);
    label1.backgroundColor = [UIColor colorWithRed:0.349 green:1.000 blue:0.847 alpha:1.000];
    label1.font = [UIFont systemFontOfSize:13];
    label1.textColor = [UIColor whiteColor];
    if (section == 0) {
        //ユーザー名取得
        EvernoteUserStore *userStore = [EvernoteUserStore userStore];
        [self.activityIndicator startAnimating];
        [userStore getUserWithSuccess:^(EDAMUser *user) {
            label1.frame = CGRectMake(0, 0, 100, 20);
            label1.backgroundColor = [UIColor whiteColor];
            label1.font = [UIFont systemFontOfSize:18];
            label1.textColor = [UIColor colorWithRed:0.349 green:1.000 blue:0.847 alpha:1.000];
            label1.text = [NSString stringWithFormat:@" %@", user.username];
            [sectitle addSubview:label1];
        } failure:^(NSError *error) {
            NSLog(@"error %@", error);
        }];
        
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button1.frame = CGRectMake(200, 7, 50, 13);
        button1.titleLabel.font = [UIFont systemFontOfSize: 13];
        //button1.backgroundColor = [UIColor colorWithRed:0.349 green:1.000 blue:0.847 alpha:1.000];
        button1.layer.cornerRadius = 3;
        [button1 setTitle:@"Logout" forState:UIControlStateNormal];
        [button1 setTitleColor:[UIColor colorWithRed:0.784 green:0.780 blue:0.800 alpha:1.000] forState:UIControlStateNormal];
        [button1 setTitleColor:[UIColor colorWithRed:0.549 green:1.000 blue:0.947 alpha:1.000] forState:UIControlStateHighlighted];
        [button1 addTarget:self action:@selector(buttonDidPush) forControlEvents:UIControlEventTouchUpInside];
        [sectitle addSubview:button1];
    }else if (section == 1) {
        label1.text = [NSString stringWithFormat:@" Notebooks"];
        [sectitle addSubview:label1];
    }else if (section == 2) {
        label1.text = [NSString stringWithFormat:@" Tags"];
        [sectitle addSubview:label1];
    }
    

    return sectitle;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15.0f];
    cell.textLabel.textColor = [UIColor colorWithRed:0.200 green:0.200 blue:0.200 alpha:1.000];
    if (indexPath.section == 0) {
        UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        separatorLineView.backgroundColor =[UIColor colorWithRed:0.349 green:1.000 blue:0.847 alpha:1.000];
        [cell.contentView addSubview:separatorLineView];
        [[cell textLabel] setText:@"All Notes"];
        
    }else if (indexPath.section == 1) {
        EDAMNotebook* notebook = self.notebooks[indexPath.row];
        [[cell textLabel] setText:notebook.name];
    }else if (indexPath.section == 2) {
        NSString* Tags = self.sortedArray[indexPath.row];
        [[cell textLabel] setText:Tags];
    }
   
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (indexPath.section == 1) {
            TableViewController *vc = /*(WebViewController*)*/[segue destinationViewController];
            EDAMNotebook* notebook = self.notebooks[indexPath.row];
            vc.notebookguid = notebook.guid;
            vc.notebooktitle = notebook.name;
        }else if (indexPath.section == 2) {
            TableViewController *vc = /*(WebViewController*)*/[segue destinationViewController];
            NSString* Tagname = self.sortedArray[indexPath.row];
            vc.Tagstitle = Tagname;
            NSMutableArray *anArray = [[NSMutableArray alloc] init];
            EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
            [self.activityIndicator startAnimating];
            [noteStore listTagsWithSuccess:^(NSArray *Tags) {
                [self.activityIndicator stopAnimating];
                self.Tags = [Tags mutableCopy];
                for ( EDAMNotebook* Tag in Tags ) {
                    if ([Tag.name isEqualToString:Tagname]) {
                        [anArray addObject:Tag.guid];
                        break;
                        
                    }
                    
                }
                
            } failure:^(NSError *error) {
                NSLog(@"error %@", error);
            }];
            vc.Tagsguid = anArray;
            
        }
        
        
        
    }
    
    
    
    
}

- (void)buttonDidPush{
    //このメソッドがコールされる
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to logout？"
                              delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"YES", nil];
    [alert show];
    

    NSLog(@"buttonPush");
}

-(void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            //１番目のボタンが押されたときの処理を記述する
            break;
        case 1:
            //２番目のボタンが押されたときの処理を記述する
            [[EvernoteSession sharedSession] logout];
            EvernoteSession *session = [EvernoteSession sharedSession];
            [session authenticateWithViewController:self completionHandler:^(NSError *error) {
                if (error || !session.isAuthenticated) {
                    NSLog(@"Error : %@",error);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"Could not authenticate"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                } else {
                    
                    NSLog(@"authenticated! noteStoreUrl:%@ webApiUrlPrefix:%@", session.noteStoreUrl, session.webApiUrlPrefix);
                    
                }
            }];
            break;
    }
    
}





@end
