//
//  FHMirrorViewController.m
//  FHMirror
//
//  Created by earth on 6/9/14.
//  Copyright (c) 2014 filmhomage.net. All rights reserved.
//

#import "FHMirrorViewController.h"

@interface FHMirrorViewController ()

@end

@implementation FHMirrorViewController


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self viewSubviewLoad];
    [self prepareVideo];
}

- (void)viewSubviewLoad
{
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.view.backgroundColor = [UIColor clearColor];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.delegate = self;
    self.scrollView.hidden = YES;
    
    self.scrollView.clipsToBounds = YES;
    self.scrollView.autoresizesSubviews = YES;
    self.scrollView.multipleTouchEnabled = YES;
    self.scrollView.maximumZoomScale = 8.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.zoomScale = 1.0;
    
    self.imageViewShow = [[UIImageView alloc]initWithFrame:self.view.frame];
    self.imageViewShow.backgroundColor = [UIColor clearColor];
    self.imageViewShow.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.scrollView addSubview:self.imageViewShow];
    [self.view addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    [self initToolbar];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapGesture:)];
    [tap setNumberOfTapsRequired:1];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
}

-(void)initToolbar
{
    self.toolbar = [[ UIToolbar alloc ] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44, 320, 44)];
    [self.view addSubview:self.toolbar];
    
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* flip = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                          target:self
                                                                          action:@selector(flip:)];
    
    UIBarButtonItem* pause = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                                                                           target:self
                                                                           action:@selector(pause:)];
    
    UIBarButtonItem* share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                           target:self
                                                                           action:@selector(share:)];
    
    NSArray* itemsArray = [NSArray arrayWithObjects:flip, flexible, pause, flexible, share,nil];
    [self.toolbar setItems:itemsArray animated:YES];
    self.toolbar.alpha = 1.0f;
}

-(void)toolbarSet:(BOOL)pause
{
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.toolbar.items];
    
    if(pause)
    {
        UIBarButtonItem* play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                              target:self
                                                                              action:@selector(play:)];
        [newItems  replaceObjectAtIndex:2 withObject:play];
    }
    else
    {
        UIBarButtonItem* pause = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                                                                               target:self
                                                                               action:@selector(pause:)];
        [newItems  replaceObjectAtIndex:2 withObject:pause];
    }
    
    self.toolbar.items = newItems;
}

-(IBAction)flip:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    
    [self changeFilp:nil];
}

-(IBAction)play:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    
    [self didTapGesture:nil];
}

-(IBAction)pause:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    
    [self didTapGesture:nil];
}

-(IBAction)share:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
}

- (AVCaptureDevice *)frontCamera
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == AVCaptureDevicePositionFront)
        {
            return device;
        }
    }
    return nil;
}

