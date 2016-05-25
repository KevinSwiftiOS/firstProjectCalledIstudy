//
//  ImageAndTitleVerticalButton.m
//  RXRotateButtonOverlayViewDemo
//
//  Created by shutup on 16/4/6.
//  Copyright © 2016年 shutup. All rights reserved.
//

#import "ImageAndTitleVerticalButton.h"

static CGFloat kTextTopPadding = 10;

@implementation ImageAndTitleVerticalButton

-(void)layoutSubviews {
    [super layoutSubviews];
    
    // Move the image to the top and center it horizontally
    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin.y = 0;
    imageFrame.origin.x = (self.frame.size.width / 2) - (imageFrame.size.width / 2);
    self.imageView.frame = imageFrame;
    
    // Adjust the label size to fit the text, and move it below the image
    CGRect titleLabelFrame = self.titleLabel.frame;
    CGSize labelSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font
                                        constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                            lineBreakMode:NSLineBreakByWordWrapping];
    titleLabelFrame.size.width = labelSize.width;
    titleLabelFrame.size.height = labelSize.height;
    titleLabelFrame.origin.x = (self.frame.size.width / 2) - (labelSize.width / 2);
    titleLabelFrame.origin.y = self.imageView.frame.origin.y + self.imageView.frame.size.height + kTextTopPadding;
    self.titleLabel.frame = titleLabelFrame;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
