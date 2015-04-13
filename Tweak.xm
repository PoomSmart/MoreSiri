#import <substrate.h>
#import "../PS.h"

NSArray *moreSupportedLanguages()
{
	return @[
				@"en-SG", // English for Singapore
				@"pt-BR", // Portuguese for Brazil
				@"da-DK", // Danish
				@"nl-NL", // Dutch
				@"en-NZ", // English for New Zealand
				@"en-IN", // English for India
				@"ru-RU", // Russian
				@"sv-SE", // Swedish
				@"th-TH", // Thai
				@"tr-TR" // Turkish
	];
}

NSArray *(*PSSupportedLanguages)();
NSArray *(*original_PSSupportedLanguages)();
NSArray *hax_PSSupportedLanguages()
{
	NSMutableArray *array = [original_PSSupportedLanguages() mutableCopy];
	for (NSString *language in moreSupportedLanguages()) {
		if (![array containsObject:language])
			[array addObject:language];
	}
	return array;
}

NSArray *(*PSSupportedLanguages2)(void *);
NSArray *(*original_PSSupportedLanguages2)(void *);
NSArray *hax_PSSupportedLanguages2(void *block)
{
	NSMutableArray *array = [original_PSSupportedLanguages2(block) mutableCopy];
	for (NSString *language in moreSupportedLanguages()) {
		if (![array containsObject:language])
			[array addObject:language];
	}
	return array;
}

%group VoiceTrigger

%hook VTPreferences

- (NSString *)localizedTriggerPhraseForLanguageCode:(NSString *)languageCode
{
	if ([languageCode isEqualToString:@"th-TH"])
		return @"หวัดดี Siri";
	if ([languageCode isEqualToString:@"da-DK"])
		return @"Hej Siri";
	if ([languageCode isEqualToString:@"nb-NO"])
		return @"Hei Siri";
	if ([languageCode isEqualToString:@"ru-RU"])
		return @"Привет Siri";
	/*if ([languageCode isEqualToString:@"nl-NL"])
		return @"??? Siri";*/
	/*if ([languageCode isEqualToString:@"pt-BR"])
		return @"??? Siri";*/
	/*if ([languageCode isEqualToString:@"sv-SE"])
		return @"??? Siri";*/
	/*if ([languageCode isEqualToString:@"tr-TR"])
		return @"??? Siri";*/
	return %orig;
}

%end

%end

%ctor
{
	const char *ASSISTANT = "/System/Library/PrivateFrameworks/AssistantServices.framework/AssistantServices";
	const char *VT = "/System/Library/PrivateFrameworks/VoiceTrigger.framework/VoiceTrigger";
	void *assistant = dlopen(ASSISTANT, RTLD_LAZY);
	if (assistant != NULL) {
		MSImageRef ref = MSGetImageByName(ASSISTANT);
		const char *function = "__AFPreferencesBuiltInLanguages";
		PSSupportedLanguages = (NSArray *(*)())MSFindSymbol(ref, function);
		MSHookFunction((void *)PSSupportedLanguages, (void *)hax_PSSupportedLanguages, (void **)&original_PSSupportedLanguages);
		if (isiOS8Up) {
			const char *function2 = "____AFPreferencesBuiltInLanguages_block_invoke";
			PSSupportedLanguages2 = (NSArray *(*)(void *))MSFindSymbol(ref, function2);
			MSHookFunction((void *)PSSupportedLanguages2, (void *)hax_PSSupportedLanguages2, (void **)&original_PSSupportedLanguages2);
			void *trigger = dlopen(VT, RTLD_LAZY);
			if (trigger != NULL) {
				%init(VoiceTrigger);
			}
		}
	}
}
