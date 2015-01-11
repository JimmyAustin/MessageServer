#import <sqlite3.h>
#import <ChatKit.framework/CKConversationList.h>
#import <ChatKit.framework/CKComposition.h>
#import <ChatKit.framework/CKEntity.h>
#import <Chatkit.framework/CKConversation.h>

#import "CocoaHTTPServerHeaders/HTTPDataResponse.h"
#import "CocoaHTTPServerHeaders/HTTPLogging.h"
#import "MSHTTPConnection.h"

@implementation MSHTTPConnection

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    NSString *relativePath = [path substringFromIndex:1];

    NSArray* components = [relativePath componentsSeparatedByString:@"/"];

    if ([components[0] isEqualToString:@"getMessages"])
    {
        NSLog(@"Getting messages");
        if ([components count] != 2) 
        {
            return nil;
        } 
        
        NSString* sender = components[1];

        sqlite3 * database;

        NSString *sqLiteDb = @"/var/mobile/Library/SMS/sms.db";

        sqlite3_open([sqLiteDb UTF8String], &database);

        NSString *query = @"select message.text, message.date, handle.id from message, handle where message.handle_id = handle.ROWID and is_from_me = 0 and handle.id = ? and text != '' order by date";
        sqlite3_stmt *statement;

        NSMutableArray* responses = [NSMutableArray array];

        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [sender UTF8String], -1, NULL);
            while (sqlite3_step(statement) == SQLITE_ROW) 
            {
                char *textChars = (char *) sqlite3_column_text(statement, 0);
                int date = sqlite3_column_int(statement, 1);
                char *senderChars = (char *) sqlite3_column_text(statement, 2);

                if (textChars[0] != '\0') {
                    NSString *text = [[NSString alloc] initWithUTF8String:textChars];
                    NSNumber *dateNum = [NSNumber numberWithInt:date];
                    NSString *sender = [[NSString alloc] initWithUTF8String:senderChars];

                    [responses addObject:@{@"message":text, @"date":dateNum, @"sender":sender}];
                }
            }
            sqlite3_finalize(statement);
        }

        NSData* responseData = [NSJSONSerialization dataWithJSONObject:responses options:0 error:nil];

        return [[HTTPDataResponse alloc] initWithData:responseData];
    }
    else if ([components[0] isEqualToString:@"sendMessage"])
    {
    
        if ([components count] != 3) {
            return nil;
        }

        NSString* receipient = components[1];
        NSString* message = [components[2] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        CKConversationList* conversationList = [CKConversationList sharedConversationList];
        CKEntity* entity = [CKEntity copyEntityForAddressString:receipient];

        CKConversation * conversation = [conversationList conversationForHandles:@[[entity handle]] displayName:@"DisplayName" joinedChatsOnly:NO create:YES];
    
        NSAttributedString* text = [[NSAttributedString alloc] initWithString:message];
        CKComposition* composition = [[CKComposition alloc] initWithText:text subject:nil];
        id smsMessage = [conversation performSelector:@selector(messageWithComposition:) withObject:composition];

        [conversation sendMessage:smsMessage newComposition:YES];

        NSString* response = @"{\"code\":200}";

        return [[HTTPDataResponse alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];

    }
    else if ([components[0] isEqualToString:@"getNewMessages"])
    {

        NSDate * date = [NSDate date];
        NSNumber * previousDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"previousDate"];

        NSTimeInterval previousTime;
    
        if (previousDate == nil) {
            previousTime = 0;
        } else {
            previousTime = [previousDate doubleValue];
        }
    
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:[date timeIntervalSinceReferenceDate]] forKey:@"previousDate"];

        sqlite3 * database;

        NSString *sqLiteDb = @"/var/mobile/Library/SMS/sms.db";

        sqlite3_open([sqLiteDb UTF8String], &database);

        NSString *query = [NSString stringWithFormat:@"select message.text, message.date, handle.id from message, handle where message.handle_id = handle.ROWID and date > %f and is_from_me = 0 and text != '' order by date", previousTime];

        sqlite3_stmt *statement;

        NSMutableArray* responses = [NSMutableArray array];
        
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                char *textChars = (char *) sqlite3_column_text(statement, 0);
                int date = sqlite3_column_int(statement, 1);
                char *senderChars = (char *) sqlite3_column_text(statement, 2);

                if (textChars[0] != '\0') {
                    NSString *text = [[NSString alloc] initWithUTF8String:textChars];
                    NSNumber *dateNum = [NSNumber numberWithInt:date];
                    NSString *sender = [[NSString alloc] initWithUTF8String:senderChars];

                    [responses addObject:@{@"message":text, @"date":dateNum, @"sender":sender}];
                }        
            }
            sqlite3_finalize(statement);
        }

        NSData* responseData = [NSJSONSerialization dataWithJSONObject:responses options:0 error:nil];

        return [[HTTPDataResponse alloc] initWithData:responseData];
    }

    return [super httpResponseForMethod:method URI:path];
}
@end
