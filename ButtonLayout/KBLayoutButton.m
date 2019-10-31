//
//  KBLayoutButton.h
//  AIWE
//
//  Created by BIMiracle on 2019/6/26.
//  Copyright © 2019年 BIMiracle. All rights reserved.
//

#import "KBLayoutButton.h"
#import "UIView+KBExtension.h"
#import "QMUICommonDefines.h"

#define KBErrorLog(...) printf("❗️❗️❗️Error---- [%s] %s [第%d行] : %s\n", __TIME__, __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])

@implementation KBLayoutButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self didInitialize];
        
        // iOS7以后的button，sizeToFit后默认会自带一个上下的contentInsets，为了保证按钮大小即为内容大小，这里直接去掉，改为一个最小的值。
        self.contentEdgeInsets = UIEdgeInsetsMake(CGFLOAT_MIN, 0, CGFLOAT_MIN, 0);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    // 默认接管highlighted和disabled的表现，去掉系统默认的表现
    self.adjustsImageWhenHighlighted = NO;
    self.adjustsImageWhenDisabled = NO;
    
    // 图片默认在按钮左边，与系统UIButton保持一致
    self.imagePosition = QMUIButtonImagePositionLeft;
}

- (CGSize)sizeThatFits:(CGSize)size {
    // 如果调用 sizeToFit，那么传进来的 size 就是当前按钮的 size，此时的计算不要去限制宽高
    if (CGSizeEqualToSize(self.bounds.size, size)) {
        size = CGSizeMax;
    }
    
    BOOL isImageViewShowing = !!self.currentImage;
    BOOL isTitleLabelShowing = !!self.currentTitle || self.currentAttributedTitle;
    CGSize imageTotalSize = CGSizeZero;// 包含 imageEdgeInsets 那些空间
    CGSize titleTotalSize = CGSizeZero;// 包含 titleEdgeInsets 那些空间
    CGFloat spacingBetweenImageAndTitle = flat(isImageViewShowing && isTitleLabelShowing ? self.spacingBetweenImageAndTitle : 0);// 如果图片或文字某一者没显示，则这个 spacing 不考虑进布局
    UIEdgeInsets contentEdgeInsets = UIEdgeInsetsRemoveFloatMin(self.contentEdgeInsets);
    CGSize resultSize = CGSizeZero;
    CGSize contentLimitSize = CGSizeMake(size.width - UIEdgeInsetsGetHorizontalValue(contentEdgeInsets), size.height - UIEdgeInsetsGetVerticalValue(contentEdgeInsets));
    
    switch (self.imagePosition) {
        case QMUIButtonImagePositionTop:
        case QMUIButtonImagePositionBottom: {
            // 图片和文字上下排版时，宽度以文字或图片的最大宽度为最终宽度
            if (isImageViewShowing) {
                CGFloat imageLimitWidth = contentLimitSize.width - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets);
                CGSize imageSize = self.imageView.image ? [self.imageView sizeThatFits:CGSizeMake(imageLimitWidth, CGFLOAT_MAX)] : self.currentImage.size;
                imageSize.width = fmin(imageSize.width, imageLimitWidth);
                imageTotalSize = CGSizeMake(imageSize.width + UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), imageSize.height + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
            }
            
            if (isTitleLabelShowing) {
                CGSize titleLimitSize = CGSizeMake(contentLimitSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), contentLimitSize.height - imageTotalSize.height - spacingBetweenImageAndTitle - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
                CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
                titleSize.height = fmin(titleSize.height, titleLimitSize.height);
                titleTotalSize = CGSizeMake(titleSize.width + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), titleSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
            }
            
            resultSize.width = UIEdgeInsetsGetHorizontalValue(contentEdgeInsets);
            resultSize.width += fmax(imageTotalSize.width, titleTotalSize.width);
            resultSize.height = UIEdgeInsetsGetVerticalValue(contentEdgeInsets) + imageTotalSize.height + spacingBetweenImageAndTitle + titleTotalSize.height;
        }
            break;
            
        case QMUIButtonImagePositionLeft:
        case QMUIButtonImagePositionRight: {
            // 图片和文字水平排版时，高度以文字或图片的最大高度为最终高度
            // 注意这里有一个和系统不一致的行为：当 titleLabel 为多行时，系统的 sizeThatFits: 计算结果固定是单行的，所以当 QMUIButtonImagePositionLeft 并且titleLabel 多行的情况下，QMUIButton 计算的结果与系统不一致
            
            if (isImageViewShowing) {
                CGFloat imageLimitHeight = contentLimitSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets);
                CGSize imageSize = self.imageView.image ? [self.imageView sizeThatFits:CGSizeMake(CGFLOAT_MAX, imageLimitHeight)] : self.currentImage.size;
                imageSize.height = fmin(imageSize.height, imageLimitHeight);
                imageTotalSize = CGSizeMake(imageSize.width + UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), imageSize.height + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
            }
            
            if (isTitleLabelShowing) {
                CGSize titleLimitSize = CGSizeMake(contentLimitSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) - imageTotalSize.width - spacingBetweenImageAndTitle, contentLimitSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
                CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
                titleSize.height = fmin(titleSize.height, titleLimitSize.height);
                titleTotalSize = CGSizeMake(titleSize.width + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), titleSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
            }
            
            resultSize.width = UIEdgeInsetsGetHorizontalValue(contentEdgeInsets) + imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width;
            resultSize.height = UIEdgeInsetsGetVerticalValue(contentEdgeInsets);
            resultSize.height += fmax(imageTotalSize.height, titleTotalSize.height);
        }
            break;
    }
    return resultSize;
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeMax];
}

