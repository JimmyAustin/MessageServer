#import "MyHTTPConnection.h"
#import "HTTPDynamicFileResponse.h"
#import "HTTPResponseTest.h"
#import "HTTPLogging.h"

// Log levels: off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_WARN; // | HTTP_LOG_FLAG_TRACE;


@implementation MyHTTPConnection

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	// Use HTTPConnection's filePathForURI method.
	// This method takes the given path (which comes directly from the HTTP request),
	// and converts it to a full path by combining it with the configured document root.
	// 
	// It also does cool things for us like support for converting "/" to "/index.html",
	// and security restrictions (ensuring we don't serve documents outside configured document root folder).
	
	NSString *filePath = [self filePathForURI:path];

	NSString *relativePath = [filePath substringFromIndex:[documentRoot length] + 1];

    NSArray* components = [relativePath componentsSeparatedByString:@"/"];

	if ([components[0] isEqualToString:@"getMessages"])
	{
		HTTPLogVerbose(@"%@[%p]: Serving up dynamic content", THIS_FILE, self);
		
		// The index.html file contains several dynamic fields that need to be completed.
		// For example:
		// 
		// Computer name: %%COMPUTER_NAME%%
		// 
		// We need to replace "%%COMPUTER_NAME%%" with whatever the computer name is.
		// We can accomplish this easily with the HTTPDynamicFileResponse class,
		// which takes a dictionary of replacement key-value pairs,
		// and performs replacements on the fly as it uploads the file.
		
		NSMutableDictionary *replacementDict = [NSMutableDictionary dictionaryWithCapacity:5];
		
		[replacementDict setObject:computerName forKey:@"JSONRESPONSE"];
		
		HTTPLogVerbose(@"%@[%p]: replacementDict = \n%@", THIS_FILE, self, replacementDict);

        NSLog(@"FIlepath:%@",[self filePathForURI:path]);
        NSLog(@"Config Doc Root:%@",[config documentRoot]);
        NSLog(@"Componenets:%@",components);

        return [[HTTPDynamicFileResponse alloc] initWithFilePath:[documentRoot stringByAppendingString:@"/jsonResponse.html"]
		                                            forConnection:self
		                                                separator:@"%%"
		                                    replacementDictionary:replacementDict];
	}
	else if ([components[0] isEqualToString:@"sendMessage"])
	{
        HTTPLogVerbose(@"%@[%p]: Serving up dynamic content", THIS_FILE, self);

        // The index.html file contains several dynamic fields that need to be completed.
        // For example:
        //
        // Computer name: %%COMPUTER_NAME%%
        //
        // We need to replace "%%COMPUTER_NAME%%" with whatever the computer name is.
        // We can accomplish this easily with the HTTPDynamicFileResponse class,
        // which takes a dictionary of replacement key-value pairs,
        // and performs replacements on the fly as it uploads the file.


        NSMutableDictionary *replacementDict = [NSMutableDictionary dictionaryWithCapacity:5];

        [replacementDict setObject:@"Sending message" forKey:@"JSONRESPONSE"];

        HTTPLogVerbose(@"%@[%p]: replacementDict = \n%@", THIS_FILE, self, replacementDict);

        NSLog(@"FIlepath:%@",[self filePathForURI:path]);
        NSLog(@"Config Doc Root:%@",[config documentRoot]);
        NSLog(@"Componenets:%@",components);
        return [[HTTPDynamicFileResponse alloc] initWithFilePath:[[config documentRoot] stringByAppendingString:@"/jsonResponse.html"]
                                                   forConnection:self
                                                       separator:@"%%"
                                           replacementDictionary:replacementDict];


	}
	
	return [super httpResponseForMethod:method URI:path];
}

@end
