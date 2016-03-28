//
//  CustomHeader.h
//  MSCDemo
//
//  Created by 钱老师 on 14-7-12.
//  Copyright (c) 2014年 钱老师. All rights reserved.
//

#ifndef MSCDemo_CustomHeader_h
#define MSCDemo_CustomHeader_h

#define IOS5_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"5.0"] != NSOrderedAscending)
#define IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)

#define APPID_VALUE @"524257da" //科大讯飞AppID 56f6250b
#define TIMEOUT_VALUE @"20000"  //连接超时的时间，以ms为单位

#endif
