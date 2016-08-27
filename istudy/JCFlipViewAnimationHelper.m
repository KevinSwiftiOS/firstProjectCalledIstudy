//
//  JCFlipViewAnimationHelper.m
//  JCFlipPageView
//
//  Created by Jimple on 14-8-8.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "JCFlipViewAnimationHelper.h"



@interface JCFlipViewAnimationHelper ()

@property (nonatomic, weak) UIView *hostView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) BOOL canBeginAnimateWithPan;
@property (nonatomic, assign) BOOL isAnimatingWithPan;
@property (nonatomic, assign) BOOL isAnimationCompleted;
@property (nonatomic, assign) BOOL isAnimationInited;
@property (nonatomic, assign) EFlipDirection currFlipDirection;
@property (nonatomic, assign) CGFloat startFlipAngle;
@property (nonatomic, assign) CGFloat endFlipAngle;

@property (nonatomic, strong) CALayer *panelLayer;
@property (nonatomic, strong) CALayer *bgTopLayer;
@property (nonatomic, strong) CALayer *bgBottomLayer;
@property (nonatomic, strong) CATransformLayer *flipLayer;
@property (nonatomic, strong) CALayer *flipFrontSubLayer;
@property (nonatomic, strong) CALayer *flipBackSubLayer;

@end

@implementation JCFlipViewAnimationHelper
@synthesize dataSource;
@synthesize delegate;

- (instancetype)initWithHostView:(UIView *)hostView
{
    self = [super init];
    if (self)
    {
        NSAssert(hostView, @"");
        _hostView = hostView;
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
        [_hostView addGestureRecognizer:_panGesture];
        
        _canBeginAnimateWithPan = YES;
        _isAnimationCompleted = YES;
        _isAnimatingWithPan = NO;
        _isAnimationInited = NO;
    }else{}
    return self;
}

- (void)dealloc
{
    [_hostView removeGestureRecognizer:_panGesture];
    [self clearLayers];
}

- (void)panGestureHandler:(UIPanGestureRecognizer *)recognizer
{
    if (!_canBeginAnimateWithPan)
    {
        return;
    }else{}
    
    CGFloat translationY = [recognizer translationInView:_hostView].y;
    
	switch (recognizer.state)
    {
		case UIGestureRecognizerStateBegan:
        {
            if (_isAnimationCompleted)
            {
                _isAnimationCompleted = NO;
                _isAnimatingWithPan = YES;
            }else{}
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (_isAnimatingWithPan)
            {
                BOOL canProgressAnimation = YES;
                if (!_isAnimationInited)
                {
                    _currFlipDirection = ((translationY > 0.0f) ? kEFlipDirectionToPrePage : kEFlipDirectionToNextPage);
                    canProgressAnimation = [self beginFlipAnimationForDirection:_currFlipDirection];
                }else{}
                
                if (canProgressAnimation)
                {
                    CGFloat progress = translationY / _hostView.bounds.size.height;
                    switch (_currFlipDirection)
                    {
                        case kEFlipDirectionToPrePage:
                        {
                            progress = MAX(progress, 0);
                        }
                            break;
                        case kEFlipDirectionToNextPage:
                        {
                            progress = MIN(progress, 0);
                        }
                            break;
                        default:
                            break;
                    }
                    progress = fabs(progress);
                    [self progressFlipAnimation:progress];
                }
                else
                {
                    [self endFlipAnimation];
                }
            }else{}
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            if (_isAnimatingWithPan)
            {
                [self progressFlipAnimation:0.0f cleanupWhenCompleted:YES];
            }else{}
        }
            break;
        case UIGestureRecognizerStateFailed:
        {
            if (_isAnimatingWithPan)
            {
                [self endFlipAnimation];
            }else{}
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (_isAnimatingWithPan)
            {
                if (fabs((translationY + [recognizer velocityInView:_hostView].y / 4) / _hostView.bounds.size.height) > 0.5f)
                {
                    [self progressFlipAnimation:1.0f cleanupWhenCompleted:YES];
                }
                else
                {
                    [self progressFlipAnimation:0.0f cleanupWhenCompleted:YES];
                }
            }else{}
        }
            break;
        default:
        {
            
        }
            break;
    }
}

