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

#define NUMBER_ITEMS_ON_LOAD 9

//////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ViewController (privates methods)
//////////////////////////////////////////////////////////////

@interface homeScreen () <GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewTransformationDelegate, GMGridViewActionDelegate>
{
    __gm_weak GMGridView *_gmGridView;
    UINavigationController *_optionsNav;
    UIPopoverController *_optionsPopOver;
    
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
        
        UIBarButtonItem *walletButton = [[UIBarButtonItem alloc] initWithTitle:@"Wallet" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space.width = 10;
        
        UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space2.width = 10;
        
        if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)]) {
            self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:space, walletButton, space2, nil];
        }else {
            
        }
        
        
        UIBarButtonItem *addContactButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
        
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
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
    _gmGridView.mainSuperView = self.navigationController.view; //[UIApplication sharedApplication].keyWindow.rootViewController.view;

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
        
        //nameLabel.text = @"Name Here";
        
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
        int trust = 100;
        int theyUsed = arc4random() % 50;
        int youUsed = arc4random() % 50;
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
    NSLog(@"Did tap at index %d", position);
    
    if (position == 0){
        NSLog(@"Show Sell Screen!");
    }
    else if (position == 1){
        UIImageView *qrCode = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        qrCode.image = [UIImage imageNamed:@"qrCode.png"];
        qrCode.contentMode = UIViewContentModeScaleAspectFit;
        
        [[KGModal sharedInstance] showWithContentView:qrCode andAnimated:YES];
    }
    else{
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
        
        CGRect welcomeLabelRect = contentView.bounds;
        welcomeLabelRect.origin.y = 20;
        welcomeLabelRect.size.height = 20;
        UIFont *welcomeLabelFont = [UIFont boldSystemFontOfSize:17];
        UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:welcomeLabelRect];
        welcomeLabel.text = @"This Is A Test!";
        welcomeLabel.font = welcomeLabelFont;
        welcomeLabel.textColor = [UIColor whiteColor];
        welcomeLabel.textAlignment = NSTextAlignmentCenter;
        welcomeLabel.backgroundColor = [UIColor clearColor];
        welcomeLabel.shadowColor = [UIColor blackColor];
        welcomeLabel.shadowOffset = CGSizeMake(0, 1);
        [contentView addSubview:welcomeLabel];
        
        CGRect infoLabelRect = CGRectInset(contentView.bounds, 5, 5);
        infoLabelRect.origin.y = CGRectGetMaxY(welcomeLabelRect)+5;
        infoLabelRect.size.height -= CGRectGetMinY(infoLabelRect);
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:infoLabelRect];
        NSString *text = [NSString stringWithFormat:@"Cell Position Index: %d", position];
        infoLabel.text = text;
        infoLabel.textColor = [UIColor whiteColor];
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.shadowColor = [UIColor blackColor];
        infoLabel.shadowOffset = CGSizeMake(0, 1);
        [contentView addSubview:infoLabel];
        
        [[KGModal sharedInstance] showWithContentView:contentView andAnimated:YES];
    }
    
    
    
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    //NSLog(@"Tap on empty space");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) 
    {
        [_currentData removeObjectAtIndex:_lastDeleteItemIndexAsked];
        [_gmGridView removeObjectAtIndex:_lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
    }
}

@end
