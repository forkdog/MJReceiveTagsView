//
//  ViewController.m
//  MJReceiveTagsView
//
//  Created by apple on 2019/5/30.
//  Copyright © 2019 apple. All rights reserved.
//

#import "ViewController.h"
#import "MJReceiveTagsView.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet MJReceiveTagsView *tagsView;

@property (nonatomic, strong) NSArray *tags;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tagsView.placeholder = @"请输入收件人...";
    
    _tags = @[@"马云", @"马化腾", @"王思聪", @"任正非", @"白莲女", @"张国厚", @"杨福林", @"马果树", @"刘埃牛", @"梦琪", @"元香", @"元香", @"香寒"];
    
}

- (IBAction)addTouch:(id)sender {
    int index = [self getRandomNumber:0 to:(int)_tags.count - 1];
    [self.tagsView.tags addObject:_tags[index]];
    [self.tagsView reloadTags];
}

- (int)getRandomNumber:(int)from to:(int)to {
    int x = arc4random() % (to - from + 1) + from;
    return x;
}


@end
