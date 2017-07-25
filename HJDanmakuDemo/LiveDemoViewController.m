//
//  LiveDemoViewController.m
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/14.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import "LiveDemoViewController.h"
#import "HJDanmakuView.h"
#import "DemoDanmakuModel.h"
#import "DemoDanmakuCell.h"
#import "DanmakuFactory.h"

@interface LiveDemoViewController () <HJDanmakuViewDateSource, HJDanmakuViewDelegate>

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) NSArray *danmakus;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) HJDanmakuView *danmakuView;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LiveDemoViewController

- (void)dealloc {
    [self.danmakuView stop];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    HJDanmakuConfiguration *config = [[HJDanmakuConfiguration alloc] initWithDanmakuMode:HJDanmakuModeLive];
    self.danmakuView = [[HJDanmakuView alloc] initWithFrame:self.view.bounds configuration:config];
    self.danmakuView.dataSource = self;
    self.danmakuView.delegate = self;
    [self.danmakuView registerClass:[DemoDanmakuCell class] forCellReuseIdentifier:@"cell"];
    self.danmakuView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.danmakuView aboveSubview:self.imageView];
    
    NSString *danmakufile = [[NSBundle mainBundle] pathForResource:@"danmakufile" ofType:nil];
    self.danmakus = [NSArray arrayWithContentsOfFile:danmakufile];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.danmakuView.isPrepared) {
        [self.danmakuView prepareDanmakus:nil];
    }
}

#pragma mark - 

- (IBAction)onPlayBtnClick:(UIButton *)sender {
    if (self.danmakuView.isPrepared) {
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(randomSendNewDanmaku) userInfo:nil repeats:YES];
        }
        [self.danmakuView play];
    }
}

- (void)randomSendNewDanmaku {
    self.index ++;
    if (self.index >= self.danmakus.count) {
        return;
    }
    NSDictionary *danmaku = self.danmakus[self.index];
    NSArray *pArray = [danmaku[@"p"] componentsSeparatedByString:@","];
    
    HJDanmakuType type = [pArray[1] integerValue] % 3;
    DemoDanmakuModel *danmakuModel = [[DemoDanmakuModel alloc] initWithType:type];
    danmakuModel.text = danmaku[@"m"];
    danmakuModel.textFont = [pArray[2] integerValue] == 1 ? [UIFont systemFontOfSize:20]: [UIFont systemFontOfSize:18];
    danmakuModel.textColor = [DanmakuFactory colorWithHexStr:pArray[3]];
    [self.danmakuView sendDanmaku:danmakuModel forceRender:NO];
}

- (IBAction)onPauseBtnClick:(id)sender {
    [self.danmakuView pause];
}

- (IBAction)onSendClick:(id)sender {
    HJDanmakuType type = arc4random() % 3;
    DemoDanmakuModel *danmakuModel = [[DemoDanmakuModel alloc] initWithType:type];
    danmakuModel.selfFlag = YES;
    danmakuModel.text = @"😊😊olinone.com😊😊";
    danmakuModel.textFont = [UIFont systemFontOfSize:20];
    danmakuModel.textColor = [UIColor blueColor];
    [self.danmakuView sendDanmaku:danmakuModel forceRender:YES];
}

#pragma mark - delegate

- (void)prepareCompletedWithDanmakuView:(HJDanmakuView *)danmakuView {
    [self.danmakuView play];
}

#pragma mark - dataSource

- (CGFloat)danmakuView:(HJDanmakuView *)danmakuView widthForDanmaku:(HJDanmakuModel *)danmaku {
    DemoDanmakuModel *model = (DemoDanmakuModel *)danmaku;
    return [model.text sizeWithAttributes:@{NSFontAttributeName: model.textFont}].width + 1.0f;
}

- (HJDanmakuCell *)danmakuView:(HJDanmakuView *)danmakuView cellForDanmaku:(HJDanmakuModel *)danmaku {
    DemoDanmakuModel *model = (DemoDanmakuModel *)danmaku;
    DemoDanmakuCell *cell = [danmakuView dequeueReusableCellWithIdentifier:@"cell"];
    if (model.selfFlag) {
        cell.zIndex = 30;
        cell.layer.borderWidth = 0.5;
        cell.layer.borderColor = [UIColor redColor].CGColor;
    }
    cell.textLabel.font = model.textFont;
    cell.textLabel.textColor = model.textColor;
    cell.textLabel.text = model.text;
    return cell;
}

@end
