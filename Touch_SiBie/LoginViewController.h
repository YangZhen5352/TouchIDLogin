//
//  LoginViewController.h
//  Touch_SiBie
//
//  Created by edz on 2017/1/5.
//  Copyright © 2017年 edz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>

//提示
#define Alert(s, d) [[[UIAlertView alloc] initWithTitle:s message:d delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show]

@interface LoginViewController : UIViewController

@property (nonatomic, assign) BOOL isLoging;

@end
