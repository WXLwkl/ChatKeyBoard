//
//  SecondViewController.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/8/24.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "SecondViewController.h"
#import "UIView+XHBadgeView.h"

#import "WeChatMessageTableViewController.h"
#import "NewsTableViewController.h"
@interface SecondViewController ()


@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.title = @"聊天";

    [self.view addSubview:self.tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showMenuOnView:)];
    
    [self loadDataSource];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
}

- (void)showMenuOnView:(UIBarButtonItem *)item {
    NSLog(@"点击了 + 号");
}

#pragma mark - DataSource

- (void)loadDataSource {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *dataSource = [[NSMutableArray alloc] initWithObjects:
                                      @"华捷新闻，点击查看美女新闻呢！",
                                      @"点击我查看最新消息，里面有惊喜哦！",
                                      @"点击我查看最新消息，里面有惊喜哦！",
                                      @"点击我查看最新消息，里面有惊喜哦！",
                                      @"点进入聊天页面，这里有多种显示样式",
                                      @"点击我查看最新消息，里面有惊喜哦！",
                                      @"点击查看自定义消息Cell的样式",
                                      @"点击我查看最新消息，里面有惊喜哦！",
                                      @"点击我查看最新消息，里面有惊喜哦！",
                                      @"点击我查看最新消息，里面有惊喜哦！",
                                      @"点击我查看最新消息，里面有惊喜哦！",
                                      @"点击我查看最新消息，里面有惊喜哦！",
                                      @"请问你现在在哪里啊？我在广州天河",
                                      @"请问你现在在哪里啊？我在广州天河",
                                      @"请问你现在在哪里啊？我在广州天河",
                                      @"请问你现在在哪里啊？我在广州天河",
                                      @"请问你现在在哪里啊？我在广州天河",
                                      @"点击我查看最新消息，里面有惊喜哦！",
                                      @"点击我查看最新消息，里面有惊喜哦！",
                                      nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dataSource = dataSource;
            [self.tableView reloadData];
        });
    });
}
#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        
    }
    if (indexPath.row < self.dataSource.count) {
        if (!indexPath.row) {
            cell.textLabel.text = self.dataSource[indexPath.row];
            cell.imageView.image = [UIImage imageNamed:@"dgame1"];
            cell.detailTextLabel.text = nil;
        } else {
            cell.textLabel.text = (indexPath.row % 2) ? @"曾宪华" : @"杨仁捷";
            cell.detailTextLabel.text = self.dataSource[indexPath.row];
            cell.imageView.image = [UIImage imageNamed:@"customAvatarDefault"];
        }
    }
    
    if (indexPath.row % 2) {
        [cell.imageView setupCircleBadge];
    } else {
        [cell.imageView destroyCircleBadge];
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    
    if (indexPath.row == 4) {
        cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor colorWithRed:0.097 green:0.633 blue:1.000 alpha:1.000];
    } else if (indexPath.row == 0) {
        cell.textLabel.textColor = [UIColor colorWithRed:0.429 green:0.187 blue:1.000 alpha:1.000];
    } else if (indexPath.row == 6) {
        cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor colorWithRed:1.000 green:0.222 blue:0.906 alpha:1.000];
    } else {
        cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    return cell;
}
#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!indexPath.row) {
        [self enterNewsController];
    } else {
        [self enterMessage];
    }
}

/**
 进入新闻页面
 */
- (void)enterNewsController {
    
    NewsTableViewController *newsTableViewController = [[NewsTableViewController alloc] init];
    [self pushNewViewController:newsTableViewController];
}

/**
 消息页面
 */
- (void)enterMessage {

    WeChatMessageTableViewController *demoWeChatMessageTableViewController = [[WeChatMessageTableViewController alloc] init];
    [self.navigationController pushViewController:demoWeChatMessageTableViewController animated:YES];
}


@end
