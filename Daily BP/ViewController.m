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
    
    printf("History button pressed \n");
    
    sqlite3_stmt *statement;
    
    if(sqlite3_open([dbPathString UTF8String], &dailyBP) == SQLITE_OK){
        
        [arrayOfDailyBp removeAllObjects];
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM DAILYBP"];
        
        char const *query_sql = [querySql UTF8String];
        if(sqlite3_prepare_v2(dailyBP, query_sql, -1, &statement, NULL) == SQLITE_OK){
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *systolic = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)];
                NSString *diastolic = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                NSString *comment = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                
                SingleBPRow *row = [[SingleBPRow alloc] init];
                [row setSystolic:systolic];
                [row setDiastolic:diastolic];
                [row setComments:comment];
                
                [arrayOfDailyBp addObject: row];
            }
        }
        
    }
    [[self myTableView] reloadData];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrayOfDailyBp count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    SingleBPRow *row = [arrayOfDailyBp objectAtIndex:indexPath.row];
    
    NSString *bp = [NSString stringWithFormat:@"%@ \\ %@", row.systolic, row.diastolic];
    
    cell.textLabel.text = bp;
    cell.detailTextLabel.text = row.comments;
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        
        SingleBPRow *row = [arrayOfDailyBp objectAtIndex:indexPath.row];
        
        [self deleteRow:[NSString stringWithFormat:@"DELETE FROM DAILYBP WHERE SYSTOLIC is '%s'",[row.systolic UTF8String]]];
        [arrayOfDailyBp removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationRight];
    }
}

-(void) deleteRow:(NSString *) deleteQuery{
    char *err;
    if(sqlite3_exec(dailyBP, [deleteQuery UTF8String], NULL, NULL, &err)){
        printf("Row Deleted\n");
    }else{
        printf("Row not Deleted\n");
    }
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}



@end
