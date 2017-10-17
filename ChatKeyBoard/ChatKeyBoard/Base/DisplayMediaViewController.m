//
//  DisplayMediaViewController.m
//  ChatKeyBoard
//
//  Created by xingl on 2017/10/16.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import "DisplayMediaViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ConfigurationHelper.h"
#import "UIView+XHRemoteImage.h"

@interface DisplayMediaViewController ()

@property (nonatomic, strong) MPMoviePlayerController *moviePlayerController;

@property (nonatomic, weak) UIImageView *photoImageView;

@end

@implementation DisplayMediaViewController


- (MPMoviePlayerController *)moviePlayerController {
    if (!_moviePlayerController) {
        _moviePlayerController = [[MPMoviePlayerController alloc] init];
        _moviePlayerController.repeatMode = MPMovieRepeatModeOne;
        _moviePlayerController.scalingMode = MPMovieScalingModeAspectFill;
        _moviePlayerController.view.frame = self.view.frame;
        [self.view addSubview:_moviePlayerController.view];
    }
    return _moviePlayerController;
}

- (UIImageView *)photoImageView {
    if (!_photoImageView) {
        UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        photoImageView.clipsToBounds = YES;
        [self.view addSubview:photoImageView];
        _photoImageView = photoImageView;
    }
    return _photoImageView;
}

- (void)setMessage:(id<MessageModel>)message {
    _message = message;
    if ([message messageMediaType] == BubbleMessageMediaTypeVideo) {
        self.title = NSLocalizedStringFromTable(@"Video", @"MessageDisplayKitString", @"详细视频");
        self.moviePlayerController.contentURL = [NSURL fileURLWithPath:[message videoPath]];
        [self.moviePlayerController play];
    } else if ([message messageMediaType] ==BubbleMessageMediaTypePhoto) {
        self.title = NSLocalizedStringFromTable(@"Photo", @"MessageDisplayKitString", @"详细照片");
        self.photoImageView.image = message.photo;
        if (message.thumbnailUrl) {
            NSString *placeholderImageName = [[ConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageTablePlaceholderImageNameKey];
            if (!placeholderImageName) {
                placeholderImageName = @"placeholderImage";
            }
            
            [self.photoImageView setImageWithURL:[NSURL URLWithString:[message thumbnailUrl]] placeholer:[UIImage imageNamed:placeholderImageName]];
        }
    }
}
#pragma mark - Life cycle

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.message messageMediaType] == BubbleMessageMediaTypeVideo) {
        [self.moviePlayerController stop];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_moviePlayerController stop];
    _moviePlayerController = nil;
    
    _photoImageView = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