- (BOOL)beginFlipAnimationForDirection:(EFlipDirection)direction
{
    BOOL canFlipPage = NO;
    NSAssert(self.dataSource, @"");
    
    UIView *currView;
    UIView *preView;
    UIView *nextView;
    
    currView = [self.dataSource flipViewAnimationHelperGetCurrentView:self];
    switch (direction)
    {
        case kEFlipDirectionToPrePage:
        {
            preView = [self.dataSource flipViewAnimationHelperGetPreView:self];
            canFlipPage = (preView != nil);
        }
            break;
        case kEFlipDirectionToNextPage:
        {
            nextView = [self.dataSource flipViewAnimationHelperGetNextView:self];
            canFlipPage = (nextView != nil);
        }
            break;
        default:
            break;
    }
    
    if (canFlipPage && currView)
    {
        [self rebulidLayers];
        
        _bgTopLayer.contentsGravity = kCAGravityBottom;
        _bgBottomLayer.contentsGravity = kCAGravityTop;
        _flipFrontSubLayer.contentsGravity = kCAGravityBottom;
        _flipBackSubLayer.contentsGravity = kCAGravityTop;
        
        
        switch (direction)
        {
            case kEFlipDirectionToPrePage:
            {
                UIImage *preImg = [self snapshotFromView:preView];
                UIImage *currImg = [self snapshotFromView:currView];
                
                [_bgTopLayer setContents:(__bridge id)preImg.CGImage];
                [_bgBottomLayer setContents:(__bridge id)currImg.CGImage];
                [_flipFrontSubLayer setContents:(__bridge id)currImg.CGImage];
                [_flipBackSubLayer setContents:(__bridge id)preImg.CGImage];
                
                [_flipLayer setTransform:CATransform3DIdentity];
                
                _startFlipAngle = 0.0f;
                _endFlipAngle = -M_PI;
            }
                break;
            case kEFlipDirectionToNextPage:
            {
                UIImage *nextImg = [self snapshotFromView:nextView];
                UIImage *currImg = [self snapshotFromView:currView];
                
                [_bgTopLayer setContents:(__bridge id)currImg.CGImage];
                [_bgBottomLayer setContents:(__bridge id)nextImg.CGImage];
                [_flipFrontSubLayer setContents:(__bridge id)nextImg.CGImage];
                [_flipBackSubLayer setContents:(__bridge id)currImg.CGImage];

                [_flipLayer setTransform:CATransform3DMakeRotation(-M_PI, 1., 0., 0.)];
                
                _startFlipAngle = -M_PI;
                _endFlipAngle = 0.0f;
            }
                break;
            default:
                break;
        }
        
        _isAnimationInited = YES;
        
        if (delegate && [delegate respondsToSelector:@selector(flipViewAnimationHelperBeginAnimation:)])
        {
            [delegate flipViewAnimationHelperBeginAnimation:self];
        }else{}
    }else{}

    return canFlipPage;
}

- (void)progressFlipAnimation:(CGFloat)progress
{
    [self progressFlipAnimation:progress cleanupWhenCompleted:NO];
}

- (void)progressFlipAnimation:(CGFloat)progress cleanupWhenCompleted:(BOOL)isCleanupWhenCompleted
{
    CGFloat newAngle = _startFlipAngle + progress * (_endFlipAngle - _startFlipAngle);
    CGFloat duration = 0.1f;                //  !!!  保持上一次的角度，然后通过剩余多少角度计算持续时间
	CATransform3D endTransform = CATransform3DIdentity;
	endTransform.m34 = 1.0f / 2500.0f;
	endTransform = CATransform3DRotate(endTransform, newAngle, -1.0, 0.0, 0.0);
	
	[_flipLayer removeAllAnimations];
    
	[CATransaction begin];
	[CATransaction setAnimationDuration:duration];
    
    if (isCleanupWhenCompleted)
    {
        __weak __typeof(self)weakSelf = self;
        [CATransaction setCompletionBlock:^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf endFlipAnimation];
            if ((progress >= 1.0f)
                && (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(flipViewAnimationHelper:flipCompletedToDirection:)]))
            {
                [strongSelf.delegate flipViewAnimationHelper:self flipCompletedToDirection:_currFlipDirection];
            }else{}
        }];
    }else{}
	
	_flipLayer.transform = endTransform;
	
	[CATransaction commit];
}

