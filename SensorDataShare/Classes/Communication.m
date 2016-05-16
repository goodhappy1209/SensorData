//
//  UIViewController+Communication.m
//  SendSensorData
//
//  Created by aa on 11/14/15.
//  Copyright © 2015 aa. All rights reserved.
//

#import "Communication.h"

@interface Communication()

@end
@implementation Communication

// Functions ;

#pragma mark - Shared Functions
+ ( Communication * ) sharedManager
{
    __strong static Communication * sharedObject = nil ;
    static dispatch_once_t onceToken;
    
    dispatch_once( &onceToken, ^{
        sharedObject = [ [ Communication alloc ] init ] ;
    } ) ;
    
    return sharedObject ;
}

#pragma mark - PMCommunication
- ( id ) init
{
    self = [ super init ] ;
    return self ;
}

- ( void ) postGetTraceID : ( NSString * ) _deviceID
                 CreateAt : ( NSString * ) _creatAt
                 StartX   : ( NSString * ) _startX
                 StartY   : ( NSString * ) _startY
                successed : ( void (^)( id _responseObject ) ) _success
                  failure : ( void (^)( NSError* _error ) ) _failure
{
    // Params ;
    NSMutableDictionary*    params  = [ NSMutableDictionary dictionary ] ;
    
    [ params setObject : _deviceID forKey : DEVICEID ];
    [ params setObject : _creatAt  forKey : CREATEAT];
    [ params setObject : _startX   forKey : STARTX ];
    [ params setObject : _startY   forKey : STARTY ];
    
    // Web Service ;
    [ self sendToService : params requestMethod:@"POST" success : _success failure : _failure ] ;
    
}

- ( void ) postSensorData : (NSString * ) _traceID
                 DeviceID : (NSString * ) _deviceID
              TraceGPSData: (NSMutableArray * ) _arrayGPSData
             TraceWifiData: (NSMutableArray * ) _arrayWifiData
           TraceSensorData: (NSMutableArray * ) _arraySensorData
         successed : ( void (^)( id _responseObject ) ) _success
           failure : ( void (^)( NSError* _error ) ) _failure
{
    // Params ;
    NSMutableDictionary*    params  = [ NSMutableDictionary dictionary ] ;
    

    [ params setObject : _traceID forKey : TRACEID ] ;
    [ params setObject : _deviceID forKey : DEVICEID ] ;
    [ params setObject : _arrayGPSData forKey : TRACEGPS ] ;
    [ params setObject : _arrayWifiData forKey : TRACEWIFIS ] ;
    [ params setObject : _arraySensorData forKey : TRACESENSORS ] ;
    
    // Web Service ;
    [ self sendToService : params requestMethod:@"PUT" success : _success failure : _failure ] ;
}


#pragma mark - Web Service
- ( void ) sendToService : ( NSDictionary* ) _params
           requestMethod : (NSString *) method
                 success : ( void (^)( id _responseObject ) ) _success
                 failure : ( void (^)( NSError* _error ) ) _failure
{
    NSURL *  url;
    
    if ([method isEqualToString:@"POST"]) {
        url  = [ NSURL URLWithString : postURL ] ;
    }
    else
    {
        url  = [ NSURL URLWithString : [NSString stringWithFormat:@"%@/%@", postURL, [_params objectForKey:TRACEID]] ] ;
    }
    
    AFHTTPClient*           client      = [ [ AFHTTPClient alloc ] initWithBaseURL: url ] ;
//    NSError *error;
//    NSString *jsonString;
    
    [client setParameterEncoding:AFJSONParameterEncoding];
    
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_params
//                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
//                                                         error:&error];
//    
//    if (!jsonData) {
//        NSLog(@"Got an error: %@", error);
//    } else {
//        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        NSLog(@"Json String : %@", jsonString);
//    }
    
    NSMutableURLRequest*    request     = [ client requestWithMethod : method path : nil parameters : _params ] ;
    AFHTTPRequestOperation* operation   = [ [ AFHTTPRequestOperation alloc ] initWithRequest : request ] ;
    
    [ client registerHTTPOperationClass : [ AFHTTPRequestOperation class ] ] ;
    [ operation setCompletionBlockWithSuccess : ^( AFHTTPRequestOperation* _operation, id _responseObject ) {
        
        NSString* string =  [ [ NSString alloc ] initWithData : _responseObject encoding : NSUTF8StringEncoding ] ;
        //        NSLog( @"%@", string ) ;
        
        // Response Object ;
        id responseObject   = string;
        
        // Success ;
        if( _success )
        {
            _success( responseObject ) ;
        }
        
    } failure : ^( AFHTTPRequestOperation* _operation, NSError* _error )
     {
         NSLog( @"%@", _error.description ) ;
         
         // Failture ;
         if( _failure )
         {
             _failure( _error ) ;
         }
     } ] ;
    [ operation start ] ;
}
@end
