//
//  TCSegmentItemView.m
//  Tally
//
//  Created by CHARS on 2019/7/15.
//  Copyright © 2019 chars. All rights reserved.
//

#import "TCSegmentItemView.h"

@interface TCSegmentItemView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CALayer *bridgeView;

@end

@implementation TCSegmentItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLabel];
        [self.layer addSublayer:self.bridgeView];
        self.layer.masksToBounds = YES;

        _state = TCSegmentItemViewStateNormal;
    }
    return self;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (CALayer *)bridgeView
{
    if (!_bridgeView) {
        _bridgeView = [[CALayer alloc] init];
        _bridgeView.hidden = YES;
    }
    return _bridgeView;
}

- (CGFloat)itemWidth
{
    if (_text.length > 0 && self.selectedTextFont) {
        CGSize size = [self sizeWithText:_text font:self.selectedTextFont constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        return ceil(size.width) + self.itemBorder;
    }
    return 0;
}

- (void)showBridge:(BOOL)show
{
    self.bridgeView.hidden = !show;
}

- (void)setText:(NSString *)text
{
    _text = text;
    self.titleLabel.text = text;

    [self setNeedsLayout];
}

- (void)setState:(TCSegmentItemViewState)state
{
    _state = state;

    [self updateItemViewForState:state];
}

- (void)updateItemViewForState:(TCSegmentItemViewState)state
{
    if (state == TCSegmentItemViewStateNormal) {
        self.titleLabel.textColor = self.textColor;
        self.titleLabel.font = self.textFont;
        self.backgroundColor = self.backgroundColor;
    } else {
        self.titleLabel.textColor = self.selectedTextColor;
        self.titleLabel.font = self.selectedTextFont;
        self.backgroundColor = self.selectedBackgroundColor;
    }
    self.bridgeView.backgroundColor = self.bridgeColor.CGColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self updateItemViewForState:_state];

    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectMake(0, 0, [self itemWidth], CGRectGetHeight(self.bounds) * 0.6);
    self.titleLabel.center = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);

    CGFloat width = self.bridgeWidth;
    self.bridgeView.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame), CGRectGetMidY(self.bounds) - width, width, width);
    self.bridgeView.cornerRadius = width / 2.0;
}

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];

    if (font) {
        attributes[NSFontAttributeName] = font;
    }

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;

    return [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
}

@end
