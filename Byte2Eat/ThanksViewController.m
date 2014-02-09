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
}

- (void)viewDidLoad {
    [super viewDidLoad];


    self.thanksButtonOutlet.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.3];

    NSShadow *blueShadow = [[NSShadow alloc] init];
    blueShadow.shadowBlurRadius = 3.0;
    blueShadow.shadowColor = [UIColor colorWithRed:60 green:71 blue:210 alpha:1];
    blueShadow.shadowOffset = CGSizeMake(0, 0);

    NSMutableAttributedString *thanksbutton = [[NSMutableAttributedString alloc] initWithString:@"Thanks, so are you guys"];
    NSRange range = NSMakeRange(0, [thanksbutton length]);
    [thanksbutton addAttribute:NSShadowAttributeName value:blueShadow range:range];
    [thanksbutton addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:range];
    [self.thanksButtonOutlet setAttributedTitle:thanksbutton forState:UIControlStateNormal];

    CAEmitterLayer *emitterLayer = [CAEmitterLayer layer];
    emitterLayer.emitterPosition = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.origin.y);
    emitterLayer.emitterZPosition = 10.0;
    emitterLayer.emitterSize = CGSizeMake(self.view.bounds.size.width, 0.0);
    emitterLayer.emitterShape = kCAEmitterLayerSphere;

    // The CAEmitterCell class represents one source of particles being emitted by a CAEmitterLayer object
    CAEmitterCell *emitterCell = [CAEmitterCell emitterCell];

    emitterCell.scale = 0.3;
    emitterCell.scaleRange = 0.3;
    emitterCell.emissionRange = (CGFloat)M_PI;
    emitterCell.lifetime = 10.0;
    emitterCell.birthRate = 20.0;
    emitterCell.velocity = 100.0;
    emitterCell.velocityRange = 100.0;
    emitterCell.yAcceleration = 300.0;

    emitterCell.contents = (__bridge id)[[UIImage imageNamed:@"star_blue.png"] CGImage];

    CAEmitterCell *emitterCell2 = [CAEmitterCell emitterCell];
    emitterCell2.scale = 0.3;
    emitterCell2.scaleRange = 0.3;
    emitterCell2.emissionRange = (CGFloat)M_PI;
    emitterCell2.lifetime = 10.0;
    emitterCell2.birthRate = 20.0;
    emitterCell2.velocity = 100.0;
    emitterCell2.velocityRange = 100.0;
    emitterCell2.yAcceleration = 300.0;
    emitterCell2.contents = (__bridge id)[[UIImage imageNamed:@"star_red.png"] CGImage];

    CAEmitterCell *emitterCell3 = [CAEmitterCell emitterCell];
    emitterCell3.scale = 0.3;
    emitterCell3.scaleRange = 0.3;
    emitterCell3.emissionRange = (CGFloat)M_PI;
    emitterCell3.lifetime = 10.0;
    emitterCell3.birthRate = 20.0;
    emitterCell3.velocity = 100.0;
    emitterCell3.velocityRange = 100.0;
    emitterCell3.yAcceleration = 300.0;
    emitterCell3.contents = (__bridge id)[[UIImage imageNamed:@"star_green.png"] CGImage];

    emitterLayer.emitterCells = @[emitterCell, emitterCell2, emitterCell3];

    explosionLayer = [CAEmitterLayer layer];
    explosionLayer.emitterPosition = CGPointMake(160, 186);
    explosionLayer.emitterSize = CGSizeMake(20, 20);
    explosionLayer.emitterShape = kCAEmitterLayerSphere;

    CAEmitterCell*sparkleCell = [CAEmitterCell emitterCell];
    sparkleCell.birthRate = 1000;
    sparkleCell.emissionLongitude = M_PI * 2;
    sparkleCell.lifetime = 1;
    sparkleCell.velocity = 200;
    sparkleCell.velocityRange = 40;
    sparkleCell.emissionRange = M_PI * 2;
    sparkleCell.spin = 3;
    sparkleCell.spinRange = 6;
    sparkleCell.yAcceleration = 60;
    sparkleCell.contents = (__bridge id) [[UIImage imageNamed:@"smoke.png"] CGImage];
    sparkleCell.scale = 0.03;
    sparkleCell.alphaSpeed = -0.12;
    sparkleCell.color =[UIColor colorWithRed:0 green:0 blue:1 alpha:0.5].CGColor;

    [self.view.layer addSublayer:explosionLayer];

    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeEmitter:) userInfo:nil repeats:NO];

    [self.view.layer addSublayer:emitterLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)removeEmitter:(NSTimer *)timer{
    [explosionLayer removeFromSuperlayer];
    [timer invalidate];
}

- (IBAction)onThankTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
