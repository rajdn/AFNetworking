// Spot.m
//
// Copyright (c) 2011 Gowalla (http://gowalla.com/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
#import "Spot.h"

#import "AFGowallaAPIClient.h"

@implementation Spot
@synthesize name = _name;
@synthesize imageURLString = _imageURLString;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@dynamic location;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.name = [attributes valueForKeyPath:@"name"];
    self.imageURLString = [attributes valueForKeyPath:@"image_url"];
    self.latitude = [attributes valueForKeyPath:@"lat"];
    self.longitude = [attributes valueForKeyPath:@"lng"];
    
    return self;
}

- (void)dealloc {
    [_name release];
    [_imageURLString release];
    [_latitude release];
    [_longitude release];
    [super dealloc];
}

- (CLLocation *)location {
    return [[[CLLocation alloc] initWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]] autorelease];
}

+ (void)spotsWithURLString:(NSString *)urlString near:(CLLocation *)location parameters:(NSDictionary *)parameters withBlock:(AFRecordsBlock)block {
    NSDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
	if (location) {
		[mutableParameters setValue:[NSString stringWithFormat:@"%1.7f", location.coordinate.latitude] forKey:@"lat"];
		[mutableParameters setValue:[NSString stringWithFormat:@"%1.7f", location.coordinate.longitude] forKey:@"lng"];
	}
    
    [[AFGowallaAPIClient sharedClient] getPath:urlString parameters:mutableParameters callback:[AFHTTPOperationCallback callbackWithSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *data) {
		if (block) {
            NSMutableArray *mutableRecords = [NSMutableArray array];
            for (NSDictionary *attributes in [data valueForKeyPath:@"spots"]) {
                Spot *spot = [[[Spot alloc] initWithAttributes:attributes] autorelease];
                [mutableRecords addObject:spot];
            }
            
            block([NSArray arrayWithArray:mutableRecords]);
        }
	}]];
}

@end
