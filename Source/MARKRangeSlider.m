//
//  MARKRangeSlider.m
//  MARKRangeSlider
//
//  Created by Vadym Markov on 2/7/15.
//  Copyright (c) 2015 Vadym Markov. All rights reserved.
//

#import "MARKRangeSlider.h"

static NSString * const kMARKRangeSliderThumbImage = @"rangeSliderThumb.png";
static NSString * const kMARKRangeSliderTrackImage = @"rangeSliderTrack.png";
static NSString * const kMARKRangeSliderTrackRangeImage = @"rangeSliderTrackRange.png";

static CGFloat const kMARKRangeSliderTrackHeight = 2.0;

@interface MARKRangeSlider ()

@property (nonatomic, strong) UIImageView *trackImageView;
@property (nonatomic, strong) UIImageView *rangeImageView;

@property (nonatomic, strong) UIImageView *leftThumbImageView;
@property (nonatomic, strong) UIImageView *rightThumbImageView;

@end

@implementation MARKRangeSlider

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        [self setDefaults];
        [self setUpViewComponents];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
        [self setUpViewComponents];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaults];
        [self setUpViewComponents];
    }
    return self;
}

#pragma mark - Configuration

- (void)setDefaults
{
    self.minimumValue = 0.0f;
    self.maximumValue = 1.0f;
    self.leftValue = self.minimumDistance;
    self.rightValue = self.maximumValue;
    self.minimumDistance = 0.2f;
}

- (void)setUpViewComponents
{
    self.multipleTouchEnabled = YES;

    // Init track image
    self.trackImageView = [[UIImageView alloc] initWithImage:self.trackImage];
    [self addSubview:self.trackImageView];

    // Init range image
    self.rangeImageView = [[UIImageView alloc] initWithImage:self.rangeImage];
    [self addSubview:self.rangeImageView];

    // Init left thumb image
    self.leftThumbImageView = [[UIImageView alloc] initWithImage:self.leftThumbImage];
    self.leftThumbImageView.userInteractionEnabled = YES;
    self.leftThumbImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:self.leftThumbImageView];

    // Add left pan recognizer
    UIPanGestureRecognizer *leftPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
    [self.leftThumbImageView addGestureRecognizer:leftPanRecognizer];

    // Init right thumb image
    self.rightThumbImageView = [[UIImageView alloc] initWithImage:self.rightThumbImage];
    self.rightThumbImageView.userInteractionEnabled = YES;
    self.rightThumbImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:self.rightThumbImageView];

    // Add right pan recognizer
    UIPanGestureRecognizer *rightPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
    [self.rightThumbImageView addGestureRecognizer:rightPanRecognizer];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    // Calculate coords & sizes
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);

    CGSize leftThumbImageSize = self.leftThumbImageView.frame.size;
    CGSize rightThumbImageSize = self.rightThumbImageView.frame.size;

    CGFloat leftAvailableWidth = width - leftThumbImageSize.width;
    CGFloat rightAvailableWidth = width - rightThumbImageSize.width;

    CGFloat leftInset = leftThumbImageSize.width / 2;
    CGFloat rightInset = rightThumbImageSize.width / 2;

    CGFloat trackRange = self.maximumValue - self.minimumValue;

    CGFloat leftX = floorf((self.leftValue - self.minimumValue) / trackRange * leftAvailableWidth);
    if (isnan(leftX)) {
        leftX = 0.0;
    }

    CGFloat rightX = floorf((self.rightValue - self.minimumValue) / trackRange * rightAvailableWidth);
    if (isnan(rightX)) {
        rightX = 0.0;
    }

    CGFloat trackY = (height - kMARKRangeSliderTrackHeight) / 2;
    CGFloat gap = 1.0;

    // Set track frame
    self.trackImageView.frame = CGRectMake(gap, trackY, width - gap, kMARKRangeSliderTrackHeight);

    // Set range frame
    CGFloat rangeWidth = rightX - leftX;
    self.rangeImageView.frame = CGRectMake(leftX + leftInset, trackY, rangeWidth, kMARKRangeSliderTrackHeight);

    // Set left & right thumb frames
    self.leftThumbImageView.center = CGPointMake(leftX + leftInset, height / 2);
    self.rightThumbImageView.center = CGPointMake(rightX + rightInset, height / 2);
}

