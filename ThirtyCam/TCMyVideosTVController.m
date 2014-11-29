//
//  TCMyVideosTVController.m
//  ThirtyCam
//
//  Created by Daniel Karsh on 11/28/14.
//  Copyright (c) 2014 bloocircle. All rights reserved.
//

#import "TCMyVideosTVController.h"
#import "Cognito.h"
#import "AWSLogging.h"

@interface TCMyVideosTVController (){
    NSMutableArray *_datasets;
}
@end

@implementation TCMyVideosTVController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSArray *allSets = [[AWSCognito defaultCognito] listDatasets];
    _datasets = [NSMutableArray arrayWithCapacity:allSets.count];
    [allSets enumerateObjectsUsingBlock:^(AWSCognitoDataset *obj, NSUInteger idx, BOOL *stop) {
        NSString *str = obj.name;
        if ([str containsString:@".mov"]) {
            [_datasets addObject:obj];
            
        }
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datasets.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    AWSCognitoDatasetMetadata *dataset = [_datasets objectAtIndex:indexPath.row];
    cell.textLabel.text = @"Share";
    cell.detailTextLabel.text = dataset.name;
    if ([dataset isDeleted]) {
        cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:dataset.name
                                                                        attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)}];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AWSCognitoDatasetMetadata *datasetMetadata = [_datasets objectAtIndex:indexPath.row];
        AWSCognitoDataset *dataset = [[AWSCognito defaultCognito] openOrCreateDataset:datasetMetadata.name];
        [dataset clear];
        [_datasets replaceObjectAtIndex:indexPath.row withObject:dataset];
        [self.tableView reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDataset"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        AWSCognitoDatasetMetadata *datasetMetadata = [_datasets objectAtIndex:indexPath.row];
        AWSCognitoDataset *dataset = [[AWSCognito defaultCognito] openOrCreateDataset:datasetMetadata.name];
//        CognitoDatasetViewController *controller = [segue destinationViewController];
//        controller.dataset = dataset;
    }
}

@end

