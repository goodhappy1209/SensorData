//
//  ViewController.m
//  SendSensorData
//
//  Created by aa on 11/12/15.
//  Copyright (c) 2015 aa. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
{
    BOOL selectButtonRun;
    NSTimer* myTimer;
}
@end

@implementation ViewController
@synthesize btnStartRunning, etvBuildingFloor, etvBuildingName, uivLoadingProgress;
@synthesize location, locationManager;
@synthesize cmMotionManager;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
 
    [self initUI];
    [self setupGesture];
    
}

- (void)setupGesture {
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(viewTapped:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGesture];
}

- (void)viewTapped:(UIGestureRecognizer*)gesture {
    
    [etvBuildingFloor resignFirstResponder];
    [etvBuildingName resignFirstResponder];
    
}

- (void)initUI
{
    
    selectButtonRun = FALSE;
    
    float UIViewWidth = [UIScreen mainScreen].bounds.size.width;
    float UIViewHeight = [[UIScreen mainScreen] bounds].size.height;
    
    
    uivLoadingProgress = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_progress.png"]];
    [uivLoadingProgress setFrame:CGRectMake(UIViewWidth * 0.25, UIViewHeight * 0.42f, UIViewWidth/2, UIViewWidth/2)];
    
    
    [uivLoadingProgress layer].anchorPoint = CGPointMake(0.5,0.5f);
    
    
    [self.view addSubview:uivLoadingProgress];
    
    [uivLoadingProgress setHidden:YES];
    
    etvBuildingName.tag = UITEXTFIELDBUILDINGNAME;
    etvBuildingFloor.tag = UITEXTFIELDBUILDINGFLOOR;
    
    gpsDataArray = [[NSMutableArray alloc] init];
    wifiDataArray = [[NSMutableArray alloc] init];
    sensorDataArray = [[NSMutableArray alloc] init];
    
    [etvBuildingFloor setEnabled:NO];
    [etvBuildingName setEnabled:NO];
    
}

- (void)rotate360WithDuration:(CGFloat)duration repeatCount:(float)repeatCount
{
    
    CABasicAnimation *fullRotation;
    fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    //fullRotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
    fullRotation.toValue = [NSNumber numberWithFloat:(2*M_PI)]; // added this minus sign as i want to rotate it to anticlockwise
    fullRotation.duration = duration;
    fullRotation.speed = 2.0f;              // Changed rotation speed
    if (repeatCount == 0)
        fullRotation.repeatCount = UIViewAnimationOptionRepeat|UIViewAnimationOptionCurveLinear;
    else
        fullRotation.repeatCount = repeatCount;
    
    [uivLoadingProgress.layer addAnimation:fullRotation forKey:@"360"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onStartRunning:(id)sender
{
    if (selectButtonRun)
    {
        [btnStartRunning setBackgroundImage:[UIImage imageNamed:@"btn_start.png"] forState:UIControlStateNormal];
        selectButtonRun = FALSE;
        
        [uivLoadingProgress.layer removeAllAnimations];
        [uivLoadingProgress setHidden:YES];
        
        [self stopSensorData];
        [locationManager stopUpdatingLocation];
        
        if(myTimer)
        {
            [myTimer invalidate];
            myTimer = nil;
            
            NSLog(@"Stop Request");
        }
        
    }
    else
    {
        
//        if (![self checkField:etvBuildingName]) return;
        [btnStartRunning setBackgroundImage:[UIImage imageNamed:@"btn_stop.png"] forState:UIControlStateNormal];
        selectButtonRun = TRUE;
        
        [uivLoadingProgress setHidden:NO];
        [self rotate360WithDuration:1.0f repeatCount:0];
        

        [self initWifiData];
        [self initSensorData];
        [self initLocationManager];
        
        [self getTraceIDRequest];
    }
}

- (void) getTraceIDRequest
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        // Hide ;
        
        NSLog(@"Get TraceID : %@", _responseObject);
        
        mTraceID = _responseObject;
        [self requestSensorDataPost];
        
        myTimer = [NSTimer scheduledTimerWithTimeInterval: 30.0f target: self
                                                 selector: @selector(requestSensorDataPost) userInfo: nil repeats: YES];
        
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        // Hide ;
//        [self showAlertView:@"Failed Request." :@"Warning"];
    } ;
    
    [[Communication sharedManager] postGetTraceID:@"9" CreateAt:[self StringTimeToDate] StartX:@"3.0" StartY:@"4.0" successed: successed failure:failure];
}


