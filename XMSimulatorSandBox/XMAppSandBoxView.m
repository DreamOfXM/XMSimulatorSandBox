//
//  XMAppSandBoxView.m
//  XMSimulatorSandBox
//
//  Created by guo ran on 17/2/22.
//  Copyright © 2017年 guo xiaoming. All rights reserved.
//

#import "XMAppSandBoxView.h"
#import <QuartzCore/QuartzCore.h>

@interface XMAppSandBoxView()

@property(nonatomic, strong)NSImageView *imageView;
@property(nonatomic, strong)CATextLayer *appSizeText;
@property(nonatomic, strong)CATextLayer *appIdentifierText;
@property(nonatomic, strong)CATextLayer *appNameText;


@end

@implementation XMAppSandBoxView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.wantsLayer = YES;
        [self p_addSubViews];
        
    }
    return self;
}

#pragma mark - Events

- (void)mouseMoved:(NSEvent *)theEvent {
    NSLog(@"theEvent=======%@",theEvent);
}


- (void)mouseDown:(NSEvent *)theEvent {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedSandBoxItem:)]) {
        [self.delegate didClickedSandBoxItem:self];
    }
}

#pragma mark - Views
- (void)p_addSubViews {
    [self p_addImageView];
    [self p_addAppSizeText];
    [self p_addAppIdentifierText];
    [self p_addAppNameText];
    
}

- (void)p_addImageView {
     _imageView = [[NSImageView alloc]initWithFrame:NSMakeRect(self.frame.size.height*2/6, self.bounds.size.height/5, self.frame.size.height*3/5, self.frame.size.height*3/5)];
    _imageView.wantsLayer = YES;
    _imageView.layer.cornerRadius = 8.0f;
    _imageView.layer.masksToBounds = YES;
    _imageView.imageScaling = NSImageScaleAxesIndependently;
    [self addSubview:_imageView];
}

- (void)p_addAppSizeText {
    _appSizeText = [CATextLayer layer];
    _appSizeText.frame = NSMakeRect(CGRectGetMaxX(_imageView.frame)+8, self.bounds.size.height/5, self.frame.size.width - CGRectGetMaxX(_imageView.frame), 15);
    NSFont *font = [NSFont systemFontOfSize:10];
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    _appSizeText.font = fontRef;
    _appSizeText.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    _appSizeText.contentsScale = 2.0;
    _appSizeText.foregroundColor = [NSColor redColor].CGColor;
    [self.layer addSublayer:_appSizeText];
    
}

- (void)p_addAppIdentifierText {
    _appIdentifierText= [CATextLayer layer];
    _appIdentifierText.frame = NSMakeRect(CGRectGetMaxX(_imageView.frame)+8, self.bounds.size.height*2/5 + 2, self.frame.size.width - CGRectGetMaxX(_imageView.frame), 15);
    NSFont *font = [NSFont systemFontOfSize:10];
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    _appIdentifierText.font = fontRef;
    _appIdentifierText.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    
    _appIdentifierText.foregroundColor = [NSColor grayColor].CGColor;
    _appIdentifierText.contentsScale = 2.0;
//    _appIdentifierText.backgroundColor = [NSColor redColor].CGColor;
    [self.layer addSublayer:_appIdentifierText];
}


- (void)p_addAppNameText {
    _appNameText = [CATextLayer layer];
    _appNameText.frame = NSMakeRect(CGRectGetMaxX(_imageView.frame)+8, self.bounds.size.height*3/5 + 6, self.frame.size.width - CGRectGetMaxX(_imageView.frame), 15);
//    if (self.frame.size.height<=30) {
//        _appNameText.frame = NSMakeRect(0, self.bounds.size.height - 6, self.bounds.size.width, 15);
//    }
    NSFont *font = [NSFont systemFontOfSize:13];
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    _appNameText.font = fontRef;
    _appNameText.fontSize = font.pointSize;
    _appNameText.contentsScale = 2.0;
    CGFontRelease(fontRef);
    _appNameText.foregroundColor = [NSColor blackColor].CGColor;
//    _appNameText.backgroundColor = [NSColor clearColor];
    [self.layer addSublayer:_appNameText];
}

#pragma mark - SetMethods
- (void)setAppImage:(NSImage *)appImage {
    _appImage = appImage;
    if (appImage) {
        self.imageView.image = appImage;
    }else {
//        [self.imageView ]
    }
    
}

- (void)setAppName:(NSString *)appName {
    _appName = appName;
    self.appNameText.string = appName;
}

- (void)setAppIdentifier:(NSString *)appIdentifier {
    _appIdentifierText.string = [self attributedStringWithText:appIdentifier textColor:[NSColor grayColor]];
}

- (void)setAppSzie:(NSString *)appSzie {
    _appSzie = appSzie;
    _appSizeText.string = [self attributedStringWithText:appSzie textColor:[NSColor grayColor]];;
}

- (NSMutableAttributedString *)attributedStringWithText:(NSString *)text textColor:(NSColor *)textColor {
    NSDictionary *dic = @{NSForegroundColorAttributeName:textColor};
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:text attributes:dic];
    return attributeStr;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
