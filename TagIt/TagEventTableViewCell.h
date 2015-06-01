//
//  TagEventTableCellTableViewCell.h
//  
//
//  Created by Brandon Schmuck on 5/31/15.
//
//

#import <UIKit/UIKit.h>

@interface TageEventTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *eventDescription;
@property (strong, nonatomic) IBOutlet UILabel *milesLabel;
@property (strong, nonatomic) IBOutlet UILabel *updateTimeLabel;

@end