- (void) requestSensorDataPost
{
   
    [self stopSensorData];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        // Hide ;
        
        NSLog(@"Request SensorData : %@", _responseObject);
        
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        // Hide ;
//        [self showAlertView:@"Failed Request." :@"Warning"];
    } ;
    
    [[Communication sharedManager] postSensorData:mTraceID DeviceID:@"9" TraceGPSData:gpsDataArray TraceWifiData:wifiDataArray TraceSensorData:sensorDataArray successed:successed failure:failure];
    
    [self refreshData];
}

- (void) refreshData
{
    [locationManager stopUpdatingLocation];
    
    [self initWifiData];
    [self initSensorData];
    
    if(gpsDataArray != nil)
    {
        gpsDataArray = nil;
    }
    gpsDataArray = [[NSMutableArray alloc] init];
    
    [locationManager startUpdatingLocation];
}

- (void) initWifiData
{
    //        CFArrayRef myArray = CNCopySupportedInterfaces();
    //        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
    
    CFArrayRef myArray = CNCopySupportedInterfaces();
    CFStringRef interfaceName = CFArrayGetValueAtIndex(myArray, 0);
    CFDictionaryRef captiveNtwrkDict = CNCopyCurrentNetworkInfo(interfaceName);
    NSDictionary *dict = (__bridge NSDictionary*) captiveNtwrkDict;
    
    //        NSLog(@"Wifi information : %@", dict);
    
    if(wifiDataArray != nil)
    {
        wifiDataArray = nil;
    }
    wifiDataArray = [[NSMutableArray alloc] init];
    
    NSMutableDictionary * dictWifiDataDetail = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * dictWifiData  = [[NSMutableDictionary alloc] init];
    
    [dictWifiDataDetail setObject:[dict objectForKey:@"SSID"] forKey:WIFIROUTENAME];
    [dictWifiDataDetail setObject:[NSString stringWithFormat:@"%@", nil] forKey:WIFIACCESSPOINTS];
    
    NSMutableArray * dictDetailsArray = [[NSMutableArray alloc] init];
    [dictDetailsArray addObject:dictWifiDataDetail];
    
    [dictWifiData setObject:dictDetailsArray forKey:TRACEWIFIDETAILS];
    [dictWifiData setObject:[self StringTimeToDate] forKey:CREATEAT];
    
    [wifiDataArray addObject:dictWifiData];
}

- (NSString *) StringTimeToDate {

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSDate * currentDate = [[NSDate alloc] init];
    
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    
    NSString * nowDateStr = [dateFormatter stringFromDate:currentDate];
    
    return nowDateStr;
}