- (void)endFlipAnimation
{
    [self clearLayers];
    
    _isAnimationCompleted = YES;
    _isAnimatingWithPan = NO;
    _isAnimationInited = NO;
    
    if (delegate && [delegate respondsToSelector:@selector(flipViewAnimationHelperEndAnimation:)])
    {
        [delegate flipViewAnimationHelperEndAnimation:self];
    }else{}
}

- (void)clearLayers
{
    if (_bgTopLayer)
    {
        [_bgTopLayer removeFromSuperlayer];
        _bgTopLayer = nil;
    }else{}
    
    if (_bgBottomLayer)
    {
        [_bgBottomLayer removeFromSuperlayer];
        _bgBottomLayer = nil;
    }else{}
    
    if (_flipFrontSubLayer)
    {
        [_flipFrontSubLayer removeFromSuperlayer];
        _flipFrontSubLayer = nil;
    }else{}
    
    if (_flipBackSubLayer)
    {
        [_flipBackSubLayer removeFromSuperlayer];
        _flipBackSubLayer = nil;
    }else{}
    
    if (_flipLayer)
    {
        [_flipLayer removeAllAnimations];
        [_flipLayer removeFromSuperlayer];
        _flipLayer = nil;
    }else{}
    
    if (_panelLayer)
    {
        [_panelLayer removeFromSuperlayer];
        _panelLayer = nil;
    }else{}
}

- (void)rebulidLayers
{
    [self clearLayers];
    
    _panelLayer = [CALayer layer];
    _panelLayer.frame = _hostView.layer.bounds;
    [_hostView.layer addSublayer:_panelLayer];
    
    _bgTopLayer = [CALayer layer];
    _bgTopLayer.frame = CGRectMake(0.0f, 0.0f, _panelLayer.bounds.size.width, _panelLayer.bounds.size.height/2.0f);
    _bgTopLayer.doubleSided = NO;
    _bgTopLayer.masksToBounds = YES;
    _bgTopLayer.contentsScale = [[UIScreen mainScreen] scale];
    [_panelLayer addSublayer:_bgTopLayer];
    
    _bgBottomLayer = [CALayer layer];
    _bgBottomLayer.frame = CGRectMake(0.0f, _panelLayer.bounds.size.height/2.0f, _panelLayer.bounds.size.width, _panelLayer.bounds.size.height/2.0f);
    _bgBottomLayer.doubleSided = NO;
    _bgBottomLayer.masksToBounds = YES;
    _bgBottomLayer.contentsScale = [[UIScreen mainScreen] scale];
    [_panelLayer addSublayer:_bgBottomLayer];
    
    _flipLayer = [CATransformLayer layer];
    _flipLayer.doubleSided = YES;
    _flipLayer.anchorPoint = CGPointMake(1., 1.);
    _flipLayer.frame = CGRectMake(0.0f, 0.0f, _panelLayer.frame.size.width, (_panelLayer.frame.size.height/2));
    _flipLayer.zPosition = 1000.0f; // Above the other ones
    [_panelLayer addSublayer:_flipLayer];
    
    _flipFrontSubLayer = [CALayer layer];
    _flipFrontSubLayer.frame = _flipLayer.bounds;
    _flipFrontSubLayer.doubleSided = NO;
    _flipFrontSubLayer.masksToBounds = YES;
    _flipFrontSubLayer.contentsScale = [[UIScreen mainScreen] scale];
    [_flipLayer addSublayer:_flipFrontSubLayer];
    
    _flipBackSubLayer = [CALayer layer];
    _flipBackSubLayer.frame = _flipLayer.bounds;
    _flipBackSubLayer.doubleSided = NO;
    _flipBackSubLayer.masksToBounds = YES;
    _flipBackSubLayer.contentsScale = [[UIScreen mainScreen] scale];
    CATransform3D transform = CATransform3DMakeRotation(M_PI, 1., 0., 0.);
    [_flipBackSubLayer setTransform:transform];
    [_flipLayer addSublayer:_flipBackSubLayer];
}

- (UIImage*)snapshotFromView:(UIView *)view
{
	UIImage *image = nil;
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return image;
}


























@end
