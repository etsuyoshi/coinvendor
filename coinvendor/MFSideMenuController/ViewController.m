//
//  ViewController.m
//  coinvendor
//
//  Created by EndoTsuyoshi on 2015/03/10.
//  Copyright (c) 2015年 com.endo. All rights reserved.
//

#import "ViewController.h"
#import "MFSideMenu.h"


@interface ViewController ()

@end

@implementation ViewController{
    UIWebView *myWebView;
    NSString *strUrl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupMenuBarButtonItems];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - UIBarButtonItems

- (void)setupMenuBarButtonItems {
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
    
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        //戻れる場合には戻るボタン
        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    } else {
        //戻れない場合にはメニューボタン（ただし、右スワイプでメニュー画面表示が可能)
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
        
        [self addWebView];
    }
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"burger"]
            style:UIBarButtonItemStylePlain
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"gear"]
            style:UIBarButtonItemStylePlain
            target:self
            action:@selector(rightSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)backBarButtonItem {
//    return [[UIBarButtonItem alloc]
//            initWithImage:[UIImage imageNamed:@"back-arrow"]
//            style:UIBarButtonItemStylePlain
//            target:self
//            action:@selector(backButtonPressed:)];
    return [[UIBarButtonItem alloc]
            initWithTitle:@"戻る"
            style:UIBarButtonItemStylePlain
            target:self action:@selector(backButtonPressed:)];
}


#pragma mark -
#pragma mark - UIBarButtonItem Callbacks

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

- (void)rightSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}


#pragma mark -
#pragma mark - IBActions

- (void)pushAnotherPressed:(id)sender {
    ViewController *initController =
    [[ViewController alloc]init];
//    [[ViewController alloc]
//     initWithNibName:@"DemoViewController"
//     bundle:nil];
    
    [self.navigationController pushViewController:initController animated:YES];
}



-(void)addWebView{
    
    myWebView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    myWebView.delegate = self;
    
    [self.view addSubview:myWebView];
    
    [self connectionStart];
}



// リクエスト実行.
- (void)connectionStart
{
    NSLog(@"%s", __func__);
//    strUrl = @"http://kumaco.in/market";
    strUrl = @"http://kumaco.in/sp/bitstamp_chart/min";
    strUrl = @"http://kumaco.in/sp/bitstamp_chart/daily";
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
    NSLog(@"%s : basic認証", __func__);
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
    NSURL *url = [NSURL URLWithString:strUrl];
    // Web読み込み.
    [myWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

/**
 * Webページのロード（表示）の開始前
 */
- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    // リンクがクリックされたとき
    if (navigationType == UIWebViewNavigationTypeLinkClicked ||//クリックされた時
        navigationType == UIWebViewNavigationTypeOther) {//初回起動時
        
    }
    
    return YES;
}


@end