- (void) stopSensorData
{
    [cmMotionManager stopAccelerometerUpdates];
    [cmMotionManager stopDeviceMotionUpdates];
    [cmMotionManager stopGyroUpdates];
    [cmMotionManager stopMagnetometerUpdates];
    
    
    if (sensorDataArray != nil) {
        sensorDataArray = nil;
    }
    
    sensorDataArray = [[NSMutableArray alloc] init];
    
    NSInteger sizeAccel = acceleratorArray.count;
    NSInteger sizeMagne = magnemeterArray.count;
    NSInteger sizeGyro = gyroScopeArray.count;
    NSInteger sizeOrien = orienationArray.count;
    
    NSInteger maxsize = MAX(MAX(sizeAccel, sizeMagne), MAX(sizeGyro, sizeOrien));
    
    for (int i = 0; i < maxsize; i++) {
        
        NSMutableDictionary * dictSensorData = [[NSMutableDictionary alloc] init];
        
        if (acceleratorArray.count > i ) {
            NSMutableDictionary * dictAccel = [acceleratorArray objectAtIndex:i];
            [dictSensorData setValuesForKeysWithDictionary:dictAccel];
        }
        else
        {
            NSMutableDictionary * sensorData = [[NSMutableDictionary alloc] init];
            
            [sensorData setObject:[NSString stringWithFormat:@"%@",nil] forKey:AccelerometerX];
            [sensorData setObject:[NSString stringWithFormat:@"%@",nil] forKey:AccelerometerY];
            [sensorData setObject:[NSString stringWithFormat:@"%@",nil] forKey:AccelerometerZ];
            
            [dictSensorData setValuesForKeysWithDictionary:sensorData];
        }
        if (gyroScopeArray.count > i)
        {
            NSMutableDictionary * dictAccel = [gyroScopeArray objectAtIndex:i];
            [dictSensorData setValuesForKeysWithDictionary:dictAccel];
        }
        else
        {
            NSMutableDictionary * sensorData = [[NSMutableDictionary alloc] init];
            
            [sensorData setObject:[NSString stringWithFormat:@"%@",nil] forKey:GyroscopeX];
            [sensorData setObject:[NSString stringWithFormat:@"%@",nil] forKey:GyroscopeY];
            [sensorData setObject:[NSString stringWithFormat:@"%@",nil] forKey:GyroscopeZ];
            
            [dictSensorData setValuesForKeysWithDictionary:sensorData];
        }
        if (orienationArray.count > i)
        {
            NSMutableDictionary * dictAccel = [orienationArray objectAtIndex:i];
            [dictSensorData setValuesForKeysWithDictionary:dictAccel];
        }
        else
        {
            NSMutableDictionary * sensorData = [[NSMutableDictionary alloc] init];
            
            [sensorData setObject:[NSString stringWithFormat:@"%@",nil] forKey:LinearAccelerationX];
            [sensorData setObject:[NSString stringWithFormat:@"%@",nil] forKey:LinearAccelerationY];
            [sensorData setObject:[NSString stringWithFormat:@"%@",nil] forKey:LinearAccelerationZ];
            
            [sensorData setObject:[NSString stringWithFormat:@"%@",nil] forKey:OrientationAzmuth];
            [sensorData setObject:[NSString stringWithFormat:@"%@",nil] forKey:OrientationPitch];
            [sensorData setObject:[NSString stringWithFormat:@"%@",nil] forKey:OrientationRoll];
            
            [dictSensorData setValuesForKeysWithDictionary:sensorData];
        }
        if (magnemeterArray.count > i)
        {
            NSMutableDictionary * dictAccel = [magnemeterArray objectAtIndex:i];
            [dictSensorData setValuesForKeysWithDictionary:dictAccel];
        }
        else
        {
            NSMutableDictionary * sensorData = [[NSMutableDictionary alloc] init];
            
            [sensorData setObject:[NSString stringWithFormat:@"%@",nil] forKey:MagnetometerX];
            [sensorData setObject:[NSString stringWithFormat:@"%@",nil] forKey:MagnetometerY];
            [sensorData setObject:[NSString stringWithFormat:@"%@",nil] forKey:MagnetometerZ];
            
            
            [dictSensorData setValuesForKeysWithDictionary:sensorData];
        }
        
        
        [sensorDataArray addObject:dictSensorData];
    }
    
}

