//
//  RotateBtnView.m
//  jspatch
//
//  Created by tom on 16/4/5.
//  Copyright © 2016年 donler. All rights reserved.
//

#import "RXRotateButtonOverlayView.h"
#import "ImageAndTitleVerticalButton.h"

static CGFloat btnWidth = 80.0f;
static CGFloat btnOffsetY = 80.0;

@interface RXRotateButtonOverlayView ()
@property (nonatomic, strong) UIDynamicAnimator* animator;
@property (nonatomic, strong) UIButton* mainBtn;
@property (nonatomic, strong) NSMutableArray* btns;
@property (nonatomic, strong) UITapGestureRecognizer* tap;
@end

@implementation RXRotateButtonOverlayView

- (instancetype)init
{
    if (self=[super init]) {
        
    }
    return self;
}

- (void)builtInterface
{
    [self removeGestureRecognizer:self.tap];
    [self addGestureRecognizer:self.tap];
    //setColor
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    //clear dynamic behaviours
    [self.animator removeAllBehaviors];
    //clear btns
    [self.btns enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.btns removeAllObjects];
    
    //add new Btns
    if (self.titles.count > 0) {
        for (NSString* title in self.titles) {
            UIView* v = nil;
            if (self.titleImages.count == self.titles.count) {
                NSUInteger index = [self.titles indexOfObject:title];
                v = [self addBtnWithTitle:title andTitleImage:[self.titleImages objectAtIndex:index]];
            }else{
                v = [self addBtnWithTitle:title];
            }
            
            [self.btns addObject:v];
        }
        [self addSubview:self.mainBtn];
    }
}


#pragma mark - public
//show the overlay
- (void)show
{
    [self builtInterface];
    [UIView animateWithDuration:.3 animations:^{
        self.mainBtn.transform = CGAffineTransformMakeRotation(M_PI_4);
    }];
    
    NSInteger count = self.btns.count;
    CGFloat space = 0;
    space = ([UIScreen mainScreen].bounds.size.width - count * btnWidth ) / (count + 1 );
    [self.animator removeAllBehaviors];
    for (int i = 0; i< count; i++) {
        CGPoint buttonPoint=  CGPointMake((i + 1)* (space ) + (i+0.5) * btnWidth, [UIScreen mainScreen].bounds.size.height - btnOffsetY * 2);
        UISnapBehavior *sna = [[UISnapBehavior alloc]initWithItem:[self.btns objectAtIndex:i] snapToPoint:buttonPoint];
        sna.damping = .5;
        [self.animator addBehavior:sna];
    }
}

//dismiss the overlay
- (void)dismiss
{
    [UIView animateWithDuration:.3 animations:^{
        self.mainBtn.transform = CGAffineTransformMakeRotation(M_PI / 180.0);
    }];
    
    NSInteger count = self.btns.count;
    CGPoint point = self.mainBtn.center;
    [self.animator removeAllBehaviors];
    for (int i = 0; i< count; i++) {
        UIView* v = [self.btns objectAtIndex:i];
        [UIView animateWithDuration:.2 animations:^{
            [v setAlpha:0];
        }];
        UISnapBehavior *sna = [[UISnapBehavior alloc]initWithItem:v snapToPoint:point];
        sna.damping = .9;
        [self.animator addBehavior:sna];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

#pragma mark - action

- (void)selectBtnAction:(UITapGestureRecognizer*)gesture
{
    UIButton* btn = (UIButton*)gesture.view;
    if ([self.delegate respondsToSelector:@selector(didSelected:)]) {
        [self.delegate didSelected:[self.titles indexOfObject:btn.titleLabel.text]];
    }
}



- (void)clickedSelf:(id)sender
{
    [self dismiss];
}
- (void)btnClicked:(id)sender
{
    
}

#pragma mark - private
- (UIView*)addBtnWithTitle:(NSString*)title andTitleImage:(NSString*)imageName
{
    ImageAndTitleVerticalButton *view = [[ImageAndTitleVerticalButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2.0 - btnWidth / 2.0, [UIScreen mainScreen].bounds.size.height - btnOffsetY, btnWidth, btnWidth)];
    view.titleLabel.textColor = [UIColor whiteColor];
    [view setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [view setTitle:title forState:UIControlStateNormal];
    [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    view.titleLabel.textAlignment = NSTextAlignmentCenter;
    view.titleLabel.font = [UIFont systemFontOfSize:17];
    [self addSubview:view];
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBtnAction:)]];
    return view;
}

- (UIView*)addBtnWithTitle:(NSString*)title
{
    UIButton *view = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2.0 - btnWidth / 2.0, [UIScreen mainScreen].bounds.size.height - btnOffsetY, btnWidth, btnWidth)];
    view.titleLabel.textColor = [UIColor whiteColor];
    view.backgroundColor = [UIColor yellowColor];
    [view setTitle:title forState:UIControlStateNormal];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = btnWidth / 2.0;
    [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    view.titleLabel.textAlignment = NSTextAlignmentCenter;
    view.titleLabel.font = [UIFont systemFontOfSize:17];
    [self addSubview:view];
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBtnAction:)]];
    return view;
}


#pragma mark - getter & setter
- (UITapGestureRecognizer *)tap
{
    if (_tap == nil) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedSelf:)];
    }
    return _tap;
}

- (UIDynamicAnimator *)animator
{
    if (_animator == nil) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    }
    return _animator;
}
- (UIButton *)mainBtn
{
    if (_mainBtn == nil) {
        _mainBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2.0 - btnWidth / 2.0, [UIScreen mainScreen].bounds.size.height - btnOffsetY, btnWidth, btnWidth)];
        [_mainBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_mainBtn.layer setCornerRadius:btnWidth / 2.0];
        UIImage* image = [UIImage imageNamed:@"mainBtnImage"];
        [_mainBtn setImage:image forState:UIControlStateNormal];
    }
    return _mainBtn;
}

- (NSMutableArray *)btns
{
    if (_btns == nil) {
        _btns = [NSMutableArray array];
    }
    return _btns;
}

- (void)setTitles:(NSArray *)titles
{
    self.btns = [NSMutableArray array];
    _titles = [NSArray arrayWithArray:titles];
}

- (void)setTitleImages:(NSArray *)titleImages
{
    self.btns = [NSMutableArray array];
    _titleImages = [NSArray arrayWithArray:titleImages];
}
@end
