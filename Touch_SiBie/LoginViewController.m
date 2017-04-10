//
//  LoginViewController.m
//  Touch_SiBie
//
//  Created by edz on 2017/1/5.
//  Copyright © 2017年 edz. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "KeychainTool.h"
#import "AFNetworking.h"
#import "MessageModel.h"


@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) NSString *msgInfo;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loginBtn.layer.masksToBounds = YES;
    self.loginBtn.layer.cornerRadius = 10;
    
    NSLog(@"+++> %@", [KeychainTool readKeychainValue:@"login"]);
    if ([[KeychainTool readKeychainValue:@"login"] isEqual:@"yes"]) {
        
        // 开启指纹识别
        [self authenticateUser];
    } else {
        [self.password becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(UIButton *)sender {
    if ([self.password.text isEqual: @"lisen"] && [self.userName.text isEqual:@"lisen"]) {
        
        // 加载个人信息
        [self loginSuccess:@"密码登陆成功!"];
//        [self loadMessage:@"密码登陆成功"];
    } else {
        // 登陆失败
        Alert(@"提示", @"登陆失败，账号或者密码错误！");
    }
}

- (void)loadMessage:(NSString *)msg
{
    // 获取个人信息
    [self HTTPRequest_AFN_Get:@"http://192.168.5.118:8080/rishang/app/zhiwen/login?name=lisen&pwd=lisen" successBlock:^(NSDictionary *result) {
        
        // 个人信息，转换成模型信息
//        MessageModel *msgModel = [[MessageModel alloc] init];
        
        self.msgInfo = [NSString stringWithFormat:@"%@, 个人信息是：===>%@", msg, result];
        NSLog(@"%@, 个人信息是：===>%@", msg, result);
        
        // 登陆成功
        //获取UIWindow
        UIWindow *window = (UIWindow*)[UIApplication sharedApplication].keyWindow;
        //TBC控制器
        MainViewController *vc = [[MainViewController alloc] init];
        vc.msgShow = self.msgInfo;
        //根视图
        window.rootViewController = vc;
        
    } failureBlock:^(NSError *error) {
        
    }];
}
- (void)loginSuccess:(NSString *)msg
{
    // 登陆成功
    //获取UIWindow
    UIWindow *window = (UIWindow*)[UIApplication sharedApplication].keyWindow;
    //TBC控制器
    MainViewController *vc = [[MainViewController alloc] init];
    vc.msgShow = msg;
    //根视图
    window.rootViewController = vc;
}

- (void)HTTPRequest_AFN_Get:(NSString *)requestURL
               successBlock:(void (^)(NSDictionary* result))successBlock
               failureBlock:(void (^)(NSError* error))failureBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.responseSerializer
     setAcceptableContentTypes:
     [NSSet setWithObjects:@"application/json", @"text/json",
      @"text/javascript", @"text/html", @"text/css",
      nil]];
    
    [manager GET:requestURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        successBlock((NSDictionary *)responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error);
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)authenticateUser
{
    //初始化上下文对象
    LAContext* context = [[LAContext alloc] init];
    //错误对象
    NSError* error = nil;
    NSString* result = @"登陆APP 需要验证你的指纹";
    // http://192.168.5.118:8080/rishang/app/zhiwen/login?name=lisen&pwd=lisen
    //首先使用canEvaluatePolicy 判断设备支持状态
    // 指纹验证方式：LAPolicyDeviceOwnerAuthenticationWithBiometrics
    // 指纹验证方式：LAPolicyDeviceOwnerAuthentication
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
        
        //支持指纹验证
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:result reply:^(BOOL success, NSError *error) {
            if (success) {
                
                NSLog(@"指纹： 验证成功");
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // 加载个人信息
//                    [self loadMessage:@"指纹登陆成功"];
                    [self loginSuccess:@"指纹登陆成功!"];
                }];
            }
            else
            {
                NSLog(@"%@",error.localizedDescription);
                switch (error.code) {
                    case LAErrorSystemCancel:
                    {
                        NSLog(@"系统取消了验证touch id");
                        //切换到其他APP，系统取消验证Touch ID
                        Alert(@"提示", @"指纹登陆失败，请选择密码登陆!");
                        break;
                    }
                    case LAErrorUserCancel:
                    {
                        NSLog(@"用户取消了验证");
                        //用户取消验证Touch ID
                        break;
                    }
                    case LAErrorUserFallback:
                    {
                        NSLog(@"用户选择手动输入密码");
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //用户选择其他验证方式，切换主线程处理
                            
                        }];
                        break;
                    }
                    default:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            NSLog(@"其它情况");
                            
                            //其他情况，切换主线程处理
                            Alert(@"提示", @"指纹登陆失败，请选择密码登陆!");
                        }];
                        break;
                    }
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.password becomeFirstResponder];
                });
            }
        }];
    }
    else
    {
        //不支持指纹识别，LOG出错误详情
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled:
            {
                Alert(@"提示", @"设备Touch ID不可用或者用户未录入！");
                break;
            }
            case LAErrorPasscodeNotSet:
            {
                Alert(@"提示", @"系统未设置密码");
                break;
            }
            default:
            {
                Alert(@"提示", @"TouchID 不可用");
                break;
            }
        }
        
    }
}
@end
