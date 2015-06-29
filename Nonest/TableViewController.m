//
//  TableViewController.m
//  Nonest
//
//  Created by 細田 大志 on 2014/04/12.
//  Copyright (c) 2014年 細田 大志. All rights reserved.
//

#import "TableViewController.h"
#import "EvernoteSession.h"
#import "EvernoteUserStore.h"
#import "EvernoteNoteStore.h"
#import "ENMLUtility.h"
#import "CustomTableViewCell.h"
#import "SWRevealViewController.h"
#import "UIViewController+ScrollingNavbar.h"

@interface TableViewController ()

@property (nonatomic,strong) UIActivityIndicatorView* activityIndicator;
@property (nonatomic,strong) NSArray* noteList;
@property(nonatomic,copy) NSString* Navtitle;



@end

@implementation TableViewController

@synthesize noteList,notebookguid,Tagsguid,menuBtn,notebooktitle,Tagstitle;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    
    [self followScrollView:self.tableView withDelay:6.0];
    
    self.Navtitle = @"All Notes";
    if (notebooktitle != nil) {
        self.Navtitle = notebooktitle;
    }
    if (Tagstitle != nil) {
        self.Navtitle = Tagstitle;
    }
    self.navigationItem.title = self.Navtitle;
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    //slidemenu　and swipeback
    _barButton.target = self.revealViewController;
    _barButton.action = @selector(revealToggle:);
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //CGRect viewRect = self.webView.frame;
    [self.activityIndicator setFrame:CGRectMake(150, 150, 20, 20)];
    [self.activityIndicator setHidesWhenStopped:YES];

    UINib *nib = [UINib nibWithNibName:TableViewCustomCellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    [self startEvernoteSession];
    
    
    
    
}

-(void)swipe:(UISwipeGestureRecognizer *)gesture {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload {

    [super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    
}


- (void)startEvernoteSession {
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
            [self getNote];
        }
    }];
    
}

