//
//  ViewController.h
//  SocketClient
//
//  Created by my on 2017/3/24.
//  Copyright © 2017年 my. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>

@interface ViewController : UIViewController<NSStreamDelegate>
{
    NSInteger flag;
}

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, assign) NSInteger kPort;


@end

