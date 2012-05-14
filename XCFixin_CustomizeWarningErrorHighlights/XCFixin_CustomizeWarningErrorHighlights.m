#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#import "XCFixin.h"


static IMP gOriginalnewMessageAttributesForFont = nil;


@interface DVTTextAnnotationTheme : NSObject{}
- (id)initWithHighlightColor:(id)arg1 borderTopColor:(id)arg2 borderBottomColor:(id)arg3 overlayGradient:(id)arg4 messageBubbleBorderColor:(id)arg5 messageBubbleGradient:(id)arg6 caretColor:(id)arg7 highlightedRangeBorderColor:(id)arg8;
@end


@interface XCFixin_CustomizeWarningErrorHighlights : NSObject{
}

@end

static DVTTextAnnotationTheme * warningTheme;
static DVTTextAnnotationTheme * errorTheme;
static DVTTextAnnotationTheme * analyzerTheme;


@implementation XCFixin_CustomizeWarningErrorHighlights

static void overridenewMessageAttributesForFont(id self, SEL _cmd, DVTTextAnnotationTheme* arg1, id arg2){

	const char* className = class_getName([self class]);	
	DVTTextAnnotationTheme * newTheme  = arg1;

	//NSLog(@">>> %s\n", className);
	if (  strcmp(className, "IDEBuildIssueStaticAnalyzerResultAnnotation") == 0 ){	// apply our own theme for Warning Messages	
		newTheme = analyzerTheme;
	}
	else if (  strcmp(className, "IDEDiagnosticErrorAnnotation") == 0 ||
		strcmp(className, "IDEBuildIssueErrorAnnotation") == 0  ){		// apply our own theme for Error Messages	
		newTheme = errorTheme;
	}
	else if (  strcmp(className, "IDEDiagnosticWarningAnnotation") ||
		strcmp(className, "IDEBuildIssueWarningAnnotation") == 0){	// apply our own theme for Warning Messages	
		newTheme = warningTheme;
	}

    ((void (*)(id, SEL, DVTTextAnnotationTheme*, id))gOriginalnewMessageAttributesForFont)(self, _cmd , newTheme, arg2);
}

+ (void)pluginDidLoad: (NSBundle *)plugin{
	
    XCFixinPreflight();

	//define gradient for warning text highlight
    NSGradient *gWarning = [[NSGradient alloc] initWithColorsAndLocations: [NSColor colorWithDeviceHue: 0.125 saturation: 1.0 brightness: 1.0 alpha: 1.0], 0.0,
																		[NSColor colorWithDeviceHue: 0.1667 saturation: 0.3 brightness: 1.0 alpha: 1.0], 0.5,
																		[NSColor colorWithDeviceHue: 0.125 saturation: 1.0 brightness: 1.0 alpha: 1.0], 1.0, nil];
	//define warning text highlight theme
	warningTheme = 
	[[DVTTextAnnotationTheme alloc] initWithHighlightColor: [NSColor colorWithDeviceHue: 0.1667 saturation: 1.0 brightness: 1.0 alpha: 0.15]
											borderTopColor: [NSColor colorWithDeviceHue: 0.1667 saturation: 0.5 brightness: 1.0 alpha: 0.30]
										 borderBottomColor: [NSColor colorWithDeviceHue: 0.1667 saturation: 0.5 brightness: 1.0 alpha: 0.30]
										   overlayGradient: nil
								  messageBubbleBorderColor: [NSColor colorWithDeviceHue: 0.1667 saturation: 1.0 brightness: 1.0 alpha: 0.30] 
									 messageBubbleGradient: gWarning
												caretColor: [NSColor yellowColor]  
							   highlightedRangeBorderColor: [NSColor clearColor] 
	 ];
	[gWarning release];
	
	//define gradient for error text highlight
    NSGradient *gError = [[NSGradient alloc] initWithColorsAndLocations: [NSColor colorWithDeviceHue: 0.0 saturation: 1.0 brightness: 0.33 alpha: 1.0], 0.0,
																		[NSColor colorWithDeviceHue: 0.0 saturation: 0.75 brightness: 0.75 alpha: 1.0], 0.5,
																		[NSColor colorWithDeviceHue: 0.0 saturation: 1.0 brightness: 0.33 alpha: 1.0], 1.0, nil];
	
	//define error text highlight theme
	errorTheme = 
	[[DVTTextAnnotationTheme alloc] initWithHighlightColor: [NSColor colorWithDeviceHue: 0.0 saturation: 0.75 brightness: 1.0 alpha: 0.15] 
											borderTopColor: [NSColor colorWithDeviceHue: 0.0 saturation: 0.75 brightness: 1.0 alpha: 0.30]
										 borderBottomColor: [NSColor colorWithDeviceHue: 0.0 saturation: 0.75 brightness: 1.0 alpha: 0.30]
										   overlayGradient: nil
								  messageBubbleBorderColor: [NSColor colorWithDeviceHue: 0.0 saturation: 0.75 brightness: 1.0 alpha: 0.30] 
									 messageBubbleGradient: gError
												caretColor: [NSColor redColor]  
							   highlightedRangeBorderColor: [NSColor clearColor] 
	];
	[gError release];

	//define gradient for static Analyzer text highlight
    NSGradient *gAnalyzer = [[NSGradient alloc] initWithColorsAndLocations: [NSColor colorWithDeviceHue: 0.611 saturation: 1.00 brightness: 0.25 alpha: 1.0], 0.0,
																		[NSColor colorWithDeviceHue: 0.611 saturation: 1.00 brightness: 0.75 alpha: 1.0], 0.5,
																		[NSColor colorWithDeviceHue: 0.611 saturation: 1.00 brightness: 0.25 alpha: 1.0], 1.0, nil];
	
	//define static Analyzer text highlight theme
	analyzerTheme = 
	[[DVTTextAnnotationTheme alloc] initWithHighlightColor: [NSColor colorWithDeviceHue: 0.611 saturation: 1.00 brightness: 1.0 alpha: 0.25] 
											borderTopColor: [NSColor colorWithDeviceHue: 0.611 saturation: 1.00 brightness: 1.0 alpha: 0.50]
										 borderBottomColor: [NSColor colorWithDeviceHue: 0.611 saturation: 1.00 brightness: 1.0 alpha: 0.50]
										   overlayGradient: nil
								  messageBubbleBorderColor: [NSColor colorWithDeviceHue: 0.611 saturation: 1.00 brightness: 1.0 alpha: 0.50] 
									 messageBubbleGradient: gAnalyzer
												caretColor: [NSColor blueColor]  
							   highlightedRangeBorderColor: [NSColor clearColor] 
	 ];
	[gAnalyzer release];

	gOriginalnewMessageAttributesForFont = XCFixinOverrideMethodString(@"DVTTextAnnotation", @selector(setTheme:forState:), (IMP)&overridenewMessageAttributesForFont);
		XCFixinAssertOrPerform(gOriginalnewMessageAttributesForFont, goto failed);
    XCFixinPostflight();
}

@end