//
//  FHMirrorViewController.h
//  FHMirror
//
//  Created by earth on 6/9/14.
//  Copyright (c) 2014 filmhomage.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface FHMirrorViewController : UIViewController
<AVCaptureVideoDataOutputSampleBufferDelegate,
UIScrollViewDelegate>
{
    AVCaptureSession*   _session;
    BOOL                _bPeviewMode;
    BOOL                _bFlipMode;
}

@property (weak, nonatomic) IBOutlet UIButton *buttonFlip;
@property(nonatomic, retain) UIImageView* imageView;
@property(nonatomic, retain) UIScrollView* scrollView;
@property(nonatomic, retain) UIImageView* imageViewShow;

@property(nonatomic, retain) UIToolbar* toolbar;
@end

