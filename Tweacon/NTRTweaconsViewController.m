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
#import "FHSTwitterEngine.h"
#import "NTRUser.h"

@interface NTRTweaconsViewController () <NTRLoginViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSArray *twitterAccounts;

@property (weak, nonatomic) NTRLoginView *loginView;

@end

@implementation NTRTweaconsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self registerForNotifications];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![PFUser currentUser]) {
        [self addLoginView];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - LoginViewDelegate

- (void)onTwitterLoginAction
{
    __weak NTRTweaconsViewController *weakSelf = self;
    [PFTwitterUtils getTwitterAccounts:^(BOOL accountsWereFound, NSArray *twitterAccounts) {
        [weakSelf handleTwitterAccounts:twitterAccounts];
    }];
}

#pragma mark - Handle Twitter Login

- (void)onTwitterLoginSuccess:(id)notification
{
    [self.loginView removeFromSuperview];
    //    [[NSUserDefaults standardUserDefaults] setObject:[twitterAccount username] forKey:@"username"];
    // start beaconing
}

- (void)onTwitterLoginFailure:(id)notification
{
    
}

#pragma mark - Private Configuration Methods

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTwitterLoginSuccess:) name:NTRNotificationTwitterLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTwitterLoginFailure:) name:NTRNotificationTwitterLoginFailure object:nil];
}

- (void)addLoginView
{
    self.loginView = [[NSBundle mainBundle] loadNibNamed:@"NTRLoginView" owner:self options:nil][0];
    self.loginView.delegate = self;
    self.loginView.frame = CGRectMake(0, 300, self.loginView.frame.size.width, self.loginView.frame.size.height);
    [self.view addSubview:self.loginView];
}

#pragma mark - Twitter Login Methods

- (void)handleTwitterAccounts:(NSArray *)twitterAccounts
{
    switch ([twitterAccounts count]) {
        case 0:
        {
            [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:NTR_TWITTER_CONSUMER_KEY andSecret:NTR_TWITTER_CONSUMER_SECRET];
            UIViewController *loginController = [[FHSTwitterEngine sharedEngine] loginControllerWithCompletionHandler:^(BOOL success) {
                if (success) {
                    [NTRTwitterClient loginUserWithTwitterEngine];
                }
            }];
            [self presentViewController:loginController animated:YES completion:nil];
        }
            break;
        case 1:
            [self onUserTwitterAccountSelection:twitterAccounts[0]];
            break;
        default:
            self.twitterAccounts = twitterAccounts;
            [self displayTwitterAccounts:twitterAccounts];
            break;
    }

}

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
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self onUserTwitterAccountSelection:self.twitterAccounts[buttonIndex]];
    }
}


@end
