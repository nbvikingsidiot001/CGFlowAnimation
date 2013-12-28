//
//  CGFlowInteractions.m
//  CGFlowSlideLeftTransition
//
//  Created by Chase Gorectke on 12/24/13.
//  Copyright (c) 2013 Revision Works, LLC. All rights reserved.
//

#import "CGFlowAnimation.h"
#import "objc/runtime.h"
#import <QuartzCore/QuartzCore.h>

/* ******************** CGFlowAnimation Definition ******************** */

@interface CGFlowAnimation()
@property (nonatomic, strong, readwrite) UIScreenEdgePanGestureRecognizer *edgeGesture;
@property (nonatomic, strong, readwrite) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong, readwrite) UILongPressGestureRecognizer *pressGesture;
@property (nonatomic, strong, readwrite) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong, readwrite) UIRotationGestureRecognizer *rotateGesture;
@property (nonatomic, strong, readwrite) UITapGestureRecognizer *tapGesture;

@property (nonatomic, assign, getter = isInteractive) BOOL interactive;
@property (nonatomic, strong) CGFlowAnimationTransition *animationController;

@property (nonatomic, assign) kCGFlowInteractionType interactorType;
@property (nonatomic, assign) kCGFlowInteractionType storedType;
@end

@implementation CGFlowAnimation
@synthesize duration=_duration;

-(instancetype)init {
    self = [super init];
    if (self) {
        _interactorType = kCGFlowInteractionNone;
        _duration = 0.4;
    }
    return self;
}

-(void)setDelegate:(UIViewController<CGFlowInteractiveDelegate> *)delegate withOptions:(kCGFlowInteractionMainType)type {
    _delegate = delegate;
    if (type == kCGFlowInteractionMainEdge) {
        if (![_delegate.view.window.gestureRecognizers containsObject:self.edgeGesture]) {
            [_delegate.view.window addGestureRecognizer:self.edgeGesture];
        }
    }
    if (type == kCGFlowInteractionMainSwipe || type == kCGFlowInteractionMainPan) {
        if (![_delegate.view.window.gestureRecognizers containsObject:self.panGesture]) {
            [_delegate.view.window addGestureRecognizer:self.panGesture];
        }
    }
    if (type == kCGFlowInteractionMainPress) {
        if (![_delegate.view.window.gestureRecognizers containsObject:self.pressGesture]) {
            [_delegate.view.window addGestureRecognizer:self.pressGesture];
        }
    }
    if (type == kCGFlowInteractionMainPinch) {
        if (![_delegate.view.window.gestureRecognizers containsObject:self.pinchGesture]) {
            [_delegate.view.window addGestureRecognizer:self.pinchGesture];
        }
    }
    if (type == kCGFlowInteractionMainRotate) {
        if (![_delegate.view.window.gestureRecognizers containsObject:self.rotateGesture]) {
            [_delegate.view.window addGestureRecognizer:self.rotateGesture];
        }
    }
    if (type == kCGFlowInteractionMainTap) {
        if (![_delegate.view.window.gestureRecognizers containsObject:self.tapGesture]) {
            [_delegate.view.window addGestureRecognizer:self.tapGesture];
        }
    }
}

#pragma mark - Gesture Recognizers

-(UIScreenEdgePanGestureRecognizer *)edgeGesture {
    if (!_edgeGesture) {
        _edgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    }
    return _edgeGesture;
}

-(UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    }
    return _panGesture;
}

-(UILongPressGestureRecognizer *)pressGesture {
    if (!_pressGesture) {
        _pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    }
    return _pressGesture;
}

-(UIPinchGestureRecognizer *)pinchGesture {
    if (!_pinchGesture) {
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    }
    return _pinchGesture;
}

-(UIRotationGestureRecognizer *)rotateGesture {
    if (!_rotateGesture) {
        _rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    }
    return _rotateGesture;
}

-(UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    }
    return _tapGesture;
}

#pragma mark - Gesture Handler

