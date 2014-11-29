//
//  ViewController.m
//  ThirtyCam
//
//  Created by Daniel Karsh on 11/27/14.
//  Copyright (c) 2014 bloocircle. All rights reserved.
//

#import "TCViewController.h"

#import "AmazonClientManager.h"
#import "TCCameraView.h"
#import "Cognito.h"
#import "S3.h"

@interface TCViewController ()
@property (nonatomic, strong) TCCameraView *cam;
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest1;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *myVideosButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView1;
@property (nonatomic) uint64_t file1Size;
@property (nonatomic) uint64_t file1AlreadyUpload;
@end

@implementation TCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self disableUI];
    
    [[AmazonClientManager sharedInstance] resumeSessionWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshUI];
        });
    }];
        
    self.cam = [[TCCameraView alloc]initWithFrame:self.view.frame withVideoPreviewFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.width)];
    self.cam.maxDuration = 2.0;
    self.cam.showCameraSwitch = YES;
    
    [self.view addSubview:self.cam];
    [self.view bringSubviewToFront:_loginButton];
    [self.view bringSubviewToFront:_saveButton];
    [self.view bringSubviewToFront:_myVideosButton];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(IBAction)loginClicked:(id)sender {

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self disableUI];
        [[AmazonClientManager sharedInstance] loginFromView:self.view withCompletionHandler:^(NSError *error) {
            if (error) {
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshUI];
                });
            }
        }];

}

-(IBAction)logoutClicked:(id)sender {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self disableUI];
    [[AmazonClientManager sharedInstance] logoutWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshUI];
        });
    }];
}



-(void)disableUI {
    self.loginButton.enabled = NO;
}

-(void)refreshUI {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    //    self.browseDataButton.enabled = YES;
    self.loginButton.enabled = NO;
    if ([[AmazonClientManager sharedInstance] isLoggedIn]) {
        _loginButton.hidden = YES;
        _saveButton.hidden = NO;
    
    }
    else {
        _loginButton.hidden = NO;
        _saveButton.hidden = YES;
        [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
    }
    _loginButton.enabled = YES;
}


-(IBAction)saveVideo:(id)sender
{
    AWSCognito *syncClient = [AWSCognito defaultCognito];
    AWSCognitoDataset *dataset = [syncClient openOrCreateDataset:@"myDataset"];
    
    time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
    NSString *str = [NSString stringWithFormat:@"%@_%ld.mov",[dataset stringForKey:@"myObjectID"],unixTime];
   
    AWSCognitoDataset *videoset = [[AWSCognito defaultCognito] openOrCreateDataset:str];
//    [videoset setValue:TCVideoStatusNotSaved forKey:@"videoStatus"];
//    [videoset synchronize];
    
    [self.cam saveVideoWithCompletionBlock:^(NSURL *urlSuccess) {
        if (urlSuccess) {
            [self uploadThis:urlSuccess setLocationName:str];
        }else{
            // video fail to save localy
        }
    }];
}

- (void)uploadThis:(NSURL*)url setLocationName:(NSString*)location
{
    [self cleanProgress];
    
    __weak typeof(self) weakSelf = self;
    

    
    self.uploadRequest1 = [AWSS3TransferManagerUploadRequest new];
    self.uploadRequest1.bucket = S3BucketName;
    self.uploadRequest1.key = location;
    self.uploadRequest1.body = url;
    self.uploadRequest1.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.file1Size = totalBytesExpectedToSend;
            weakSelf.file1AlreadyUpload = totalBytesSent;
            [weakSelf updateProgress];
        });
    };
    _cam.durationProgressBar.progressTintColor = [UIColor blueColor];
    [self uploadFiles];
}

- (void)updateProgress {
    
    if (self.file1AlreadyUpload <= self.file1Size)
    {
        _cam.durationProgressBar.progress = 1-(float)self.file1AlreadyUpload / (float)self.file1Size;
    }
}


- (void) uploadFiles {
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:self.uploadRequest1] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error != nil) {
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused)
            {
            //  video fail to upload s3
            }
        } else {
            self.uploadRequest1 = nil;
            // StatusLabelCompleted;
        }
        return nil;
    }];
    
}
- (void) cleanProgress {
    self.progressView1.progress = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
