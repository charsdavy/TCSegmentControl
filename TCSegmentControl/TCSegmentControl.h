//
//  TCSegmentControl.h
//  Tally
//
//  Created by CHARS on 2019/7/15.
//  Copyright © 2019 chars. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct TCSegmentTheme {
    UIColor *itemTextColor;
    UIColor *itemSelectedTextColor;
    
    UIColor *itemBackgroundColor;
    UIColor *itemSelectedBackgroundColor;
    
    CGFloat itemBorder;
    
    UIFont *textFont;
    UIFont *selectedTextFont;
    
    UIColor *sliderColor;
    CGFloat sliderHeight;
    
    UIColor *bridgeColor;
    CGFloat bridgeWidth;
} TCSegmentTheme;

@class TCSegmentControl;

@protocol TCSegmentControlDelegate <NSObject>

@optional
- (void)segmentControl:(TCSegmentControl *)segmentControl didSelected:(NSInteger)index;

@end

@interface TCSegmentControl : UIControl

@property (nonatomic, weak) id<TCSegmentControlDelegate> delegate;
@property (nonatomic, assign) BOOL autoAdjustWidth;
@property (nonatomic, assign) NSInteger selectedIndex;
/// when true, scrolled the itemView to a point when index changed
@property (nonatomic, assign) BOOL autoScrollWhenIndexChange;
@property (nonatomic, assign) CGPoint scrollToPointWhenIndexChanged;
@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, assign) TCSegmentTheme theme;
/// titles
@property (nonatomic, copy) NSArray<NSString *> *items;

+ (CGFloat)height;
- (TCSegmentTheme)defaultSegmentTheme;
- (void)moveToIndex:(NSInteger)index;

@end
