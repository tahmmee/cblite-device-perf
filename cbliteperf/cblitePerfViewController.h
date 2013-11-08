//
//  cblitePerfViewController.h
//  cbliteperf
//
//  Created by Tommie McAfee on 11/8/13.
//  Copyright (c) 2013 Couchbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import <sqlite3.h>

@interface cblitePerfViewController : UIViewController

@property (strong, nonatomic) CBLDatabase *database;
@property int numdocs;

@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *sqldb;

@end
