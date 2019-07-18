//
//  TCSegmentControl.m
//  Tally
//
//  Created by CHARS on 2019/7/15.
//  Copyright © 2019 chars. All rights reserved.
//

#import "TCSegmentControl.h"
#import "TCSegmentItemView.h"

#define v_height 40.0

@interface TCSegmentControl ()

@property (nonatomic, copy) NSArray *itemWidths;
@property (nonatomic, copy) NSArray<TCSegmentItemView *> *itemViews;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *sliderView;

@end

@implementation TCSegmentControl

+ (CGFloat)height
{
    return v_height;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _autoAdjustWidth = NO;
        _autoScrollWhenIndexChange = YES;
        _scrollToPointWhenIndexChanged = CGPointZero;
        _bounces = NO;
        _theme = [self defaultSegmentTheme];
        _selectedIndex = 0;
        
        [self setupViews];
        [self addTapGesture];
        
        _scrollToPointWhenIndexChanged = self.scrollView.center;
    }
    return self;
}

- (TCSegmentTheme)defaultSegmentTheme
{
    TCSegmentTheme defalut = {};
    defalut.itemTextColor = [UIColor grayColor];
    defalut.itemSelectedTextColor = [UIColor colorWithRed:252.0 / 255.0 green:107.0 / 255.0 blue:1.0 / 255.0 alpha:0.3];
    defalut.itemBackgroundColor = [UIColor colorWithRed:255.0 / 255.0 green:250.0 / 255.0 blue:250.0 / 255.0 alpha:1.0];
    defalut.itemSelectedBackgroundColor = [UIColor colorWithRed:252.0 / 255.0 green:107.0 / 255.0 blue:1.0 / 255.0 alpha:0.1];
    defalut.itemBorder = 16.0;
    defalut.textFont = [UIFont systemFontOfSize:14.0];
    defalut.selectedTextFont = [UIFont boldSystemFontOfSize:17.0];
    defalut.sliderColor = [UIColor orangeColor];
    defalut.sliderHeight = 3.0;
    defalut.bridgeColor = [UIColor redColor];
    defalut.bridgeWidth = 7.0;
    return defalut;
}

- (void)setupViews
{
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    [self.contentView addSubview:self.sliderView];
}

- (void)addTapGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSegement:)];
    [self.contentView addGestureRecognizer:tap];
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
    }
    return _scrollView;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (UIView *)sliderView
{
    if (!_sliderView) {
        _sliderView = [[UIView alloc] init];
        _sliderView.backgroundColor = _theme.sliderColor;
    }
    return _sliderView;
}

- (void)setTheme:(TCSegmentTheme)theme
{
    _theme = theme;
    
    self.sliderView.backgroundColor = theme.sliderColor;
    
    [self updateItems:theme];
    
    [self setNeedsLayout];
}

- (void)didTapSegement:(UITapGestureRecognizer *)sender
{
    NSInteger index = [self selectedTargetIndex:sender];
    [self moveToIndex:index];
}

- (NSInteger)selectedTargetIndex:(UITapGestureRecognizer *)gesture
{
    NSInteger index = 0;
    CGPoint location = [gesture locationInView:self.contentView];
    
    if (_autoAdjustWidth) {
        for (int i = 0; i < self.itemViews.count; i++) {
            TCSegmentItemView *v = self.itemViews[i];
            if (CGRectContainsPoint(v.frame, location)) {
                index = i;
                break;
            }
        }
    } else {
        index = location.x / self.sliderView.bounds.size.width;
    }
    
    if (index < 0) {
        index = 0;
    }
    if (index > [self numberOfSegments] - 1) {
        index = [self numberOfSegments] - 1;
    }
    
    return index;
}

- (void)moveToIndex:(NSInteger)index
{
    [self moveToIndex:index animated:YES];
}