- (void) initSensorData
{
    if (cmMotionManager != nil) {
        cmMotionManager = nil;
    }
    cmMotionManager = [[CMMotionManager alloc] init];
    
    // 0.01 = 1s/100 = 100Hz
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    
    if(acceleratorArray != nil)
    {
        acceleratorArray = nil;
    }
    else if(magnemeterArray != nil)
    {
        magnemeterArray = nil;
    }
    else if(gyroScopeArray != nil)
    {
        gyroScopeArray = nil;
    }
    else if(orienationArray != nil)
    {
        orienationArray = nil;
    }
    
    acceleratorArray = [[NSMutableArray alloc] init];
    orienationArray = [[NSMutableArray alloc] init];
    gyroScopeArray = [[NSMutableArray alloc] init];
    magnemeterArray = [[NSMutableArray alloc] init];
    
    if ([cmMotionManager isAccelerometerAvailable])
    {
        [cmMotionManager setAccelerometerUpdateInterval:0.01];
        [cmMotionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
            
            NSMutableDictionary * sensorData = [[NSMutableDictionary alloc] init];
            
            [sensorData setObject:[NSString stringWithFormat:@"%f",accelerometerData.acceleration.x] forKey:AccelerometerX];
            [sensorData setObject:[NSString stringWithFormat:@"%f",accelerometerData.acceleration.y] forKey:AccelerometerY];
            [sensorData setObject:[NSString stringWithFormat:@"%f",accelerometerData.acceleration.z] forKey:AccelerometerZ];
            [sensorData setObject:[self StringTimeToDate] forKey:CREATEAT];
            
            [acceleratorArray addObject:sensorData];
            
        }];
    }
    if ([cmMotionManager isGyroAvailable]) {
        /* Update us 2 times a second */
        [cmMotionManager setGyroUpdateInterval:0.01];
        
        /* Add on a handler block object */
        
        /* Receive the gyroscope data on this block */
        [cmMotionManager startGyroUpdatesToQueue:queue withHandler:^(CMGyroData *gyroData, NSError *error)
         {
             
             NSString *x = [[NSString alloc] initWithFormat:@"%f",gyroData.rotationRate.x];
             NSString *y = [[NSString alloc] initWithFormat:@"%f",gyroData.rotationRate.y];
             NSString *z = [[NSString alloc] initWithFormat:@"%f",gyroData.rotationRate.z];
             
             NSMutableDictionary * sensorData = [[NSMutableDictionary alloc] init];
             
             [sensorData setObject:x forKey:GyroscopeX];
             [sensorData setObject:y forKey:GyroscopeY];
             [sensorData setObject:z forKey:GyroscopeZ];
             
             [gyroScopeArray addObject:sensorData];
             
             
         }];
    }
    if ([cmMotionManager isMagnetometerAvailable]) {
        
        [cmMotionManager setMagnetometerUpdateInterval:0.01];
        
        [cmMotionManager startMagnetometerUpdatesToQueue: queue withHandler:^(CMMagnetometerData * motion, NSError *error) {
           
            NSString * x = [NSString stringWithFormat:@"%f",motion.magneticField.x];
            NSString * y = [NSString stringWithFormat:@"%f",motion.magneticField.y];
            NSString * z = [NSString stringWithFormat:@"%f",motion.magneticField.z];
            
            NSMutableDictionary * sensorData = [[NSMutableDictionary alloc] init];
           
            [sensorData setObject:x forKey:GyroscopeX];
            [sensorData setObject:y forKey:GyroscopeY];
            [sensorData setObject:z forKey:GyroscopeZ];
            
            [magnemeterArray addObject:sensorData];
            
            
        }];
    }
    if([cmMotionManager isDeviceMotionAvailable])
    {
        [cmMotionManager setDeviceMotionUpdateInterval:0.01];
        [cmMotionManager startDeviceMotionUpdatesToQueue:queue withHandler:^(CMDeviceMotion * Devicemotion, NSError * error){
            
            NSString * x = [NSString stringWithFormat:@"%f",Devicemotion.rotationRate.x];
            NSString * y = [NSString stringWithFormat:@"%f",Devicemotion.rotationRate.y];
            NSString * z = [NSString stringWithFormat:@"%f",Devicemotion.rotationRate.z];
            
            NSMutableDictionary * sensorData = [[NSMutableDictionary alloc] init];
            
            [sensorData setObject:x forKey:LinearAccelerationX];
            [sensorData setObject:y forKey:LinearAccelerationY];
            [sensorData setObject:z forKey:LinearAccelerationZ];
            
            NSString * pitch = [NSString stringWithFormat:@"%f",Devicemotion.attitude.pitch];
            NSString * roll = [NSString stringWithFormat:@"%f",Devicemotion.attitude.roll];
            NSString * azimuth = [NSString stringWithFormat:@"%f",Devicemotion.attitude.yaw];
            
            [sensorData setObject:pitch forKey:OrientationPitch];
            [sensorData setObject:roll forKey:OrientationRoll];
            [sensorData setObject:azimuth forKey:OrientationAzmuth];
            
            [orienationArray addObject:sensorData];
            
        }];
    }
    
}
//-(double)getWifiSignalStrength
//{
//    CFArrayRef devices = WiFiManagerClientCopyDevices(WifiManager);
//    
//    WiFiDeviceClientRef client = (WiFiDeviceClientRef)CFArrayGetValueAtIndex(devices, 0);
//    CFDictionaryRef data = (CFDictionaryRef)WiFiDeviceClientCopyProperty(client, CFSTR("RSSI"));
//    CFNumberRef scaled = (CFNumberRef)WiFiDeviceClientCopyProperty(client, kWiFiScaledRSSIKey);
//    
//    CFNumberRef RSSI = (CFNumberRef)CFDictionaryGetValue(data, CFSTR("RSSI_CTL_AGR"));
//
//    int raw;
//    CFNumberGetValue(RSSI, kCFNumberIntType, &raw);
//    
//    double strength;
//    CFNumberGetValue(scaled, kCFNumberFloatType, &strength);
//    CFRelease(scaled);
//    
//    strength *= -1;
//    
//    // Apple uses -3.0.
//    int bars = (int)ceilf(strength * -3.0f);
//    bars = MAX(1, MIN(bars, 3));
//    
//    
//    printf("WiFi signal strength: %d dBm\n\t Bars: %d\n", raw,  bars);
//    
//    CFRelease(data);
//    CFRelease(scaled);
//    CFRelease(devices);
//    return strength;
//}

