//
//  ViewController.m
//  ProtocolBufferDemo
//
//  Created by ALittleNasty on 2017/2/14.
//  Copyright © 2017年 vcredit. All rights reserved.
//

#import "ViewController.h"


#pragma mark - Util

#import <Protobuf/GPBProtocolBuffers.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>

#pragma mark - Model

#import "Book.pbobjc.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.button.layer.cornerRadius = 5.f;
}

#pragma mark - requestData

- (IBAction)requestData:(id)sender
{
    [SVProgressHUD show];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    /*
     因为AFNetworking默认的请求解析和响应解析都是JSON格式的, 但是我们使用的是Google的ProtoBuf, 所以要将请求解析和响应解析设置为AFHTTPRequestSerializer和AFHTTPResponseSerializer
     */
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"application/x-protobuf",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml"]];
    
    [manager GET:@"http://10.141.10.80/hello-world/proto" parameters:nil progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [SVProgressHUD dismiss];
        
        Book *book = [Book parseFromData:responseObject error:nil];
        
        NSString *title = [NSString stringWithFormat:@"返回数据大小为%zd字节", [(NSData *)responseObject length]];
        NSString *msg = [NSString stringWithFormat:@"编号: %d\n名称: %@\n简介: %@", book.id_p, book.name, book.desc];
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:okAction];
        [self presentViewController:alertVC animated:YES completion:NULL];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"请求失败"];
    }];
}

@end
