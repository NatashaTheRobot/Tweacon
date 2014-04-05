//
//  NTRViewController.m
//  Tweacon
//
//  Created by Natasha Murashev on 4/5/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

#import "NTRTweaconsViewController.h"
#import "NTRLoginView.h"
#import "PFTwitterUtils+NativeTwitter.h"
#import "NTRTwitterClient.h"

@interface NTRTweaconsViewController () <NTRLoginViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSArray *twitterAccounts;

@end

@implementation NTRTweaconsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![PFUser currentUser]) {
        [self addLoginView];
    }
}

#pragma mark - LoginViewDelegate

- (void)onTwitterLoginAction
{
    __weak NTRTweaconsViewController *weakSelf = self;
    [PFTwitterUtils getTwitterAccounts:^(BOOL accountsWereFound, NSArray *twitterAccounts) {
        if (accountsWereFound) {
            if (twitterAccounts.count > 1) {
                weakSelf.twitterAccounts = twitterAccounts;
                [weakSelf displayTwitterAccounts:twitterAccounts];
            } else {
                [weakSelf onUserTwitterAccountSelection:twitterAccounts[0]];
            }
        }
    }];
}

#pragma mark - Private Configuration Methods

- (void)addLoginView
{
    NTRLoginView *loginView = [[NSBundle mainBundle] loadNibNamed:@"NTRLoginView" owner:self options:nil][0];
    loginView.delegate = self;
    loginView.frame = CGRectMake(0, 300, loginView.frame.size.width, loginView.frame.size.height);
    [self.view addSubview:loginView];
}

#pragma mark - Twitter Login Methods

#pragma mark - Private Methods

- (void)displayTwitterAccounts:(NSArray *)twitterAccounts
{
    __block UIActionSheet *selectTwitterAccountsActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Twitter Account"
                                                                                          delegate:self
                                                                                 cancelButtonTitle:nil
                                                                            destructiveButtonTitle:nil
                                                                                 otherButtonTitles:nil];
    
    [twitterAccounts enumerateObjectsUsingBlock:^(id twitterAccount, NSUInteger idx, BOOL *stop) {
        [selectTwitterAccountsActionSheet addButtonWithTitle:[twitterAccount username]];
        // save username right away - start beaconing!
    }];
    selectTwitterAccountsActionSheet.cancelButtonIndex = [selectTwitterAccountsActionSheet addButtonWithTitle:@"Cancel"];
    
    [selectTwitterAccountsActionSheet showInView:self.view];
}

- (void)onUserTwitterAccountSelection:(ACAccount *)twitterAccount
{
    [NTRTwitterClient loginUserWithAccount:twitterAccount];
//    [[NSUserDefaults standardUserDefaults] setObject:[twitterAccount username] forKey:@"username"];
    // start beaconing
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self onUserTwitterAccountSelection:self.twitterAccounts[buttonIndex]];
    }
}


@end
