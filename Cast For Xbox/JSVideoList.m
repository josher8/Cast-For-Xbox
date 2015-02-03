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
#import "AppDelegate.h"

@interface JSVideoList (){
    __weak ChromecastDeviceController *_chromecastController;
}

@end

@implementation JSVideoList

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationItem.title = @"My Game Clips";
    NSLog(@"Gamertag: %@", _gamertag);
    
    //Store a reference to the chromecast controller.
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _chromecastController = delegate.chromecastDeviceController;
    
    //Show cast icon if chromecast is available
    if (_chromecastController.deviceScanner.devices.count > 0) {
        [self showCastIcon];
    }
    
    [self retrieveData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"My Game Clips";
    
    _chromecastController.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_chromecastController updateToolbarForViewController:self];

}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

// instructions highlighting the cast icon.
- (void) showCastIcon {
    self.navigationItem.rightBarButtonItem = _chromecastController.chromecastBarButton;
    [CastInstructionsViewController showIfFirstTimeOverViewController:self];
}
- (void)didDiscoverDeviceOnNetwork {
    // Add the chromecast icon if not present.
    [self showCastIcon];
}
- (void)shouldDisplayModalDeviceController {
    [self performSegueWithIdentifier:@"listDevices" sender:self];
}
/**
 * Called when connection to the device was established.
 *
 * @param device The device to which the connection was established.
 */
- (void)didConnectToDevice:(GCKDevice *)device {
    [_chromecastController updateToolbarForViewController:self];
}

/**
 * Called when connection to the device was closed.
 */
- (void)didDisconnect {
    [_chromecastController updateToolbarForViewController:self];
}

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange {
    [_chromecastController updateToolbarForViewController:self];
}

- (void)shouldPresentPlaybackController {
    // Select the item being played in the table, so prepareForSegue can find the
    // associated Media object.
    [_chromecastController.mediaInformation.metadata stringForKey:kGCKMetadataKeyTitle];
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
    _gamertag = [_gamertag stringByReplacingOccurrencesOfString:@" " withString: @"%20"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.webjosher.net/xboxapi/index.php?gamertag=%@", _gamertag]];
    @try {
        
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
            NSURL *theLargeThumbnail;
            NSURL *theVideo;
            
            for(int i = 0; i < thumbnail.count; i++){
                if([[[thumbnail objectAtIndex:i] objectForKey:@"thumbnailType"] isEqualToString:@"Small"]){
                        theThumbnail =[NSURL URLWithString:[[thumbnail objectAtIndex:i] objectForKey:@"uri"]];
                    }
                if([[[thumbnail objectAtIndex:i] objectForKey:@"thumbnailType"] isEqualToString:@"Large"]){
                    theLargeThumbnail =[NSURL URLWithString:[[thumbnail objectAtIndex:i] objectForKey:@"uri"]];
                }
            }
            
            for(int i = 0; i < video.count; i++){
            
                if([[[video objectAtIndex:i] objectForKey:@"uriType"] isEqualToString:@"Download"]){
                    theVideo = [NSURL URLWithString:[[video objectAtIndex:i] objectForKey:@"uri"]];
                }
            }
            
            NSLog(@"the Title %@  The Thumbnail %@ the Video %@" , theTitle, theThumbnail, theVideo);
            
            //Adds all teh video information to an object in an array
            [_videoArray addObject:[[JSVideos alloc] initWithVideoName:theTitle andThumbnailUrl:theThumbnail andVideoUrl:theVideo andLargeThumbnailUrl:theLargeThumbnail]];
            
            
            }
            [self.tableView reloadData];
        }@catch (NSException *exception) {
            //Error on retrieving json feed. Go back to home
            [[[UIAlertView alloc] initWithTitle:@"Gamertag not found"
                                        message:nil
                                       delegate:nil cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            [self.navigationController popToRootViewControllerAnimated:YES];
            NSLog(@"Error: %@", exception);
        }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"segueVideo" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //set gamertag variable in the next view controller
    if ([[segue identifier] isEqualToString:@"segueVideo"] || [[segue identifier] isEqualToString:@"castMedia"] ){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        JSVideoPlayer *videoPlayer = (JSVideoPlayer *)segue.destinationViewController;
        JSVideos *videoObject = [_videoArray objectAtIndex:indexPath.row];
        
        //Send over video object to retrieve ons Video Player controller
        videoPlayer.mediaToPlay = videoObject;
    }
}

@end
