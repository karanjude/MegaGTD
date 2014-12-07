//
//  InTaskViewController.m
//  MegaGTD
//
//  Created by Karan Singh on 11/26/14.
//  Copyright (c) 2014 Karan Singh. All rights reserved.
//

#import "InTaskViewController.h"
#import "DetailViewController.h"
#import "Task.h"

@interface InTaskViewController ()

- (IBAction)newTaskCreated:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *taskDescription;
@property (weak, nonatomic) IBOutlet UILabel *taskDescriptionLabel;

@end

@implementation InTaskViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.taskDescription.delegate = self;
    self.taskDescription.backgroundColor = [UIColor colorWithRed:0.540631 green:0.788434 blue:1 alpha:.1];
    self.taskDescription.layer.borderColor = [[UIColor colorWithRed:0.540631 green:0.788434 blue:1 alpha:.5]CGColor];
    self.taskDescription.layer.borderWidth = 1;
    self.taskDescription.textColor = [UIColor grayColor];
    
    self.taskDescriptionLabel.textColor = [UIColor colorWithRed:0.540631 green:0.788434 blue:1 alpha:1];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonSystemItemCancel target:self action:@selector(home:)];
    self.navigationItem.leftBarButtonItem=newBackButton;

    
}

-(void)home:(UIBarButtonItem *)sender {
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    self.taskDescription.text = @"";
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation


- (IBAction)newTaskCreated:(id)sender {
    
    Task *newTask = (Task *)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];

    newTask.taskDescription = self.taskDescription.text;
    newTask.category = @"in";
    newTask.startDate = [NSDate date];
    
    NSError *error;
    if([self.managedObjectContext save:&error]){

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        DetailViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"TaskDetails"];
        UIColor* color = [UIColor colorWithRed:0.540631 green:0.788434 blue:1 alpha:.03];
        [controller setBackColor:color];
        controller.managedObjectContext = self.managedObjectContext;
        controller.category = @"in";
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        

        /*
        UIViewController* presentingViewController = self.presentingViewController;
        [self dismissViewControllerAnimated:NO completion:^
        {

            [[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];
            [presentingViewController presentViewController:navController animated:NO completion:nil];
        }];*/
        
        //[self.navigationController pushViewController:controller animated:YES];
        [self presentViewController:navController animated:NO completion:nil];

    }

}
@end


