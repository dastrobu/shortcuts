//
//  main.m
//  shortcuts
//
//  Created by Dmitry Rodionov on 21/08/16.
//  Copyright © 2016 Internals Exposed. All rights reserved.
//

@import Foundation;
@import InputMethodKit;

#include <objc/runtime.h>
#import "shortcuts.h"

static const char * const kVersion = "1.0.0";

static int usage(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSArray <NSString *> *arguments = [[NSProcessInfo processInfo] arguments];
        if (arguments.count < 2) {
            return usage();
        }
        NSString *mode = arguments[1];
        if ([mode isEqualToString:@"import"] && arguments.count >= 3) {
            BOOL force = arguments.count > 4 && [arguments[2] isEqualToString:@"--force"];
            return import(arguments[force ? 3 : 2], force);
        } else if ([mode isEqualToString:@"new"] && arguments.count >= 4) {
            BOOL force = arguments.count > 4 && [arguments[2] isEqualToString:@"--force"];
            NSUInteger userInputOffset = force ? 1 : 0;
            return new(arguments[userInputOffset+2], arguments[userInputOffset+3], force);
        }  else if ([mode isEqualToString:@"update"] && arguments.count >= 4) {
            return update(arguments[2], arguments[3]);
        } else if ([mode isEqualToString:@"list"]) {
            return list(arguments.count > 2 ? arguments[2] : nil);
        } else if ([mode isEqualToString:@"delete"] && arguments.count >= 3) {
            return delete(arguments[2]);
        }
        return usage();
    }
}

static int usage(void)
{
    printf("Command line interface to user's text replacements.\nshortcuts version: %s\n", kVersion);
    printf("\nNOTE: beware that if you use iCloud to sync your text substitutions they will be screwed up eventually\n"
           "(because that's how good iCloud sync is). But at least you may use this tool to make and restore backups 🎉.\n\n");
    printf("Usage:\n\n\t%s list [--as-plist]\n\t\tList existing text replacements. You can also specify the desired output format."
           "\n\n\t%s import [--force] /path/to/input.plist\n\t\t"
           "Import text replacement from a property list file generated by Keyboard Preferences Pane\n\t\t(see https://support.apple.com/en-au/HT204006 for details).\n\t\t"
           "The default conflict resolution strategy is that the existing entries will not be overwritten\n\t\t"
           "with those from the input file. You can alter this behaviour by specifying the --force flag."
           "\n\n\t%s new [--force] <shortcut> <phrase>\n"
           "\t\tCreate a new text replacement that expands <shortcut> to <phrase>.\n\t\t"
           "The conflict resolution strategy is conservative: you should use the --force flag to update\n\t\t"
           "existing entries (with the same <shortcut>)."
           "\n\n\t%s update <shortcut> <phrase>\n"
           "\t\tUpdate an existing entry for the same <shortcut> or creates a new one if such entry\n"
           "\t\tdoesn't exist yet. Currently this command is an alias for the 'new --force' command."
           "\n\n\t%s delete <shortcut>\n"
           "\t\tDelete the specified shortcut (if any)."
           "\n\nMade by Internals Exposed @ 2016.\n"
           "Issue tracker: https://github.com/rodionovd/shortcuts/issues\n",
           getprogname(), getprogname(), getprogname(), getprogname(), getprogname());
    return EXIT_FAILURE;
}