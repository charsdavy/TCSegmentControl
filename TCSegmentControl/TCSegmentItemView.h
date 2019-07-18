//
//  TCSegmentItemView.h
//  Tally
//
//  Created by CHARS on 2019/7/15.
//  Copyright © 2019 chars. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, TCSegmentItemViewState) {
    TCSegmentItemViewStateNormal,
    TCSegmentItemViewStateSelectd
};

@interface TCSegmentItemView : UIView

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) TCSegmentItemViewState state;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIFont *selectedTextFont;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *selectedBackgroundColor;
@property (nonatomic, assign) CGFloat itemBorder;
@property (nonatomic, strong) UIColor *bridgeColor;
@property (nonatomic, assign) CGFloat bridgeWidth;

- (CGFloat)itemWidth;
- (void)showBridge:(BOOL)show;

@end