#pragma textfield Delegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    
    if (textField.tag == 1000) {
        [etvBuildingFloor becomeFirstResponder];
    }
    else if (textField.tag == 1001)
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    //    CGRect textFieldRect = [textField frame];
    //    CGPoint pt = CGPointMake(0, textFieldRect.origin.y + 30 + 58);
    //    [scrollView setContentOffset:pt animated:YES];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    return YES;
}

- (BOOL)checkField : (UITextField *) textfield
{
    if(textfield.tag == 1000 && [textfield.text isEqualToString:@""])
    {
        [self showAlertView:@"Please input the building information." : @"Warning"];
        return FALSE;
    }
    return TRUE;
}

#pragma checkEmail
- ( BOOL ) checkEmail : (UITextField *) textfield
{
    BOOL            filter = YES ;
    NSString*       filterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" ;
    NSString*       laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*" ;
    NSString*       emailRegex = filter ? filterString : laxString ;
    NSPredicate*    emailTest = [ NSPredicate predicateWithFormat : @"SELF MATCHES %@", emailRegex ] ;
    
    if( [ emailTest evaluateWithObject : textfield.text ] == NO )
    {
        //        [ self showAlertView : @"The e-mail address you have entered appears to be invalid. Please enter another one." ] ;
        return NO ;
    }
    
    return YES ;
}


#pragma mark - Location ;


- ( void ) initLocationManager
{

    if (gpsDataArray != nil) {
        gpsDataArray = nil;
    }
    gpsDataArray = [[NSMutableArray alloc] init];
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone;//me
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
        
        
        if (IOS_VERSION >= 8.0) {
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
        }
        
        [self.locationManager startUpdatingLocation];
        
    } else {
        //        [SVProgressHUD showErrorWithStatus:@"Can not track your location. Please try again when you have location tracking service available."];
        [self showAlertView:@"Can not track your location. Please try again when you have location tracking service available.":@"Warning"];
    }
    
}

- ( void ) locationManager : ( CLLocationManager* ) _manager didUpdateToLocation : ( CLLocation* ) _newLocation fromLocation : ( CLLocation* ) _oldLocation
{
    self.location = _newLocation ;
//    [self.location altitude];
    
//    NSLog(@"Location Value : %f, %f, %f", _newLocation.coordinate.latitude, _newLocation.coordinate.longitude, _newLocation.altitude);

    NSMutableDictionary * gpsDataVal = [NSMutableDictionary dictionary];
    [gpsDataVal setObject:[NSString stringWithFormat:@"%f", _newLocation.coordinate.latitude] forKey:GPSLATITUDE];
    [gpsDataVal setObject:[NSString stringWithFormat:@"%f", _newLocation.coordinate.longitude] forKey:GPSLOGITUDE];
    [gpsDataVal setObject:[NSString stringWithFormat:@"%f", _newLocation.coordinate.latitude] forKey:GPSALTITUDE];
    [gpsDataVal setObject:[self StringTimeToDate] forKey:CREATEAT];
//    NSLog(@"GPS Data : %@", gpsDataVal);
    
    [gpsDataArray addObject:gpsDataVal];
    
}

- ( void ) locationManager : ( CLLocationManager* ) _manager didFailWithError : ( NSError* ) _error
{
//    NSLog( @"Invalid Postion" ) ;
}




#pragma AlertView
- (void)showAlertView : (NSString*) _message : (NSString *) title
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle : title
                                                        message : _message
                                                       delegate : self
                                              cancelButtonTitle : @"OK"
                                              otherButtonTitles : nil, nil];
    
    [alertView show];
}
@end
