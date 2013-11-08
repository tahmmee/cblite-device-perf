//
//  cblitePerfViewController.m
//  cbliteperf
//
//  Created by Tommie McAfee on 11/8/13.
//  Copyright (c) 2013 Couchbase. All rights reserved.
//

#import "cblitePerfViewController.h"

@interface cblitePerfViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *result1;
@property (weak, nonatomic) IBOutlet UILabel *result2;

@end

@implementation cblitePerfViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // any dbs
    [self initCBL];
    [self initSQL];
    
    self.numdocs = 5000;  //todo also get from input
    
    // init view
    self.label.text = [[NSString alloc] initWithFormat:@"Creating %d docs...", self.numdocs];

}


- (void)initCBL
{
    // init couchbase db and delete if already exists
    CBLManager *manager = [CBLManager sharedInstance];
    NSError *error;
    CBLDatabase *db = [manager databaseNamed:@"cblperf" error: &error];
    if (db != nil){
        [db deleteDatabase:&error];
        NSLog(@"db deleted!");
    }
    self.database = [manager createDatabaseNamed: @"cblperf" error: &error];
    
}

- (void)initSQL
{
    // init sqlite db
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    _databasePath =  @"/tmp/perfdb.db"; //[[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"perfdb.db"]];
    
    NSFileManager *f = [NSFileManager defaultManager];
    
    if([f fileExistsAtPath: _databasePath] == NO){
        const char *dbpath = [_databasePath UTF8String];
        
        if(sqlite3_open(dbpath, &_sqldb) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS PERFDB (a INTEGER, b INTEGER, c VARCHAR(100))";
            if(sqlite3_exec(_sqldb, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            sqlite3_close(_sqldb);
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    // LOAD CouchbaseLite with numdocs
    NSDate *start = [NSDate date];
    [self loadCBL];
    NSDate *finised = [NSDate date];
    NSTimeInterval tsdelta = [finised timeIntervalSinceDate:start];
    
    //TODO: verify ->(unsigned long)[self.database documentCount]
    // update UI
    NSString *val = [[NSString alloc] initWithFormat:@"CB Time: %f ",  tsdelta];
    self.result1.text = val;
    
    // LOAD SQL db with numdocs and update UI
    start = [NSDate date];
    [self loadSql];
    finised = [NSDate date];
    tsdelta = [finised timeIntervalSinceDate:start];
    val = [[NSString alloc] initWithFormat:@"SQL Time: %f ",  tsdelta];
    self.result2.text = val;
    
}

- (void) loadCBL
{
    NSError *error;
    NSDictionary *contents = nil;
    
    NSString *perfstr = @"perf cbl str thousand two hundred eighty nine";
    for(int n = 1; n <= self.numdocs; n = n + 1){
        contents = @{@"a"       : [NSNumber numberWithInt:n],
                     @"b"       : [NSNumber numberWithInt:n],
                     @"c"       : [NSString stringWithFormat:@"%@", perfstr]};
        
        CBLDocument* doc = [self.database untitledDocument];
        [doc putProperties: contents error: &error];
        
    }
    
}


- (void) loadSql
{
    for(int n = 1; n <= self.numdocs; n = n + 1){
        [self saveToSQL:n];
    }
    
}

- (void) saveToSQL:(int)n
{
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    NSString *perfstr = @"perf cbl str thousand two hundred eighty nine";
    
    if(sqlite3_open(dbpath, &_sqldb) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO PERFDB (a,b,c) VALUES (\"%d\", \"%d\", \"%@\")",
                               n, n, perfstr];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_sqldb, insert_stmt, -1, &statement, NULL);
        if(sqlite3_step(statement) != SQLITE_DONE)
        {
            NSLog(@"Failed to add row");
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(_sqldb);
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