- (void)prepareVideo
{
    AVCaptureDevice* device = [self frontCamera];
    AVCaptureDeviceInput*   deviceInput;
    deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
    NSMutableDictionary*        settings;
    AVCaptureVideoDataOutput*   dataOutput;
    settings = [NSMutableDictionary dictionary];
    [settings setObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    dataOutput.videoSettings = settings;
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    _session = [[AVCaptureSession alloc] init];
    [_session addInput:deviceInput];
    [_session addOutput:dataOutput];
    _session.sessionPreset = AVCaptureSessionPresetHigh;
    
    [_session startRunning];
}

//--------------------------------------------------------------//
#pragma mark -- AVCaptureVideoDataOutputSampleBufferDelegate --
//--------------------------------------------------------------//
- (void)captureOutput:(AVCaptureOutput*)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection*)connection
{
    CVImageBufferRef    buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(buffer, 0);
    
    uint8_t*    base;
    size_t      width, height, bytesPerRow;
    base = CVPixelBufferGetBaseAddress(buffer);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    CGColorSpaceRef colorSpace;
    CGContextRef    cgContext;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cgContext = CGBitmapContextCreate(base,
                                      width,
                                      height,
                                      8,
                                      bytesPerRow,
                                      colorSpace,
                                      kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    CGImageRef  cgImage = CGBitmapContextCreateImage(cgContext);
    UIImage*    image = [UIImage imageWithCGImage:cgImage scale:1.0f orientation:UIImageOrientationRight];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    
    self.imageView.image = image;
    self.imageView.transform = CGAffineTransformIdentity;
    
    if(_bFlipMode)
    {
        self.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    }
}

- (void)didTapGesture:(UITapGestureRecognizer*)sender
{
    NSLog(@"%s", __FUNCTION__);
    
    CGPoint touchPoint = [sender locationInView:self.view];
    BOOL bIntersects = CGRectIntersectsRect(CGRectMake(touchPoint.x, touchPoint.y, 1, 1), self.toolbar.frame);
    if(bIntersects)
    {
        return;
    }
    
    
    if(_bPeviewMode == NO)
    {
        self.scrollView.frame = self.view.frame;
        self.imageViewShow.frame = self.view.frame;
        
        self.imageView.hidden = YES;
        self.imageViewShow.image = self.imageView.image;
        self.scrollView.hidden = NO;
        if(_bFlipMode)
        {
            self.imageViewShow.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
        [self.view bringSubviewToFront:self.scrollView];
        
        
        [self toolbarSet:YES];
        [self.view bringSubviewToFront:self.toolbar];
        
        [self updateImageViewSize];
        [self updateImageViewOrigin];
    }
    else
    {
        self.imageView.hidden = NO;
        self.scrollView.hidden = YES;
        self.scrollView.zoomScale = 1.0;
        
        self.imageViewShow.transform = CGAffineTransformIdentity;
        [self.view bringSubviewToFront:self.imageView];
        
        [self toolbarSet:NO]; // puase
        [self.view bringSubviewToFront:self.toolbar];
    }
    
    _bPeviewMode = !_bPeviewMode;
}

- (IBAction)changeFilp:(id)sender
{
    _bFlipMode = !_bFlipMode;
}


//--------------------------------------------------------------//
#pragma mark -- Pause Image Zoom Process --
//--------------------------------------------------------------//
- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView
{
    return self.imageViewShow;
}

- (void)updateImageViewSize
{
    CGSize  imageSize = self.imageViewShow.image.size;
    CGRect  bounds = self.scrollView.bounds;
    CGRect  rect;
    
    rect.origin = CGPointZero;
    if (imageSize.width / imageSize.height > CGRectGetWidth(bounds) / CGRectGetHeight(bounds))
    {
        rect.size.width = CGRectGetWidth(bounds);
        rect.size.height = floor(imageSize.height / imageSize.width * CGRectGetWidth(rect));
    }
    else
    {
        rect.size.height = CGRectGetHeight(bounds);
        rect.size.width = imageSize.width / imageSize.height * CGRectGetHeight(rect);
    }
    
    self.imageViewShow.frame = rect;
}

- (void)updateImageViewOrigin
{
    CGRect  rect = self.imageViewShow.frame;
    rect.origin = CGPointZero;
    
    CGRect  bounds = self.scrollView.bounds;
    
    if (CGRectGetWidth(rect) < CGRectGetWidth(bounds))
    {
        rect.origin.x = floor((CGRectGetWidth(bounds) - CGRectGetWidth(rect)) * 0.5f);
    }
    if (CGRectGetHeight(rect) < CGRectGetHeight(bounds))
    {
        rect.origin.y = floor((CGRectGetHeight(bounds) - CGRectGetHeight(rect)) * 0.5f);
    }
    self.imageViewShow.frame = rect;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //    self.toolbar.alpha = 0.0f;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    //    self.toolbar.alpha = 1.0f;
}

- (void)scrollViewDidZoom:(UIScrollView*)scrollView
{
    [self updateImageViewOrigin];
}

@end
