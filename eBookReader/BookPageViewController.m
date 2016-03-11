//
//  BookPageViewController.m
//  eBookReader
//
//  Created by Shang Wang on 6/19/14.
//  Copyright (c) 2014 Andreea Danielescu. All rights reserved.
//

#import "BookPageViewController.h"
#import "LogFileController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "NodeCell.h"
#import "ConceptLink.h"
#import "PreViewNode.h"
#import "VideoViewController.h"
@interface BookPageViewController ()

@end
@implementation BookPageViewController
@synthesize bookView;
@synthesize cmapView;
@synthesize restClient;
@synthesize logWrapper;
@synthesize QA;
@synthesize bulbImageView;
@synthesize ShowingQA;
@synthesize userName;
@synthesize enableHyperLink;
@synthesize totalCountdownInterval;
@synthesize remainTime;
@synthesize startDate;
@synthesize timerLable;
@synthesize previewImg;
@synthesize upperBorder;
@synthesize isShowPreView;
@synthesize conceptNodeArray;
@synthesize PreviewRect;
@synthesize  originalFrame;
@synthesize isSecondShow;
@synthesize CmapTimer;
@synthesize videoView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
        logWrapper= [LogDataParser loadLogData];
        ShowingQA=true;
        conceptNodeArray=[[NSMutableArray alloc] init];
        
    }
    return self;
}

-(void)test{
    NSLog(@"Test");
}


-(void)addSwitchView{
    
    bulbImageView = [[UIImageView alloc]initWithFrame:CGRectMake(498, 350, 30, 30)];
    [bulbImageView setImage:[UIImage imageNamed:@"switch.png"]];
    //bulbImageView.alpha=0.8;
    bulbImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *bulbTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickOnBulb:)];
    
    [self.bulbImageView addGestureRecognizer:bulbTap];
    
    [self.view addSubview:bulbImageView];
    [bulbImageView setHidden:YES];
    bulbImageView.layer.shadowOpacity = 0.4;
    bulbImageView.layer.shadowRadius = 4;
    bulbImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    bulbImageView.layer.shadowOffset = CGSizeMake(2, 2);
    
}

- (IBAction)clickOnBulb : (id)sender
{
    if(ShowingQA){
        [self.view bringSubviewToFront:cmapView.view];
        [cmapView loadConceptMap:nil];
        
        ShowingQA=false;
    }else{
        [self.view bringSubviewToFront:QA.view];
        ShowingQA=true;
    }
    [self.view bringSubviewToFront:bulbImageView];
    
}


