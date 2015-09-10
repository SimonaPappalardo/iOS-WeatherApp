#import <UIKit/UIKit.h>

@interface OWMViewController : UIViewController <UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UILabel *cityName;
@property (nonatomic, weak) IBOutlet UILabel *currentTemp;
@property (nonatomic, weak) IBOutlet UITableView *forecastTableView;
@property (nonatomic, weak) IBOutlet UILabel *currentTimestamp;
@property (nonatomic, weak) IBOutlet UILabel *weather;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *conversionButton;

@end
