//
//  XMSimulatorSandBox.m
//  XMSimulatorSandBox
//
//  Created by guo ran on 17/2/21.
//  Copyright © 2017年 guo xiaoming. All rights reserved.
//

/**
 * 说实在的这个小插件写了有一段时间了，直到今天才上传，原因是自己并没太多成就感，因为思路并不是自己独有的创造，我看了https://github.com/MakeZL写的东西，然后觉得可能不能满足我的需要，我就重新写了这个插件，在此也感谢MakeZl,虽说并没有完全照抄照搬MakeZl的东西，也加入不少自己的学习和理解，相比MakeZl，我用了不少Mac OS的Api接口，从功能上来说都是查找沙盒路径，但是我增加了新的功能，也可以说是UI展现，这个算是自己的贡献吧，这个思路来源于simPholder,但是simPholder在电脑上不稳定，经常闪退，而且有很多应用运行后找不到，所以，感觉体验有点……，这个也算是一点点改进吧，如果发现有什么bug的话，欢迎指正！！！！
 */

#import "XMSimulatorSandBox.h"
#import "XMSimulatorInfo.h"
#import "AppInfo.h"
#import "XMMenuItem.h"
#import "NSString+FileSize.h"
#import "XMAppSandBoxView.h"

@interface XMSimulatorSandBox()<NSMenuDelegate,XMAppSandBoxViewDelegate>
@property(nonatomic, strong)NSFileManager *fileManager;
@property(nonatomic, strong)NSMutableArray *simulatorInfos;
@property(nonatomic, strong)NSMutableArray *appSandBoxs;
@property(nonatomic, strong)NSMutableArray *appInfos;
@end

