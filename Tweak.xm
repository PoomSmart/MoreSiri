#import <substrate.h>

//#include "InspCWrapper.m"

NSArray *moreSupportedLanguages() {
    return @[
        @"en-SG",                         // English for Singapore
        @"pt-BR",                         // Portuguese for Brazil
        @"da-DK",                         // Danish
        @"nl-NL",                         // Dutch
        @"en-NZ",                         // English for New Zealand
        @"en-IN",                         // English for India
        @"ru-RU",                         // Russian
        @"sv-SE",                         // Swedish
        @"th-TH",                         // Thai
        @"tr-TR",                         // Turkish

        // as of iOS 9
        @"nb-NO",                         // Norwegian (Bokmål) (Norway)
        @"de-AT",                         // German for Austria
        @"fr-BE",                         // French for Belgium
        @"nl-BE",                         // Dutch for Belgium

        @"ar-SA",                         // Saudi Arabia (Arabic)
        @"fi-FI",                         // Finnish (Finland)
        @"he-IL",                         // Hebrew (Israel)
        @"ms-MY"                         // Malay (Malaysia)
    ];
}

NSArray *(*PSSupportedLanguages)();
NSArray *(*original_PSSupportedLanguages)();
NSArray *hax_PSSupportedLanguages() {
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:original_PSSupportedLanguages()];
    for (NSString *language in moreSupportedLanguages()) {
        if (![array containsObject:language])
            [array addObject:language];
    }
    return array;
}

NSArray *(*PSSupportedLanguages2)(void *);
NSArray *(*original_PSSupportedLanguages2)(void *);
NSArray *hax_PSSupportedLanguages2(void *block) {
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:original_PSSupportedLanguages2(block)];
    for (NSString *language in moreSupportedLanguages()) {
        if (![array containsObject:language])
            [array addObject:language];
    }
    return array;
}

%ctor {
    const char *ASSISTANT = "/System/Library/PrivateFrameworks/AssistantServices.framework/AssistantServices";
    void *assistant = dlopen(ASSISTANT, RTLD_LAZY);
    if (assistant != NULL) {
        MSImageRef ref = MSGetImageByName(ASSISTANT);
        const char *function = "__AFPreferencesBuiltInLanguages";
        PSSupportedLanguages = (NSArray *(*)())MSFindSymbol(ref, function);
        MSHookFunction((void *)PSSupportedLanguages, (void *)hax_PSSupportedLanguages, (void * *)&original_PSSupportedLanguages);
        if (kCFCoreFoundationVersionNumber >= 1129.15) {
            const char *function2 = "____AFPreferencesBuiltInLanguages_block_invoke";
            PSSupportedLanguages2 = (NSArray *(*)(void *))MSFindSymbol(ref, function2);
            MSHookFunction((void *)PSSupportedLanguages2, (void *)hax_PSSupportedLanguages2, (void * *)&original_PSSupportedLanguages2);
        }
    }
}