- (void)moveToIndex:(NSInteger)index animated:(BOOL) animated
{
    CGFloat position = [self centerX:index];
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            CGPoint center = self.sliderView.center;
            center.x = position;
            self.sliderView.center = center;
            self.sliderView.bounds = CGRectMake(0, 0, [self segmentWidthForIndex:index] - self.theme.itemBorder, self.sliderView.bounds.size.height);
        }];
    } else {
        CGPoint center = self.sliderView.center;
        center.x = position;
        self.sliderView.center = center;
        self.sliderView.bounds = CGRectMake(0, 0, [self segmentWidthForIndex:index] - _theme.itemBorder, self.sliderView.bounds.size.height);
    }
    
    if ([_delegate respondsToSelector:@selector(segmentControl:didSelected:)]) {
        [_delegate segmentControl:self didSelected:index];
    }
    self.selectedIndex = index;
    
    if (_autoScrollWhenIndexChange) {
        [self scrollItemToPoint:index point:_scrollToPointWhenIndexChanged];
    }
}

- (CGFloat)currentItemX:(NSInteger)index
{
    if (_autoAdjustWidth) {
        CGFloat x = 0;
        for (int i = 0; i < index; i++) {
            x += [self segmentWidthForIndex:i];
        }
        return x;
    }
    return [self segmentWidth] * index;
}

- (CGFloat)centerX:(NSInteger)index
{
    if (_autoAdjustWidth) {
        return [self currentItemX:index] + [self segmentWidthForIndex:index] * 0.5;
    }
    return index * 0.5 * [self segmentWidth];
}

- (void)setItems:(NSArray<NSString *> *)items
{
    [self removeAllItemView];
    NSMutableArray<TCSegmentItemView *> *arr = [NSMutableArray array];
    for (NSString *title in items) {
        TCSegmentItemView *v = [self createItemViewWithTitle:title];
        [arr addObject:v];
        [self.contentView addSubview:v];
    }
    _items = items;
    _itemViews = arr;
    self.selectedIndex = 0;
    [self.contentView bringSubviewToFront:self.sliderView];
}

/// recomend to use segmentWidth(index:Int)
- (CGFloat)segmentWidth
{
    return CGRectGetWidth(self.bounds) / self.itemViews.count;
}

