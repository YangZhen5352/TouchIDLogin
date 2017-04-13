# TouchIDLogin
调用系统指纹识别的SDK，实现用户登陆，并且使用系统登陆的数字验证密码，作为失败的进一步验证登陆过程。

核心方法
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
