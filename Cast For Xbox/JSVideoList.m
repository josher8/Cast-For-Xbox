//
//  JSVideoList.m
//  Cast For Xbox
//
//  Created by Josher Slebodnik on 2/1/15.
//  Copyright (c) 2015 Josher. All rights reserved.
//

#import "JSVideoList.h"
#import "JSVideos.h"
#import "SimpleImageFetcher.h"
#import "JSVideoPlayer.h"

@interface JSVideoList ()

@end

@implementation JSVideoList

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationItem.title = @"My Game Clips";
    NSLog(@"Gamertag: %@", _gamertag);
    [self retrieveData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"My Game Clips";
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_videoArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];

    
    
//    // Configure the cell...
    JSVideos *videoObject = [_videoArray objectAtIndex:indexPath.row];


    UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
    titleLabel.text = videoObject.titleName;
    
    UIImageView *mediaThumb = (UIImageView *)[cell viewWithTag:1];
    UIImage *defaultImage = [UIImage imageNamed:@"xboxonelogo"];
    [mediaThumb setImage:defaultImage];
    
    // Asynchronously load the table view image
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(queue, ^{
        UIImage *image = [UIImage imageWithData:[SimpleImageFetcher getDataFromImageURL:videoObject.thumbnailUrl]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [mediaThumb setImage:image];
            [cell setNeedsLayout];
        });
    });

    
    return cell;
}


-(void) retrieveData
{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.webjosher.net/xboxapi/index.php?gamertag=%@", _gamertag]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    _jsonArray = [NSJSONSerialization JSONObjectWithData:data options: kNilOptions error: nil];
    _videoArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *thumbnail = [[NSMutableArray alloc] init];
    NSMutableArray *video = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < _jsonArray.count; i++)
    {
        thumbnail = [[_jsonArray objectAtIndex:i]  valueForKey:@"thumbnails"];
        video = [[_jsonArray objectAtIndex:i]  valueForKey:@"gameClipUris"];
        NSString *theTitle = [[_jsonArray objectAtIndex:i] objectForKey:@"titleName"];
        NSURL *theThumbnail;
        NSURL *theVideo;
        
        for(int i = 0; i < thumbnail.count; i++){
            if([[[thumbnail objectAtIndex:i] objectForKey:@"thumbnailType"] isEqualToString:@"Small"]){
                    theThumbnail =[NSURL URLWithString:[[thumbnail objectAtIndex:i] objectForKey:@"uri"]];
                }
        }
        
        for(int i = 0; i < video.count; i++){
        
            if([[[video objectAtIndex:i] objectForKey:@"uriType"] isEqualToString:@"Download"]){
                theVideo = [NSURL URLWithString:[[video objectAtIndex:i] objectForKey:@"uri"]];
            }
        }
        
        NSLog(@"the Title %@  The Thumbnail %@ the Video %@" , theTitle, theThumbnail, theVideo);

        
        
        [_videoArray addObject:[[JSVideos alloc] initWithVideoName:theTitle andThumbnailUrl:theThumbnail andVideoUrl:theVideo]];
        
        
        }
    [self.tableView reloadData];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"segueVideo" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //set gamertag variable in the next view controller
    if ([[segue identifier] isEqualToString:@"segueVideo"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        JSVideoPlayer *videoPlayer = (JSVideoPlayer *)segue.destinationViewController;
        JSVideos *videoObject = [_videoArray objectAtIndex:indexPath.row];
        
        videoPlayer.videoUrl = videoObject.videoUrl;
        videoPlayer.thumbnailUrl = videoObject.thumbnailUrl;
        videoPlayer.videoTitle = videoObject.titleName;
    }
}

@end
