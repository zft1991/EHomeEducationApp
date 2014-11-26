//
//  EHEStdLoginViewController.m
//  EHomeEducation
//
//  Created by Yixiang Chen on 11/17/14.
//  Copyright (c) 2014 AppChen. All rights reserved.
//

#import "EHEStdLoginViewController.h"
#import "MF_Base64Additions.h"
#import "EHEStdRegisterViewController.h"

@interface EHEStdLoginViewController ()

@end

@implementation EHEStdLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.txtPassWord.delegate = self;
    self.txtUserName.delegate = self;
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


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)loginButtonPressed:(id)sender {
    
    NSString * postData = [NSString stringWithFormat:@"{\"username\":\"%@\",\"password\":\"%@\"}",self.txtUserName.text,[self.txtPassWord.text base64String]];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://218.249.130.194:8080/ehomeedu/api/customer/userlogin.action"]];
    NSString * data = [NSString stringWithFormat:@"info=%@",postData];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData * responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(responseData != nil){
        //使用系统自带JSON解析方法
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSLog(@"%@",dict);
        if([dict[@"code"] intValue] == 0){
            NSLog(@"message=%@",[dict objectForKey:@"message"]);
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:self.txtUserName.text forKey:@"userName"];
            [defaults setObject:self.txtPassWord.text forKey:@"passWord"];
            [defaults synchronize];
            [self.navigationController popViewControllerAnimated:NO];
            
            NSString * path=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString * realPath=[path stringByAppendingString:@".plist"];
            NSLog(@"%@",realPath);
            
        }else{
            NSLog(@"%@",dict[@"message"]);
        }
    }
}


- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)forgetPasswordButtonPressed:(id)sender {
}

- (IBAction)goToRegisterButtonPressed:(id)sender {
    
    EHEStdRegisterViewController *registerViewController = [[EHEStdRegisterViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:registerViewController animated:YES completion:nil];
}
@end
