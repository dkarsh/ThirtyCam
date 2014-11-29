

#import <UIKit/UIKit.h>

@class CaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer;

@interface TCCameraView : UIView <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) float maxDuration;
@property (nonatomic,assign) BOOL showCameraSwitch;
@property (nonatomic,strong) UIProgressView *durationProgressBar;

- (id)initWithFrame:(CGRect)frame withVideoPreviewFrame:(CGRect)videoFrame;
- (void) saveVideoWithCompletionBlock:(void(^)(NSURL  *urlSuccess))completion;


@end
