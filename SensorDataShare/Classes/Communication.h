//
//  UIViewController+Communication.h
//  SendSensorData
//
//  Created by aa on 11/14/15.
//  Copyright © 2015 aa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"



#define postURL             @"http://54.209.68.226:1008/api/TraceService"
#define DEVICEID            @"deviceId"
#define CREATEAT            @"createdAt"

#define STARTX              @"startX"
#define STARTY              @"startY"
#define GETTRACEID          @"GETTRACEID"
#define SENDSENSORDATA      @"SENDSENSORDATA"
#define TRACEID             @"id"

#define AccelerometerX      @"AccelerometerX"
#define AccelerometerY      @"AccelerometerY"
#define AccelerometerZ      @"AccelerometerZ"
#define GyroscopeX          @"GyroscopeX"
#define GyroscopeY          @"GyroscopeY"
#define GyroscopeZ          @"GyroscopeZ"
#define OrientationAzmuth   @"OrientationAzimuth"
#define OrientationPitch    @"OrientationPitch"
#define OrientationRoll     @"OrientationRoll"
#define MagnetometerX       @"MagnetometerX"
#define MagnetometerY       @"MagnetometerY"
#define MagnetometerZ       @"MagnetometerZ"
#define LinearAccelerationX @"LinearAccelerationX"
#define LinearAccelerationY @"LinearAccelerationY"
#define LinearAccelerationZ @"LinearAccelerationZ"
#define GPSALTITUDE         @"altitude"

#define TRACESENSORS        @"traceSensors"
#define WIFIROUTENAME       @"routerName"
#define WIFIACCESSPOINTS    @"accessPoints"
#define TRACEWIFIDETAILS    @"traceWiFiDetails"
#define TRACEWIFIS          @"traceWiFis"

#define GPSLOGITUDE         @"longitude"
#define GPSLATITUDE         @"latitude"
#define TRACEGPS            @"traceGPS"

@interface Communication : NSObject

+ ( Communication * ) sharedManager;

// Web Service ;
- ( void ) sendToService : ( NSDictionary* ) _params
           requestMethod : (NSString *) method
                 success : ( void (^)( id _responseObject ) ) _success
                 failure : ( void (^)( NSError* _error ) ) _failure ;

- ( void ) postGetTraceID : (NSString * ) _deviceID
                 CreateAt : (NSString * ) _creatAt
                 StartX   : (NSString * ) _startX
                 StartY   : (NSString * ) _startY
                successed : ( void (^)( id _responseObject ) ) _success
                  failure : ( void (^)( NSError* _error ) ) _failure;

- ( void ) postSensorData : (NSString * ) _traceID
                 DeviceID : (NSString * ) _deviceID
             TraceGPSData : (NSArray * ) _arrayGPSData
            TraceWifiData : (NSArray * ) _arrayWifiData
          TraceSensorData : (NSArray * ) _arraySensorData
               successed  : ( void (^)( id _responseObject ) ) _success
                 failure  : ( void (^)( NSError* _error ) ) _failure;

@end
