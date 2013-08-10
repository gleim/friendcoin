//
//  homeScreen.m
//  FriendCoin
//
//  Created by Tyler Phelps on 7-20-13.
//  Copyright (c) 2013 Tyler Phelps. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "homeScreen.h"
#import "GMGridView.h"
#import "KGModal.h"
#import "BackgroundLayerViewController.h"
#import "AksStraightPieChart.h"
#import "QRCodeGenerator.h"

#define NUMBER_ITEMS_ON_LOAD 9

//////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ViewController (privates methods)
//////////////////////////////////////////////////////////////

@interface homeScreen () <GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewTransformationDelegate, GMGridViewActionDelegate>
{
    __gm_weak GMGridView *_gmGridView;
    
    NSMutableArray *_data;
    __gm_weak NSMutableArray *_currentData;
    NSInteger _lastDeleteItemIndexAsked;
}

@end


//////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ViewController implementation
//////////////////////////////////////////////////////////////

@implementation homeScreen


- (id)init
{
    if ((self =[super init])) 
    {
        self.title = @"FriendCoin";
        
        UIBarButtonItem *walletButton = [[UIBarButtonItem alloc] initWithTitle:@"Wallet" style:UIBarButtonItemStylePlain target:self action:@selector(walletButtonPressed:)];
        
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space.width = 10;
        
        UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space2.width = 10;
        
        if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)]) {
            self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:space, walletButton, space2, nil];
        }else {
            
        }
        
        
        UIBarButtonItem *addContactButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContactButtonPressed:)];
        
        if ([self.navigationItem respondsToSelector:@selector(rightBarButtonItems)]) {
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:addContactButton, nil];
        }else {
            
        }
        
        _data = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < (NUMBER_ITEMS_ON_LOAD + 2); i ++)
        {
            [_data addObject:[NSString stringWithFormat:@"%d.jpg", (i-2)]];
        }
        
        _currentData = _data;
    }
    
    return self;
}

//////////////////////////////////////////////////////////////
#pragma mark controller events
//////////////////////////////////////////////////////////////

