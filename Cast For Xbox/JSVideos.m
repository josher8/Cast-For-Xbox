//
//  JSVideos.m
//  Cast For Xbox
//
//  Created by Josher Slebodnik on 2/1/15.
//  Copyright (c) 2015 Josher. All rights reserved.
//

#import "JSVideos.h"

@implementation JSVideos

-(id)initWithVideoName:(NSString *)titleName andThumbnailUrl:(NSURL *)thumbnailUrl andVideoUrl:(NSURL *)videoUrl
{
    self =[super init];
    if(self)
    {
        _titleName = titleName;
        _thumbnailUrl = thumbnailUrl;
        _videoUrl = videoUrl;
    }
    
    return self;
    
}

@end
