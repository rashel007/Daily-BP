//
//  ViewController.h
//  Daily BP
//
//  Created by Estique on 10/16/16.
//  Copyright © 2016 Estique. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "SingleBPRow.h"

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *systolicText;
@property (strong, nonatomic) IBOutlet UITextField *diastolicText;
@property (strong, nonatomic) IBOutlet UITextField *commentsText;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

- (IBAction)btnSave:(id)sender;
- (IBAction)btnHistory:(id)sender;

@end