@implementation XMSimulatorSandBox
static NSString * deviceStr = @"/Library/Developer/CoreSimulator/Devices";
static id _instance;
- (instancetype)init  {
    if (self = [super init]) {
        [self addNSNotfications];
        
    }
    return self;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (void)pluginDidLoad:(NSBundle *)plugin {
    NSLog(@"hello every");
    _instance = [[self alloc]init];
    [_instance commonInit];
    //    [self addNSNotfications];
}

#pragma mark - NSNotifications
- (void)applicationDidFinishLaunching:(NSNotification *)sender {

    [self adddItermsIsUpdate:NO];
}

- (void)receiveEveryNSNotifaction:(NSNotification *)sender {
    //    NSLog(@"objectName ==== %@,info ====== %@",sender.name,sender.userInfo);
//    if([sender.name isEqualToString:NSUserDefaultsDidChangeNotification]) {
//        NSLog(@"objectName ==== %@ ==== %@",sender.name,sender.userInfo);

//    }
}

#pragma mark - Delegates
- (void)menuWillOpen:(NSMenu *)menu {

//    NSLog(@"menu ======== %@",menu.title);
    //更新文件大小的计算
    [self commonInit];
    [self adddItermsIsUpdate:YES];
}

- (void)menuNeedsUpdate:(NSMenu*)menu {
// NSLog(@"menu ======== %@",menu.title);
}

- (void)didClickedSandBoxItem:(XMAppSandBoxView *)item {
    if (item) {
        [self goToAppSanBox:item];
    }
}

#pragma mark - NSViews
/**
 *  Mac OS 坐标系是数学坐标系，即以左下角圆点O为（0，0）分别y向上为正，x向右为正。
 */

- (void)adddItermsIsUpdate:(BOOL)isUpDate {
    
    //1 first level menu
    NSMenu *mainMenu = [NSApp mainMenu];
    
    //1.1 first level Item
    NSMenuItem *fileItem = [mainMenu itemWithTitle:@"File"];
    //2 set delegate for second level menu
    fileItem.submenu.delegate = self;
    
    //2.1 second level Item
    NSMenuItem *sandBoxItem = [[NSMenuItem alloc]init];
    sandBoxItem.tag = 100001;
    sandBoxItem.title  = @"simulator sanbox ->";
    sandBoxItem.state = NSOnState;
    
    if (isUpDate) {
       NSMenuItem *item = [fileItem.submenu itemWithTag:100001];
        if (item) {
            [item.submenu removeAllItems];
            [fileItem.submenu removeItem:item];
        }
    }
  
    //2.2 add a Item and a separator line  to second menu (@"File" menu)
    [fileItem.submenu addItem:[NSMenuItem separatorItem]];
    [fileItem.submenu addItem:sandBoxItem];

    
    //3 third menu
    NSMenu *sanBoxMenu = [[NSMenu alloc]init];
    
    NSUInteger count = self.simulatorInfos.count;
    for (NSUInteger index = 0; index < count; index++) {
        XMSimulatorInfo *simulator = self.simulatorInfos[index];
        // third level Item
        //        NSMenuItem *item = [[NSMenuItem alloc]initWithTitle:simulator.name action:@selector(lala) keyEquivalent:@""];
        NSMenuItem *item = [[NSMenuItem alloc]init];
        NSString *version = [self versionWithRuntime:simulator.runtime];
        item.title = [NSString stringWithFormat:@"%@(%@)",simulator.name,version];
        [item setTarget:self];
        [sanBoxMenu addItem:[NSMenuItem separatorItem]];
        [sanBoxMenu addItem:item];
        
        [self addAppSandBoxInfoOfSimulator:simulator toItem:item];
    }
    sandBoxItem.submenu = sanBoxMenu;
}


//添加应用沙盒信息
- (void)addAppSandBoxInfoOfSimulator:(XMSimulatorInfo *)simulator toItem:(NSMenuItem *)item {
    [self filterSandBoxsWhichHasNotAppBundleWithSimulatorPath:simulator.simulatorPath appInfos:simulator.appInfos];
    //3各个应用沙盒
     NSMenu *appMenu = [[NSMenu alloc]init];
    if (!simulator.appInfos || !simulator.appInfos.count) {
//fourth level  Item
        NSMenuItem *appMenuItem = [[NSMenuItem alloc]init];
        appMenuItem.title = @"no Application sandBox info";
        [appMenuItem setTarget:self];
        [appMenu addItem:appMenuItem];
        item.submenu = appMenu;
        return;
    }
    
    for (AppInfo *app in simulator.appInfos) {
        XMMenuItem *appMenuItem = [[XMMenuItem alloc]init];
   
        if (app.appName == nil) {
            continue;
        }

        NSData *imageData = [[NSData alloc]initWithContentsOfFile:app.imagePath];
        NSImage *image = nil;
        appMenuItem.image = image;
        if (imageData) {
            image = [[NSImage alloc]initWithData:imageData];
        }else {
            NSString *path = [[self homePath] stringByAppendingPathComponent:@"Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/XMSimulatorSandBox.xcplugin/Contents/Resources/iOS7Template@2x.png"];
            NSArray *array = [self.fileManager contentsOfDirectoryAtPath:path error:nil];
            NSData *data = [NSData dataWithContentsOfFile:path];
            image = [[NSImage alloc]initWithData:data];
            
        }
        
        appMenuItem.title = app.appName == nil?@"no name":app.appName;
        appMenuItem.appPath = app.appPath;
        [appMenuItem setAction:@selector(goToAppSanBox:)];
        [appMenuItem setTarget:self];
        
        XMAppSandBoxView *view = [[XMAppSandBoxView alloc]initWithFrame:NSMakeRect(0, 0, 400, 60)];
        view.delegate = self;
        view.autoresizingMask = NSViewWidthSizable;
        view.appImage = image;
        view.appName = app.appName;
        view.appIdentifier = app.identifier;
        view.appPath = app.appPath;
        view.appSzie = [NSString stringWithFormat:@"size:%@",[self appFileSizeWithSize:app.size]];
        
        appMenuItem.view = view;
        [appMenu addItem:[NSMenuItem separatorItem]];
        [appMenu addItem:appMenuItem];
        
      
    }
    item.submenu = appMenu;
}

- (void)filterSandBoxsWhichHasNotAppBundleWithSimulatorPath:(NSString *)simulatorPath appInfos:(NSMutableArray *)appInfos {
    NSString *path = [simulatorPath stringByAppendingPathComponent:@"data/Containers/Bundle/Application"];
    NSError *error = nil;
    NSArray *bundles = nil;
    if (![self.fileManager fileExistsAtPath:path]) {
        return ;
    }else{
        bundles = [self.fileManager contentsOfDirectoryAtPath:path error:&error];
    }
    
    //    NSBundle *bundle = [NSBundle bundleWithIdentifier:app.identifier];
    // bundles of every simulator
    NSString *appName = nil;
    for (NSString *bundleStr in bundles) {
        //bundle path
        NSString *bundlePath = [path stringByAppendingPathComponent:bundleStr];
        
        // calculate bundle size
        long long bundleSize = [bundlePath totalFileSize];
        
        if(![self.fileManager fileExistsAtPath:bundlePath]) {
            return ;
        }
        
        NSArray *fileArray = [self.fileManager contentsOfDirectoryAtPath:bundlePath error:nil];
        NSString *imagePath = nil;
        for (NSString *str in fileArray) {
            if ([[[str componentsSeparatedByString:@"."] lastObject] isEqualToString:@"app"]) {
                appName = [str substringWithRange:NSMakeRange(0, str.length - 4)];
                NSString *fullPathStr = [bundlePath stringByAppendingPathComponent:str];
                 NSArray *array  = [self.fileManager contentsOfDirectoryAtPath:fullPathStr error:nil];
                NSUInteger count = array.count;
                for (NSUInteger index = 0; index<count; index++) {
                    NSArray *sources = [array[index] componentsSeparatedByString:@"."];
                    if ([sources containsObject:@"png"]) {
                        if ([array[index] rangeOfString:@"AppIcon"].location  == NSNotFound) continue;
                        
                        imagePath = [fullPathStr stringByAppendingPathComponent:array[index]];
                        break;
                    }
                }
            }
        }
        
        // search exist bundle in existed sanndBoxs
        NSString *bundlePlistPath = [bundlePath stringByAppendingPathComponent:@".com.apple.mobile_container_manager.metadata.plist"];
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:bundlePlistPath];
        NSString *identifier = plistDic[@"MCMMetadataIdentifier"];
        
        for (AppInfo *app in appInfos) {
            if ([app.identifier isEqualToString:identifier]) {
                app.appName = appName;
                long long dataSize = [app.appPath totalFileSize];
                app.size = dataSize + bundleSize;
                app.imagePath = imagePath;
                
            }else{
//                NSLog(@"plistDic MCMMetadataIdentifier ===== %@",plistDic[@"MCMMetadataIdentifier"]);
            }
        }
        
    }
}

