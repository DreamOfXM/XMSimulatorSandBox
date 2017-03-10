//
//  AppInfo.h
//  XMSandBox
//
//  Created by guo ran on 17/2/21.
//  Copyright © 2017年 guo xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppInfo : NSObject
@property(nonatomic, copy)NSString *appName;
@property(nonatomic, copy)NSString *identifier;
@property(nonatomic, assign)long long size;
@property(nonatomic, copy)NSString *appPath;
@property(nonatomic, copy)NSString *imagePath;


@end
