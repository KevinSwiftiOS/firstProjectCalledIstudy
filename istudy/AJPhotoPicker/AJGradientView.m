//
//  AJGradientView.m
//  AJPhotoPicker
//
//  Created by AlienJunX on 15/4/28.
//  Copyright (c) 2015 AlienJunX
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "AJGradientView.h"

@implementation AJGradientView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (void)setupCAGradientLayer:(NSArray *)colors locations:(NSArray *)locations {
    CAGradientLayer *gradient=(CAGradientLayer*)self.layer;
    gradient.colors = colors;
    gradient.locations = locations;
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com