- (void)getNote {
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    //order:created-1,updated-2,RELEVANCE-3,UPDATE_SEQUENCE_NUMBER-4,TITLE-5
    EDAMNoteFilter* filter = [[EDAMNoteFilter alloc] initWithOrder:2 ascending:NO words:nil notebookGuid:notebookguid tagGuids:Tagsguid timeZone:nil inactive:NO emphasized:nil];
    //NSLog(@"errorrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr %@", Tagsguid);
    //返り値に何を含むせるか
    EDAMNotesMetadataResultSpec *resultSpec = [[EDAMNotesMetadataResultSpec alloc] initWithIncludeTitle:YES includeContentLength:NO includeCreated:NO includeUpdated:NO includeDeleted:NO includeUpdateSequenceNum:NO includeNotebookGuid:YES includeTagGuids:YES includeAttributes:NO includeLargestResourceMime:NO includeLargestResourceSize:NO];
    //offsetは結果をどこから表示するかの値
    [[EvernoteNoteStore noteStore] findNotesMetadataWithFilter:filter offset:0 maxNotes:100 resultSpec:resultSpec success:^(EDAMNotesMetadataList *metadata) {
        
        if(metadata.notes.count > 0) {
            self.noteList = metadata.notes;
            [[self activityIndicator] stopAnimating];
            [self.tableView reloadData];
           
        }
        else {

            [[self activityIndicator] stopAnimating];
        }
    } failure:^(NSError *error) {
        NSLog(@"Failed to find notes : %@",error);
        [[self activityIndicator] stopAnimating];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [noteList count];
    //return 10;	// 0 -> 10 に変更
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    EDAMNoteMetadata* note = [noteList objectAtIndex:[indexPath row]];
    EvernoteSession *session = [EvernoteSession sharedSession];
    NSString* aToken = [session authenticationToken];
    NSString *str = [NSString stringWithFormat:@"%@thm/note/%@.png?size=75", session.webApiUrlPrefix,note.guid];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    NSString *body = [NSString stringWithFormat:@"auth=%@", aToken];
    [request setURL:[NSURL URLWithString:str]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse* response = nil;
    NSError* error = nil;
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
                
    UIImage* imaga = [UIImage imageWithData:data];
    
    
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    
    [noteStore getNoteTagNamesWithGuid:note.guid success:^(NSArray *names){
        
        __block NSInteger result = -1;  // オブジェクト型でない変数をBlock内で操作する場合は__block修飾子が必要
        
        [names enumerateObjectsUsingBlock:^(NSString *tagname, NSUInteger idx, BOOL *stop) {
            
            if (idx == 0) {
                cell.LabelTag1.backgroundColor = [UIColor colorWithRed:0.784 green:0.780 blue:0.800 alpha:1.];
                cell.LabelTag1.textColor = [UIColor colorWithRed:0.996 green:0.996 blue:0.996 alpha:1.0];
                cell.LabelTag1.layer.cornerRadius = 3;
                cell.LabelTag1.clipsToBounds = true;
                cell.LabelTag1.font = [UIFont boldSystemFontOfSize:9];
                cell.LabelTag1.text = tagname;
            }else if (idx == 1){
                cell.LabelTag2.backgroundColor = [UIColor colorWithRed:0.784 green:0.780 blue:0.800 alpha:1.];
                cell.LabelTag2.textColor = [UIColor colorWithRed:0.996 green:0.996 blue:0.996 alpha:1.0];
                cell.LabelTag2.layer.cornerRadius = 3;
                cell.LabelTag2.clipsToBounds = true;
                cell.LabelTag2.font = [UIFont boldSystemFontOfSize:9];
                cell.LabelTag2.text = tagname;
            }
            else if (idx == 2){
                cell.LabelTag3.backgroundColor = [UIColor colorWithRed:0.784 green:0.780 blue:0.800 alpha:1.];
                cell.LabelTag3.textColor = [UIColor colorWithRed:0.996 green:0.996 blue:0.996 alpha:1.0];
                cell.LabelTag3.layer.cornerRadius = 3;
                cell.LabelTag3.clipsToBounds = true;
                cell.LabelTag3.font = [UIFont boldSystemFontOfSize:9];
                cell.LabelTag3.text = tagname;
            }
            if ([tagname isEqualToString:@"nil"]) {
                result = idx;
                *stop = YES;
            }   
        }];
        
        
        
    } failure:^(NSError *error) {
        NSLog(@"error %@", error);
    }];
    
    
    cell.separatorInset = UIEdgeInsetsZero;
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    //cell.backgroundColor = [UIColor colorWithRed:0.992 green:0.992 blue:0.992 alpha:1.];
    cell.backgroundColor = [UIColor colorWithRed:0.996 green:0.996 blue:0.996 alpha:1.0];
    cell.LabelCell.textColor = [UIColor colorWithRed:0.200 green:0.200 blue:0.200 alpha:1.000];
    cell.LabelCell.text = note.title;
    cell.imageThumb.image = imaga;
    
    cell.LabelCell.lineBreakMode  = NSLineBreakByWordWrapping;
    cell.LabelCell.numberOfLines  = 3;
    cell.LabelCell.frame          = CGRectMake(0, 0, 320, 10);
    [cell.LabelCell sizeToFit];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CustomTableViewCell rowHeight];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        [self performSegueWithIdentifier:@"selectRow" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // identifier が toViewController であることの確認
    if ([[segue identifier] isEqualToString:@"selectRow"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        WebViewController *vc = /*(WebViewController*)*/[segue destinationViewController];
        EDAMNoteMetadata* note = [noteList objectAtIndex:[indexPath row]];
        vc.noteguid = note.guid;
        
        //vc.cityName = [noteList objectAtIndex:indexPath.row];
        // 移行先の ViewController に画像名を渡す
       // vc.guid = WebViewController.guid;
    }
}



@end
