//
//  NTRLoginView.m
//  Tweacon
//
//  Created by Natasha Murashev on 4/5/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

#import "NTRLoginView.h"

@interface NTRLoginView ()

@property (strong, nonatomic) NSArray *twitterAccounts;
@property (assign, nonatomic) id selectedTwitterAccount;

@end

@implementation NTRLoginView

- (IBAction)onLoginWithTwitterButtonTap:(id)sender
{
    [self.delegate onTwitterLoginAction];
    
}

@end
