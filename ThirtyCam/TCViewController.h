//
//  ViewController.h
//  ThirtyCam
//
//  Created by Daniel Karsh on 11/27/14.
//  Copyright (c) 2014 bloocircle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCCameraView.h"


typedef NS_ENUM(NSUInteger, TCVideoStatus) {
  
    TCVideoStatusNotSaved   = 0,

    TCVideoStatusSaved  = 1,

    TCVideoStatusStartUpload = 2,

    TCVideoStatusFailUpload  = 3,

    TCVideoStatusUploadDone = 4,
    
    TCVideoStatusSharedFail = 5,
    
    TCVideoStatusSharedFB
};


@interface TCViewController : UIViewController



@end

