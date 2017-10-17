//
//  NewsTableViewController.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/18.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "NewsTableViewController.h"
#import "NewsTemplateTableViewCell.h"
@interface NewsTableViewController ()

@end

@implementation NewsTableViewController

#pragma mark - DataSource

- (void)loadDataSource {
    self.dataSource = (NSMutableArray *)@[@"asfa", @"dafas", @"wegrw", @"sdbwr"];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedStringFromTable(@"News", @"MessageDisplayKitString", @"");
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self loadDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    NewsTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[NewsTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kNewsTemplateContainerViewHeight + kNewsTemplateContainerViewSpacing * 2;
}

@end
