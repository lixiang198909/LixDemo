//
//  ViewController.m
//  SSDD
//
//  Created by 李翔 on 16/2/29.
//  Copyright © 2016年 lixiang. All rights reserved.
//

#import "ViewController.h"


////带界面的语音识别空间
//#import <iflyMSC/IFlyRecognizerViewDelegate.h>
//#import <iflyMSC/IFlyRecognizerView.h>
//
////不带界面的语音识别控件
//#import <iflyMSC/IFlySpeechRecognizerDelegate.h>
//#import <iflyMSC/IFlySpeechSynthesizer.h>
//
////不带界面的语音合成控件
//#import <iflyMSC/IFlySpeechSynthesizerDelegate.h>
//#import <iflyMSC/IFlySpeechSynthesizer.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor=[UIColor whiteColor];
     
    
    UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(150, 150, 100, 40)];
    lab.backgroundColor=[UIColor yellowColor];
    lab.layer.borderWidth=2;
    lab.layer.cornerRadius=10;
    lab.layer.borderColor=[UIColor redColor].CGColor;
//    lab.clipsToBounds=YES;
    lab.layer.masksToBounds=YES;
    [self.view addSubview:lab];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
