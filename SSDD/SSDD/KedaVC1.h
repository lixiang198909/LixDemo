//
//  KedaVC1.h
//  SSDD
//
//  Created by 李翔 on 16/3/26.
//  Copyright © 2016年 lixiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iflyMSC/IFlySpeechRecognizerDelegate.h>
#import <iflyMSC/IFlySpeechRecognizer.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"

@interface KedaVC1 : UIViewController<IFlySpeechRecognizerDelegate>

@property (nonatomic,strong)IFlySpeechRecognizer *iFlySpeechRecognizer;
@property (nonatomic,strong)UITextView *tView;
@property (nonatomic,strong)UIButton *startBtn;
@property (nonatomic,strong)AVAudioPlayer *player;
@property (nonatomic,strong)MBProgressHUD *HUD;
@property (nonatomic,strong)NSMutableString *result;//接收结果
@property (nonatomic,strong)UIProgressView *progressView;//等待提示视图

@end
