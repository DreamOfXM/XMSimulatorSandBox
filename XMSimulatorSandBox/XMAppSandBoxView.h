//
//  XMAppSandBoxView.h
//  XMSimulatorSandBox
//
//  Created by guo ran on 17/2/22.
//  Copyright © 2017年 guo xiaoming. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XMAppSandBoxView;
@protocol XMAppSandBoxViewDelegate <NSObject>
@optional
- (void)didClickedSandBoxItem:(XMAppSandBoxView *)item;
@end

@interface XMAppSandBoxView : NSView

@property(nonatomic, strong)NSImage *appImage;

@property(nonatomic, copy)NSString *appName;
@property(nonatomic, copy)NSString *appIdentifier;
@property(nonatomic, copy)NSString *appSzie;

@property(nonatomic, copy)NSString *appPath;

@property(nonatomic, weak)id<XMAppSandBoxViewDelegate>delegate;


@end
