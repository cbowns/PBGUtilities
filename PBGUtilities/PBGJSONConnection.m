//	PBGUtilities
//  PBGJSONConnection.m
//
//	Created by Patrick B. Gibson.
//

#import "PBGJSONConnection.h"
#import "JSONKit.h"

@implementation PBGJSONConnection

#ifdef PBGJSONCONNECTIONLOGGING
static BOOL logging = YES;
#else
static BOOL logging = NO;
#endif

+ (void)getFromURL:(NSURL *)inURL handleJSONResponseWithBlock:(void (^)(id responseObj))inBlock handleErrorWithBlock:(void (^)(NSError *error))errorBlock;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:inURL];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
		if (responseData == nil && error) {
			NSLog(@"ERROR: GET connection error: %@", [error localizedDescription]);
			return;
		}
        
        NSError *jsonError = nil;
        id responseObject = [responseData objectFromJSONDataWithParseOptions:JKParseOptionNone error:&jsonError];
        
        if (responseObject == nil && jsonError) {
			NSLog(@"ERROR: GET JSON Reading error: %@", [jsonError localizedDescription]);
			dispatch_async(dispatch_get_main_queue(), ^{
				errorBlock(jsonError);
			});
			return;
		}
		if (responseObject == nil) {
			NSLog(@"ERROR: GET JSON object conversion failed");
		}
        
        if (logging) {
            NSLog(@"PBGJSONINTERFACELOGGING: Response Object for GET: %@\n\n", responseObject);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            inBlock(responseObject);
        });
    });
}

+ (void)postToURL:(NSURL *)inURL withJSONSerializableObject:(id)inObj handleJSONResponseWithBlock:(void (^)(id responseObj))inBlock handleErrorWithBlock:(void (^)(NSError *error))errorBlock;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *jsonError = nil;
		NSData *jsonData = nil;

		if ([[inObj class] isSubclassOfClass:[NSArray class]]) {
			NSArray *inObject = (NSArray *)inObj;
			jsonData = [inObject JSONDataWithOptions:JKSerializeOptionNone error:&jsonError];
		} else if ([[inObj class] isSubclassOfClass:[NSDictionary class]]) {
			NSDictionary *inObject = (NSDictionary *)inObj;
			jsonData = [inObject JSONDataWithOptions:JKSerializeOptionNone error:&jsonError];
		}

        if (jsonData == nil && jsonError) {
			NSLog(@"ERROR: POST JSON Writing error: %@", [jsonError localizedDescription]);
			return;
		}
		if (jsonData == nil) {
			NSLog(@"ERROR: POST JSON object conversion failed");
		}
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:inURL];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:jsonData];
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (responseData == nil && error) {
			NSLog(@"ERROR: POST connection error: %@", [error localizedDescription]);
			dispatch_async(dispatch_get_main_queue(), ^{
				errorBlock(error);
			});
			return;
		}
        
        jsonError = nil;
        id responseObject = [responseData objectFromJSONDataWithParseOptions:JKParseOptionNone error:&jsonError];
        
        if (responseObject == nil && jsonError) {
			NSLog(@"ERROR: POST JSON Reading error: %@", [jsonError localizedDescription]);
			return;
		}

		if (responseObject == nil) {
			NSLog(@"ERROR: POST JSON object conversion failed");
		}

        if (logging) {
            NSLog(@"PBGJSONINTERFACELOGGING: Response Object for POST: %@\n\n", responseObject);
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            inBlock(responseObject);
        });
    });
}

+ (void)deleteAtURL:(NSURL *)inURL handleJSONResponseWithBlock:(void (^)(id responseObj))inBlock;
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:inURL];
		[request setHTTPMethod:@"DELETE"];
		[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

		NSURLResponse *response      = nil;
		NSError *error               = nil;

		NSData *responseData         = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

		if (responseData == nil && error) {
			NSLog(@"ERROR: DELETE connection error: %@", [error localizedDescription]);
			return;
		}

		NSError *jsonError = nil;
		id responseObject = [responseData objectFromJSONDataWithParseOptions:JKParseOptionNone error:&jsonError];

		if (responseObject == nil && jsonError) {
			NSLog(@"ERROR: DELETE JSON Reading error: %@", [jsonError localizedDescription]);
			return;
		}
		if (responseObject == nil) {
			NSLog(@"ERROR: DELETE JSON object conversion failed");
		}

		if (logging) {
			NSLog(@"PBGJSONINTERFACELOGGING: Response Object for DELETE: %@\n\n", responseObject);
		}

		dispatch_async(dispatch_get_main_queue(), ^{
			inBlock(responseObject);
		});
	});
	}


@end