#pragma mark - HandleEvents
- (void)haha {
    //    NSLog(@"世界是美好的");
    [self showAlert];
}

- (void)goToAppSanBox:(XMAppSandBoxView *)sender {
    [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:sender.appPath];
}

#pragma mark - Events

- (void)addNSNotfications {
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(applicationDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveEveryNSNotifaction:) name:nil object:nil];
}

- (void)commonInit {
    [self.simulatorInfos removeAllObjects];
    [self dealWithDeviceInfosAndAppInfos];
}

- (void)showAlert {
    NSAlert *alert = [[NSAlert alloc]init];
    [alert setMessageText:@"世界是美好的"];
    [alert runModal];
}


- (void)dealWithDeviceInfosAndAppInfos {
    NSString *devicePath = [self devicePath];
    if (![self.fileManager fileExistsAtPath:devicePath]) {
        return;
    }
    NSError *error;
    
    NSArray *array = [self.fileManager contentsOfDirectoryAtPath:devicePath error:&error];
    
    for (NSString *str in array) {
        //1 记录模拟器信息
        NSString *devivePlistPath = [[devicePath stringByAppendingPathComponent:str] stringByAppendingPathComponent:@"device.plist"];
        
        if (![self.fileManager fileExistsAtPath:devivePlistPath]) {
            continue;
        }
        
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:devivePlistPath];
        XMSimulatorInfo *simulator = [[XMSimulatorInfo alloc]init];
        simulator.UDID = dic[@"UDID"];
        simulator.deviceType = dic[@"deviceType"];
        simulator.name = dic[@"name"];
        simulator.runtime = dic[@"runtime"];
        simulator.state = dic[@"state"];
        simulator.simulatorPath = [devicePath stringByAppendingPathComponent:str];
        simulator.appInfos = [self getAppInfosWithDevicePath:devicePath str:str];
        [self.simulatorInfos addObject:simulator];
    }
    
    //排序
    [self sortDeviceVesionAndIOSVesion];
}



