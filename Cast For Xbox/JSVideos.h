//
//  JSVideos.h
//  Cast For Xbox
//
//  Created by Josher Slebodnik on 2/1/15.
//  Copyright (c) 2015 Josher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSVideos : NSObject
@property (strong,nonatomic) NSString *titleName;
@property (strong,nonatomic) NSURL *thumbnailUrl;
@property (strong,nonatomic) NSURL *videoUrl;

-(id)initWithVideoName: (NSString *)titleName andThumbnailUrl:(NSURL *)thumbnailUrl andVideoUrl:(NSURL *)videoUrl;

@end
