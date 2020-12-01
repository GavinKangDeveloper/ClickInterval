//
//  ViewController.m
//  KKClickInterval
//
//  Created by ZhuKangKang on 2020/12/1.
//

#import "ViewController.h"
#import "UIControl+KKClickInterval.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *singleBtn;
@property (weak, nonatomic) IBOutlet UIButton *doubleBtn;
@property (weak, nonatomic) IBOutlet UIButton *normalBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.normalBtn.ignoreClickInterval = YES;
    
    self.singleBtn.clickInterval = 1.5;
}

- (IBAction)onSingleButtonAction:(UIButton *)sender {
    NSLog(@"+++++++%s",__FUNCTION__);
}

- (IBAction)onDoubleButtonTouchUpInsideAction:(UIButton *)sender {
    NSLog(@"+++++++%s",__FUNCTION__);
}

- (IBAction)onDoubleButtonTouchUpOutsideAction:(UIButton *)sender {
    NSLog(@"+++++++%s",__FUNCTION__);
}

- (IBAction)onNormalButtonAction:(UIButton *)sender {
    NSLog(@"+++++++%s",__FUNCTION__);
}


@end
