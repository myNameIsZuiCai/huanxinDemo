//
//  rootTabbarController.m
//  环信test
//
//  Created by 上海均衡 on 2016/12/23.
//  Copyright © 2016年 上海均衡. All rights reserved.
//

#import "rootTabbarController.h"
#import "conversationViewController.h"
#import "contactViewController.h"
#import "settingViewController.h"
@interface rootTabbarController ()

@end

@implementation rootTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpChildViewController];
}
-(void)setUpChildViewController{
    
    conversationViewController *conversation=[[conversationViewController alloc]init];
    [self setupChildViewControllers:conversation title:@"消息" image:@"" selectedImage:@""];
    contactViewController *contact=[[contactViewController alloc]init];
    [self setupChildViewControllers:contact title:@"联系人" image:@"" selectedImage:@""];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    settingViewController *setting= [story instantiateViewControllerWithIdentifier:@"set"];
    [self setupChildViewControllers:setting title:@"设置" image:@"" selectedImage:@""];
    
}

- (void)setupChildViewControllers:(UIViewController *)childVC title:(NSString *)title image:(NSString *) deselectImage selectedImage:(NSString *) selectedImage{

    childVC.title=title;
    UIImage *selected=[UIImage imageNamed:selectedImage];
    childVC.tabBarItem.selectedImage=[selected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *deselected=[UIImage imageNamed:deselectImage];
    childVC.tabBarItem.image=[deselected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    //包装一个导航控制器
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:childVC];
    [self addChildViewController:nav];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
