//
//  JSVideoList.h
//  Cast For Xbox
//
//  Created by Josher Slebodnik on 2/1/15.
//  Copyright (c) 2015 Josher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CastInstructionsViewController.h"

@interface JSVideoList : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong,nonatomic) NSString *gamertag;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *jsonArray;
@property(nonatomic,strong) NSMutableArray *videoArray;


@end
