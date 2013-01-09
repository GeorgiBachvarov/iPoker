//
//  RaiseViewController.m
//  iPoker
//
//  Created by Georgi Bachvarov on 1/9/13.
//  Copyright (c) 2013 Georgi Bachvarov. All rights reserved.
//

#import "RaiseViewController.h"

@interface RaiseViewController ()



@end

@implementation RaiseViewController

- initWithDelegate: (id <RaiseViewControllerDelegate>) delegate{
    self = [super init];
    if (self){
        self.delegate = delegate;
        
        self.numberField = [[UITextField alloc] init];
        [self.numberField setKeyboardType:UIKeyboardTypeNumberPad];
        [self.numberField setFrame:CGRectMake(5, 5, 190, 44)];
        self.numberField.backgroundColor = [UIColor whiteColor];
        
        
        self.raiseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.raiseButton setTitle:@"Raise" forState:UIControlStateNormal];
        [self.raiseButton setFrame:CGRectMake(50, 53, 100, 44)];
        [self.raiseButton addTarget:self action:@selector(confirmSum) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:self.numberField];
        [self.view addSubview:self.raiseButton];
        
        [self.view setBounds:CGRectMake(0, 0, 200, 100)];
        
    }
    return self;
}

- (void) confirmSum{
    NSScanner* scan = [NSScanner localizedScannerWithString:self.numberField.text];
    NSInteger value;
    BOOL isValid = [scan scanInteger:&value] && [scan isAtEnd] && value>0;
    if(isValid) {
        [self.delegate raiseViewController:self didChooseSum:value];
    }
    else {
        return;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
