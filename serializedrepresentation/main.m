// serializedrepresentation main.m
//
// Copyright © 2011, Roy Ratcliffe, Pioneering Software, United Kingdom
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//------------------------------------------------------------------------------

// NSFileWrapper lives in AppKit not Foundation
#import <AppKit/AppKit.h>

/*
 * Turn a file wrapper to data or vice versa. The syntax is:
 *
 *	serializedrepresentation [-r] file representation
 *
 * The two arguments are paths. Option ‘r’ optionally indicates reverse
 * serialisation, i.e. from representation to file, rather than file to
 * representation.
 *
 * ‘File’ means a file wrapper and can therefore be a directory too. So by
 * default, the forward serialisation takes the ‘file’ and encloses this within
 * a file wrapper. From this wrapper, the tool extracts the serialised
 * data. Finally, the forward serialisation outputs the data to the
 * ‘representation’ path.
 *
 * The reverse serialisation process takes the ‘r’ option (short for reverse)
 * and loads the data at the path given by ‘representation.’ From this it
 * constructs a file wrapper using de-serialisation. Finally it outputs the
 * de-serialised wrapper to the path at ‘file.’ You therefore get back your
 * original file or directory tree.
 */
int main(int argc, char **argv)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL reverse = NO;
	int opt;
	while ((opt = getopt(argc, argv, "r")) != -1)
	{
		switch (opt)
		{
			case 'r':
			{
				reverse = YES;
				break;
			}
			default:
			{
				
			}
		}
	}
	argc -= optind;
	argv += optind;
	NSError *error = nil;
	if (argc == 2)
	{
		NSString *filePath = [NSString stringWithCString:argv[0] encoding:NSUTF8StringEncoding];
		NSString *dataPath = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
		if (reverse == NO)
		{
			// file --> representation
			NSFileWrapper *fileWrapper = [[[NSFileWrapper alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:0 error:&error] autorelease];
			NSData *data = [fileWrapper serializedRepresentation];
			[[NSFileManager defaultManager] createFileAtPath:dataPath contents:data attributes:nil];
		}
		else
		{
			// file <-- representation
			NSData *data = [NSData dataWithContentsOfFile:dataPath options:NSDataReadingMapped error:&error];
			NSFileWrapper *fileWrapper = [[[NSFileWrapper alloc] initWithSerializedRepresentation:data] autorelease];
			[fileWrapper writeToURL:[NSURL fileURLWithPath:filePath] options:0 originalContentsURL:nil error:&error];
		}
		if (error)
		{
			fprintf(stderr, "%s\n", [[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
		}
	}
	else
	{
		
	}
	[pool drain];
	return error ? (int)[error code] : 0;
}
