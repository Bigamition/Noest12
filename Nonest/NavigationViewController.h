//
//  NavigationViewController.h
//  Nonest
//
//  Created by 細田 大志 on 5/26/15.
//  Copyright (c) 2015 細田 大志. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"

@interface NavigationViewController : UITableViewController

@property (nonatomic,strong) NSArray* notebooks;
@property (nonatomic,strong) NSMutableArray* Tags;
@property (nonatomic,strong) NSArray* sortedArray;
@property (nonatomic,strong) NSMutableArray* sortTags;


@end
