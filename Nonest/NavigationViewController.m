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
@property (nonatomic,strong) NSMutableArray* section3;

@end

@implementation NavigationViewController

@synthesize section1,section2,section3;

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
    
    
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self listNotes];
    [self listTags];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
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
        
        
        
        //[self.tableView reloadData];
        //[self performSegueWithIdentifier:@"ShowNotebookTableView" sender:nil];
        
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
        //NSLog(@"taaaaaaaaaaaaaaaaaaaaaaaaaaaaaag %@", self.sortTags);
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
        count = self.section1.count;
    }else if (section == 2) {
        count = self.section2.count;
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
    UILabel *sectitle = [UILabel new];
    sectitle.backgroundColor = [UIColor colorWithRed:0.349 green:1.000 blue:0.847 alpha:1.000];
    sectitle.font = [UIFont systemFontOfSize:13];
    sectitle.textColor = [UIColor whiteColor];
    if (section == 0) {
        sectitle.backgroundColor = [UIColor whiteColor];
        sectitle.font = [UIFont systemFontOfSize:18];
        sectitle.textColor = [UIColor colorWithRed:0.349 green:1.000 blue:0.847 alpha:1.000];
        sectitle.text = [NSString stringWithFormat:@" Evernote"];
    }else if (section == 1) {
        sectitle.text = [NSString stringWithFormat:@" Notebooks"];
    }else if (section == 2) {
        sectitle.text = [NSString stringWithFormat:@" Tags"];
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
            EDAMNotebook* Tags = self.Tags[indexPath.row];
            vc.Tagstitle = Tags.name;
            NSMutableArray *anArray = [[NSMutableArray alloc] init];
            [anArray addObject:Tags.guid];
            vc.Tagsguid = anArray;
           
            
        }
        
        
        
    }
    
    
    
    
}





@end
