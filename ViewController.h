//
//  ViewController.h
//  MetaioAugmentedRealityExample
//
//  Created by Samuel Scott Robbins on 10/21/14.
//  Copyright (c) 2014 Scott Robbins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaioSDKViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "EAGLView.h"

@interface ViewController : MetaioSDKViewController
{
    int trackingOpen;
    metaio::IGeometry*	m_moviePlane;
    metaio::IGeometry*	m_imagePlane;
    metaio::IGeometry*	m_metaioMan;
    bool moviePaused;
}

@property (nonatomic, strong) MPMoviePlayerController *mpPlayer;
@property (strong, nonatomic) NSString *pictureFileLocation;
@property (strong, nonatomic) UIImageView *imageView;

@end

