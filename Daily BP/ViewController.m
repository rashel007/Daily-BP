//
//  ViewController.m
//  Daily BP
//
//  Created by Estique on 10/16/16.
//  Copyright © 2016 Estique. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController{
    NSMutableArray *arrayOfDailyBp;
    sqlite3 *dailyBP;
    NSString *dbPathString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    printf("in viewDidLoad\n");
    arrayOfDailyBp = [[NSMutableArray alloc] init];
    [[self myTableView] setDelegate:self];
    [[self myTableView] setDataSource:self];
    [self createOrOpenDB];
}

-(void)createOrOpenDB{
    printf("in CreateOrOpenDB\n");
    
    NSArray *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dirPath = [docsDir objectAtIndex:0];
    
    dbPathString = [[NSString alloc] initWithString:[dirPath stringByAppendingString:@"dailybp.db"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    char *err;
    
    if(![fileManager fileExistsAtPath:dbPathString]){
        printf("DB File Not Exists \n");
        const char *dbPath = [dbPathString UTF8String];
        
        if(sqlite3_open(dbPath, &dailyBP) == SQLITE_OK){
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS DAILYBP(ID INTEGER PRIMARY KEY AUTOINCREMENT, SYSTOLIC TEXT, DIASTOLIC TEXT, COMMENTS TEXT)";
            
            if(sqlite3_exec(dailyBP, sql_stmt, NULL, NULL, &err) != SQLITE_OK){
                printf("Failed to create Database Table \n");
            }else{
                printf("Database Table Created \n");
            }
        }
        
    }else{
        printf("DB file Exists \n");
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSave:(id)sender {
    printf("Save Button Clicked\n ");
    
    if(sqlite3_open([dbPathString UTF8String], &dailyBP) == SQLITE_OK){
        printf("Sqlite open\n");
        NSString *insert_stmt = [NSString stringWithFormat:@"INSERT INTO DAILYBP(SYSTOLIC, DIASTOLIC, COMMENTS) values ('%s', '%s', '%s')", [self.systolicText.text UTF8String], [self.diastolicText.text UTF8String], [self.commentsText.text UTF8String]] ;
        
        const char *insert = [insert_stmt UTF8String];
        sqlite3_stmt *statement;
        sqlite3_prepare_v2(dailyBP, insert, -1, &statement, NULL);
        
        if(sqlite3_step(statement) == SQLITE_DONE){
            printf("New BP Added \n");
        }else{
            printf("BP not added \n");
        }
        sqlite3_reset(statement);
    }
}

- (IBAction)btnHistory:(id)sender {
}
@end
