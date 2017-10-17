//
//  LocationHelper.h
//  ChatKeyBoard
//
//  Created by xingl on 2017/9/15.
//  Copyright © 2017年 xingl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^DidGetGeolocationsCompledBlock)(NSArray *placemarks);

@interface LocationHelper : NSObject

- (void)getCurrentGeolocationsCompled:(DidGetGeolocationsCompledBlock)compled;

@end
