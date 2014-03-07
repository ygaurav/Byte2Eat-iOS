//
//  ThanksViewController.m
//  Byte2Eat
//
//  Created by Gaurav Yadav on 09/02/14.
//  Copyright (c) 2014 spiderlogic. All rights reserved.
//

#import "ThanksViewController.h"

@implementation ThanksViewController {
    CAEmitterLayer *explosionLayer;
    CAEmitterLayer *emitterLayer;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSShadow *blueShadow = [[NSShadow alloc] init];
    blueShadow.shadowBlurRadius = 3.0;
    blueShadow.shadowColor = [UIColor colorWithRed:60 green:71 blue:210 alpha:1];
    blueShadow.shadowOffset = CGSizeMake(0, 0);

    NSMutableAttributedString *thanksbutton = [[NSMutableAttributedString alloc] initWithString:@"Thanks, so are you guys"];
    NSRange range = NSMakeRange(0, [thanksbutton length]);
    [thanksbutton addAttribute:NSShadowAttributeName value:blueShadow range:range];
    [thanksbutton addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:25] range:range];
    [self.thanksButtonOutlet setAttributedTitle:thanksbutton forState:UIControlStateNormal];

    [self setUpShowerAnimation];
    [self setUpExplosionAnimation];
    [self setUpTimers];

}

- (void)setUpTimers {
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(addExplosion:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(removeExplosion:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addStars:) userInfo:nil repeats:NO];
}

- (void)setUpShowerAnimation {
    emitterLayer = [CAEmitterLayer layer];
    emitterLayer.emitterPosition = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.origin.y);
    emitterLayer.emitterZPosition = 10.0;
    emitterLayer.emitterSize = CGSizeMake(self.view.bounds.size.width, 0.0);
    emitterLayer.emitterShape = kCAEmitterLayerSphere;

    CAEmitterCell *emitterCell = [CAEmitterCell emitterCell];

    emitterCell.scale = 0.3;
    emitterCell.scaleRange = 0.3;
    emitterCell.emissionRange = (CGFloat)M_PI;
    emitterCell.lifetime = 10.0;
    emitterCell.birthRate = 0;
    emitterCell.velocity = 100.0;
    emitterCell.velocityRange = 100.0;
    emitterCell.yAcceleration = 300.0;

    emitterCell.contents = (__bridge id)[[UIImage imageNamed:@"star_blue.png"] CGImage];
    [emitterCell setName:@"emitter1"];

    CAEmitterCell *emitterCell2 = [CAEmitterCell emitterCell];
    emitterCell2.scale = 0.3;
    emitterCell2.scaleRange = 0.3;
    emitterCell2.emissionRange = (CGFloat)M_PI;
    emitterCell2.lifetime = 10.0;
    emitterCell2.birthRate = 0;
    emitterCell2.velocity = 100.0;
    emitterCell2.velocityRange = 100.0;
    emitterCell2.yAcceleration = 300.0;
    emitterCell2.contents = (__bridge id)[[UIImage imageNamed:@"star_red.png"] CGImage];
    [emitterCell2 setName:@"emitter2"];

    CAEmitterCell *emitterCell3 = [CAEmitterCell emitterCell];
    emitterCell3.scale = 0.3;
    emitterCell3.scaleRange = 0.3;
    emitterCell3.emissionRange = (CGFloat)M_PI;
    emitterCell3.lifetime = 10.0;
    emitterCell3.birthRate = 0;
    emitterCell3.velocity = 100.0;
    emitterCell3.velocityRange = 100.0;
    emitterCell3.yAcceleration = 300.0;
    emitterCell3.contents = (__bridge id)[[UIImage imageNamed:@"star_green.png"] CGImage];
    [emitterCell3 setName:@"emitter3"];

    emitterLayer.emitterCells = @[emitterCell, emitterCell2, emitterCell3];
    [self.view.layer addSublayer:emitterLayer];
}

