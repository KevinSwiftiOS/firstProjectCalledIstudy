//
//  AJPhotoListCell.h
//  AJPhotoPicker
//
//  Created by AlienJunX on 15/11/2.
//  Copyright (c) 2015 AlienJunX
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>
@class ALAsset;

@interface AJPhotoListCell : UICollectionViewCell

/**
 *  显示照片
 *
 *  @param asset           照片
 *  @param selectionFilter 过滤器
 *  @param isSelected YES选中，NO取消选中
 */
- (void)bind:(ALAsset *)asset selectionFilter:(NSPredicate*)selectionFilter isSelected:(BOOL)isSelected;


/**
 *  选中
 *
 *  @param isSelected YES选中，NO取消选中
 */
- (void)isSelected:(BOOL)isSelected;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com