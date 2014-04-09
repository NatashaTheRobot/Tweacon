//
//  NTRBeaconManager.m
//  Tweacon
//
//  Created by Natasha Murashev on 4/7/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

#import "NTRBeaconManager.h"
@import CoreBluetooth;
#import "NTRUser.h"

@interface NTRBeaconManager () <CBPeripheralManagerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSMutableDictionary *beaconPeripheralData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegionToMonitor;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation NTRBeaconManager

static NTRBeaconManager *beaconManager;

+ (instancetype)sharedManager
{
    if (!beaconManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            beaconManager = [[NTRBeaconManager alloc] init];
        });
        
    }
    
    return beaconManager;
}

- (id)init
{
    self = [super init];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self transmitUserBeacon];
    [self startMonitoringRegion];
    
    return self;
}

#pragma mark - Transimit Beacon

- (void)transmitUserBeacon
{
    NTRUser *user = [NTRUser currentUser];
    if (user) {
        NSUUID *userUUID = [[NSUUID alloc] initWithUUIDString:user[@"uuidString"]];
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:NTR_BEACON_UUID
                                                               identifier:NTR_BEACON_REGION];
        self.beaconPeripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
        self.beaconPeripheralData[NTR_BEACON_KEY_SCREENNAME] = user[@"screenName"];
        if (user[@"imageURL"]) {
            self.beaconPeripheralData[NTR_BEACON_KEY_IMAGE_URL] = user[@"imageURL"];
        }
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                         queue:nil
                                                                       options:@{CBPeripheralManagerOptionShowPowerAlertKey : @YES}];
    }
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        if (![self.peripheralManager isAdvertising]) {
            [self.peripheralManager startAdvertising:self.beaconPeripheralData];
        }
    } else if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        [self.peripheralManager stopAdvertising];
    }
}

#pragma mark - Detect Beacon

- (void)startMonitoringRegion
{
    self.beaconRegionToMonitor = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:NTR_BEACON_UUID]
                                                                              identifier:NTR_BEACON_REGION];
    if (self.beaconRegionToMonitor) {
        [self.locationManager startMonitoringForRegion:self.beaconRegionToMonitor];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegionToMonitor];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegionToMonitor];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    CLBeacon *beacon = [beacons lastObject];
    NSDictionary *peripheralData = [region peripheralDataWithMeasuredPower:nil];
    NSString *username = peripheralData[NTR_BEACON_KEY_SCREENNAME];
    NSString *imageURL = peripheralData[NTR_BEACON_KEY_IMAGE_URL];
    
}

@end
