//
//  AJPhotoListView.m
//  AJPhotoPicker
//
//  Created by AlienJunX on 15/11/2.
//  Copyright (c) 2015 AlienJunX
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "AJPhotoListView.h"
#import "AJPhotoListCell.h"

@implementation AJPhotoListView

#pragma mark - init
- (instancetype)init {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self = [[AJPhotoListView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:flowLayout];
    if (self) {
        [self registerClass:[AJPhotoListCell class] forCellWithReuseIdentifier:@"cell"];
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com