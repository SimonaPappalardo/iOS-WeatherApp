#import <Foundation/Foundation.h>

typedef enum {
    kOWMTempCelcius,
    kOWMTempFahrenheit
} OWMTemperature;

@interface OWMUtility : NSObject

+ (UIColor *) getColorBasedOnWeather:(NSString *)weatherString;

@end
