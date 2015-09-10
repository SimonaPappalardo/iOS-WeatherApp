#import "OWMUtility.h"

@implementation OWMUtility

+ (UIColor *) getColorBasedOnWeather:(NSString *)weatherString {
    
    if ([weatherString containsString:@"Clear"]) {
        return [UIColor whiteColor];
    } else if ([weatherString containsString:@"Rain"]) {
        return [UIColor darkGrayColor];
    } else if ([weatherString containsString:@"Clouds"]) {
        return [UIColor lightGrayColor];
    } else if ([weatherString containsString:@"Snow"]) {
        return [UIColor cyanColor];
    } else if ([weatherString containsString:@"Thunderstorm"]) {
        return [UIColor redColor];
    } else {
        return [UIColor greenColor];
    }
}

@end
