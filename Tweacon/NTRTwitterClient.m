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

@implementation NTRTwitterClient

+ (void)loginUserWithAccount:(ACAccount *)twitterAccount
{
    [PFTwitterUtils initializeWithConsumerKey:NTR_TWITTER_CONSUMER_KEY consumerSecret:NTR_TWITTER_CONSUMER_SECRET];
    
    [PFTwitterUtils setNativeLogInSuccessBlock:^(PFUser *parseUser, NSString *userTwitterId, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NTRNotificationTwitterLoginSuccess object:nil];
        [self fetchDataForUser:(NTRUser *)parseUser userName:[twitterAccount username]];
    }];
    
    [PFTwitterUtils setNativeLogInErrorBlock:^(TwitterLogInError logInError) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NTRNotificationTwitterLoginFailure object:@(logInError)];
    }];
    
    [PFTwitterUtils logInWithAccount:twitterAccount];
}

#pragma mark - Private

+ (void)fetchDataForUser:(NTRUser *)user userName:(NSString *)username
{
    NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", username];
    
    NSURL *verify = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
    [[PFTwitterUtils twitter] signRequest:request];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error;
        NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (!error) {
            [user configureWithData:result];
            [user saveEventually];
        }
    }];

}

@end
