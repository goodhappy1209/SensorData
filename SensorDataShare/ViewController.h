//
//  ViewController.h
//  SendSensorData
//
//  Created by aa on 11/12/15.
//  Copyright (c) 2015 aa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Communication.h"
#import <NetworkExtension/NetworkExtension.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define IOS_VERSION     [[[UIDevice currentDevice] systemVersion] floatValue]


#define UITEXTFIELDBUILDINGNAME 1000;
#define UITEXTFIELDBUILDINGFLOOR 1001;

#define PINKCOLOR [UIColor colorWithRed:184/255 green:120/255 blue:255/255 alpha:1];
#define DEEPBULUCOLOR [UIColor colorWithRed:29/255 green:135/255 blue:184/255 alpha:1];
#define UISCREENWIDTH [UIScreen mainScreen].bounds.size.width;
#define UISCREENHEIGHT [[UIScreen mainScreen] bounds].size.height;

@interface ViewController : UIViewController<UITextFieldDelegate, CLLocationManagerDelegate, CBPeripheralDelegate>
{
   
    NSMutableArray * gpsDataArray;
    NSMutableArray * wifiDataArray;
    NSMutableArray * sensorDataArray;
    
    NSMutableArray * acceleratorArray;
    NSMutableArray * gyroScopeArray;
    NSMutableArray * magnemeterArray;
    NSMutableArray * orienationArray;
    
    NSMutableDictionary * requestSensorData;
    
    NSString * mTraceID;
    
}

@property (nonatomic, retain) IBOutlet UITextField * etvBuildingName;
@property (nonatomic, retain) IBOutlet UITextField * etvBuildingFloor;
@property (nonatomic, retain) IBOutlet UIButton * btnStartRunning;
@property (nonatomic, retain) IBOutlet UIImageView * uivLoadingProgress;

/**
 Get Locations.
 **/
@property ( strong, nonatomic ) CLLocationManager*  locationManager ;
@property ( strong, nonatomic ) CLLocation*         location ;
@property ( strong, nonatomic ) CMMotionManager * cmMotionManager;
@property ( strong, nonatomic ) CBPeripheralManager * cbPerpheralManager;







- (IBAction)onStartRunning:(id)sender;

@end

