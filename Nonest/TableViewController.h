//
//  TableViewController.h
//  Nonest
//
//  Created by 細田 大志 on 2014/04/12.
//  Copyright (c) 2014年 細田 大志. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"

static NSString * const TableViewCustomCellIdentifier = @"CustomCell";

@interface TableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{
@protected
    NSString* sharedId;
}



@property (weak,nonatomic) IBOutlet UIBarButtonItem *barButton;

@property (nonatomic ,strong) NSString *notebookguid;
@property (nonatomic ,strong) NSString *notebooktitle;

@property (nonatomic ,strong) NSMutableArray *Tagsguid;
@property (nonatomic ,strong) NSString *Tagstitle;


@property (nonatomic ,strong) UIButton *menuBtn;

@end
