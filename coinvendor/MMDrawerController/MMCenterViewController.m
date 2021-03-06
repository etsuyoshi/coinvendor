// Copyright (c) 2013 Mutual Mobile (http://mutualmobile.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "MMCenterViewController.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "MMLogoView.h"
#import "MMCenterTableViewCell.h"
#import "MMLeftSideDrawerViewController.h"
#import "MMRightSideDrawerViewController.h"
#import "MMNavigationController.h"

#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, MMCenterViewControllerSection){
    MMCenterViewControllerSectionLeftViewState,
    MMCenterViewControllerSectionLeftDrawerAnimation,
    MMCenterViewControllerSectionRightViewState,
    MMCenterViewControllerSectionRightDrawerAnimation,
};






@interface MMCenterViewController ()

@end

@implementation MMCenterViewController{
    NSString *strUrl;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setRestorationIdentifier:@"MMExampleCenterControllerRestorationKey"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"%s, type = %d", __func__, self.controllerStyle);
    
//    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
//    [self.tableView setDelegate:self];
//    [self.tableView setDataSource:self];
//    [self.view addSubview:self.tableView];
//    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    if(self.controllerStyle != ControllerStyleConfig){
        self.myWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        self.myWebView.delegate = self;
        self.myWebView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.myWebView];
        [self setUrl];
        [self connectionStart];
    }
    
    //それぞれのcontrollerタイプに対して適切な部品を貼り付ける
    [self setContents];
    
//    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
//    [doubleTap setNumberOfTapsRequired:2];
//    [self.view addGestureRecognizer:doubleTap];
//    UITapGestureRecognizer * twoFingerDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerDoubleTap:)];
//    [twoFingerDoubleTap setNumberOfTapsRequired:2];
//    [twoFingerDoubleTap setNumberOfTouchesRequired:2];
//    [self.view addGestureRecognizer:twoFingerDoubleTap];
    

    [self setupLeftMenuButton];
    //[self setupRightMenuButton];
    
    if(OSVersionIsAtLeastiOS7()){
        UIColor * barColor = [UIColor
                              colorWithRed:247.0/255.0
                              green:249.0/255.0
                              blue:250.0/255.0
                              alpha:1.0];
        [self.navigationController.navigationBar setBarTintColor:barColor];
    }
    else {
        UIColor * barColor = [UIColor
                              colorWithRed:78.0/255.0
                              green:156.0/255.0
                              blue:206.0/255.0
                              alpha:1.0];
        [self.navigationController.navigationBar setTintColor:barColor];
    }
    
    
    MMLogoView * logo = [[MMLogoView alloc] initWithFrame:CGRectMake(0, 0, 29, 31)];
    [self.navigationItem setTitleView:logo];
    [self.navigationController.view.layer setCornerRadius:10.0f];
    
    
    UIView *backView = [[UIView alloc] init];
    [backView setBackgroundColor:[UIColor colorWithRed:208.0/255.0
                                                 green:208.0/255.0
                                                  blue:208.0/255.0
                                                 alpha:1.0]];
//    [self.tableView setBackgroundView:backView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"Center will appear");
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"Center did appear");
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"Center will disappear");
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"Center did disappear");
}

-(void)setupLeftMenuButton{
    
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
}

-(void)setupRightMenuButton{
    MMDrawerBarButtonItem * rightDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(rightDrawerButtonPress:)];
    [self.navigationItem setRightBarButtonItem:rightDrawerButton animated:YES];
}

//superClassのnotificationで実行されるメソッド
-(void)contentSizeDidChange:(NSString *)size{
    //[self.tableView reloadData];
    NSLog(@"%s", __func__);
    
    
}

-(void)setContents{
    if(self.controllerStyle == ControllerStyleDaily ||
       self.controllerStyle == ControllerStyleMinute){
        NSLog(@"controller type = daily | minute");
        
        //すでにウェブビューがあればそのまま更新し、なければ貼り付けてから更新する
        BOOL isWebviewExist = false;
        for(UIView *view in self.view.subviews){
            if([view isKindOfClass:[UIWebView class]]){
                isWebviewExist = YES;
                break;
            }
        }
        
        //なければウェブビューを初期化して貼り付ける
        if(!isWebviewExist){
            
            self.myWebView = [[UIWebView alloc]initWithFrame:self.view.bounds];
            self.myWebView.delegate = self;
            [self.view addSubview:self.myWebView];
            
        }
        
        
        //アクセスするurlを設定
        [self setUrl];
        //設定したurlにアクセスする
        [self connectionStart];
    }else if(self.controllerStyle == ControllerStyleConfig){
        NSLog(@"controller type = config");
        
        //ウェブビューを消去
        [self.myWebView removeFromSuperview];
        
        [self removeAllView];
        [self setConfigView];
        
    }
}