#pragma mark - Gesture recognition

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self];
        CGFloat trackRange = self.maximumValue - self.minimumValue;
        CGFloat width = CGRectGetWidth(self.frame) - CGRectGetWidth(self.leftThumbImageView.frame);

        // Change left value
        self.leftValue += translation.x / width * trackRange;

        [gesture setTranslation:CGPointZero inView:self];

        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)handleRightPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self];
        CGFloat trackRange = self.maximumValue - self.minimumValue;
        CGFloat width = CGRectGetWidth(self.frame) - CGRectGetWidth(self.rightThumbImageView.frame);

        // Change right value
        self.rightValue += translation.x / width * trackRange;

        [gesture setTranslation:CGPointZero inView:self];

        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark - Getters

- (UIImage *)trackImage
{
    if (!_trackImage) {
        UIImage *image = [UIImage imageNamed:kMARKRangeSliderTrackImage];
        _trackImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 2.0, 0.0, 2.0)];
    }
    return _trackImage;
}

- (UIImage *)rangeImage
{
    if (!_rangeImage) {
        UIImage *image = [UIImage imageNamed:kMARKRangeSliderTrackRangeImage];
        _rangeImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 2.0, 0.0, 2.0)];
    }
    return _rangeImage;
}

- (UIImage *)leftThumbImage
{
    if (!_leftThumbImage) {
        _leftThumbImage = [UIImage imageNamed:kMARKRangeSliderThumbImage];
    }
    return _leftThumbImage;
}

- (UIImage *)rightThumbImage
{
    if (!_rightThumbImage) {
        _rightThumbImage = [UIImage imageNamed:kMARKRangeSliderThumbImage];
    }
    return _rightThumbImage;
}

#pragma mark - Setters

- (void)setMinimumValue:(CGFloat)minimumValue
{
    if (minimumValue >= self.maximumValue) {
        minimumValue = self.maximumValue - self.minimumDistance;
    }

    if (self.leftValue < minimumValue) {
        self.leftValue = minimumValue;
    }

    if (self.rightValue < minimumValue) {
        self.rightValue = self.maximumValue;
    }

    _minimumValue = minimumValue;

    [self checkMinimumDistance];

    [self setNeedsLayout];
}

- (void)setMaximumValue:(CGFloat)maximumValue
{
    if (maximumValue <= self.minimumValue) {
        maximumValue = self.minimumValue + self.minimumDistance;
    }

    if (self.leftValue > maximumValue) {
        self.leftValue = self.minimumValue;
    }

    if (self.rightValue > maximumValue) {
        self.rightValue = maximumValue;
    }

    _maximumValue = maximumValue;

    [self checkMinimumDistance];

    [self setNeedsLayout];
}


- (void)setLeftValue:(CGFloat)leftValue
{
    CGFloat allowedValue = self.rightValue - self.minimumDistance;
    if (leftValue > allowedValue) {
        leftValue = allowedValue;
    }

    if (leftValue < self.minimumValue) {
        leftValue = self.minimumValue;
        if (self.rightValue - leftValue < self.minimumDistance) {
            self.rightValue = leftValue + self.minimumDistance;
        }
    }

    _leftValue = leftValue;

    [self setNeedsLayout];
}

- (void)setRightValue:(CGFloat)rightValue
{
    CGFloat allowedValue = self.leftValue + self.minimumDistance;
    if (rightValue < allowedValue) {
        rightValue = allowedValue;
    }

    if (rightValue > self.maximumValue) {
        rightValue = self.maximumValue;
        if (rightValue - self.leftValue < self.minimumDistance) {
            self.leftValue = rightValue - self.minimumDistance;
        }
    }

    _rightValue = rightValue;

    [self setNeedsLayout];
}

- (void)setMinimumDistance:(CGFloat)minimumDistance
{
    CGFloat distance = self.maximumValue - self.minimumValue;
    if (minimumDistance > distance) {
        minimumDistance = distance;
    }

    if (self.rightValue - self.leftValue < minimumDistance) {
        // Reset left and right values
        self.leftValue = self.minimumValue;
        self.rightValue = self.maximumValue;
    }

    _minimumDistance = minimumDistance;

    [self setNeedsLayout];
}

- (void)checkMinimumDistance
{
    if (self.maximumValue - self.minimumValue < self.minimumDistance) {
        self.minimumDistance = 0.0f;
    }
}

@end
