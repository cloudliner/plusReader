//
//  CLRConsoleViewController.m
//  plusReader
//
//  Created by 大野 廉 on 2012/12/26.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import "CLRConsoleViewController.h"

@interface CLRConsoleViewController ()

@end

@implementation CLRConsoleViewController

- (IBAction)closeModalDialog:(id)sender {
  [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)clearConsole:(id)sender {
  CLRConsoleClear();
  
  self.textView.text = @"";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.textView.text = CLRConsoleText();
  
  CLRGAITrack();
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
