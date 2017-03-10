//
//  XMSimulatorInfo.h
//  XMSandBox
//
//  Created by guo ran on 17/2/20.
//  Copyright © 2017年 guo xiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMSimulatorInfo : NSObject
@property(nonatomic, copy)NSString *UDID;
@property(nonatomic, copy)NSString *deviceType;
@property(nonatomic, copy)NSString *name;
//获取版本，如 ios9.0
@property(nonatomic, copy)NSString *runtime;
@property(nonatomic, copy)NSString *state;

@property(nonatomic, copy)NSString *simulatorPath;

@property(nonatomic, strong)NSMutableArray *appInfos;


@end
