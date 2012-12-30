//
//  CLConsoleViewController.m
//  plusReader
//
//  Created by 大野 廉 on 2012/12/26.
//  Copyright (c) 2012年 cloudliner.jp. All rights reserved.
//

#import "CLConsoleViewController.h"

@interface CLConsoleViewController ()

@end

@implementation CLConsoleViewController

- (IBAction)closeModalDialog:(id)sender {
  [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
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
  if (plusReader_CLConsole_textView != nil) {
    _textView.text = plusReader_CLConsole_textView.text;
    plusReader_CLConsole_textView = nil;
  }
	plusReader_CLConsole_textView = _textView;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
