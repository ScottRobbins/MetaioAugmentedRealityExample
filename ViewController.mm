//
//  ViewController.m
//  MetaioAugmentedRealityExample
//
//  Created by Samuel Scott Robbins on 10/21/14.
//  Copyright (c) 2014 Scott Robbins. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()

@end

@implementation ViewController
@synthesize mpPlayer;

- (void)viewDidLoad {
    [super viewDidLoad];

    moviePaused = false;
    trackingOpen = 0; // reset tracking, none found

    [self loadTrackingConfigurationFiles];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    trackingOpen = 0;
}

- (void) loadTrackingConfigurationFiles
{
    NSLog(@"Starting to load tracking files");
    
    // Load the tracking configuration file
    NSString* markerlessTrackingFile = [[NSBundle mainBundle] pathForResource:@"markerless_tracking" ofType:@"xml" inDirectory:@"tracking"];
    
    if(markerlessTrackingFile) {
        bool success = m_metaioSDK->setTrackingConfiguration([markerlessTrackingFile UTF8String]);
        if (!success)
            NSLog(@"No success loading the tracking configuration");
        else
            NSLog(@"Loaded tracking xml file correctly");
    } else {
        NSLog(@"Error Loading the tracking configuration file");
    }
}

-(void)onTrackingEvent:(const metaio::stlcompat::Vector<metaio::TrackingValues> &)poses
{
    if (poses.size() > 0) {
        metaio::TrackingValues pose = poses[0];
        if (pose.isTrackingState()) {  // Marker is detected.
            if (pose.coordinateSystemID != trackingOpen && !(mpPlayer.playbackState == MPMoviePlaybackStatePlaying)) {
                //  remove all textures and possible additional views
                moviePaused = false;
                if(m_moviePlane)
                {
                    m_moviePlane->pauseMovieTexture();
                    m_moviePlane->setVisible(false);
                    m_moviePlane->removeMovieTexture();
                }
                
                // now remove scrollview
                for (UIView *subview in self.view.subviews)
                {
                    if([subview isKindOfClass: [UIScrollView class]])
                        [subview removeFromSuperview];
                }
                
                if(m_imagePlane)
                {
                    m_imagePlane->setVisible(false);
                }
                
                if (m_metaioMan)
                {
                    m_metaioMan->setVisible(false);
                }
                
                // disable tap gesture recognizer
                for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers){
                    if ([recognizer isKindOfClass:[UITapGestureRecognizer class]])
                        recognizer.enabled = NO;
                }
                
                trackingOpen = pose.coordinateSystemID;
                
                // parse out id from xml file MarkerlessCos name
                [self showSupplementalMediaWithCosID:pose.coordinateSystemID];
                
            } else if(m_moviePlane || m_imagePlane || m_metaioMan) {
                if (m_moviePlane &&  m_moviePlane->getCoordinateSystemID() == pose.coordinateSystemID) {
                    m_moviePlane->setVisible(true);
                    m_moviePlane->startMovieTexture(true);
                    
                    if (m_imagePlane) {
                        m_imagePlane->setVisible(false);
                    }
                }
                else if (m_imagePlane && m_imagePlane->getCoordinateSystemID() == pose.coordinateSystemID)
                {
                    // enable tap gesture recognizer (for imageView)
                    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers){
                        if ([recognizer isMemberOfClass:[UITapGestureRecognizer class]])
                            recognizer.enabled = YES;
                    }
                    
                    m_imagePlane->setVisible(true);
                    if (m_moviePlane)
                    {
                        m_moviePlane->setVisible(false);
                        m_moviePlane->removeMovieTexture();
                    }
                    
                }
                else if (m_metaioMan && m_metaioMan->getCoordinateSystemID() == pose.coordinateSystemID)
                {
                    if (m_imagePlane)
                    {
                        m_imagePlane->setVisible(false);
                    }
                    
                    if (m_moviePlane)
                    {
                        m_moviePlane->setVisible(false);
                        m_moviePlane->removeMovieTexture();
                    }
                    
                    m_metaioMan->setVisible(true);
                }
            }
        }
        else {  // Marker is lost
            //removeFromSuperView
            if(m_moviePlane)
            {
                m_moviePlane->pauseMovieTexture();
                moviePaused = true;
            }
            if (m_imagePlane)
            {
                // ImagePlane will not be visible at the same time the image view is
                if(m_imagePlane->isVisible())
                    // disable tap gesture recognizer (for imageView)
                    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers){
                        if ([recognizer isMemberOfClass:[UITapGestureRecognizer class]])
                            recognizer.enabled = NO;
                    }
            }
        }
    }
}

- (void)showSupplementalMediaWithCosID:(int)cosID
{
    switch (cosID) {
        case 1:
            [self showClippyOnCosID:cosID];
            break;
        case 2:
            [self showTransparentVideoOnCosID:cosID];
            break;
        case 3:
            [self showGoogleWebPage];
            break;
        case 4:
            [self show3DFigureOnCosID:cosID];
            break;
        default:
            break;
    }
}

- (void)showClippyOnCosID:(int)cosID
{
    NSString *clippyImage = [[NSBundle mainBundle] pathForResource:@"clippy" ofType:@"jpg" inDirectory:@"tracking"];
    if(m_imagePlane)
    {
        m_imagePlane->removeMovieTexture();
    }
    m_imagePlane =  m_metaioSDK->createGeometryFromImage([clippyImage UTF8String]);
    if(m_imagePlane)
    {
        m_imagePlane->setCoordinateSystemID(cosID);
        m_imagePlane->setScale(metaio::Vector3d(4.0,4.0,4.0));
        m_imagePlane->setVisible(true);
    }
    else
    {
        NSLog(@"Error: could not load image plane");
    }

}

- (void)showTransparentVideoOnCosID:(int)cosID
{
    NSString *movie = [[NSBundle mainBundle] pathForResource:@"clippy" ofType:@"jpg" inDirectory:@"tracking"];
    if(m_moviePlane)
        m_moviePlane->removeMovieTexture();
    m_moviePlane =  m_metaioSDK->createGeometryFromMovie([movie UTF8String], true); // true for transparent movie
    if(m_moviePlane)
    {
        m_moviePlane->setCoordinateSystemID(cosID);
        m_moviePlane->setScale(metaio::Vector3d(4.0,4.0,4.0));
        m_moviePlane->setRotation(metaio::Rotation(metaio::Vector3d(0, 0, 0)));
        m_moviePlane->setVisible(true);
        
        if (!moviePaused)
            m_moviePlane->startMovieTexture(true); // false for do not loop video
    }
    else
    {
        NSLog(@"Error: could not load movie planes");
    }
}

- (void)showGoogleWebPage
{
    WebViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    viewController.url = @"https://www.google.com/doodles/";
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)show3DFigureOnCosID:(int)cosID
{
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"metaioman" ofType:@"md2" inDirectory:@"tracking"];
    // if this call was successful, theLoadedModel will contain a pointer to the 3D model
    if(m_metaioMan)
        m_metaioMan->removeMovieTexture();
    
    m_metaioMan =  m_metaioSDK->createGeometry([modelPath UTF8String]);
    
    if( m_metaioMan )
    {
        // scale it a bit up
        m_metaioMan->setCoordinateSystemID(cosID);
        m_metaioMan->setScale(metaio::Vector3d(4.0f,4.0f,4.0f));
       // m_metaioMan->setVisible(true);
    }
    else
    {
        NSLog(@"error, could not load %@", modelPath);
    }
}



@end