/// when autoAdjustWidth is true, the width is not necessarily the same
- (CGFloat)segmentWidthForIndex:(NSInteger)index
{
    if (index >= 0 && index < self.itemViews.count) {
        if (_autoAdjustWidth) {
            return [self.itemViews[index] itemWidth];
        } else {
            return [self segmentWidth];
        }
    } else {
        return 0;
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    TCSegmentItemView *originItem = self.itemViews[_selectedIndex];
    originItem.state = TCSegmentItemViewStateNormal;
    
    TCSegmentItemView *selectItem = self.itemViews[selectedIndex];
    selectItem.state = TCSegmentItemViewStateSelectd;
    
    _selectedIndex = selectedIndex;
}

- (void)setBounces:(BOOL)bounces
{
    _bounces = bounces;
    
    self.scrollView.bounces = bounces;
}

- (void)showBridgeWithIndex:(NSInteger)index show:(BOOL)show
{
    if (index >= 0 && index < self.itemViews.count) {
        [self.itemViews[index] showBridge:show];
    }
}

- (void)removeAllItemView
{
    for (TCSegmentItemView *v in self.itemViews) {
        [v removeFromSuperview];
    }
    _itemViews = nil;
}

- (TCSegmentItemView *)createItemViewWithTitle:(NSString *)title
{
    return [self createItemViewWithTitle:title font:_theme.textFont selectedFont:_theme.selectedTextFont textColor:_theme.itemTextColor selectedTextColor:_theme.itemSelectedTextColor backgroundColor:_theme.itemBackgroundColor selectedBackgroundColor:_theme.itemSelectedBackgroundColor bridgeColor:_theme.bridgeColor itemBorder:_theme.itemBorder bridgeWidth:_theme.bridgeWidth];
}

- (TCSegmentItemView *)createItemViewWithTitle:(NSString *)title font:(UIFont *)font selectedFont:(UIFont *)selectedFont textColor:(UIColor *)textColor selectedTextColor:(UIColor *)selectedTextColor backgroundColor:(UIColor *)backgroundColor selectedBackgroundColor:(UIColor *)selectedBackgroundColor bridgeColor:(UIColor *)bridgeColor itemBorder:(CGFloat)itemBorder bridgeWidth:(CGFloat)bridgeWidth
{
    TCSegmentItemView *item = [[TCSegmentItemView alloc] init];
    item.text = title;
    item.textFont = font;
    item.selectedTextFont = selectedFont;
    item.textColor = textColor;
    item.selectedTextColor = selectedTextColor;
    item.backgroundColor = backgroundColor;
    item.selectedBackgroundColor = selectedBackgroundColor;
    item.bridgeColor = bridgeColor;
    item.itemBorder = itemBorder;
    item.bridgeWidth = bridgeWidth;
    return item;
}

- (void)updateItems:(TCSegmentTheme)theme
{
    if (self.itemViews.count <= 0) {
        return;
    }
    for (int i = 0; i < self.itemViews.count; i++) {
        TCSegmentItemView *v = self.itemViews[i];
        v.textFont = theme.textFont;
        v.selectedTextFont = theme.selectedTextFont;
        v.textColor = theme.itemTextColor;
        v.selectedTextColor = theme.itemSelectedTextColor;
        v.backgroundColor = theme.itemBackgroundColor;
        v.selectedBackgroundColor = theme.itemSelectedBackgroundColor;
        v.bridgeColor = theme.bridgeColor;
        v.itemBorder = theme.itemBorder;
        v.bridgeWidth = theme.bridgeWidth;
    }
}

- (NSInteger)numberOfSegments
{
    return self.itemViews.count;
}

- (void)scrollItemToCenter:(NSInteger)index
{
    [self scrollItemToPoint:index point:CGPointMake(self.scrollView.bounds.size.width * 0.5, 0)];
}

- (void)scrollItemToPoint:(NSInteger)index point:(CGPoint)point
{
    CGFloat currentX = [self currentItemX:index];
    CGFloat scrollViewWidth = self.scrollView.bounds.size.width;
    CGFloat scrollX = currentX - point.x + [self segmentWidthForIndex:index] * 0.5;
    CGFloat maxScrollX = self.scrollView.contentSize.width - scrollViewWidth;
    if (scrollX > maxScrollX) {
        scrollX = maxScrollX;
    }
    if (scrollX < 0) {
        scrollX = 0;
    }

    [self.scrollView setContentOffset:CGPointMake(scrollX, 0) animated:YES];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.itemViews.count <= 0) {
        return;
    }
    
    self.scrollView.frame = self.bounds;
    self.contentView.frame = self.scrollView.bounds;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGFloat width = [self segmentWidthForIndex:_selectedIndex];
    self.sliderView.frame = CGRectMake([self currentItemX:_selectedIndex] + self.theme.itemBorder / 2.0, CGRectGetHeight(self.contentView.bounds) - self.theme.sliderHeight, width - self.theme.itemBorder, self.theme.sliderHeight);
    self.sliderView.layer.cornerRadius = self.theme.sliderHeight / 2.0;
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat contentWidth = 0;
    CGFloat x = 0;
    for (int i = 0; i < self.itemViews.count; i++) {
        TCSegmentItemView *v = self.itemViews[i];
        x = contentWidth;
        CGFloat w = [self segmentWidthForIndex:i];
        v.frame = CGRectMake(x, 0, w, height);
        contentWidth += w;
    }
    self.contentView.frame = CGRectMake(0, 0, contentWidth, CGRectGetHeight(self.contentView.bounds));
    self.scrollView.contentSize = self.contentView.bounds.size;
}

@end
