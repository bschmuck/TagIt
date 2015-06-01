//
//  TagListLocationsViewController.m
//  
//
//  Created by Brandon Schmuck on 5/31/15.
//
//

#import "TagListLocationsViewController.h"
#import "TagEventTableViewCell.h"

@interface TagListLocationsViewController()

@property (strong, nonatomic) NSMutableArray *eventsArray;
@property (strong, nonatomic) IBOutlet UITableView *eventsListView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sortSelector;

@end


@implementation TagListLocationsViewController

- (void)viewDidLoad{
    _eventsArray = [[NSMutableArray alloc]
                    init];
    _eventsListView.delegate = self;
    _eventsListView.dataSource = self;
    
    [self retrieveCurrentEvents:nil];
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager startUpdatingLocation];

}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *eventTableIdentifier = @"TagEventTableCell";
    TageEventTableViewCell *eventCell = (TageEventTableViewCell *)[tableView dequeueReusableCellWithIdentifier:eventTableIdentifier];
    if(eventCell == nil){
        NSArray *loadCell = [[NSBundle mainBundle] loadNibNamed:@"TagEventTableCell" owner:self options:nil];
        eventCell = [loadCell objectAtIndex:0];
    }
    
    NSDictionary *currentEvent = [_eventsArray objectAtIndex:indexPath.row];
    eventCell.eventDescription.text = currentEvent[@"Description"];
    NSDate *eventDate = currentEvent[@"Timestamp"];
    
    NSTimeInterval timePassed = [[NSDate date] timeIntervalSinceDate:eventDate];
    NSInteger minutes = floor(timePassed/60);
    //NSInteger seconds = round(timePassed - minutes * 60);
    eventCell.updateTimeLabel.text = [NSString stringWithFormat:@"%ld minutes ago", (long)minutes];
    
    eventCell.milesLabel.text = [NSString stringWithFormat:@"%0.2f", [currentEvent[@"Distance"] floatValue]];
    return eventCell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{
    return [_eventsArray count];
}

- (IBAction)retrieveCurrentEvents:(id)sender{
    PFQuery *query = [PFQuery queryWithClassName:@"EventLocation"];
    [query whereKeyExists:@"objectId"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(error){
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else{
            _eventsArray = [[NSMutableArray alloc] init];
            for(PFObject *object in objects){
                NSMutableDictionary *eventDescription = [[NSMutableDictionary alloc] init];
                eventDescription[@"Description"] = object[@"Description"];
                //eventDescription[@"Longitude"] = object[@"Longitude"];
                //eventDescription[@"Latitude"] = object[@"Latitude"];
                eventDescription[@"Timestamp"] = object[@"Timestamp"];
                [_eventsArray addObject:eventDescription];
                CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:[object[@"Latitude"] doubleValue] longitude:[object[@"Longitude"] doubleValue]];
                eventDescription[@"Location"] = eventLocation;
                double miles = [eventLocation distanceFromLocation:_locationManager.location] * 0.00062137;
                eventDescription[@"Distance"] = [NSNumber numberWithDouble:miles];
            }
        }
        switch([_sortSelector selectedSegmentIndex]){
            case 0:
                //most recent
                _eventsArray = [[_eventsArray sortedArrayUsingComparator:^NSComparisonResult(NSMutableDictionary *object1, NSMutableDictionary *object2) {
                    NSDate *first = object1[@"Timestamp"];
                    NSDate *second = object2[@"Timestamp"];
                    return [second compare:first];
                }] mutableCopy];
                break;
            case 1:
                _eventsArray = [[_eventsArray sortedArrayUsingComparator:^NSComparisonResult(NSMutableDictionary *object1, NSMutableDictionary *object2) {
                    NSDate *first = object1[@"Distance"];
                    NSDate *second = object2[@"Distance"];
                    return [first compare:second];
                }] mutableCopy];
                //distance
                break;
            case 2:
                _eventsArray = [[_eventsArray sortedArrayUsingComparator:^NSComparisonResult(NSMutableDictionary *object1, NSMutableDictionary *object2) {
                    NSDate *first = object1[@"Description"];
                    NSDate *second = object2[@"Description"];
                    return [first compare:second];
                }] mutableCopy];
                //name
                break;
            default:
                _eventsArray = [[_eventsArray sortedArrayUsingComparator:^NSComparisonResult(NSMutableDictionary *object1, NSMutableDictionary *object2) {
                    NSDate *first = object1[@"Timestamp"];
                    NSDate *second = object2[@"Timestamp"];
                    return [first compare:second];
                }] mutableCopy];
                //distance
                break;
        }
        [_eventsListView reloadData];
    }];
}

@end