-(void)setUrl{
    if(self.controllerStyle == ControllerStyleMinute){
        strUrl = @"http://kumaco.in/sp/bitstamp_chart/min";
    }else if(self.controllerStyle == ControllerStyleDaily){
        strUrl = @"http://kumaco.in/sp/bitstamp_chart/daily";
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case MMCenterViewControllerSectionLeftDrawerAnimation:
        case MMCenterViewControllerSectionRightDrawerAnimation:
            return 5;
        case MMCenterViewControllerSectionLeftViewState:
        case MMCenterViewControllerSectionRightViewState:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[MMCenterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    UIColor * selectedColor = [UIColor
                               colorWithRed:1.0/255.0
                               green:15.0/255.0
                               blue:25.0/255.0
                               alpha:1.0];
    UIColor * unselectedColor = [UIColor
                                 colorWithRed:79.0/255.0
                                 green:93.0/255.0
                                 blue:102.0/255.0
                                 alpha:1.0];
    
    switch (indexPath.section) {
        case MMCenterViewControllerSectionLeftDrawerAnimation:
        case MMCenterViewControllerSectionRightDrawerAnimation:{
             MMDrawerAnimationType animationTypeForSection;
            if(indexPath.section == MMCenterViewControllerSectionLeftDrawerAnimation){
                animationTypeForSection = [[MMExampleDrawerVisualStateManager sharedManager] leftDrawerAnimationType];
            }
            else {
                animationTypeForSection = [[MMExampleDrawerVisualStateManager sharedManager] rightDrawerAnimationType];
            }
            
            if(animationTypeForSection == indexPath.row){
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                [cell.textLabel setTextColor:selectedColor];
            }
            else {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell.textLabel setTextColor:unselectedColor];
            }
            switch (indexPath.row) {
                case MMDrawerAnimationTypeNone:
                    [cell.textLabel setText:@"None"];
                    break;
                case MMDrawerAnimationTypeSlide:
                    [cell.textLabel setText:@"Slide"];
                    break;
                case MMDrawerAnimationTypeSlideAndScale:
                    [cell.textLabel setText:@"Slide and Scale"];
                    break;
                case MMDrawerAnimationTypeSwingingDoor:
                    [cell.textLabel setText:@"Swinging Door"];
                    break;
                case MMDrawerAnimationTypeParallax:
                    [cell.textLabel setText:@"Parallax"];
                    break;
                default:
                    break;
            }
             break;   
        }
        case MMCenterViewControllerSectionLeftViewState:{
            [cell.textLabel setText:@"Enabled"];
            if(self.mm_drawerController.leftDrawerViewController){
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                [cell.textLabel setTextColor:selectedColor];
            }
            else{
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell.textLabel setTextColor:unselectedColor];
            }
            break;
        }
        case MMCenterViewControllerSectionRightViewState:{
            [cell.textLabel setText:@"Enabled"];
            if(self.mm_drawerController.rightDrawerViewController){
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                [cell.textLabel setTextColor:selectedColor];
            }
            else{
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell.textLabel setTextColor:unselectedColor];
            }
            break;
        }
        default:
            break;
    }
    
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case MMCenterViewControllerSectionLeftDrawerAnimation:
            return @"Left Drawer Animation";
        case MMCenterViewControllerSectionRightDrawerAnimation:
            return @"Right Drawer Animation";
        case MMCenterViewControllerSectionLeftViewState:
            return @"Left Drawer";
        case MMCenterViewControllerSectionRightViewState:
            return @"Right Drawer";
        default:
            return nil;
    }
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case MMCenterViewControllerSectionLeftDrawerAnimation:
        case MMCenterViewControllerSectionRightDrawerAnimation:{
            if(indexPath.section == MMCenterViewControllerSectionLeftDrawerAnimation){
                [[MMExampleDrawerVisualStateManager sharedManager] setLeftDrawerAnimationType:indexPath.row];
            }
            else {
                [[MMExampleDrawerVisualStateManager sharedManager] setRightDrawerAnimationType:indexPath.row];
            }
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        }
        case MMCenterViewControllerSectionLeftViewState:
        case MMCenterViewControllerSectionRightViewState:{
            UIViewController * sideDrawerViewController;
            MMDrawerSide drawerSide = MMDrawerSideNone;
            if(indexPath.section == MMCenterViewControllerSectionLeftViewState){
                sideDrawerViewController = self.mm_drawerController.leftDrawerViewController;
                drawerSide = MMDrawerSideLeft;
            }
            else if(indexPath.section == MMCenterViewControllerSectionRightViewState){
                sideDrawerViewController = self.mm_drawerController.rightDrawerViewController;
                drawerSide = MMDrawerSideRight;
            }
            
            if(sideDrawerViewController){
                [self.mm_drawerController
                 closeDrawerAnimated:YES
                 completion:^(BOOL finished) {
                     if(drawerSide == MMDrawerSideLeft){
                         [self.mm_drawerController setLeftDrawerViewController:nil];
                         [self.navigationItem setLeftBarButtonItems:nil animated:YES];
                     }
                     else if(drawerSide == MMDrawerSideRight){
                         [self.mm_drawerController setRightDrawerViewController:nil];
                         [self.navigationItem setRightBarButtonItem:nil animated:YES];
                     }
                     [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                     [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                     [tableView deselectRowAtIndexPath:indexPath animated:YES];
                 }];

            }
            else {
                if(drawerSide == MMDrawerSideLeft){
                    UIViewController * vc = [[MMLeftSideDrawerViewController alloc] init];
                    UINavigationController * navC = [[MMNavigationController alloc] initWithRootViewController:vc];
                    [self.mm_drawerController setLeftDrawerViewController:navC];
                    [self setupLeftMenuButton];
                    
                }
                else if(drawerSide == MMDrawerSideRight){
                    UIViewController * vc = [[MMRightSideDrawerViewController alloc] init];
                    UINavigationController * navC = [[MMNavigationController alloc] initWithRootViewController:vc];
                    [self.mm_drawerController setRightDrawerViewController:navC];
                    [self setupRightMenuButton];
                }
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)rightDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

-(void)doubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideLeft completion:nil];
}

-(void)twoFingerDoubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideRight completion:nil];
}