- (IBAction)QAonConcpet
{
    if(ShowingQA){
        [self.view bringSubviewToFront:cmapView.view];
        [cmapView loadConceptMap:nil];
        
        ShowingQA=false;
    }else{
        [self.view bringSubviewToFront:QA.view];
        ShowingQA=true;
    }
    [self.view bringSubviewToFront:bulbImageView];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.delegate = self;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"See Tutorial"
                                                                   style:UIBarButtonItemStyleDone target:self action:@selector(showTutorial)];
    self.navigationItem.rightBarButtonItem = leftButton;

    //[self.navigationItem setHidesBackButton:YES animated:YES];
    
   // [self.parentViewController.navigationController.navigationBar setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self // put here the view controller which has to be notified
                                             selector:@selector(orientationChanged:)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
    
    
    //[self.navigationController setNavigationBarHidden:YES];
    // self.navigationController.navigationBar.translucent = NO;
    //self.parentViewController.navigationController.navigationBar.translucent = YES;
    // self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    // [ self.parentViewController.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    // Do any additional setup after loading the view from its nib.
    [self createCmapView];
    //[self createQA];
    //[self addSwitchView];
    bookView.parent_BookPageViewController=self;
    bookView.logWrapper=logWrapper;
    //[self splitScreen];
    if( ([[UIApplication sharedApplication] statusBarOrientation]==UIInterfaceOrientationLandscapeLeft)||([[UIApplication sharedApplication] statusBarOrientation]==UIInterfaceOrientationLandscapeRight)){
        [self splitScreen];
    }
    upperBorder = [CALayer layer];
   // [self.view bringSubviewToFront:cmapView.toolBar];
    //[self.view bringSubviewToFront:previewImg];
    [self.view sendSubviewToBack:bookView.view];
    [self.view bringSubviewToFront:previewImg];
    NSString* isPreview=[[NSUserDefaults standardUserDefaults] stringForKey:@"isPreview"];
    
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if( (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)&&[isPreview isEqualToString:@"YES"])
    {
        [previewImg setHidden:NO];
        [PreviewRect setHidden:NO];

    }else{
        [previewImg setHidden:YES];
        [PreviewRect setHidden:YES];
        
    }
    /*
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        if([isPreview isEqualToString:@"NO"]){
            [previewImg setHidden:YES];
            [PreviewRect setHidden:YES];
        }
        else{
            [previewImg setHidden:NO];
            [PreviewRect setHidden:NO];
            
        }
    }else{
        [previewImg setHidden:NO];
        [PreviewRect setHidden:NO];
        
    }*/

    
    
    /* [cmapView loadConceptMap:nil];
       NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkCountdown:) userInfo:nil repeats:YES];
     QuizViewController *quiz=[[QuizViewController alloc] initWithNibName:@"ViewController" bundle:nil];
     quiz.isFinished=false;
     quiz.userName=userName;
     quiz.bookLogDataWrapper=logWrapper;
     quiz.testType=0;//pre test
     quiz.parentBookPageViewController=self;
     [self.navigationController pushViewController:quiz animated:YES];
     */
  
    if([isPreview isEqualToString:@"YES"]){
    
     UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
     panGesture.delegate=self;
     [previewImg addGestureRecognizer:panGesture];
     [previewImg setUserInteractionEnabled:YES];
     
     PreviewRect= [[UIView alloc] initWithFrame:CGRectMake(2,2,previewImg.frame.size.width-4,previewImg.frame.size.height-4)];
     PreviewRect.backgroundColor=[UIColor clearColor];
     PreviewRect.layer.borderColor = [UIColor redColor].CGColor;
     PreviewRect.tag=1;
     PreviewRect.layer.borderWidth = 1.0f;
     originalFrame=PreviewRect.frame;
     [previewImg addSubview:PreviewRect];
    }
    // [self splitScreen];
    
}


- (void)orientationChanged:(NSNotification *)notification{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    
    
    
    //when retating the device, clear the thumbnail icons and reload
    if(orientation==UIInterfaceOrientationPortrait||orientation==UIInterfaceOrientationPortraitUpsideDown){
        
        [self resumeNormalScreen ];
    }
    //otherwise, hide the concept map view.
    if(orientation==UIInterfaceOrientationLandscapeLeft||orientation==UIInterfaceOrientationLandscapeRight){
        [self splitScreen];
    }
    //do stuff
    NSLog(@"Orientation changed");
}

-(void)viewWillAppear:(BOOL)animated{
    [self.view bringSubviewToFront:previewImg];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(orientation==UIInterfaceOrientationLandscapeLeft&&orientation==UIInterfaceOrientationLandscapeRight){
        [self splitScreen];
    }
}





-(void)viewDidAppear:(BOOL)animated{

    
    NSString* istest=[[NSUserDefaults standardUserDefaults] stringForKey:@"testMode"];
    if(![istest isEqualToString:@"YES"]){
        
        if(!isSecondShow){
            QuizViewController *quiz=[[QuizViewController alloc] initWithNibName:@"QuizViewController" bundle:nil];
            quiz.isFinished=false;
            quiz.userName=userName;
            quiz.bookLogDataWrapper=logWrapper;
            quiz.testType=0;//pre test
            quiz.parentBookPageViewController=self;
            [self.navigationController pushViewController:quiz animated:NO];
            isSecondShow=YES;
        }
        
    }
    /*
     self.parentViewController.navigationController.navigationBar.translucent = YES;
     self.navigationController.navigationBar.translucent = YES;
     [ self.parentViewController.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
     [ self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
     [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
     forBarMetrics:UIBarMetricsDefault];
     self.navigationController.navigationBar.shadowImage = [UIImage new];
     self.navigationController.navigationBar.translucent = YES;
     
     [self.navigationController.navigationBar setFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, 30)];*/
    // [self.navigationController.navigationBar setFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, 40)];
    
}