- (void)setUpExplosionAnimation {
    explosionLayer = [CAEmitterLayer layer];
    explosionLayer.emitterPosition = CGPointMake(160, 186);
    explosionLayer.emitterSize = CGSizeMake(1, 1);
    explosionLayer.emitterShape = kCAEmitterLayerSphere;

    CAEmitterCell *explosionCell1 = [CAEmitterCell emitterCell];

    explosionCell1.birthRate = 0;
    explosionCell1.emissionLongitude = M_PI * 2;
    explosionCell1.lifetime = 3;
    explosionCell1.velocity = 300;
    explosionCell1.velocityRange = 40;
    explosionCell1.emissionRange = M_PI * 2;
    explosionCell1.spin = 3;
    explosionCell1.spinRange = 6;
    explosionCell1.scaleRange = .3;
    explosionCell1.yAcceleration = 200;
    explosionCell1.contents = (__bridge id) [[UIImage imageNamed:@"star_red.png"] CGImage];
    explosionCell1.scale = 0.3;
    explosionCell1.color =[UIColor colorWithRed:1 green:0 blue:0 alpha:0.5].CGColor;

    CAEmitterCell *explosionCell2 = [CAEmitterCell emitterCell];
    explosionCell2.birthRate = 0;
    explosionCell2.emissionLongitude = M_PI * 2;
    explosionCell2.lifetime = 3;
    explosionCell2.scaleRange = .3;
    explosionCell2.velocity = 300;
    explosionCell2.velocityRange = 40;
    explosionCell2.emissionRange = M_PI * 2;
    explosionCell2.spin = 3;
    explosionCell2.spinRange = 6;
    explosionCell2.yAcceleration = 200;
    explosionCell2.contents = (__bridge id) [[UIImage imageNamed:@"star_blue.png"] CGImage];
    explosionCell2.scale = 0.3;
    explosionCell2.color =[UIColor colorWithRed:0 green:0 blue:1 alpha:0.5].CGColor;

    CAEmitterCell *explosionCell3 = [CAEmitterCell emitterCell];
    explosionCell3.birthRate = 0;
    explosionCell3.emissionLongitude = M_PI * 2;
    explosionCell3.lifetime = 3;
    explosionCell3.scaleRange = .3;
    explosionCell3.velocity = 300;
    explosionCell3.velocityRange = 40;
    explosionCell3.emissionRange = M_PI * 2;
    explosionCell3.spin = 3;
    explosionCell3.spinRange = 6;
    explosionCell3.yAcceleration = 200;
    explosionCell3.contents = (__bridge id) [[UIImage imageNamed:@"star_green.png"] CGImage];
    explosionCell3.scale = 0.3;
    explosionCell3.color =[UIColor colorWithRed:0 green:1 blue:0 alpha:0.5].CGColor;

    [explosionCell1 setName:@"explosion1"];
    [explosionCell2 setName:@"explosion2"];
    [explosionCell3 setName:@"explosion3"];

    explosionLayer.emitterCells = @[explosionCell1,explosionCell2,explosionCell3];
    [self.view.layer addSublayer:explosionLayer];
}

- (void)addExplosion:(NSTimer *)timer {
    [explosionLayer setValue:@1000 forKeyPath:@"emitterCells.explosion1.birthRate"];
    [explosionLayer setValue:@1000 forKeyPath:@"emitterCells.explosion2.birthRate"];
    [explosionLayer setValue:@1000 forKeyPath:@"emitterCells.explosion3.birthRate"];
    [timer invalidate];
}

- (void)addStars:(NSTimer *)timer {
    [emitterLayer setValue:@20 forKeyPath:@"emitterCells.emitter1.birthRate"];
    [emitterLayer setValue:@20 forKeyPath:@"emitterCells.emitter2.birthRate"];
    [emitterLayer setValue:@20 forKeyPath:@"emitterCells.emitter3.birthRate"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)removeExplosion:(NSTimer *)timer{
    [explosionLayer setValue:@0 forKeyPath:@"emitterCells.explosion1.birthRate"];
    [explosionLayer setValue:@0 forKeyPath:@"emitterCells.explosion2.birthRate"];
    [explosionLayer setValue:@0 forKeyPath:@"emitterCells.explosion3.birthRate"];
    [timer invalidate];
}

- (IBAction)onThankTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
