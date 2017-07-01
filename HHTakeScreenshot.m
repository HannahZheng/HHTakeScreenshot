//
//  HHTakeScreenshot.m
//  GlobalTimes
//
//  Created by MXTH on 2017/6/30.
//  Copyright © 2017年 Hannah. All rights reserved.
//

#import "HHTakeScreenshot.h"
#import "HHShareView.h"

@interface HHTakeScreenshot ()

@property (nonatomic, strong)UIImageView *shotV;
@property (nonatomic, strong) UIView *clearView;
@property (nonatomic, strong) UIView *promptV;
@property (nonatomic, strong) HHShareView *shareView;

@end

#define HHMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define HHMainScreenHeight [UIScreen mainScreen].bounds.size.height
#define HHMainScreenBounds [UIScreen mainScreen].bounds
#define HHKeyWindow [UIApplication sharedApplication].keyWindow

@implementation HHTakeScreenshot

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        
        UIView *clearView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        clearView.backgroundColor = HHAlphaColor(0, 0, 0, 0.7);
        [self addSubview: clearView];
        _clearView = clearView;

    }
    return self;
}

- (UIImageView *)shotV{
    if (_shotV == nil) {
        UIImageView *imageV = [[UIImageView alloc] init];
        imageV.frame = CGRectMake(0, 0, HHKeyWindow.frame.size.width/2, HHKeyWindow.frame.size.height/2);
        imageV.center = CGPointMake( HHKeyWindow.frame.size.width/2, HHKeyWindow.frame.size.height/2);
        
        CALayer *layer = [imageV layer];
        layer.borderColor = [UIColor whiteColor].CGColor;
        layer.borderWidth = 3.0f;
        //添加四个边阴影
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOffset = CGSizeMake(0, 0);
        layer.shadowOpacity = 0.5;
        layer.shadowRadius = 10.0;
        //添加两个边阴影
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOffset = CGSizeMake(4, 4);
        layer.shadowOpacity = 0.5;
        layer.shadowRadius = 2.0;
        [_clearView addSubview:imageV];
        _shotV = imageV;
    }
    
    return _shotV;
}

- (UIView *)promptV{
    if (_promptV == nil) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HHMainScreenWidth, 80)];
        bgView.backgroundColor = [UIColor whiteColor];
        
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
        shareBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        shareBtn.backgroundColor = [UIColor colorWithRed:246/255.0 green:66/255.0 blue:83/255.0 alpha:1.0];
        shareBtn.frame = CGRectMake(HHMainScreenWidth-100, 0, 100, 80);
        [shareBtn addTarget:self action:@selector(didShowShareView) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:shareBtn];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, HHMainScreenWidth-120, 80)];
        label.font = [UIFont systemFontOfSize:20];
        label.numberOfLines = 0;
        label.textColor = [UIColor blackColor];
        label.text = @"已捕获屏幕截图\n快分享给朋友吧";
        
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:label.text];
        NSRange subRange = [label.text rangeOfString:@"快分享给朋友吧" options:NSBackwardsSearch];
        [attrStr addAttributes:@{
                                 NSForegroundColorAttributeName:[UIColor colorWithRed:127/255.0 green:127/255.0 blue:127/255.0 alpha:1.0],
                                 NSFontAttributeName:[UIFont systemFontOfSize:18]} range:subRange];
        NSMutableParagraphStyle *paraSty = [[NSMutableParagraphStyle alloc] init];
        [paraSty setLineSpacing:5];
        [attrStr addAttribute:NSParagraphStyleAttributeName value:paraSty range:NSMakeRange(0, label.text.length)];
        label.attributedText = attrStr;
        
        [bgView addSubview:label];
        
        [self.clearView addSubview:bgView];
        _promptV = bgView;
    }
    
    return _promptV;
}

- (void)didShowShareView{
    
    self.shareView.shareImg = self.shotV.image;
    [self.shareView showShareView];
    [self dismiss];
}

- (HHShareView *)shareView{
    if (_shareView == nil) {
        HHShareView *shareView = [[HHShareView alloc]initWithFrame:HHMainScreenBounds];
        shareView.hidden = YES;
        shareView.justShareImg = YES;
        [HHKeyWindow addSubview:shareView];
        _shareView = shareView;

    }
    return _shareView;
}

- (void)handleShotImageV{
    self.shotV.image = [self imageWithScreenshot];
    self.promptV.hidden = NO;
    self.hidden = NO;
    HHKeyWindow.windowLevel = UIWindowLevelAlert;

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if ([touch.view isEqual:self.clearView]) {
        [self dismiss];
    }
}

- (void)dismiss{
    self.hidden = YES;
    HHKeyWindow.windowLevel = UIWindowLevelNormal;
}

#pragma mark 截屏
- (NSData *)dataWithScreenshotInPNGFormat{
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = HHMainScreenBounds.size;
    else
        imageSize = CGSizeMake(HHMainScreenHeight, HHMainScreenWidth);
    
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
   
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        
        switch (orientation) {
            case UIInterfaceOrientationLandscapeLeft:
            {
                CGContextRotateCTM(context, M_PI_2);
                CGContextTranslateCTM(context, 0, -imageSize.width);
            }
                break;
                
            case UIInterfaceOrientationLandscapeRight:
            {
                CGContextRotateCTM(context, -M_PI_2);
                CGContextTranslateCTM(context, -imageSize.height, 0);
            }
                break;
                
            case UIInterfaceOrientationPortraitUpsideDown:
            {
                CGContextRotateCTM(context, M_PI);
                CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
            }
                break;
                
                
            default:
                break;
        }
        
       
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }else{
            [window.layer renderInContext:context];
        }
        
        CGContextRestoreGState(context);
    }
    
    if (orientation == UIInterfaceOrientationPortrait || orientation ==UIInterfaceOrientationPortraitUpsideDown) {
        CGContextSaveGState(context);
        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        [statusBar drawViewHierarchyInRect:statusBar.bounds afterScreenUpdates:NO];
        CGContextRestoreGState(context);

    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImagePNGRepresentation(image);
}

- (UIImage *)imageWithScreenshot{
    NSData *imageData = [self dataWithScreenshotInPNGFormat];
    return [UIImage imageWithData:imageData];
}


@end
