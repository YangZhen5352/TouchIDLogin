//
//  MainViewController.m
//  Touch_SiBie
//
//  Created by edz on 2017/1/5.
//  Copyright © 2017年 edz. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"
#import "KeychainTool.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([[KeychainTool readKeychainValue:@"login"] isEqual:@"yes"]) {
        self.switchBtn.on = YES;
    }
}
- (IBAction)toLogin:(id)sender {
    if (self.switchBtn.on) {
        
        [KeychainTool saveKeychainValue:@"yes" key:@"login"];
    } else {
        [KeychainTool saveKeychainValue:@"no" key:@"login"];
    }
    // 退出成功
    //获取UIWindow
    UIWindow *window = (UIWindow*)[UIApplication sharedApplication].keyWindow;
    //TBC控制器
    LoginViewController *vc = [[LoginViewController alloc] init];
    vc.isLoging = self.switchBtn.on;
    //根视图
    window.rootViewController = vc;
}
- (void)setMsgShow:(NSString *)msgShow
{
    _msgShow = msgShow;
//    self.msgInfo.text = msgShow;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 375, 270)];
    label.text = msgShow;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor lightGrayColor];
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