-(void)startTimer{
    totalCountdownInterval=140;
    //totalCountdownInterval=8;
    startDate = [NSDate date];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkTutorialCountdown:) userInfo:nil repeats:YES];
    });
    
}



-(void)startCmapTimer{
    totalCountdownInterval=1200;
    //totalCountdownInterval=2;
    startDate = [NSDate date];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Finish"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(showEndAlert)];
    self.navigationItem.rightBarButtonItem = rightButton;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"See Tutorial"
                                                                   style:UIBarButtonItemStyleDone target:self action:@selector(showTutorial)];
    self.navigationItem.leftBarButtonItem = leftButton;
    CmapTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkCmapCountdown:) userInfo:nil repeats:YES];
    
    
}


-(void)showTutorial{
    VideoViewController *tutorial= [[VideoViewController alloc]initWithNibName:@"VideoViewController" bundle:nil];
    tutorial.hideImg=YES;
    ///[tutorial.teachImg removeFromSuperview];
    [self.navigationController pushViewController:tutorial animated:NO];
}



-(void)showEndAlert{
    LogData* newlog= [[LogData alloc]initWithName:userName SessionID:@"session_id" action:@"attenping to finish concept mapping session" selection:@"concept map view" input:@"" pageNum:@"0"];
    [logWrapper addLogs:newlog];
    [LogDataParser saveLogData:logWrapper];
    
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:startDate];
    if( (int)elapsedTime<600   ){
        LogData* newlog= [[LogData alloc]initWithName:userName SessionID:@"session_id" action:@"Deny finish concept map session due to insufficient time spent" selection:@"concept map view" input:@"" pageNum:@"0"];
        [logWrapper addLogs:newlog];
        [LogDataParser saveLogData:logWrapper];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Warning"
                              message:@"Please spend at least 10 minutes in this session"
                              delegate:self // <== changed from nil to self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil];
        [alert show];
    }else{
        
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Warning"
                              message:@"Do you want to finish this session?"
                              delegate:self // <== changed from nil to self
                              cancelButtonTitle:@"NO"
                              otherButtonTitles:@"YES", nil];
        [alert show];
    }
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 0) {
        // do something here...
    }
    if (buttonIndex == 1) {
        LogData* newlog= [[LogData alloc]initWithName:userName SessionID:@"session_id" action:@"Student finish concept mapping view" selection:@"concept map view" input:@"" pageNum:@"0"];
        [logWrapper addLogs:newlog];
        [LogDataParser saveLogData:logWrapper];
        
        [cmapView uploadCmapCocneptAddedList];
        
        [self goToPostTest];
        // do something here...
    }
}

-(void)goToPostTest{
    
    [CmapTimer invalidate];
    [cmapView LogStudentMapNum];
    QuizViewController *quiz=[[QuizViewController alloc] initWithNibName:@"QuizViewController" bundle:nil];
    quiz.isFinished=false;
    quiz.parentBookPageViewController=self;
    quiz.testType=1; //post test
    quiz.userName=userName;
    quiz.bookLogDataWrapper=logWrapper;
    [self.navigationController pushViewController:quiz animated:YES];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)createCmapView{
    cmapView=[[CmapController alloc] initWithNibName:@"CmapView" bundle:nil];
    cmapView.userName=userName;
    cmapView.bookLogDataWrapper=logWrapper;
    cmapView.showType=1;
    cmapView.enableHyperLink=enableHyperLink;
    cmapView.parentBookPageViewController=self;
    cmapView.neighbor_BookViewController=self.bookView;
    [self addChildViewController:cmapView];
    [self.view addSubview:cmapView.view];
    [cmapView.view setUserInteractionEnabled:YES];
    cmapView.view.center=CGPointMake(768, 384);
    [cmapView.view setHidden:YES];
}