-(void)handleGesture:(UIGestureRecognizer *)gr {
    CGFloat percentage;
    if (_interactorType == kCGFlowInteractionNone) {
        percentage = 0.0;
    } else {
        if ([gr isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            if (_interactorType == kCGFlowInteractionEdgeTop) {
                percentage = [CGFlowInteractions flowEdgeTopPercentageFromRecognizer:(UIScreenEdgePanGestureRecognizer *)gr];
            } else if (_interactorType == kCGFlowInteractionEdgeBottom) {
                percentage = [CGFlowInteractions flowEdgeBottomPercentageFromRecognizer:(UIScreenEdgePanGestureRecognizer *)gr];
            } else if (_interactorType == kCGFlowInteractionEdgeLeft) {
                percentage = [CGFlowInteractions flowEdgeLeftPercentageFromRecognizer:(UIScreenEdgePanGestureRecognizer *)gr];
            } else if (_interactorType == kCGFlowInteractionEdgeRight) {
                percentage = [CGFlowInteractions flowEdgeRightPercentageFromRecognizer:(UIScreenEdgePanGestureRecognizer *)gr];
            } else {
                percentage = 0.0;
            }
        } else if ([gr isKindOfClass:[UIPanGestureRecognizer class]]) {
            if (_interactorType == kCGFlowInteractionSwipeUp) {
                percentage = [CGFlowInteractions flowPanUpPercentageFromRecognizer:(UIPanGestureRecognizer *)gr];
            } else if (_interactorType == kCGFlowInteractionSwipeDown) {
                percentage = [CGFlowInteractions flowPanDownPercentageFromRecognizer:(UIPanGestureRecognizer *)gr];
            } else if (_interactorType == kCGFlowInteractionSwipeLeft) {
                percentage = [CGFlowInteractions flowPanLeftPercentageFromRecognizer:(UIPanGestureRecognizer *)gr];
            } else if (_interactorType == kCGFlowInteractionSwipeRight) {
                percentage = [CGFlowInteractions flowPanRightPercentageFromRecognizer:(UIPanGestureRecognizer *)gr];
            } else {
                percentage = 0.0;
            }
        } else if ([gr isKindOfClass:[UILongPressGestureRecognizer class]]) {
            if (_interactorType == kCGFlowInteractionLongPress) {
                percentage = [CGFlowInteractions flowPressPercentageFromRecognizer:(UILongPressGestureRecognizer *)gr withDuration:_duration];
            } else {
                percentage = 0.0;
            }
        } else if ([gr isKindOfClass:[UIPinchGestureRecognizer class]]) {
            if (_interactorType == kCGFlowInteractionPinchIn) {
                percentage = [CGFlowInteractions flowPinchInPercentageFromRecognizer:(UIPinchGestureRecognizer *)gr];
            } else if (_interactorType == kCGFlowInteractionPinchOut) {
                percentage = [CGFlowInteractions flowPinchOutPercentageFromRecognizer:(UIPinchGestureRecognizer *)gr];
            } else {
                percentage = 0.0;
            }
        } else if ([gr isKindOfClass:[UIRotationGestureRecognizer class]]) {
            if (_interactorType == kCGFlowInteractionRotateClockwise) {
                percentage = [CGFlowInteractions flowRotateClockwisePercentageFromRecognizer:(UIRotationGestureRecognizer *)gr];
            } else if (_interactorType == kCGFlowInteractionRotateCounterClockwise) {
                percentage = [CGFlowInteractions flowRotateCounterClockwisePercentageFromRecognizer:(UIRotationGestureRecognizer *)gr];
            } else {
                percentage = 0.0;
            }
        } else if ([gr isKindOfClass:[UITapGestureRecognizer class]]) {
            if (_interactorType == kCGFlowInteractionSingleTap) {
                percentage = [CGFlowInteractions flowTapPercentageFromRecognizer:(UITapGestureRecognizer *)gr];
            } else {
                percentage = 0.0;
            }
        } else {
            percentage = 0.0;
        }
    }
    
    BOOL shouldBegin = YES;
    if ([self.delegate respondsToSelector:@selector(transitionShouldBegin:)]) {
        shouldBegin = [self.delegate transitionShouldBegin:self];
    }
    if (!shouldBegin) {
        return;
    }
    
    switch (gr.state) {
        case UIGestureRecognizerStateBegan:
            self.interactive = YES;
            if ([gr isKindOfClass:[UIPanGestureRecognizer class]]) {
                _interactorType = [CGFlowInteractions determinePanType:(UIPanGestureRecognizer *)gr];
            }
            self.animationController.orientation = [self.delegate interfaceOrientation];
            self.animationController.wasCancelled = NO;
            if ([self.delegate respondsToSelector:@selector(transitionDidBeginPresentation:)]) {
                [self.delegate transitionDidBeginPresentation:self];
            }
            [self.delegate proceedToNextViewControllerWithTransition:_interactorType];
            break;
        case UIGestureRecognizerStateChanged: {
            [self updateInteractiveTransition:percentage];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            if(percentage < 0.5) {
                self.completionSpeed = 0.5f;
                self.animationController.wasCancelled = YES;
                [self cancelInteractiveTransition];
                if ([self.delegate respondsToSelector:@selector(transitionDidCancelPresentation:)]) {
                    [self.delegate transitionDidCancelPresentation:self];
                }
            } else {
                self.completionSpeed = 1.0f;
                self.animationController.wasCancelled = NO;
                [self finishInteractiveTransition];
                if ([self.delegate respondsToSelector:@selector(transitionDidPresent:)]) {
                    [self.delegate transitionDidPresent:self];
                }
            }
            self.interactive = NO;
            self.storedType = self.interactorType;
            self.interactorType = kCGFlowInteractionNone;
        default:
            break;
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.animationController = [CGFlowAnimationTransition new];
    self.animationController.animationType = _animationType;
    self.animationController.duration = _duration;
    self.animationController.orientation = [self.delegate interfaceOrientation];
    return self.animationController;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.animationController = [CGFlowAnimationTransition new];
    self.animationController.animationType = [CGFlowAnimations oppositeType:_animationType];
    self.animationController.duration = _duration;
    self.animationController.orientation = [self.delegate interfaceOrientation];
    return self.animationController;
}

-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator {
    if (self.interactive) {
        return self;
    }
    return nil;
}

-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    if (self.interactive) {
        _interactorType = [CGFlowInteractions oppositeInteraction:_storedType];
        return self;
    }
    return nil;
}

@end

/* *********************** CGFlowInteractor End ************************ */

@implementation CGFlowInteractions

+(CGFloat)flowEdgeTopPercentageFromRecognizer:(UIScreenEdgePanGestureRecognizer *)sgr {
    CGPoint translation = [sgr translationInView:sgr.view];
    CGFloat percentage  = translation.y / CGRectGetHeight(sgr.view.bounds);
    return percentage;
}

+(CGFloat)flowEdgeBottomPercentageFromRecognizer:(UIScreenEdgePanGestureRecognizer *)sgr {
    CGPoint translation = [sgr translationInView:sgr.view];
    CGFloat percentage  = -(translation.y / CGRectGetHeight(sgr.view.bounds));
    return percentage;
}

+(CGFloat)flowEdgeLeftPercentageFromRecognizer:(UIScreenEdgePanGestureRecognizer *)sgr {
    CGPoint translation = [sgr translationInView:sgr.view];
    CGFloat percentage  = -(translation.x / CGRectGetWidth(sgr.view.bounds));
    return percentage;
}

+(CGFloat)flowEdgeRightPercentageFromRecognizer:(UIScreenEdgePanGestureRecognizer *)sgr {
    CGPoint translation = [sgr translationInView:sgr.view];
    CGFloat percentage  = translation.x / CGRectGetWidth(sgr.view.bounds);
    return percentage;
}

+(CGFloat)flowPanUpPercentageFromRecognizer:(UIPanGestureRecognizer *)pgr {
    CGPoint translation = [pgr translationInView:pgr.view];
    CGFloat percentage  = -(translation.y / CGRectGetHeight(pgr.view.bounds));
    return percentage;
}

+(CGFloat)flowPanDownPercentageFromRecognizer:(UIPanGestureRecognizer *)pgr {
    CGPoint translation = [pgr translationInView:pgr.view];
    CGFloat percentage  = translation.y / CGRectGetHeight(pgr.view.bounds);
    return percentage;
}

+(CGFloat)flowPanLeftPercentageFromRecognizer:(UIPanGestureRecognizer *)pgr {
    CGPoint translation = [pgr translationInView:pgr.view];
    CGFloat percentage  = -(translation.x / CGRectGetWidth(pgr.view.bounds));
    return percentage;
}

+(CGFloat)flowPanRightPercentageFromRecognizer:(UIPanGestureRecognizer *)pgr {
    CGPoint translation = [pgr translationInView:pgr.view];
    CGFloat percentage  = translation.x / CGRectGetWidth(pgr.view.bounds);
    return percentage;
}

+(CGFloat)flowPressPercentageFromRecognizer:(UILongPressGestureRecognizer *)lgr withDuration:(CGFloat)duration {
    return 0.0;
}

+(CGFloat)flowPinchInPercentageFromRecognizer:(UIPinchGestureRecognizer *)pgr {
    return 0.0;
}

+(CGFloat)flowPinchOutPercentageFromRecognizer:(UIPinchGestureRecognizer *)pgr {
    return 0.0;
}

+(CGFloat)flowRotateClockwisePercentageFromRecognizer:(UIRotationGestureRecognizer *)rgr {
    return 0.0;
}

+(CGFloat)flowRotateCounterClockwisePercentageFromRecognizer:(UIRotationGestureRecognizer *)rgr {
    return 0.0;
}

+(CGFloat)flowTapPercentageFromRecognizer:(UITapGestureRecognizer *)tgr {
    return 0.0;
}

+(kCGFlowInteractionType)determineEdgeType:(UIScreenEdgePanGestureRecognizer *)edgeGesture {
    return kCGFlowInteractionNone;
}

+(kCGFlowInteractionType)determinePanType:(UIPanGestureRecognizer *)panGesture {
    CGPoint velocity = [panGesture velocityInView:panGesture.view];
    if ([panGesture numberOfTouches] == 1) {
        if (fabs(velocity.x) > fabs(velocity.y)) {
            if (velocity.x > 0) {
                return kCGFlowInteractionSwipeRight;
            } else {
                return kCGFlowInteractionSwipeLeft;
            }
        } else {
            if (velocity.y > 0) {
                return kCGFlowInteractionSwipeDown;
            } else {
                return kCGFlowInteractionSwipeUp;
            }
        }
    } else if ([panGesture numberOfTouches] == 2) {
        if (fabs(velocity.x) > fabs(velocity.y)) {
            if (velocity.x > 0) {
                return kCGFlowInteractionSwipeRightDouble;
            } else {
                return kCGFlowInteractionSwipeLeftDouble;
            }
        } else {
            if (velocity.y > 0) {
                return kCGFlowInteractionSwipeDownDouble;
            } else {
                return kCGFlowInteractionSwipeUpDouble;
            }
        }
    } else if ([panGesture numberOfTouches] == 3) {
        if (fabs(velocity.x) > fabs(velocity.y)) {
            if (velocity.x > 0) {
                return kCGFlowInteractionSwipeRightTriple;
            } else {
                return kCGFlowInteractionSwipeLeftTriple;
            }
        } else {
            if (velocity.y > 0) {
                return kCGFlowInteractionSwipeDownTriple;
            } else {
                return kCGFlowInteractionSwipeUpTriple;
            }
        }
    }
    return kCGFlowInteractionNone;
}

+(kCGFlowInteractionType)determinePressType:(UILongPressGestureRecognizer *)pressGesture {
    return kCGFlowInteractionNone;
}

+(kCGFlowInteractionType)determinePinchType:(UIPinchGestureRecognizer *)pinchGesture {
    return kCGFlowInteractionNone;
}

+(kCGFlowInteractionType)determineRotateType:(UIRotationGestureRecognizer *)rotateGesture {
    return kCGFlowInteractionNone;
}

+(kCGFlowInteractionType)determineTapType:(UITapGestureRecognizer *)tapGesture {
    return kCGFlowInteractionNone;
}

+(kCGFlowInteractionType)oppositeInteraction:(kCGFlowInteractionType)type {
    if (type == kCGFlowInteractionEdgeTop) {
        return kCGFlowInteractionEdgeBottom;
    } else if (type == kCGFlowInteractionEdgeBottom) {
        return kCGFlowInteractionEdgeTop;
    } else if (type == kCGFlowInteractionEdgeLeft) {
        return kCGFlowInteractionEdgeRight;
    } else if (type == kCGFlowInteractionEdgeRight) {
        return kCGFlowInteractionEdgeLeft;
    } else if (type == kCGFlowInteractionSwipeUp) {
        return kCGFlowInteractionSwipeDown;
    } else if (type == kCGFlowInteractionSwipeDown) {
        return kCGFlowInteractionSwipeUp;
    } else if (type == kCGFlowInteractionSwipeLeft) {
        return kCGFlowInteractionSwipeRight;
    } else if (type == kCGFlowInteractionSwipeRight) {
        return kCGFlowInteractionSwipeLeft;
    } else if (type == kCGFlowInteractionSwipeUpDouble) {
        return kCGFlowInteractionSwipeDownDouble;
    } else if (type == kCGFlowInteractionSwipeDownDouble) {
        return kCGFlowInteractionSwipeUpDouble;
    } else if (type == kCGFlowInteractionSwipeLeftDouble) {
        return kCGFlowInteractionSwipeRightDouble;
    } else if (type == kCGFlowInteractionSwipeRightDouble) {
        return kCGFlowInteractionSwipeLeftDouble;
    } else if (type == kCGFlowInteractionSwipeUpTriple) {
        return kCGFlowInteractionSwipeDownTriple;
    } else if (type == kCGFlowInteractionSwipeDownTriple) {
        return kCGFlowInteractionSwipeUpTriple;
    } else if (type == kCGFlowInteractionSwipeLeftTriple) {
        return kCGFlowInteractionSwipeRightTriple;
    } else if (type == kCGFlowInteractionSwipeRightTriple) {
        return kCGFlowInteractionSwipeLeftTriple;
    } else if (type == kCGFlowInteractionPinchIn) {
        return kCGFlowInteractionPinchOut;
    } else if (type == kCGFlowInteractionPinchOut) {
        return kCGFlowInteractionPinchIn;
    } else if (type == kCGFlowInteractionRotateClockwise) {
        return kCGFlowInteractionRotateCounterClockwise;
    } else if (type == kCGFlowInteractionRotateCounterClockwise) {
        return kCGFlowInteractionRotateClockwise;
    }
    return type;
}

@end

/* ********************* CGFlowAnimation Definition ******************** */

@interface CGFlowAnimationTransition()

@end

@implementation CGFlowAnimationTransition

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return _duration;
}

#pragma mark - UIViewControllerAnimatedTransitioning

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    self.presentedController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    CGRect initialFrame = [transitionContext initialFrameForViewController:fromVC];
    
    if (_animationType == kCGFlowAnimationSlideUp) {
        [CGFlowAnimations flowSlideUpFromSource:fromVC toDestination:self.presentedController withInContainer:containerView initialFrame:initialFrame andDuration:[self transitionDuration:transitionContext] completion:^{
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else if (_animationType == kCGFlowAnimationSlideDown) {
        [CGFlowAnimations flowSlideDownFromSource:fromVC toDestination:self.presentedController withInContainer:containerView initialFrame:initialFrame andDuration:[self transitionDuration:transitionContext] completion:^{
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else if (_animationType == kCGFlowAnimationSlideLeft) {
        [CGFlowAnimations flowSlideLeftFromSource:fromVC toDestination:self.presentedController withInContainer:containerView initialFrame:initialFrame andDuration:[self transitionDuration:transitionContext] completion:^{
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else if (_animationType == kCGFlowAnimationSlideRight) {
        [CGFlowAnimations flowSlideRightFromSource:fromVC toDestination:self.presentedController withInContainer:containerView initialFrame:initialFrame andDuration:[self transitionDuration:transitionContext] completion:^{
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else if (_animationType == kCGFlowAnimationFlipUp) {
        [CGFlowAnimations flowFlipUpFromSource:fromVC toDestination:self.presentedController withInContainer:containerView initialFrame:initialFrame andDuration:[self transitionDuration:transitionContext] completion:^{
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else if (_animationType == kCGFlowAnimationFlipDown) {
        [CGFlowAnimations flowFlipDownFromSource:fromVC toDestination:self.presentedController withInContainer:containerView initialFrame:initialFrame andDuration:[self transitionDuration:transitionContext] completion:^{
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else {
        NSAssert(NO, @"Animation type must be specified.");
    }
}

@end

/* ************************ CGFlowAnimation End ************************ */

@implementation CGFlowAnimations

+(void)flowSlideUpFromSource:(UIViewController *)srcController toDestination:(UIViewController *)destController
             withInContainer:(UIView *)containerView initialFrame:(CGRect)initialFrame andDuration:(CGFloat)duration completion:(completion)complete {
    UIView *fromView = srcController.view;
    UIView *toView = destController.view;
    
    // Add the toView to the container
    [toView removeFromSuperview];
    [containerView addSubview:toView];
    
    // Set the frames
    fromView.frame = initialFrame;
    toView.center = CGPointMake(containerView.center.x, containerView.center.y + containerView.frame.size.height);
    
    [UIView animateKeyframesWithDuration:duration delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        fromView.center = CGPointMake(containerView.center.x, containerView.center.y - containerView.frame.size.height);
        toView.center = CGPointMake(containerView.center.x, containerView.center.y);
    } completion:^(BOOL finished) {
        if (finished) {
            complete();
        }
    }];
}

+(void)flowSlideDownFromSource:(UIViewController *)srcController toDestination:(UIViewController *)destController
               withInContainer:(UIView *)containerView initialFrame:(CGRect)initialFrame andDuration:(CGFloat)duration completion:(completion)complete {
    UIView *fromView = srcController.view;
    UIView *toView = destController.view;
    
    // Add the toView to the container
    [toView removeFromSuperview];
    [containerView addSubview:toView];
    
    // Set the frames
    fromView.frame = initialFrame;
    toView.center = CGPointMake(containerView.center.x, containerView.center.y - containerView.frame.size.height);
    
    [UIView animateKeyframesWithDuration:duration delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        fromView.center = CGPointMake(containerView.center.x, containerView.center.y + containerView.frame.size.height);
        toView.center = CGPointMake(containerView.center.x, containerView.center.y);
    } completion:^(BOOL finished) {
        if (finished) {
            complete();
        }
    }];
}

+(void)flowSlideLeftFromSource:(UIViewController *)srcController toDestination:(UIViewController *)destController
               withInContainer:(UIView *)containerView initialFrame:(CGRect)initialFrame andDuration:(CGFloat)duration completion:(completion)complete {
    UIView *fromView = srcController.view;
    UIView *toView = destController.view;
    
    // Add the toView to the container
    [toView removeFromSuperview];
    [containerView addSubview:toView];
    
    // Set the frames
    fromView.frame = initialFrame;
    toView.center = CGPointMake((containerView.center.x + containerView.frame.size.width), containerView.center.y);
    
    [UIView animateKeyframesWithDuration:duration delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        fromView.center = CGPointMake((containerView.center.x - containerView.frame.size.width), containerView.center.y);
        toView.center = CGPointMake(containerView.center.x, containerView.center.y);
    } completion:^(BOOL finished) {
        if (finished) {
            complete();
        }
    }];
}

+(void)flowSlideRightFromSource:(UIViewController *)srcController toDestination:(UIViewController *)destController
                withInContainer:(UIView *)containerView initialFrame:(CGRect)initialFrame andDuration:(CGFloat)duration completion:(completion)complete {
    UIView *fromView = srcController.view;
    UIView *toView = destController.view;
    
    // Add the toView to the container
    [toView removeFromSuperview];
    [containerView addSubview:toView];
    
    // Set the frames
    fromView.frame = initialFrame;
    toView.center = CGPointMake((containerView.center.x - containerView.frame.size.width), containerView.center.y);
    
    [UIView animateKeyframesWithDuration:duration delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        fromView.center = CGPointMake((containerView.center.x + containerView.frame.size.width), containerView.center.y);
        toView.center = CGPointMake(containerView.center.x, containerView.center.y);
    } completion:^(BOOL finished) {
        if (finished) {
            complete();
        }
    }];
}

+(void)flowFlipUpFromSource:(UIViewController *)srcController toDestination:(UIViewController *)destController
            withInContainer:(UIView *)containerView initialFrame:(CGRect)initialFrame andDuration:(CGFloat)duration completion:(completion)complete {
    UIView *fromView = srcController.view;
    UIView *toView = destController.view;
    
    // Add the toView to the container
    [containerView addSubview:toView];
    
    // Set the frames
    fromView.frame = initialFrame;
    toView.frame = initialFrame;
    
    // Start building the transform - 3D so need perspective
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1/CGRectGetHeight(initialFrame);
    containerView.layer.sublayerTransform = transform;
    
    toView.layer.transform = CATransform3DMakeRotation(-1.0 * M_PI_2, 1, 0, 0);
    [UIView animateKeyframesWithDuration:duration delay:0.0 options:0 animations:^{
        // First half is rotating in
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            fromView.layer.transform = CATransform3DMakeRotation(M_PI_2, 1, 0, 0);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            toView.layer.transform = CATransform3DMakeRotation(0, 1, 0, 0);
        }];
    } completion:^(BOOL finished) {
        if (finished) {
            complete();
        }
    }];
}

+(void)flowFlipDownFromSource:(UIViewController *)srcController toDestination:(UIViewController *)destController
              withInContainer:(UIView *)containerView initialFrame:(CGRect)initialFrame andDuration:(CGFloat)duration completion:(completion)complete {
    UIView *fromView = srcController.view;
    UIView *toView = destController.view;
    
    // Add the toView to the container
    [containerView addSubview:toView];
    
    // Set the frames
    fromView.frame = initialFrame;
    toView.frame = initialFrame;
    
    // Start building the transform - 3D so need perspective
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1 / CGRectGetHeight(initialFrame);
    containerView.layer.sublayerTransform = transform;
    
    toView.layer.transform = CATransform3DMakeRotation(1.0 * M_PI_2, 1, 0, 0);
    [UIView animateKeyframesWithDuration:duration delay:0.0 options:0 animations:^{
        // First half is rotating in
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            fromView.layer.transform = CATransform3DMakeRotation(-1.0 * M_PI_2, 1, 0, 0);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            toView.layer.transform = CATransform3DMakeRotation(0, 1, 0, 0);
        }];
    } completion:^(BOOL finished) {
        if (finished) {
            complete();
        }
    }];
}

+(kCGFlowAnimationType)oppositeType:(kCGFlowAnimationType)type {
    if (type == kCGFlowAnimationSlideUp) {
        return kCGFlowAnimationSlideDown;
    } else if (type == kCGFlowAnimationSlideDown) {
        return kCGFlowAnimationSlideUp;
    } else if (type == kCGFlowAnimationSlideLeft) {
        return kCGFlowAnimationSlideRight;
    } else if (type == kCGFlowAnimationSlideRight) {
        return kCGFlowAnimationSlideLeft;
    } else if (type == kCGFlowAnimationFlipUp) {
        return kCGFlowAnimationFlipDown;
    } else if (type == kCGFlowAnimationFlipDown) {
        return kCGFlowAnimationFlipUp;
    }
    return kCGFlowAnimationNone;
}

@end

#pragma mark - UIViewController(CGFlowAnimation) Category

static char loadKey;
static char unloadKey;

@interface UIViewController() {
    CGFlowAnimation *loadInteractor;
    CGFlowAnimation *unloadInteractor;
}
@property (nonatomic, strong) CGFlowAnimation *loadInteractor;
@property (nonatomic, strong) CGFlowAnimation *unloadInteractor;
@end

@implementation UIViewController (CGFlowInteractor)

+(void)load {
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(prepareForSegue:sender:)), class_getInstanceMethod(self, @selector(prepareForSegueOverride:sender:)));
}

-(void)prepareForSegueOverride:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destController = (UIViewController *)segue.destinationViewController;
    destController.transitioningDelegate = self.unloadInteractor;
    destController.loadInteractor = self.unloadInteractor;
}

-(void)proceedToNextViewControllerWithTransition:(kCGFlowInteractionType)type {
    
}

-(void)setLoadInteractor:(CGFlowAnimation *)interactor {
    objc_setAssociatedObject(self, &loadKey, interactor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CGFlowAnimation *)loadInteractor {
    return objc_getAssociatedObject(self, &loadKey);
}

-(void)setUnloadInteractor:(CGFlowAnimation *)interactor {
    objc_setAssociatedObject(self, &unloadKey, interactor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CGFlowAnimation *)unloadInteractor {
    return objc_getAssociatedObject(self, &unloadKey);
}

@end