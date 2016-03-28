//
//  KedaVC1.m
//  SSDD
//
//  Created by 李翔 on 16/3/26.
//  Copyright © 2016年 lixiang. All rights reserved.
//

#import "KedaVC1.h"
#import <iflyMSC/IFlySpeechUtility.h>
#import <iflyMSC/IFlySpeechConstant.h>
#import <QuartzCore/QuartzCore.h>
#import "JSONKit.h"
#import "PCMToWAV.h"

@interface KedaVC1 ()

@end

@implementation KedaVC1

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.title=@"语音识别";
        self.result=[[NSMutableString alloc]init];//接收语音识别信息,开辟空间
    }
    return self;
}

/**
 @功能：初始化科大讯飞语音配置，语音识别对象
 @参数：无
 @返回值：无
 */

-(void)initMSC
{
    //创建语音配置
    NSString *appid=[NSString stringWithFormat:@"appid=%@,timeout=%@",APPID_VALUE,TIMEOUT_VALUE];
    [IFlySpeechUtility createUtility:appid];
    
    //创建一个语音识别单例对象
    self.iFlySpeechRecognizer=[IFlySpeechRecognizer sharedInstance];
    self.iFlySpeechRecognizer.delegate=self;
    //iat表示普通文本听写; search表示热词搜索; video表示视频音乐搜索; asr表示关键词识别;
    [self.iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    //设置采样率
    [self.iFlySpeechRecognizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
    //设置识别录音保存路径，默认目录是documents。asr.pcm为保存的文件名
    [self.iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    //设置返回结果数据格式为json，默认为json
    [self.iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    //设置语言(英文:en_us, 中文:zh_cn)，默认为中英文
    //    [self.iFlySpeechRecognizer setParameter:@"en_us" forKey:[IFlySpeechConstant LANGUAGE]];
    //设置音量(0~100)，默认为50
    [self.iFlySpeechRecognizer setParameter:@"100" forKey:[IFlySpeechConstant VOLUME]];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor groupTableViewBackgroundColor];
    
    //adjust the UI for iOS 7
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_OR_LATER)
    {
        self.edgesForExtendedLayout=UIRectEdgeNone;//指定边缘要延伸的方向为不延伸
    }

#endif
    
    self.tView = [[UITextView alloc] initWithFrame:CGRectMake(10, 20, self.view.bounds.size.width-20, 300)];
    self.tView.text = @"点击开始说话按钮，进行语音识别!";
    self.tView.backgroundColor = [UIColor lightGrayColor];
    self.tView.textColor = [UIColor blueColor];
    self.tView.font = [UIFont systemFontOfSize:18];
    self.tView.editable = NO;
    self.tView.layer.cornerRadius = 10;
    self.tView.layer.masksToBounds = YES;
    [self.view addSubview:self.tView];
    
    //开始说话按钮
    self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startBtn setTitle:@"按住开始说话" forState:UIControlStateNormal];
    [self.startBtn setTitle:@"松开停止说话" forState:UIControlStateHighlighted];
    [self.startBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.startBtn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    self.startBtn.backgroundColor = [UIColor redColor];
    self.startBtn.layer.cornerRadius = 5;
    self.startBtn.layer.masksToBounds = YES;
    self.startBtn.frame = CGRectMake(10, self.tView.frame.origin.y+self.tView.frame.size.height+40, 150, 40);
    [self.startBtn addTarget:self action:@selector(beginToSay) forControlEvents:UIControlEventTouchDown];//按住不放时调用
    [self.startBtn addTarget:self action:@selector(endToSay) forControlEvents:UIControlEventTouchUpInside];//点击后松开调用
    [self.view addSubview:self.startBtn];
    
    //播放录音按钮
    UIButton *readBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [readBtn setTitle:@"播放录音" forState:UIControlStateNormal];
    [readBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    readBtn.backgroundColor = [UIColor greenColor];
    readBtn.layer.cornerRadius = 5;
    readBtn.layer.masksToBounds = YES;
    readBtn.frame = CGRectMake(self.startBtn.frame.origin.x+self.startBtn.frame.size.width+10, self.startBtn.frame.origin.y, 140, 40);
    [readBtn addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:readBtn];
    
    //
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(10, self.tView.frame.origin.y+self.tView.frame.size.height+10, 300, 10);
    self.progressView.progress = 0.0;
    self.progressView.trackTintColor = [UIColor clearColor];
    self.progressView.progressTintColor = [UIColor greenColor];
    [self.view addSubview:self.progressView];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initMSC];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //销毁语音识别并设置委托为nil
    [self.iFlySpeechRecognizer stopListening];//停止语音识别
    [self.iFlySpeechRecognizer setDelegate:nil];//设置委托为nil
    [self.iFlySpeechRecognizer destroy];//销毁识别对象
    
    [self.player stop];
}

/**
 @功能：开始说话，进行语音识别
 @参数：无
 @返回值：无
 */
-(void)beginToSay
{
    self.startBtn.enabled=NO;
    [self.result deleteCharactersInRange:NSMakeRange(0, self.result.length)];//清空接收字符串
    if ([self.iFlySpeechRecognizer isListening])
    [self.iFlySpeechRecognizer stopListening];
    
    BOOL ret=[self.iFlySpeechRecognizer startListening];
    if (!ret)
    {
        [self show:@"启动识别服务失败,请稍后重试"];
    }
}
/**
 @功能：停止说话，停止语音识别
 @参数：无
 @返回值：无
 */
-(void) endToSay
{
    self.startBtn.enabled=YES;
    [self.iFlySpeechRecognizer stopListening];
}

/**
 @功能：播放录音(即播放刚才说的那段话)
 @参数：无
 @返回值：无
 */
-(void)playSound
{
    NSArray *originPcmPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pcmPath = [[originPcmPaths objectAtIndex:0] stringByAppendingPathComponent:@"asr.pcm"];
    
    NSLog(@"~~~~~%@",pcmPath);
//    BOOL directory=NO;
//    if (![[NSFileManager defaultManager] fileExistsAtPath:pcmPath isDirectory:&directory])
//    {
//        [[NSFileManager defaultManager] createDirectoryAtPath:pcmPath withIntermediateDirectories:NO attributes:nil error:nil];
//    }
    
    NSArray *newWAVPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *wavPath = [[newWAVPaths objectAtIndex:0] stringByAppendingPathComponent:@"asr.wav"];
    NSLog(@"11111%@",wavPath);
    
//    if (![[NSFileManager defaultManager] fileExistsAtPath:wavPath isDirectory:&directory])
//    {
//        [[NSFileManager defaultManager] createDirectoryAtPath:wavPath withIntermediateDirectories:NO attributes:nil error:nil];
//    }

    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pcmPath])
    {
        //pcm格式转换wav格式文件
        NSArray *ary = [NSArray arrayWithObjects:wavPath, pcmPath, nil];
        [[PCMToWAV sharePCM] pcmToWav:ary];
        
        //播放
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:wavPath]
                                                             error:nil];
        self.player.volume = 1.0;
        [self.player prepareToPlay];
        [self.player play];
    }
}


