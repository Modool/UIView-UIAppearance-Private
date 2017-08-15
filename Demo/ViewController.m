//
//  ViewController.m
//  test
//
//  Created by xulinfeng on 16/8/7.
//  Copyright © 2016年 Marike Jave. All rights reserved.
//

#import "ViewController.h"
#import "TestViewController.h"

@interface UITestLabel : UILabel

@property (nonatomic, copy) UIColor *color UI_APPEARANCE_SELECTOR;

@end

@implementation UITestLabel

- (void)setColor:(UIColor *)color{
    self.textColor = color;
}

- (UIColor *)color {
    return [self textColor];
}

- (BOOL)allowSynchronizeAppreance{
    return YES;
}

- (void)dealloc{
    
}

@end

@interface ViewController ()

@property (nonatomic, strong) UIButton *colorButton;

@property (nonatomic, strong) UIButton *addButton;

@property (nonatomic, strong) UIButton *clearButton;

@property (nonatomic, strong) UIButton *presentButton;

@end

@implementation ViewController

+ (void)load{
    [super load];
    
    UITestLabel.appearance.color = [UIColor redColor];
}

- (void)loadView{
    [super loadView];
    
    self.colorButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 500, 50, 40)];
    [[self colorButton] setTitle:@"color" forState:UIControlStateNormal];
    [[self colorButton] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[self colorButton] addTarget:self action:@selector(didClickTestColor:) forControlEvents:UIControlEventTouchUpInside];
    
    self.addButton = [[UIButton alloc] initWithFrame:CGRectMake(80, 500, 50, 40)];
    [[self addButton] setTitle:@"add" forState:UIControlStateNormal];
    [[self addButton] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[self addButton] addTarget:self action:@selector(didClickAdd:) forControlEvents:UIControlEventTouchUpInside];
    
    self.clearButton = [[UIButton alloc] initWithFrame:CGRectMake(140, 500, 50, 40)];
    [[self clearButton] setTitle:@"clear" forState:UIControlStateNormal];
    [[self clearButton] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[self clearButton] addTarget:self action:@selector(didClickClear:) forControlEvents:UIControlEventTouchUpInside];
    
    self.presentButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 500, 80, 40)];
    [[self presentButton] setTitle:@"present" forState:UIControlStateNormal];
    [[self presentButton] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[self presentButton] addTarget:self action:@selector(didClickPresent:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self view] addSubview:[self colorButton]];
    [[self view] addSubview:[self addButton]];
    [[self view] addSubview:[self clearButton]];
    [[self view] addSubview:[self presentButton]];
}

#pragma mark - actions

static BOOL red = YES;
static NSUInteger count = 1;

- (IBAction)didClickTestColor:(id)sender{
    red = !red;
    
    UITestLabel.appearance.color = red ? [UIColor redColor] : [UIColor blueColor];
}

- (IBAction)didClickAdd:(id)sender{
    
    UITestLabel *textLabel = [[UITestLabel alloc] initWithFrame:CGRectMake(50, 10 + count * 50, 200, 40)];
    textLabel.text = [NSString stringWithFormat:@"test%lu", (unsigned long)count];
    textLabel.font = [UIFont systemFontOfSize:20];
    count++;
    
    [[self view] addSubview:textLabel];
}

- (IBAction)didClickClear:(id)sender{
    count = 0;
    for (UITestLabel *label in [[[self view] subviews] copy]) {
        if ([label isKindOfClass:[UITestLabel class]]) {
            [label removeFromSuperview];
        }
    }
}

- (IBAction)didClickPresent:(id)sender{

    [self presentViewController:[TestViewController new] animated:YES completion:nil];
}

@end
