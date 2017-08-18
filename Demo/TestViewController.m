//
//  TestViewController.m
//  Demo
//
//  Created by 徐 林峰 on 2017/8/15.
//  Copyright © 2017年 Marike Jave. All rights reserved.
//

#import <objc/runtime.h>
#import "TestViewController.h"
#import "UIView+UIAppearance+Private.h"

@implementation NSObject(_UIAppearanceRecorder)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIView_UIAppearanceMethodSwizzle(object_getClass((id)NSClassFromString(@"_UIAppearanceRecorder")), @selector(allocWithZone:), @selector(UIAppearanceRecorder_allocWithZone:));
    });
}

+ (id)UIAppearanceRecorder_allocWithZone:(NSZone *)zone{
    return [self UIAppearanceRecorder_allocWithZone:zone];
}

@end

@interface TestLabel : UILabel

@property (nonatomic, copy) UIColor *color UI_APPEARANCE_SELECTOR;

@end

@implementation TestLabel

- (void)setColor:(UIColor *)color{
    [super setTextColor:color];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
}

//- (BOOL)allowSynchronizeAppreance{
//    return YES;
//}

@end

@interface TestViewController ()

@property (nonatomic, strong) UIButton *dissmissButton;

@property (nonatomic, strong) UIButton *testBackgroundColorButton;

@property (nonatomic, strong) UIButton *appearanceBackgroundColorButton;

@property (nonatomic, strong) UIButton *testFontButton;

@property (nonatomic, strong) UIButton *appearanceFontButton;

@property (nonatomic, strong) UIButton *testTextColorButton;

@property (nonatomic, strong) UIButton *appearanceTextColorButton;

@property (nonatomic, strong) UIButton *resetLabelButton;

@property (nonatomic, strong) TestLabel *testLabel;

@end

@implementation TestViewController

- (void)loadView{
    [super loadView];
    
    self.view.backgroundColor = [UIColor lightGrayColor];

    self.dissmissButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
    [[self dissmissButton] setTitle:@"<" forState:UIControlStateNormal];
    [[self dissmissButton] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[self dissmissButton] addTarget:self action:@selector(didClickDismiss:) forControlEvents:UIControlEventTouchUpInside];
    
    self.testBackgroundColorButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 30, 130, 50)];
    self.testBackgroundColorButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [[self testBackgroundColorButton] setTitle:@"background:  View" forState:UIControlStateNormal];
    [[self testBackgroundColorButton] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[self testBackgroundColorButton] addTarget:self action:@selector(didClickResetBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
    
    self.appearanceBackgroundColorButton = [[UIButton alloc] initWithFrame:CGRectMake(140, 30, 150, 50)];
    self.appearanceBackgroundColorButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [[self appearanceBackgroundColorButton] setTitle:@"Appearance" forState:UIControlStateNormal];
    [[self appearanceBackgroundColorButton] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[self appearanceBackgroundColorButton] addTarget:self action:@selector(didClickResetAppearance:) forControlEvents:UIControlEventTouchUpInside];
    
    self.testFontButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 80, 150, 50)];
    self.testFontButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [[self testFontButton] setTitle:@"font:  View" forState:UIControlStateNormal];
    [[self testFontButton] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[self testFontButton] addTarget:self action:@selector(didClickResetFont:) forControlEvents:UIControlEventTouchUpInside];
    
    self.appearanceFontButton = [[UIButton alloc] initWithFrame:CGRectMake(140, 80, 150, 50)];
    self.appearanceFontButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [[self appearanceFontButton] setTitle:@"Appearance" forState:UIControlStateNormal];
    [[self appearanceFontButton] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[self appearanceFontButton] addTarget:self action:@selector(didClickResetAppearanceFont:) forControlEvents:UIControlEventTouchUpInside];
    
    self.testTextColorButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 130, 150, 50)];
    self.testTextColorButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [[self testTextColorButton] setTitle:@"text color:  View" forState:UIControlStateNormal];
    [[self testTextColorButton] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[self testTextColorButton] addTarget:self action:@selector(didClickResetTextColor:) forControlEvents:UIControlEventTouchUpInside];
    
    self.appearanceTextColorButton = [[UIButton alloc] initWithFrame:CGRectMake(140, 130, 150, 50)];
    self.appearanceTextColorButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [[self appearanceTextColorButton] setTitle:@"Appearance" forState:UIControlStateNormal];
    [[self appearanceTextColorButton] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[self appearanceTextColorButton] addTarget:self action:@selector(didClickResetAppearanceTextColor:) forControlEvents:UIControlEventTouchUpInside];
    
    self.resetLabelButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 180, 200, 50)];
    self.resetLabelButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [[self resetLabelButton] setTitle:@"Reset view hierarchy" forState:UIControlStateNormal];
    [[self resetLabelButton] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[self resetLabelButton] addTarget:self action:@selector(didClickResetViewHierarchy:) forControlEvents:UIControlEventTouchUpInside];
    
    self.testLabel = [[TestLabel alloc] initWithFrame:CGRectMake(30, 300, 200, 40)];
    self.testLabel.text = @"哈哈哈哈哈哈哈哈哈哈哈哈";
    
    [[self view] addSubview:[self dissmissButton]];
    [[self view] addSubview:[self testBackgroundColorButton]];
    [[self view] addSubview:[self appearanceBackgroundColorButton]];
    [[self view] addSubview:[self testFontButton]];
    [[self view] addSubview:[self appearanceFontButton]];
    [[self view] addSubview:[self testTextColorButton]];
    [[self view] addSubview:[self appearanceTextColorButton]];
    [[self view] addSubview:[self resetLabelButton]];
    [[self view] addSubview:[self testLabel]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)didClickDismiss:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didClickResetBackgroundColor:(id)sender{
    
    self.testLabel.backgroundColor = [UIColor yellowColor];
}

- (IBAction)didClickResetAppearance:(id)sender{

    TestLabel.appearance.backgroundColor = [UIColor grayColor];
}

- (IBAction)didClickResetFont:(id)sender{
    
    self.testLabel.font = [UIFont systemFontOfSize:10];
}

- (IBAction)didClickResetAppearanceFont:(id)sender{
    
    TestLabel.appearance.font = [UIFont systemFontOfSize:20];
}

- (IBAction)didClickResetTextColor:(id)sender{
    
    self.testLabel.color = [UIColor redColor];
}

- (IBAction)didClickResetAppearanceTextColor:(id)sender{
    
    TestLabel.appearance.color = [UIColor greenColor];
}

- (IBAction)didClickResetViewHierarchy:(id)sender{
    if ([[self testLabel] superview]) {
        [[self testLabel] removeFromSuperview];
    } else {
        [[self view] addSubview:[self testLabel]];
    }
    
    id<UIAppearance> appearance = [TestLabel appearance];
    
    NSLog(@"%@", [appearance description]);
    
    appearance = [TestLabel appearanceWhenContainedIn:[self class], nil];
    
    NSLog(@"%@", [appearance description]);
    
    appearance = [TestLabel appearanceForTraitCollection:[self traitCollection]];
    
    NSLog(@"%@", [appearance description]);
    
}

@end
