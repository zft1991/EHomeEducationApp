//
//  EHEStdSettingViewController.h
//  EHomeEducation
//
//  Created by Yixiang Chen on 11/17/14.
//  Copyright (c) 2014 AppChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EHEStdSettingTableViewCell.h"
#import "EHEStdSettingDetailViewController.h"
@interface EHEStdSettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(strong,nonatomic)UITableView * tableViewSetting;
@property(strong,nonatomic)NSArray * personalInfomationArray;
@property(strong,nonatomic)NSArray * systemSettingArray;
@property(strong,nonatomic)NSArray * connectAndShareArray;
@property(strong,nonatomic)NSString * detailType;
@property(nonatomic)BOOL check;
@property(strong,nonatomic)NSArray * testArray;
@end
