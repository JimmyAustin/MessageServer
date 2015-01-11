#import "CocoaHTTPServerHeaders/HTTPServer.h"
#import "MSHTTPConnection.h"

%hook SMSApplication

-(id)init{

    [self performSelector:@selector(startServer) withObject:nil afterDelay:1];

    return %orig;
}

%new

-(void)startServer
{
    HTTPServer* httpServer = [[HTTPServer alloc] init];
    
    [httpServer setType:@"_http._tcp."];
    [httpServer setPort:12345];
    
    NSString *webPath = @"/";

    [httpServer setDocumentRoot:webPath];
    [httpServer setConnectionClass:[MSHTTPConnection class]];
	
    NSLog(@"MessageServer started.");
    NSError *error;
    if(![httpServer start:&error])
    {
        NSLog(@"Error starting HTTP Server: %@", error);
    }
}

%end
