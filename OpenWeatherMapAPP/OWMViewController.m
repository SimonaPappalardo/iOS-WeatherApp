#import "OWMViewController.h"
#import "OWMWeatherAPP.h"
#import "OWMAlertHandlerController.h"
#import "OWMUtility.h"
#import "UIImageView+AFNetworking.h"
#import <CoreLocation/CoreLocation.h>

@interface OWMViewController ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) OWMWeatherAPP *weatherAPI;
@property (nonatomic, strong) NSArray *forecast;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, assign) CGFloat currentTemperature;
@property (nonatomic, assign) OWMTemperature currentTemperatureFormat;
@property (nonatomic, strong) NSString *imgURL;

@end

@implementation OWMViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self applyStyleToViewElements];
    
    self.imgURL = @"http://openweathermap.org/img/w/";
    self.weatherAPI = [[OWMWeatherAPP alloc] initWithAPIKey:@"ff287173dfc02d8de3aad212143202e1"];
    
    [self initCurrentLocation];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.forecastTableView addSubview:refreshControl];
    
    self.forecast = @[];
    self.currentTemperatureFormat = kOWMTempCelcius;
    
    // We want localized strings according to the prefered system language
    [self.weatherAPI setLangWithPreferedLanguage];
    
    // We want the temperatures in celcius, you can also get them in farenheit.
    [self.weatherAPI setTemperatureFormat:kOWMTempCelcius];

    [self getWeatherInformation];
    
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)applyStyleToViewElements {
    
    self.forecastTableView.backgroundColor = [UIColor clearColor];
    self.forecastTableView.allowsSelection = NO;
    
    [self applyStyleConversionButton:kOWMTempCelcius];
    
    self.dateFormatter = [[NSDateFormatter alloc]init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
    self.dateFormatter.doesRelativeDateFormatting = YES;
}

- (void)applyStyleConversionButton:(OWMTemperature)temperatureType {
    
    NSMutableAttributedString *textButtonTitle = [[NSMutableAttributedString alloc] initWithString:@"°C /°F"];
    if (temperatureType == kOWMTempCelcius) {
        [textButtonTitle setAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0,2)];
        [textButtonTitle setAttributes:@{NSForegroundColorAttributeName:[UIColor lightTextColor]} range:NSMakeRange(2,4)];
    } else {
        [textButtonTitle setAttributes:@{NSForegroundColorAttributeName:[UIColor lightTextColor]} range:NSMakeRange(0,3)];
        [textButtonTitle setAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(3,3)];
    }
    [self.conversionButton setAttributedTitle:textButtonTitle forState:UIControlStateNormal];
}

- (void)initCurrentLocation {
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)getWeatherInformation {
    
    [self.weatherAPI currentWeatherByCoordinate:self.currentLocation.coordinate withCallback:^(NSError *error, NSDictionary *result) {
        if (error) {
            [OWMAlertHandlerController displayNetworkErrorAlert];
            return;
        }
        
        self.cityName.text = [NSString stringWithFormat:@"%@, %@",
                              result[@"name"],
                              result[@"sys"][@"country"]
                              ];
        
        self.currentTemp.text = [NSString stringWithFormat:@"%.1f℃",
                                 [result[@"main"][@"temp"] floatValue] ];
        self.currentTemperature = [result[@"main"][@"temp"] floatValue];
        
        self.currentTimestamp.text =  [NSString stringWithFormat:@"Last update: %@",[_dateFormatter stringFromDate:result[@"dt"]]];
        
        self.weather.text = result[@"weather"][0][@"description"];
        NSString *iconName = result[@"weather"][0][@"icon"];
        NSString *path = [NSString stringWithFormat:@"%@%@.png",self.imgURL,iconName];
        NSURL *url = [NSURL URLWithString:path];
        [self.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
       
    }];

    [self.weatherAPI forecastWeatherByCoordinate:self.currentLocation.coordinate withCallback:^(NSError *error, NSDictionary *result) {
        if (error) {
            [OWMAlertHandlerController displayNetworkErrorAlert];
            return;
        }
        
        self.forecast = result[@"list"];
        [self.forecastTableView reloadData];
        
    }];

}

#pragma mark - Tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _forecast.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary *forecastData = [_forecast objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%.1f℃ - %@",
                            [forecastData[@"main"][@"temp"] floatValue],
                            forecastData[@"weather"][0][@"main"]
                           ];
    
    cell.textLabel.textColor = [OWMUtility getColorBasedOnWeather:forecastData[@"weather"][0][@"main"]];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    NSString *dateStringToDisplay = [_dateFormatter stringFromDate:forecastData[@"dt"]];
    
    
    cell.detailTextLabel.textColor = [UIColor lightTextColor];
    
    NSString *iconName = forecastData[@"weather"][0][@"icon"];
    if ([iconName containsString:@"n"]) {
        dateStringToDisplay = [dateStringToDisplay stringByAppendingString:@" night"];
        cell.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    }
    cell.detailTextLabel.text = dateStringToDisplay;
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    NSString *path = [NSString stringWithFormat:@"%@%@.png",self.imgURL,iconName];
    NSURL *url = [NSURL URLWithString:path];
    [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    return cell;
    
}

#pragma mark - Action methods

- (IBAction)conversionButtonTapped:(id)sender {

    NSNumber *newTemperature;
    if (self.currentTemperatureFormat == kOWMTempCelcius) {
        newTemperature = [OWMWeatherAPP tempCelsiusToFahrenheit:[NSNumber numberWithFloat:self.currentTemperature]];
        self.currentTemperatureFormat = kOWMTempFahrenheit;
    } else {
        newTemperature = [OWMWeatherAPP tempFarToCelcius:[NSNumber numberWithFloat:self.currentTemperature]];
        self.currentTemperatureFormat = kOWMTempCelcius;
    }
    self.currentTemperature = [newTemperature floatValue];
    [self applyStyleConversionButton:self.currentTemperatureFormat];
    self.currentTemp.text = [NSString stringWithFormat:@"%.1f℃",[newTemperature floatValue]];
    
}

#pragma mark - LocationManager delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.currentLocation = [[CLLocation alloc] init];
    self.currentLocation = [locations lastObject];
    [self.locationManager stopUpdatingLocation];
    [self getWeatherInformation];
}

#pragma mark - private methods

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    [self getWeatherInformation];
    [refreshControl endRefreshing];
}
    


@end