- (void)layoutSubviews{
    [super layoutSubviews];

    if (CGRectIsEmpty(self.bounds)) {
        return;
    }

    CGFloat imageWidth = self.imageWidth > 0 ? self.imageWidth : self.imageView.image.size.width;
    CGFloat imageHeight = self.imageHeight > 0 ? self.imageHeight : self.imageView.image.size.height;
    if (self.rightCenter){
        self.titleLabel.frame = CGRectMake(0, 0, self.titleLabel.kb_width, self.titleLabelHeight > 0 ? self.titleLabelHeight : self.titleLabel.kb_height);
        [self.titleLabel sizeToFit];
        self.titleLabel.kb_centerY = self.kb_centerY;

        CGFloat allWidth = self.titleLabel.kb_width + self.margin + imageWidth;
        if (self.autoWidth) {
            self.kb_width = allWidth;
            self.imageView.frame = CGRectMake(self.margin + self.titleLabel.kb_width, 0, imageWidth, imageHeight);
            self.imageView.kb_centerY = self.kb_centerY;
            self.titleLabel.kb_x = 0;
        }else{
            CGFloat halfAllWidth = allWidth * 0.5;
            self.titleLabel.kb_x = self.kb_centerX - halfAllWidth;
            self.imageView.frame = CGRectMake(self.titleLabel.kb_maxX + self.margin, 0, imageWidth, imageHeight);
            self.imageView.kb_centerY = self.kb_centerY;

            if (self.kb_width < allWidth) {
                KBErrorLog(@"%@设置的Button宽度不能低于 %f",self.titleLabel.text,allWidth);
            }
        }
        CGFloat allHeight = self.titleLabel.kb_height > imageHeight ? self.titleLabel.kb_height : imageHeight;
        if (self.autoHeight) {
            self.kb_height = allHeight;
        }else{
            if (self.kb_height < allHeight) {
                KBErrorLog(@"%@设置的Button高度不能低于 %f",self.titleLabel.text,allWidth);
            }
        }
    } else if (self.topCenter){
        [self.titleLabel sizeToFit];
        CGFloat allHeight = imageHeight + self.margin + self.titleLabel.frame.size.height;

        if (self.autoHeight) {
            self.kb_height = allHeight;
            self.imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
            self.imageView.kb_centerX = self.kb_centerX;
            self.titleLabel.frame = CGRectMake(0, self.imageView.kb_maxY + self.margin, self.titleLabel.kb_width, self.titleLabelHeight > 0 ? self.titleLabelHeight : self.titleLabel.kb_height);
            self.titleLabel.kb_centerX = self.kb_centerX;
        }else{
            CGFloat imageY = (self.frame.size.height - allHeight) * 0.5;
            self.imageView.frame = CGRectMake(0, imageY, imageWidth, imageHeight);
            self.imageView.kb_centerX = self.kb_centerX;

            self.titleLabel.frame = CGRectMake(0, self.imageView.kb_maxY + self.margin, self.titleLabel.kb_width, self.titleLabelHeight > 0 ? self.titleLabelHeight : self.titleLabel.kb_height);
            self.titleLabel.kb_centerX = self.kb_centerX;
            if (self.kb_height < allHeight) {
                KBErrorLog(@"%@设置的Button高度不能低于 %f",self.titleLabel.text,allHeight);
            }
        }

        CGFloat allWidth = self.titleLabel.kb_width > imageWidth ? self.titleLabel.kb_width : imageWidth;
        if (self.autoWidth) {
            self.kb_width = allWidth;
        }else{
            if (self.kb_width < allWidth) {
                KBErrorLog(@"%@设置的Button宽度不能低于 %f",self.titleLabel.text,allWidth);
            }
        }
    } else if (self.bottomCenter){
        [self.titleLabel sizeToFit];
        CGFloat allHeight = imageHeight + self.margin + self.titleLabel.frame.size.height;

        if (self.autoHeight) {
            self.kb_height = allHeight;
            self.titleLabel.frame = CGRectMake(0, 0, self.titleLabel.kb_width, self.titleLabelHeight > 0 ? self.titleLabelHeight : self.titleLabel.kb_height);
            self.titleLabel.kb_centerX = self.kb_centerX;
            self.imageView.frame = CGRectMake(0,self.titleLabel.kb_maxY + self.margin, imageWidth, imageHeight);
            self.imageView.kb_centerX = self.kb_centerX;
        }else{
            CGFloat titleLabelY = (self.frame.size.height - allHeight) * 0.5;
            self.titleLabel.frame = CGRectMake(0, titleLabelY, self.titleLabel.kb_width, self.titleLabelHeight > 0 ? self.titleLabelHeight : self.titleLabel.kb_height);
            self.titleLabel.kb_centerX = self.kb_centerX;


            self.imageView.frame = CGRectMake(0, self.titleLabel.kb_maxY + self.margin, imageWidth, imageHeight);
            self.imageView.kb_centerX = self.kb_centerX;
            if (self.kb_height < allHeight) {
                KBErrorLog(@"%@设置的Button高度不能低于 %f",self.titleLabel.text,allHeight);
            }
        }
        CGFloat allWidth = self.titleLabel.kb_width > imageWidth ? self.titleLabel.kb_width : imageWidth;
        if (self.autoWidth) {
            self.kb_width = allWidth;
        }else{
            if (self.kb_width < allWidth) {
                KBErrorLog(@"%@设置的Button宽度不能低于 %f",self.titleLabel.text,allWidth);
            }
        }
    } else {
        // 图片左 文字右
        self.titleLabel.frame = CGRectMake(0, 0, self.titleLabel.kb_width, self.titleLabelHeight > 0 ? self.titleLabelHeight : self.titleLabel.kb_height);
        [self.titleLabel sizeToFit];
        self.titleLabel.kb_centerY = self.kb_centerY;

        CGFloat allWidth = self.titleLabel.kb_width + self.margin + imageWidth;
        if (self.autoWidth) {
            self.kb_width = allWidth;
            self.titleLabel.kb_x = self.margin + imageWidth;
            self.imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
            self.imageView.kb_centerY = self.kb_centerY;
        }else{
            CGFloat halfAllWidth = allWidth * 0.5;
            self.imageView.frame = CGRectMake(self.kb_centerX - halfAllWidth, 0, imageWidth, imageHeight);
            self.imageView.kb_centerY = self.kb_centerY;
            self.titleLabel.kb_x = self.imageView.kb_maxX + self.margin;

            if (self.kb_width < allWidth) {
                KBErrorLog(@"%@设置的Button宽度不能低于 %f",self.titleLabel.text,allWidth);
            }
        }
        CGFloat allHeight = self.titleLabel.kb_height > imageHeight ? self.titleLabel.kb_height : imageHeight;
        if (self.autoHeight) {
            self.kb_height = allHeight;
        }else{
            if (self.kb_height < allHeight) {
                KBErrorLog(@"%@设置的Button高度不能低于 %f",self.titleLabel.text,allWidth);
            }
        }
    }
//    NSLog(@"%@  %@",self.titleLabel.text,NSStringFromCGRect(self.frame));
}

- (void)setSpacingBetweenImageAndTitle:(CGFloat)spacingBetweenImageAndTitle {
    _spacingBetweenImageAndTitle = spacingBetweenImageAndTitle;
    
    [self setNeedsLayout];
}

- (void)setImagePosition:(QMUIButtonImagePosition)imagePosition {
    _imagePosition = imagePosition;
    
    [self setNeedsLayout];
}

- (void)setRightCenter:(BOOL)rightCenter{
    _rightCenter = rightCenter;
    _imagePosition = QMUIButtonImagePositionRight;
    [self setNeedsLayout];
}

- (void)setTopCenter:(BOOL)topCenter{
    _topCenter = topCenter;
    _imagePosition = QMUIButtonImagePositionTop;
    [self setNeedsLayout];
}

- (void)setBottomCenter:(BOOL)bottomCenter{
    _bottomCenter = bottomCenter;
    _imagePosition = QMUIButtonImagePositionBottom;
    [self setNeedsLayout];
}

- (void)setMargin:(CGFloat)margin{
    _margin = margin;
    _spacingBetweenImageAndTitle = margin;
    [self setNeedsLayout];
}

@end