-(void)createQA{
    QA=[[QAViewController alloc] initWithNibName:@"QAViewController" bundle:nil];
    [self addChildViewController:QA];
    [self.view addSubview:QA.view];
    [QA.view setUserInteractionEnabled:YES];
    QA.view.center=CGPointMake(768, 384);
    [QA.view setHidden:YES];
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    /*
     //when retating the device, clear the thumbnail icons and reload
     if(fromInterfaceOrientation==UIInterfaceOrientationPortrait||fromInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown){
     [self splitScreen];
     }
     //otherwise, hide the concept map view.
     if(fromInterfaceOrientation==UIInterfaceOrientationLandscapeLeft||fromInterfaceOrientation==UIInterfaceOrientationLandscapeRight){
     [self resumeNormalScreen ];
     }*/
}



-(void)splitScreen{
    CGRect rec=CGRectMake(0, 0, 512, 768);
    [bookView.view setFrame:rec];
    [cmapView.view setHidden:NO];
    [QA.view setHidden:NO];
    [bulbImageView setHidden:NO];
    LogFileController *logFile=[[LogFileController alloc]init];
    [logFile writeToTextFile:@"Show concept map view.\n" logTimeStampOrNot:YES];
    [self.view bringSubviewToFront:bulbImageView];
    
    
    NSString* isPreview=[[NSUserDefaults standardUserDefaults] stringForKey:@"isPreview"];
    if([isPreview isEqualToString:@"YES"]){
        [previewImg setHidden:NO];
        [self.view bringSubviewToFront: previewImg];
        
        previewImg.layer.shadowColor = [UIColor blackColor].CGColor;
        previewImg.layer.shadowOffset = CGSizeMake(2, 2);
        previewImg.layer.shadowOpacity = 0.75;
        previewImg.layer.shadowRadius = 5;
        previewImg.clipsToBounds = NO;
        
        previewImg.backgroundColor= [[UIColor whiteColor]colorWithAlphaComponent:0.3];
        previewImg.layer.borderColor = [UIColor grayColor].CGColor;
        previewImg.layer.borderWidth = 2.0f;
        
        [self.view.layer insertSublayer:upperBorder below:previewImg.layer];
        [previewImg becomeFirstResponder];
        isShowPreView=YES;
        
    }
}


-(void)resumeNormalScreen{
    CGRect rec=CGRectMake(0, 0, 768, 1024);
    [bookView.view setFrame:rec];
    [cmapView.view setHidden:YES];
    [QA.view setHidden:YES];
    [bulbImageView setHidden:YES];
    LogFileController *logFile=[[LogFileController alloc]init];
    [logFile writeToTextFile:@"Show book view.\n" logTimeStampOrNot:YES];
    [previewImg setHidden:YES];
    isShowPreView= NO;
    [upperBorder removeFromSuperlayer];
    
}

- (IBAction)pan:(UIPanGestureRecognizer *)gesture
{
    static CGPoint originalCenter;
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        originalCenter = gesture.view.center;
        gesture.view.layer.shouldRasterize = YES;
    }
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translate = [gesture translationInView:gesture.view.superview];
        gesture.view.center = CGPointMake(originalCenter.x + translate.x, originalCenter.y + translate.y);
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        upperBorder.position = CGPointMake(originalCenter.x + translate.x, originalCenter.y + translate.y);
        [CATransaction commit];
    }
    
    
}


-(void)hideAndShowPreView{
    if(YES==isShowPreView){
        [previewImg setHidden:YES];
        [upperBorder removeFromSuperlayer];
        isShowPreView=NO;
    }else{
        [previewImg setHidden:NO];
        upperBorder.backgroundColor = [[UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.7f]CGColor];
        upperBorder.frame=previewImg.frame;
        previewImg.layer.borderColor = [UIColor grayColor].CGColor;
        previewImg.layer.borderWidth = 2.0f;
        
        [self.view.layer insertSublayer:upperBorder below:previewImg.layer];
        
        //[previewImg becomeFirstResponder];
        
        isShowPreView=YES;
        
    }
    
}

-(void)searchAndHighlight{
    
}


