//
//  HIDIdleTime.m
//  bluelock
//
//

#import <CoreFoundation/CoreFoundation.h>
#import "HIDIdleTime.h"

@implementation HIDIdleTime

- (id)init {
	self = [super init];
	if( self ) {
		mach_port_t masterPort;
		kern_return_t err = IOMasterPort( MACH_PORT_NULL, &masterPort );
		//[NSException raiseKernReturn:err];
		
		io_iterator_t  hidIter;
		err = IOServiceGetMatchingServices( masterPort,
										   IOServiceMatching("IOHIDSystem"), &hidIter );
		//[NSException raiseKernReturn:err];
		//NSAssert0( hidIter != NULL );
		
		_hidEntry = IOIteratorNext( hidIter );
		//NSAssert0( _hidEntry != NULL );
		IOObjectRelease(hidIter);
	}
	return self;
}

- (void)dealloc {
	if( _hidEntry ) {
		//kern_return_t err = IOObjectRelease( _hidEntry );
		//[NSException raiseKernReturn:err];
		//_hidEntry = NULL;
	}
	[super dealloc];
}

- (unsigned)idleTimeInSeconds {
#define NS_SECONDS 1000000000 // 10^9 -- number of ns in a second
	return [self idleTime] / NS_SECONDS;
}

- (uint64_t)idleTime {
	NSMutableDictionary *hidProperties;
	kern_return_t err = IORegistryEntryCreateCFProperties( _hidEntry, (CFMutableDictionaryRef*) &hidProperties, kCFAllocatorDefault, 0 );
	//[NSException raiseKernReturn:err];
	//NSAssert0( hidProperties != nil );
	[hidProperties autorelease];
	
	id hidIdleTimeObj = [hidProperties objectForKey:@"HIDIdleTime"];
	//NSAssert0( [hidIdleTimeObj isKindOfClass:[NSData class]] || [hidIdleTimeObj isKindOfClass:[NSNumber class]] );
	uint64_t result;
	if( [hidIdleTimeObj isKindOfClass:[NSData class]] ) {
		//sNSAssert0( [(NSData*)hidIdleTimeObj length] == sizeof( result ) );
		[hidIdleTimeObj getBytes:&result];
	} else {
		//ASSERT_CAST( result, long long );
		result = [hidIdleTimeObj longLongValue];
	}
	
	return result;
}

@end