-(void)show:(NSString *)info
{
    if (!self.HUD)
    {
        self.HUD=[[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:self.HUD];
    }
    
    self.HUD.labelText=info;
    self.HUD.mode = MBProgressHUDModeText;//设置模式为文本
    [self.HUD show:YES];
    [self.HUD hide:YES afterDelay:1.5];//1.5秒后隐藏
}

/**
 @功能：解析网络json串
 @参数：网络json串
 @返回值：解析后的json数据
 */

- (NSString*)resolveNetworkJson:(NSString*)json
{
    if (json &&json.length)
    {
        NSDictionary *dic=nil;
        //ios5.0以后使用系统自带的json解析，之前的使用第三方库jsonkit
        if (IOS5_OR_LATER)
        {
            NSData *data=[json dataUsingEncoding:NSUTF8StringEncoding];
            dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        }
        else
        {
            dic=[json objectFromJSONStringWithParseOptions:JKSerializeOptionEscapeUnicode];
        }
        
        if (dic)
        {
            NSMutableString *str=[NSMutableString string];
            NSArray *array=[dic objectForKey:@"ws"];
            for (NSDictionary*dic in array)
            {
                NSArray *wordAry=[dic objectForKey:@"cw"];
                for (NSDictionary *wordDic in wordAry)
                {
                    [str appendString:[wordDic objectForKey:@"w"]];
                }
            }
            return str;
        }
    }
    return @"";
}

#pragma mark - IFlySpeechRecognizerDelegate
/** 开始录音回调
 当调用了`startListening`函数之后，如果没有发生错误则会回调此函数。如果发生错误则回调onError:函数
 */
-(void)onBeginOfSpeech
{
    self.progressView.progress=0;
    [self show:@"正在录音"];
}

/** 停止录音回调
 当调用了`stopListening`函数或者引擎内部自动检测到断点，如果没有发生错误则回调此函数。如果发生错误则回调onError:函数
 */
-(void) onEndOfSpeech
{
    self.progressView.progress=0;
    [self show:@"停止录音"];
}

/** 取消识别回调
 当调用了`cancel`函数之后，会回调此函数，在调用了cancel函数和回调onError之前会有一个短暂时间，您可以在此函数中实现对这段时间的界面显示。
 */
- (void) onCancel
{
    [self show:@"语音识别取消了"];
}

/** 音量变化回调
 在录音过程中，回调音频的音量。
 @param volume -[out] 音量，范围从1-100
 */
- (void) onVolumeChanged: (int)volume
{
    self.progressView.progress = volume/100.0;//设置进度
}


/** 识别结果回调
 在进行语音识别过程中的任何时刻都有可能回调此函数，你可以根据errorCode进行相应的处理，当errorCode没有错误时，表示此次会话正常结束；否则，表示此次会话有错误发生。特别的当调用`cancel`函数时，引擎不会自动结束，需要等到回调此函数，才表示此次会话结束。在没有回调此函数之前如果重新调用了`startListenging`函数则会报错误。
 @param errorCode 错误描述类，
 */
- (void) onError:(IFlySpeechError *) error
{
    if (error.errorCode ==0)
    {
        if (self.result.length==0)
        {
            [self show:@"囧! 没识别出来〜〜"];
        }
        else
        {
            self.tView.text = self.result;//最终识别的文本
        }
    }
}

/** 识别结果回调
 在识别过程中可能会多次回调此函数，你最好不要在此回调函数中进行界面的更改等操作，只需要将回调的结果保存起来。
 @param   results     -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度。
 @param   isLast      -[out] 是否最后一个结果
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSDictionary *dic = results[0];
    for (NSString *key in dic)
    {
        [self.result appendString:[self resolveNetworkJson:key]];//不断追加来自网络的文本
    }
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
