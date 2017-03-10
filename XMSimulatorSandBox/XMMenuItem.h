//
//  XMMenuItem.h
//  XMSimulatorSandBox
//
//  Created by guo ran on 17/2/21.
//  Copyright © 2017年 guo xiaoming. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XMMenuItem : NSMenuItem
@property(nonatomic, copy)NSString *appPath;

@property(nonatomic, assign)long size;
@end
