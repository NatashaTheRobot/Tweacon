//
//  NTRTwitterClient.m
//  Tweacon
//
//  Created by Natasha Murashev on 4/5/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

#import "NTRTwitterClient.h"
#import "PFTwitterUtils+NativeTwitter.h"
#import "NTRUser.h"
#import <Accounts/Accounts.h>
#import "FHSTwitterEngine.h"

@implementation NTRTwitterClient

+ (void)loginUserWithAccount:(ACAccount *)twitterAccount
{
    [PFTwitterUtils initializeWithConsumerKey:NTR_TWITTER_CONSUMER_KEY consumerSecret:NTR_TWITTER_CONSUMER_SECRET];
    
    [PFTwitterUtils setNativeLogInSuccessBlock:^(PFUser *parseUser, NSString *userTwitterId, NSError *error) {
        ((NTRUser *)parseUser).screenName = [twitterAccount username];
        [self onLoginSuccess:parseUser];
    }];
    
    [PFTwitterUtils setNativeLogInErrorBlock:^(TwitterLogInError logInError) {
        NSError *error = [[NSError alloc] initWithDomain:nil code:logInError userInfo:@{@"logInErrorCode" : @(logInError)}];
        [self onLoginFailure:error];
    }];
    
    [PFTwitterUtils logInWithAccount:twitterAccount];
}

+ (void)loginUserWithTwitterEngine
{
    [PFTwitterUtils initializeWithConsumerKey:NTR_TWITTER_CONSUMER_KEY consumerSecret:NTR_TWITTER_CONSUMER_SECRET];
    
    FHSTwitterEngine *twitterEngine = [FHSTwitterEngine sharedEngine];
    FHSToken *token = [FHSTwitterEngine sharedEngine].accessToken;
    
    [PFTwitterUtils logInWithTwitterId:twitterEngine.authenticatedID
                            screenName:twitterEngine.authenticatedUsername
                             authToken:token.key
                       authTokenSecret:token.secret
                                 block:^(PFUser *user, NSError *error) {
                                     if (user) {
                                         ((NTRUser *)user).screenName = twitterEngine.authenticatedUsername;
                                         [self onLoginSuccess:user];
                                     } else {
                                         [self onLoginFailure:error];
                                     }
    }];
}

#pragma mark - Private

+ (void)onLoginSuccess:(PFUser *)user
{
    [user saveInBackground];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTRNotificationTwitterLoginSuccess object:user];
    [self fetchDataForUser:(NTRUser *)user];
}

+ (void)onLoginFailure:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NTRNotificationTwitterLoginFailure object:error];
}

+ (void)fetchDataForUser:(NTRUser *)user
{
    NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", user.screenName];
    
    NSURL *verify = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
    [[PFTwitterUtils twitter] signRequest:request];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error;
        NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (result) {
            [user configureWithData:result];
            [user saveEventually];
        }
    }];

}

@end
