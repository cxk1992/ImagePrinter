//
//  ViewController.m
//  Image
//
//  Created by 陈旭珂 on 16/5/20.
//  Copyright © 2016年 cxk. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"someImage"];
    NSInteger width = image.size.width;
    NSInteger height = image.size.height;
    NSData *data = [self grayImageDatawithImage:image];
    
    data = [self transformGrayImageDta:data width:width height:height mode:6 midValue:70];
    
    [self drawBitImageWithData:data width:width height:height mode:6];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSData *) grayImageDatawithImage:(UIImage *)image {
    NSInteger width = image.size.width;
    NSInteger height = image.size.height;
    
    NSUInteger totalCount = width * height;
    
    Byte *pixels = malloc(totalCount);
    memset(pixels, 0, totalCount);
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaNone);
    
    CGContextTranslateCTM(context, 0, 0);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    for (NSUInteger i=0; i<totalCount; i++) {
        pixels[i] = ~pixels[i];
    }
    
    for (NSInteger i=0; i<height; i++) {
        printf("%3zi : ",i);
        for (NSInteger j=0; j<width; j++) {
            int pixel = pixels[i*width + j];
            if (pixel > 70) {
                printf("*");
            }else{
                printf(" ");
            }
        }
        printf("\n");
    }
    
    NSData *data = [NSData dataWithBytes:pixels length:totalCount];
    free(pixels);
    pixels = NULL;
    
    return data;
}

- (void)drawBitImageWithData:(NSData *)data width:(NSInteger)width height:(NSInteger)height mode:(NSInteger)mode{
    
    Byte *bytes = (Byte *)data.bytes;
    
    for (NSInteger i=0; i<height; i++) {
        
        NSInteger b = 7 - i&7;
        NSInteger move = (i >> 3)%mode;
        NSInteger baseRow = (i >> 3)/mode;
        printf("%3zi : ",i);
        for (NSInteger j = 0; j<width; j++) {
            NSInteger count = baseRow * width *mode + j * mode + move;
            Byte value = bytes[count];
            BOOL c = (value & (1 << b)) > 0;
            if (c) {
                printf("*");
            }else{
                printf(" ");
            }
        }
        printf("\n");
    }
}

- (NSData *)transformGrayImageDta:(NSData *)imageData width:(NSInteger)width height:(NSInteger)height mode:(NSInteger)mode midValue:(Byte)midValue{
    
    switch (mode) {
        case 1:
        case 3:
        case 6:
            break;
        default:
            NSLog(@"mode can only match 1 3 6 , thx");
            return nil;
            break;
    }
    
    NSInteger s = mode;
    
    NSInteger rows = (height>>3) + mode;
    NSInteger total = rows * width;
    char *dataBuffer = malloc(total);
    bzero(dataBuffer, total);
    
    Byte *fromBtyes = (Byte *)imageData.bytes;
    
    for (NSInteger i=0; i<total; i += s) {
        NSInteger row = i/(width * s);
        NSInteger col = (i%(s*width))/s; 
        for (NSInteger j=0; j<s; j++) {
            NSInteger srow = row * s + j;
            Byte value = 0;
            for (NSInteger b=7; b>=0; b--) {
                NSInteger fRow = srow * 8 + (7 - b);
                NSInteger count = fRow * width + col;
                if (count >= imageData.length) {
                    continue;
                }
                value |= (fromBtyes[count] > midValue) << b;
            }
            dataBuffer[i+j] = value;
        }
    }
    
    NSData *result = [NSData dataWithBytes:dataBuffer length:total];
    
//    for (NSInteger i=0; i<total; i++) {
//        Byte value = dataBuffer[i];
//        printf("   %3zi : %3zi",i,value);
//    }
    
    free(dataBuffer);
    dataBuffer = NULL;
    return result;
    
}

@end
