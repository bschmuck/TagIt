//
//  TagNewLocationViewController.m
//  TagIt
//
//  Created by Brandon Schmuck on 5/31/15.
//  Copyright (c) 2015 Brandon Schmuck. All rights reserved.
//

#import "TagNewLocationViewController.h"

@interface TagNewLocationViewController()

@property (strong, nonatomic) IBOutlet UITextField *locationTextField;
@property (strong, nonatomic) IBOutlet MKMapView *currentLocationMap;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation TagNewLocationViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    _locationTextField.delegate = self;
    
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager requestAlwaysAuthorization];
    [_currentLocationMap setZoomEnabled:NO];
    [_currentLocationMap setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)tagEvent:(id)sender {
    PFObject *eventObject = [PFObject objectWithClassName:@"EventLocation"];
    eventObject[@"Description"] = _locationTextField.text;
    
    MKAnnotationView *currentLocation = _currentLocationMap.annotations[0];

    eventObject[@"Latitude"] = [NSNumber numberWithDouble:[currentLocation.annotation coordinate].latitude];
    eventObject[@"Longitude"] = [NSNumber numberWithDouble:[currentLocation.annotation coordinate].longitude];
    eventObject[@"Timestamp"] = [NSDate date];
    [eventObject saveInBackground];
}

@end
