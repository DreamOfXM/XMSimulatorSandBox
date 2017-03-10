//
//  NSString+FileSize.m
//  XMSimulatorSandBox
//
//  Created by guo ran on 17/2/21.
//  Copyright © 2017年 guo xiaoming. All rights reserved.
//

#import "NSString+FileSize.h"

@implementation NSString (FileSize)

- (unsigned long long)totalFileSize {
    // total size
    unsigned long long size = 0;
    NSFileManager *mgr = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    
    BOOL exists = [mgr fileExistsAtPath:self isDirectory:&isDirectory];
    if (!exists) return size;
    
    if (isDirectory) {
        NSDirectoryEnumerator *enumerator = [mgr enumeratorAtPath:self];
        for (NSString *subpath in enumerator) {
            // fullSubPath
            NSString *fullSubpath = [self stringByAppendingPathComponent:subpath];
            // accumulation file size
            size += [mgr attributesOfItemAtPath:fullSubpath error:nil].fileSize;
        }
    } else {
        size = [mgr attributesOfItemAtPath:self error:nil].fileSize;
    }
    
    return size;
}


@end