-(void)upLoadLogFile{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/LogData.xml",
                          documentsDirectory];
    NSString *content = [[NSString alloc] initWithContentsOfFile:fileName
                                                    usedEncoding:nil
                                                           error:nil];
    NSString *filename = @"LogData.xml";
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
    [content writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    // Upload file to Dropbox
    NSString *destDir = @"/";
    [self.restClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
}


-(void)uploadCmapLink{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/ExpertCmapLinkList.xml",
                          documentsDirectory];
    NSString *content = [[NSString alloc] initWithContentsOfFile:fileName
                                                    usedEncoding:nil
                                                           error:nil];
    NSString *text = content;
    NSString *filename = @"ExpertCmapLinkList.xml";
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
    [text writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    // Upload file to Dropbox
    NSString *destDir = @"/";
    [self.restClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
    
}

-(void)uploadCmapNode{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/ExpertCmapNodeList.xml",
                          documentsDirectory];
    NSString *content = [[NSString alloc] initWithContentsOfFile:fileName
                                                    usedEncoding:nil
                                                           error:nil];
    
    NSString *text = content;
    NSString *filename = @"ExpertCmapNodeList.xml";
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
    [text writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    // Upload file to Dropbox
    NSString *destDir = @"/";
    [self.restClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
    
    
}

-(void)upLoadCmap{
    
    [self uploadCmapNode];
    [self uploadCmapLink];
}


- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}


- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
}


/*
 -(void) checkCmapCountdown:(NSTimer*)_timer {
 
 NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:startDate];
 remainTime = totalCountdownInterval - elapsedTime;
 int second=(int)remainTime;
 NSString *speedLabel = [[NSString alloc] initWithFormat:@"Time remaining %02d : %02d ", second/60, second%60];
 timerLable.text=speedLabel;
 self.navigationController.navigationBar.topItem.title=speedLabel;
 if(remainTime<=30){
 [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
 }
 
 if (remainTime <= 0.0) {
 [_timer invalidate];
 //[cmapView upLoad:nil];
 
 QuizViewController *quiz=[[QuizViewController alloc] initWithNibName:@"ViewController" bundle:nil];
 quiz.isFinished=false;
 quiz.parentBookPageViewController=self;
 quiz.testType=1;
 quiz.userName=userName;
 quiz.bookLogDataWrapper=logWrapper;
 [self.navigationController pushViewController:quiz animated:YES];
 
 /*   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Time is up."
 message:@"Your data has been uploaded. Thank you for your participation!"
 delegate:self
 cancelButtonTitle:@"OK"
 otherButtonTitles:nil];
 */
// [alert show];
// }
//}



-(void) checkCmapCountdown:(NSTimer*)_timer {
    
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:startDate];
    remainTime = totalCountdownInterval - elapsedTime;
    int second=(int)remainTime;
    NSString *speedLabel = [[NSString alloc] initWithFormat:@"Concept Mapping time remaining %02d : %02d ", second/60, second%60];
    timerLable.text=speedLabel;
    self.navigationController.navigationBar.topItem.title=speedLabel;
    if(remainTime<=30){
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
    }
    
    if (remainTime <= 0.0) {
        [_timer invalidate];
        //[cmapView upLoad:nil];
        
        //  [cmapView uploadCMapImg];//upload concetp map image
        
        [cmapView uploadCmapCocneptAddedList];
        
        [cmapView LogStudentMapNum];
        
        QuizViewController *quiz=[[QuizViewController alloc] initWithNibName:@"QuizViewController" bundle:nil];
        quiz.isFinished=false;
        quiz.parentBookPageViewController=self;
        quiz.testType=1; //post test
        quiz.userName=userName;
        quiz.bookLogDataWrapper=logWrapper;
        [self.navigationController pushViewController:quiz animated:YES];
        
        /*   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Time is up."
         message:@"Your data has been uploaded. Thank you for your participation!"
         delegate:self
         cancelButtonTitle:@"OK"
         otherButtonTitles:nil];
         */
        // [alert show];
    }
}




-(void) checkTutorialCountdown:(NSTimer*)_timer {
    
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:startDate];
    remainTime = totalCountdownInterval - elapsedTime;
    int second=(int)remainTime;
    NSString *speedLabel = [[NSString alloc] initWithFormat:@"Tutorial time remaining %02d : %02d ", second/60, second%60];
    timerLable.text=speedLabel;
    self.navigationController.navigationBar.topItem.title=speedLabel;
    if(remainTime<=30){
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
    }
    if (remainTime <= 0.0) {
        [_timer invalidate];
        NSLog(@"%@",self.navigationController.viewControllers);
        [self.navigationController popToViewController:self animated:false];
        
        LogData* newlog= [[LogData alloc]initWithName:userName SessionID:@"session_id" action:@"Student start concept mapping" selection:@"concept map view" input:@"" pageNum:@"0"];
        [logWrapper addLogs:newlog];
        [LogDataParser saveLogData:logWrapper];
        [self splitScreen];
        [self startCmapTimer];
    }
}