#pragma mark - connectionStart

// リクエスト実行.
- (void)connectionStart
{
    NSLog(@"%s", __func__);
    //    strUrl = @"http://kumaco.in/market";

    NSURL *url = [NSURL URLWithString:strUrl];
    NSURLConnection *connection =
    [[NSURLConnection alloc]
     initWithRequest:[NSURLRequest requestWithURL:url]
     delegate:self];
    [connection start];
    //    [connection release];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // BASIC認証を行う為のUserとPasswordを設定.
    NSURLCredential* creds =
    [NSURLCredential credentialWithUser:@"wataryoichi"
                               password:@"password"
                            persistence:NSURLCredentialPersistencePermanent];
    [[challenge sender] useCredential:creds forAuthenticationChallenge:challenge];
}

// データ読み込み完了.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"%s", __func__);
    NSURL *url = [NSURL URLWithString:strUrl];
    // Web読み込み.
    [self.myWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

/**
 * Webページのロード（表示）の開始前
 */
- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%s : %d", __func__, (int)navigationType);
    // リンクがクリックされたとき
    if (navigationType == UIWebViewNavigationTypeLinkClicked){//クリックされた時
        return NO;
    }else if(navigationType == UIWebViewNavigationTypeOther) {//初回起動時
        return YES;
    }
    
    return YES;
}


-(void)setConfigView{
    NSLog(@"%s", __func__);
    
    int totalWidth = self.view.bounds.size.width;
    int heightComponent = 40;
    int margin = 15;
    UILabel *labelTop = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, totalWidth/3, heightComponent)];
    labelTop.text = @"上限";
    labelTop.center = CGPointMake(totalWidth/3, totalWidth/3);
    [self.view addSubview:labelTop];
    
    UILabel *labelBottom = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, totalWidth/3, heightComponent)];
    labelBottom.text = @"下限";
    labelBottom.center = CGPointMake(totalWidth/3, totalWidth/3 + heightComponent + margin);
    [self.view addSubview:labelBottom];
    
    
    UITextField *tfTop = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, totalWidth/3, heightComponent)];
    tfTop.borderStyle = UITextBorderStyleLine;
    tfTop.delegate = self;
    tfTop.keyboardType = UIKeyboardTypeNumberPad;
    tfTop.center = CGPointMake(totalWidth/3 * 2, totalWidth/3);
    [self.view addSubview:tfTop];
    
    
    UITextField *tfBottom = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, totalWidth/3, heightComponent)];
    tfBottom.borderStyle = UITextBorderStyleLine;
    tfBottom.delegate = self;
    tfBottom.keyboardType = UIKeyboardTypeNumberPad;
    tfBottom.center = CGPointMake(totalWidth/3 * 2, totalWidth/3 + heightComponent + margin);
    [self.view addSubview:tfBottom];
    
}


-(void)removeAllView{
    for(UIView *subview in self.view.subviews){
        [subview removeFromSuperview];
    }
}

@end
