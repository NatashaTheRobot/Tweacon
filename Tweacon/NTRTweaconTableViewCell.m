//
//  NTRTweaconTableViewCell.m
//  Tweacon
//
//  Created by Natasha Murashev on 4/20/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

#import "NTRTweaconTableViewCell.h"
#import "NTRUser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+NTRImageEffects.h"

@interface NTRTweaconTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;


@end

@implementation NTRTweaconTableViewCell

- (void)configureWithUserData:(NTRUser *)userData
{
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", userData.screenName];
    self.nameLabel.text = userData.name;
    self.profileImageView.clipsToBounds = YES;
    
    __weak NTRTweaconTableViewCell *weakSelf = self;
    [self.profileImageView setImageWithURL:[NSURL URLWithString:userData.imageURL]
                          placeholderImage:[UIImage imageNamed:@"placeholder"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                     weakSelf.profileImageView.layer.cornerRadius = image.size.width / 4;
                                 }];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:[NSURL URLWithString:userData.backgroundImageURL]
                     options:0
                    progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
     }
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             weakSelf.backgroundColor = [UIColor colorWithPatternImage:[image applyDarkEffect]];
         }
     }];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 2.0, self.frame.size.width, 2)];
    
    lineView.backgroundColor = [UIColor blackColor];
    lineView.alpha = 0.35;
    [self addSubview:lineView];
}

@end