/*
 - (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
 // the user clicked OK
 if (buttonIndex == 0) {
 [self.navigationController popToRootViewControllerAnimated:YES];
 }
 }*/


-(void)addConceptMapPreview:(NSMutableArray*)nodeArray Links: (NSMutableArray*)linkArray CMapFrame: (CGRect)frame{
    conceptNodeArray=[[NSMutableArray alloc] init];
    CGRect previewFrame=previewImg.frame;
    
    float xRatio=previewFrame.size.width/frame.size.width;
    float yRatio=previewFrame.size.height/frame.size.height;
    
    float sizeRatiox=cmapView.conceptMapView.frame.size.width/cmapView.conceptMapView.contentSize.width;
    float sizeRatioy=cmapView.conceptMapView.frame.size.height/cmapView.conceptMapView.contentSize.height;
    if(sizeRatiox>100){
        sizeRatiox=1;
    }
    if(sizeRatioy>100){
        sizeRatioy=1;
    }
    
    NSArray *viewsToRemove = [previewImg subviews];
    for (UIView *v in viewsToRemove) {
        if(1==v.tag){
            continue;
        }
        [v removeFromSuperview];
    }
    [PreviewRect removeFromSuperview];
    previewImg.layer.sublayers = nil;
    
    [PreviewRect setFrame:CGRectMake(originalFrame.origin.x*sizeRatiox+2, originalFrame.origin.y*sizeRatioy+2,  originalFrame.size.width*sizeRatiox-4, originalFrame.size.height*sizeRatioy-4)];
    
    [previewImg addSubview:PreviewRect];
    for(NodeCell* cell in nodeArray){
        NSString* str=cell.text.text;
        PreViewNode *pNode=[[PreViewNode alloc]initWithNibName:@"PreViewNode" bundle:nil];
        [pNode.view setFrame:CGRectMake(cell.showPoint.x*xRatio, cell.showPoint.y*yRatio,6, 6)];
        pNode.ParentPreView=previewImg;
        pNode.name=cell.text.text;
        [conceptNodeArray addObject:pNode];
        [previewImg addSubview:pNode.view];
    }
    
    for(ConceptLink* link in linkArray){
        
        PreViewNode* c1, *c2;
        
        for(PreViewNode* pNnode in conceptNodeArray){
            
            if([link.leftNode.text.text isEqualToString:pNnode.name]){
                c1=pNnode;
            }
            if([link.righttNode.text.text isEqualToString:pNnode.name]){
                c2=pNnode;
            }
        }
        [c1 createLink:c2 name:@"x"];
    }
    
}

-(void)updatePrevireRect{
    
}


-(void)addTutorial{
    VideoViewController *tutorial= [[VideoViewController alloc]initWithNibName:@"VideoViewController" bundle:nil];
    tutorial.parentBookCtr=self;
    self.videoView=tutorial;
    [tutorial startTimer];
    [self.navigationController pushViewController:tutorial animated:NO];
    // [self startTimer];
}

-(void)showAdminPsdAlert{
    DTAlertView *alertView  = [DTAlertView alertViewWithTitle:@"Please Input Password!!" message:@"Password is \"1234567890\"" delegate:self cancelButtonTitle:@"Cancel" positiveButtonTitle:@"OK"];
    [alertView setAlertViewMode:DTAlertViewModeTextInput];
    [alertView setPositiveButtonEnable:NO];
    
    [alertView setTextFieldDidChangeBlock:^(DTAlertView *_alertView, NSString *text) {
        [_alertView setPositiveButtonEnable:(text.length >= 5)];
    }];
    
    [alertView showForPasswordInputWithAnimation:DTAlertViewAnimationDefault];
    
    // Set text field to secure text mode after show.
    [alertView.textField setSecureTextEntry:YES];

}
@end
