//
//  NTRUser.m
//  Tweacon
//
//  Created by Natasha Murashev on 4/5/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

#import "NTRUser.h"

@interface NTRUser ()

@end

@implementation NTRUser

@dynamic screenName;
@dynamic name;
@dynamic imageURL;
@dynamic profileDescription;
@dynamic location;
@dynamic backgroundImageURL;

- (void)configureWithData:(NSDictionary *)data
{
    self.screenName = data[@"screen_name"];
    self.name= data[@"name"];
    self.profileDescription = data[@"description"];
    self.imageURL = [data[@"profile_image_url_https"] stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
    self.location = data[@"location"];
    self.backgroundImageURL = [NSString stringWithFormat:@"%@/mobile_retina", data[@"profile_banner_url"]];
}

@end