//Get simulator infos
- (NSMutableArray *)getAppInfosWithDevicePath:(NSString *)devicePath str:(NSString *)str {
    NSMutableArray *appInfos = [[NSMutableArray alloc]init];
    NSString *appPath = [[devicePath stringByAppendingPathComponent:str] stringByAppendingPathComponent:@"data/Containers/Data/Application"];
    if (![self.fileManager fileExistsAtPath:appPath]) {
        return nil;
    }
    
    NSError *error = nil;
    NSArray *appSandBoxs = [self.fileManager contentsOfDirectoryAtPath:appPath error:&error];
    for (NSString *appendStr in appSandBoxs) {
        NSString *fullAppPath = [appPath stringByAppendingPathComponent:appendStr];
        if (![self.fileManager fileExistsAtPath:fullAppPath]) {
            continue;
        }
        
//        //查看数组，除了doucument、temp、library 还有一个plist文件，查看可知是一个关于应用信息的plist
//        NSError *error = nil;
//        NSArray *temp = [self.fileManager contentsOfDirectoryAtPath:fullAppPath error:&error];
        

        NSString *appDataInfoPath = [fullAppPath stringByAppendingPathComponent:@".com.apple.mobile_container_manager.metadata.plist"];
        NSDictionary *appDir = [NSDictionary dictionaryWithContentsOfFile:appDataInfoPath];
        if (appDir == nil) {
            continue;
        }
        AppInfo *app = [[AppInfo alloc]init];
        app.identifier = appDir[@"MCMMetadataIdentifier"];
        app.appPath = fullAppPath;
        [appInfos addObject:app];
    }
    
    return appInfos;
}

- (void)sortDeviceVesionAndIOSVesion {
    //version
        NSArray *simulators = [self.simulatorInfos sortedArrayUsingComparator:^NSComparisonResult(XMSimulatorInfo * _Nonnull obj1, XMSimulatorInfo * _Nonnull obj2) {
            NSString *version1 = [self versionWithRuntime:obj1.runtime];
            NSString *version2 = [self versionWithRuntime:obj2.runtime];;
          
            if ([obj1.name compare:obj2.name] == NSOrderedAscending) {
                return NSOrderedAscending;
            }else if ([obj1.name compare:obj2.name] == NSOrderedDescending) {
                return NSOrderedDescending;
            }else {
                if ([version1 compare:version2] == NSOrderedAscending) {
                    return NSOrderedAscending;
                }else if ([version1 compare:version2] == NSOrderedDescending) {
                    return NSOrderedDescending;
                }else{
                    return NSOrderedSame;
                }
            }
        }];
    
    [self.simulatorInfos removeAllObjects];
    for (XMSimulatorInfo *simulatorInfo in simulators) {
        [self.simulatorInfos addObject:simulatorInfo];
    }
}

- (NSString *)versionWithRuntime:(NSString *)runtime {
    return [[[runtime componentsSeparatedByString:@"."] lastObject] stringByReplacingOccurrencesOfString:@"-" withString:@"."];
}

//获取沙盒路径
- (NSString *)homePath {
    NSString *homeStr = NSHomeDirectory();
    return homeStr;
}

- (NSString *)devicePath {
    NSString *devicePath = [[self homePath] stringByAppendingPathComponent:deviceStr];
    return devicePath;
}

- (NSString *)appFileSizeWithSize:(long long)fileSize {
    if (fileSize>1024*1024) {
        return [NSString stringWithFormat:@"%.1f M",(float)fileSize/1024/1024];
    }else if(fileSize>1024) {
        return [NSString stringWithFormat:@"%d KB",(int)round((double)fileSize/1024)];
  }
    return [NSString stringWithFormat:@"%d B",(int)fileSize];
}

#pragma mark - Layzes
- (NSFileManager *)fileManager {
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

- (NSMutableArray *)simulatorInfos {
    if (!_simulatorInfos) {
        _simulatorInfos = [[NSMutableArray alloc]init];
    }
    return _simulatorInfos;
}

- (NSMutableArray *)appSandBoxs {
    if (!_appSandBoxs) {
        _appSandBoxs = [[NSMutableArray alloc]init];
    }
    return _appSandBoxs;
}

- (NSMutableArray *)appInfos {
    if (!_appInfos) {
        _appInfos = [[NSMutableArray alloc]init];
    }
    return _appInfos;
}

@end