- (void)loadView 
{
    [super loadView];
    //self.view.backgroundColor = [UIColor whiteColor];
    
    NSInteger spacing = INTERFACE_IS_PHONE ? 10 : 15;
    
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.view.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gmGridView];
    _gmGridView = gmGridView;
    
    _gmGridView.style = GMGridViewStyleSwap;
    _gmGridView.itemSpacing = spacing;
    _gmGridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    _gmGridView.centerGrid = YES;
    _gmGridView.actionDelegate = self;
    _gmGridView.sortingDelegate = self;
    _gmGridView.transformDelegate = self;
    _gmGridView.dataSource = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CAGradientLayer *bgLayer = [BackgroundLayer greyGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    _gmGridView = nil;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [_currentData count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (INTERFACE_IS_PHONE) 
    {
        if (UIInterfaceOrientationIsLandscape(orientation)) 
        {
            return CGSizeMake(170, 135);
        }
        else
        {
            return CGSizeMake(145, 145);
        }
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(orientation)) 
        {
            return CGSizeMake(285, 205);
        }
        else
        {
            return CGSizeMake(230, 175);
        }
    }
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //NSLog(@"Creating view indx %d", index);
    
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) 
    {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        cell.deleteButtonOffset = CGPointMake(-15, -15);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor blackColor];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 8;
        
        cell.contentView = view;
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (index > 1){
        cell.function = @"Contact";
        UIImageView *contactImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 145, 145)];
        NSString *imageName = [NSString stringWithFormat:@"%d.jpg", (index - 2)];
        contactImage.image = [UIImage imageNamed:imageName];
        //contactImage.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:contactImage];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 143, 145)];
        
        CGRect cellRect = contentView.bounds;
        cellRect.origin.y = 120;
        cellRect.size.height = 20;
        UIFont *nameLabelFont = [UIFont boldSystemFontOfSize:17];
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:cellRect];
        
        //For Demo Purposes
        //////////////////////////////////////////
        
        switch ((index-2)){
            case 0:
                nameLabel.text = @"Tyler";
                break;
            case 1:
                nameLabel.text = @"Christian";
                break;
            case 2:
                nameLabel.text = @"Marissa";
                break;
            case 3:
                nameLabel.text = @"Jennifer";
                break;
            case 4:
                nameLabel.text = @"James";
                break;
            case 5:
                nameLabel.text = @"Noble";
                break;
            case 6:nameLabel.text = @"Morgan";
                break;
            case 7:
                nameLabel.text = @"Tammi";
                break;
            case 8:
                nameLabel.text = @"Kayla";
                break;
        }
        
        //////////////////////////////////////////
        
        nameLabel.font = nameLabelFont;
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.textAlignment = NSTextAlignmentRight;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.shadowColor = [UIColor blackColor];
        nameLabel.shadowOffset = CGSizeMake(1, 1);
        [contentView addSubview:nameLabel];
        [cell.contentView addSubview:contentView];
        
        AksStraightPieChart * straightPieChart = [[AksStraightPieChart alloc]initWithFrame:CGRectMake((3), 139, (cellRect.size.width-6), 3)];
        [cell.contentView addSubview:straightPieChart];
        
        [straightPieChart clearChart];
        
        //For Demo Purposes
        //////////////////////////////////////////
        int trust = 100;
        int theyUsed = arc4random() % 50;
        int youUsed = arc4random() % 50;
        //////////////////////////////////////////
        
        [straightPieChart addDataToRepresent:50 WithColor:[UIColor redColor]];
        [straightPieChart addDataToRepresent:(trust - theyUsed - youUsed) WithColor:[UIColor whiteColor]];
        [straightPieChart addDataToRepresent:38 WithColor:[UIColor greenColor]];
        
    }
    else if (index == 0){
        cell.function = @"Sell";
        UIImageView *sellImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 145, 145)];
        sellImage.image = [UIImage imageNamed:@"moneybag.png"];
        //sellImage.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:sellImage];
        
    }
    else if (index == 1){
        cell.function = @"Buy";
        UIImageView *sellImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 145, 145)];
        sellImage.image = [UIImage imageNamed:@"cart.png"];
        sellImage.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:sellImage];
    }
    
    return cell;
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return YES; //index % 2 == 0;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    if (position == 0){
        NSLog(@"Show Sell Screen!");
    }
    else if (position == 1){
        UIImageView *qrCode = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        
        //For Demo Purposes
        //////////////////////////////////////////
        NSString *rippleAddress = @"rNpxnJzgAo4NiDtgopbbLQzByoX8XxbNAh";
        //////////////////////////////////////////
        
        qrCode.backgroundColor = [UIColor whiteColor];
        qrCode.image = [QRCodeGenerator qrImageForString:rippleAddress imageSize:qrCode.bounds.size.width];
        
        qrCode.contentMode = UIViewContentModeScaleAspectFit;
        
        [[KGModal sharedInstance] showWithContentView:qrCode andAnimated:YES];
    }
    else{
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 350)];
        
        CGRect nameLabelRect = contentView.bounds;
        nameLabelRect.origin.y = 10;
        nameLabelRect.size.height = 26;
        UIFont *nameLabelFont = [UIFont boldSystemFontOfSize:24];
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameLabelRect];
        
        //For Demo Purposes
        //////////////////////////////////////////
        switch ((position-2)){
            case 0:
                nameLabel.text = @"Tyler";
                break;
            case 1:
                nameLabel.text = @"Christian";
                break;
            case 2:
                nameLabel.text = @"Marissa";
                break;
            case 3:
                nameLabel.text = @"Jennifer";
                break;
            case 4:
                nameLabel.text = @"James";
                break;
            case 5:
                nameLabel.text = @"Noble";
                break;
            case 6:nameLabel.text = @"Morgan";
                break;
            case 7:
                nameLabel.text = @"Tammi";
                break;
            case 8:
                nameLabel.text = @"Kayla";
                break;
        }
        //////////////////////////////////////////
        
        nameLabel.font = nameLabelFont;
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.shadowColor = [UIColor blackColor];
        nameLabel.shadowOffset = CGSizeMake(0, 1);
        [contentView addSubview:nameLabel];
        
        UIImageView *contactImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 40, 125, 125)];
        NSString *imageName = [NSString stringWithFormat:@"%d.jpg", (position - 2)];
        contactImage.image = [UIImage imageNamed:imageName];
        contactImage.contentMode = UIViewContentModeScaleAspectFit;
        [contentView addSubview:contactImage];
        
        CGRect buttonBox1 = CGRectMake(135, 40, 110, 40);
        UIButton *sendButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
        sendButton.frame = buttonBox1;
        [sendButton setTitle:@"Send" forState:UIControlStateNormal];
        sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [contentView addSubview:sendButton];
        
        CGRect buttonBox2 = CGRectMake(135, 82, 110, 40);
        UIButton *requestButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
        requestButton.frame = buttonBox2;
        [requestButton setTitle:@"Request" forState:UIControlStateNormal];
        requestButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [contentView addSubview:requestButton];
        
        CGRect buttonBox3 = CGRectMake(135, 124, 110, 40);
        UIButton *settingsButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
        settingsButton.frame = buttonBox3;
        [settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
        settingsButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [contentView addSubview:settingsButton];
        
        AksStraightPieChart * straightPieChart = [[AksStraightPieChart alloc]initWithFrame:CGRectMake(5, 170, 240, 5)];
        [contentView addSubview:straightPieChart];
        
        [straightPieChart clearChart];
        
        //For Demo Purposes
        //////////////////////////////////////////
        int trust = arc4random() % 250;
        int youTrust = arc4random() % trust;
        int theyTrust = trust - youTrust;
        int theyUsed = arc4random() % youTrust;
        int youUsed = arc4random() % theyTrust;
        int connectionValue = youUsed - theyUsed;
        //////////////////////////////////////////
        
        [straightPieChart addDataToRepresent:50 WithColor:[UIColor redColor]];
        [straightPieChart addDataToRepresent:(trust - theyUsed - youUsed) WithColor:[UIColor whiteColor]];
        [straightPieChart addDataToRepresent:38 WithColor:[UIColor greenColor]];
        
        NSString *totalTrustValue = [NSString stringWithFormat:@"Total Trust Value: $%d.00", trust];
        NSString *theirTrustValue = [NSString stringWithFormat:@"They Trust You: $%d.00", theyTrust];
        NSString *yourTrustValue = [NSString stringWithFormat:@"You Trust Them: $%d.00", youTrust];
        NSString *theirBorrowed = [NSString stringWithFormat:@"They Have Borrowed: $%d.00", theyUsed];
        NSString *yourBorrowed = [NSString stringWithFormat:@"You Have Borrowed: $%d.00", youUsed];
        NSString *contactValue = [NSString stringWithFormat:@"Connection Value: %d", connectionValue];
        
        NSString *contactInfo = [NSString stringWithFormat:@"%@ \n %@ \n %@ \n %@ \n %@ \n %@", totalTrustValue, yourTrustValue, theirTrustValue, yourBorrowed, theirBorrowed, contactValue];
        
        NSLog(@"%@", contactInfo);
        
        CGRect infoLabelBox = CGRectMake(5, 180, 240, 170);
        UILabel *contactInfoLabel = [[UILabel alloc] initWithFrame:infoLabelBox];
        contactInfoLabel.font = [UIFont systemFontOfSize:16];
        contactInfoLabel.text = contactInfo;
        contactInfoLabel.numberOfLines = 6;
        contactInfoLabel.textColor = [UIColor whiteColor];
        contactInfoLabel.textAlignment = NSTextAlignmentCenter;
        contactInfoLabel.backgroundColor = [UIColor clearColor];
        contactInfoLabel.shadowColor = [UIColor blackColor];
        contactInfoLabel.shadowOffset = CGSizeMake(0, 1);
        [contentView addSubview:contactInfoLabel];
        
        [[KGModal sharedInstance] showWithContentView:contentView andAnimated:YES];
    }
    
    
    
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    //NSLog(@"Tap on empty space");
}

- (IBAction)walletButtonPressed:(id)sender
{
    NSLog(@"Wallet Button Pressed");
     
}

- (IBAction)addContactButtonPressed:(id)sender
{
    NSLog(@"Add Contact Was Pressed!");
}

@end
