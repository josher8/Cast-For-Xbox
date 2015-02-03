//
//  AppDelegate.h
//  Cast For Xbox
//
//  Created by Josher Slebodnik on 1/29/15.
//  Copyright (c) 2015 Josher. All rights reserved.
//
#import <GoogleCast/GoogleCast.h>
#import <UIKit/UIKit.h>
#import "ChromecastDeviceController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property ChromecastDeviceController* chromecastDeviceController;

@end

