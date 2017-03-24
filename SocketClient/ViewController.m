//
//  ViewController.m
//  SocketClient
//
//  Created by my on 2017/3/24.
//  Copyright © 2017年 my. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *port;

@property (weak, nonatomic) IBOutlet UITextField *serviceIP;

@property (weak, nonatomic) IBOutlet UILabel *message;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)connectService:(id)sender {
    flag = 0;
    [self initNetworkCommunication];
}
- (IBAction)reviveMsg:(id)sender {
    flag = 1;
    [self initNetworkCommunication];
}

- (void)initNetworkCommunication {
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.serviceIP.text, (int)[self.port.text intValue], &readStream, &writeStream);
    _inputStream = (__bridge_transfer NSInputStream *)readStream;
    _outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_inputStream open];
    [_outputStream open];
    
}

- (void)close {
    [_outputStream close];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream setDelegate:nil];
    [_inputStream close];
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream setDelegate:nil];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    NSString *event;
    switch (eventCode) {
        case NSStreamEventNone:
            event = @"NSStreamEventNone";
            NSLog(@"%@",event);
            break;
        case NSStreamEventOpenCompleted:
            event = @"NSStreamEventOpenCompleted";
            NSLog(@"%@",event);
            break;
        case NSStreamEventHasBytesAvailable:
            event = @"NSStreamEventHasBytesAvailable";
            NSLog(@"%@",event);
            if (flag == 1 && aStream == _inputStream) {
                NSMutableData *input = [[NSMutableData alloc] init];
                uint8_t buffer[1024];
                NSInteger len;
                while ([_inputStream hasBytesAvailable]) {
                    len = [_inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        [input appendBytes:buffer length:len];
                    }
                }
                NSString *result = [[NSString alloc] initWithData:input encoding:NSUTF8StringEncoding];
                NSLog(@"%@",result);
                _message.text = result;
            }
        case NSStreamEventHasSpaceAvailable:
            event = @"NSStreamEventHasSpaceAvailable";
            NSLog(@"%@",event);
            if (flag ==0 && aStream == _outputStream) {
                //输出
                UInt8 buff[] = "Hi Server!";
                [_outputStream write:buff maxLength: strlen((const char*)buff)+1];
                //必须关闭输出流否则，服务器端一直读取不会停止，
                [_outputStream close];
            }
            break;
        case NSStreamEventErrorOccurred:
            event = @"NSStreamEventErrorOccurred";
            NSLog(@"%@",event);
            [self close];
            break;
        case NSStreamEventEndEncountered:
            event = @"NSStreamEventEndEncountered";
            NSLog(@"%@",event);
            NSLog(@"Error:%ld:%@",[[aStream streamError] code], [[aStream streamError] localizedDescription]);
            break;
        default:
            [self close];
            event = @"Unknown";
            break;
    }
}



@end
