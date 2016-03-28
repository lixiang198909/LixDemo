//
//  KedaVC2.h
//  SSDD
//
//  Created by 李翔 on 16/3/26.
//  Copyright © 2016年 lixiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iflyMSC/IFlySpeechSynthesizerDelegate.h>
#import <iflyMSC/IFlySpeechSynthesizer.h>
#import "MBProgressHUD.h"

@interface KedaVC2 : UIViewController<IFlySpeechSynthesizerDelegate>

@property (nonatomic,strong)MBProgressHUD * HUD;
@property (nonatomic,strong)IFlySpeechSynthesizer *iFlySpeechSynthesizer;
@property (nonatomic,strong)UITextView *tView;
@property (nonatomic,strong)UIProgressView *progressView;

@end
