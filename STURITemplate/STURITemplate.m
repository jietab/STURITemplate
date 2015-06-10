//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014-2015 Scott Talbot.

#import "STURITemplate.h"
#import "STURITemplateScanner.h"


NSString * const STURITemplateErrorDomain = @"STURITemplate";


@implementation STURITemplate {
@private
    NSArray *_components;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wall"
- (id)init {
    return nil;
}
#pragma clang diagnostic pop

- (id)initWithString:(NSString *)string {
    return [self initWithString:string error:NULL];
}

- (id)initWithString:(NSString *)string error:(NSError *__autoreleasing *)error {
    if (!string) {
        return nil;
    }

    STURITemplateScanner * const scanner = [[STURITemplateScanner alloc] initWithString:string];
    if (!scanner) {
        return nil;
    }

    NSMutableArray * const components = [[NSMutableArray alloc] init];
    while (![scanner isAtEnd]) {
        id<STURITemplateComponent> component = nil;
        if (![scanner sturit_scanTemplateComponent:&component]) {
            return nil;
        }
        [components addObject:component];
    }

    if ((self = [super init])) {
        _components = components.copy;
    }
    return self;
}

- (NSArray *)variableNames {
    NSMutableArray * const variableNames = [[NSMutableArray alloc] init];
    for (id<STURITemplateComponent> component in _components) {
        [variableNames addObjectsFromArray:component.variableNames];
    }
    return variableNames.copy;
}

- (NSString *)string {
    return [self stringByExpandingWithVariables:@{}];
}

- (NSString *)stringByExpandingWithVariables:(NSDictionary *)variables {
    NSMutableString * const urlString = [[NSMutableString alloc] init];
    for (id<STURITemplateComponent> component in _components) {
        NSString * const componentString = [component stringWithVariables:variables];
        if (!componentString) {
            return nil;
        }
        [urlString appendString:componentString];
    }
    return urlString;
}

- (NSURL *)url {
    return [self urlByExpandingWithVariables:@{}];
}

- (NSURL *)urlByExpandingWithVariables:(NSDictionary *)variables {
    NSString * const urlString = [self stringByExpandingWithVariables:variables];
    return [NSURL URLWithString:urlString];
}

- (NSString *)templatedStringRepresentation {
    NSMutableString * const templatedString = [[NSMutableString alloc] init];
    for (id<STURITemplateComponent> component in _components) {
        NSString * const componentString = component.templateRepresentation;
        if (componentString.length) {
            [templatedString appendString:componentString];
        }
    }
    return templatedString.copy;
}

@end
