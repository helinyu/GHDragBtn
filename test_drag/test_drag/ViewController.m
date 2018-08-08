//
//  ViewController.m
//  test_drag
//
//  Created by Aka on 2018/8/7.
//  Copyright © 2018年 Aka. All rights reserved.
//

#import "ViewController.h"
#import "GHDragBtn.h"

@interface ViewController ()

@property (nonatomic, strong) GHDragBtn *hoverBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
    _hoverBtn = [[GHDragBtn alloc] initInKeyWindowWithFrame:CGRectMake(0.f, 200.f, 100.f, 100.f)];;
    [_hoverBtn setBackgroundImage:[UIImage imageNamed:@"icon_xm_music_player"] forState:UIControlStateNormal];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
