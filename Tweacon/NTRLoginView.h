//
//  NTRLoginView.h
//  Tweacon
//
//  Created by Natasha Murashev on 4/5/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

@protocol NTRLoginViewDelegate <NSObject>

- (void)onTwitterLoginAction;

@end

@interface NTRLoginView : UIView

@property (weak, nonatomic) id<NTRLoginViewDelegate>delegate;

@end
