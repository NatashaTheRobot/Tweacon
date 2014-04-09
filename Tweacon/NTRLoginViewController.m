//
//  NTRViewController.m
//  Tweacon
//
//  Created by Natasha Murashev on 4/5/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

#import "NTRLoginViewController.h"
#import "PFTwitterUtils+NativeTwitter.h"
#import "NTRTwitterClient.h"
#import "FHSTwitterEngine.h"
#import "NTRUser.h"
#import "NTRNearbyServicesManager.h"

@interface NTRLoginViewController () <UIActionSheetDelegate>

@property (strong, nonatomic) NSArray *twitterAccounts;

@end

@implementation NTRLoginViewController

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
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (IBAction)onTwitterLoginButtonTap:(id)sender
{
    __weak NTRLoginViewController *weakSelf = self;
    [PFTwitterUtils getTwitterAccounts:^(BOOL accountsWereFound, NSArray *twitterAccounts) {
        [weakSelf handleTwitterAccounts:twitterAccounts];
    }];
}

#pragma mark - Handle Twitter Login

- (void)onTwitterLoginSuccess:(id)notification
{
    [[NTRNearbyServicesManager sharedManager] start];
    [self performSegueWithIdentifier:@"loginToTweaconsSegue" sender:self];
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
