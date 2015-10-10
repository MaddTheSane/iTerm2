//
//  CharacterRunInline.m
//  iTerm2
//
//  Created by C.W. Betts on 10/9/15.
//
//

#import <Foundation/Foundation.h>
#import "CharacterRun.h"
#import "CharacterRunInline.h"

#undef CRUN_INLINE
#define CRUN_INLINE extern inline

CRUN_INLINE void CRunInitialize(CRun *run,
                                CAttrs *attrs,
                                CRunStorage *storage,
                                VT100GridCoord coord,
                                CGFloat x) {
    run->attrs = *attrs;
    run->x = x;
    run->length = 0;
    run->index = -1;
    run->next = NULL;
    run->string = nil;
    run->terminated = NO;
    run->numImageCells = 0;
    run->coord = coord;
    run->storage = [storage retain];
}

// Append codes to an existing run. It must not have a complex string already set.
CRUN_INLINE void CRunAppendSelf(CRun *run,
                                unichar code,
                                CGFloat advance) {
    assert(!run->string);
    int theIndex = [(CRunStorage*)run->storage appendCode:code andAdvance:NSMakeSize(advance, 0)];
    if (run->index < 0) {
        run->index = theIndex;
    }
    run->length++;
}

// Append a complex string to a run which has neither characters nor a string
// already set.
CRUN_INLINE void CRunAppendSelfString(CRun *run,
                                      NSString *string,
                                      int key,
                                      CGFloat advance) {
    assert(run->length == 0);
    int theIndex = [(CRunStorage*)run->storage appendCode:0 andAdvance:NSMakeSize(advance, 0)];
    if (run->index < 0) {
        run->index = theIndex;
    }
    run->string = CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)string);
    run->key = key;
}

// Allocate a new run and append a character to it. Link the new run as the
// successor of |run|.
CRUN_INLINE CRun *CRunAppendNew(CRun *run,
                                CAttrs *attrs,
                                CGFloat x,
                                unichar code,
                                VT100GridCoord coord,
                                CGFloat advance) {
    assert(!run->next);
    CRun *newRun = malloc(sizeof(CRun));
    CRunInitialize(newRun, attrs, run->storage, coord, x);
    CRunAppendSelf(newRun, code, advance);
    run->next = newRun;
    return newRun;
}

// Allocate a new run and append a complex string to it. Link the new run as
// the successor of |run|.
CRUN_INLINE CRun *CRunAppendNewString(CRun *run,
                                      CAttrs *attrs,
                                      CGFloat x,
                                      NSString *string,
                                      int key,
                                      VT100GridCoord coord,
                                      CGFloat advance) {
    assert(!run->next);
    CRun *newRun = malloc(sizeof(CRun));
    CRunInitialize(newRun, attrs, run->storage, coord, x);
    CRunAppendSelfString(newRun, string, key, advance);
    run->next = newRun;
    if (attrs->imageCode) {
        newRun->numImageCells = 1;
    }
    return newRun;
}

CRUN_INLINE CRun *CRunAppend(CRun *run,
                             CAttrs *attrs,
                             unichar code,
                             CGFloat advance,
                             CGFloat x) {
    if (run->attrs.antiAlias == attrs->antiAlias &&
        run->attrs.color == attrs->color &&
        run->attrs.fakeBold == attrs->fakeBold &&
        run->attrs.fakeItalic == attrs->fakeItalic &&
        run->attrs.underline == attrs->underline &&
        run->attrs.fontInfo == attrs->fontInfo &&
        run->attrs.imageCode == attrs->imageCode &&
        !run->terminated &&
        !run->string) {
        CRunAppendSelf(run, code, advance);
        return run;
    } else {
        return CRunAppendNew(run, attrs, x, code, VT100GridCoordMake(run->coord.x + run->length,
                                                                     run->coord.y), advance);
    }
}

CRUN_INLINE CRun *CRunAppendString(CRun *run,
                                   CAttrs *attrs,
                                   NSString *string,
                                   int key,
                                   CGFloat advance,
                                   CGFloat x) {
    if (run->length == 0 && !run->string) {
        CRunAppendSelfString(run, string, key, advance);
        if (attrs->imageCode) {
            run->numImageCells = 1;
        }
        return run;
    } else if (run->attrs.imageCode &&
               run->attrs.imageCode == attrs->imageCode &&
               run->attrs.imageLine == attrs->imageLine &&
               (run->attrs.imageColumn + run->numImageCells) == attrs->imageColumn) {
        // This is the next image cell in the run.
        run->numImageCells++;
        return run;
    } else {
        // Current run already has data so create a new complex run.
        return CRunAppendNewString(run, attrs, x, string, key,
                                   VT100GridCoordMake(run->coord.x + run->length, run->coord.y),
                                   advance);
    }
}

CRUN_INLINE void CRunDestroy(CRun *run) {
    CFRelease(run->string);
    [(CRunStorage*)run->storage release];
    if (run->next) {
        CRunDestroy(run->next);
        free(run->next);
        run->next = NULL;
    }
}

CRUN_INLINE void CRunFree(CRun *run) {
    CRunDestroy(run);
    free(run);
}

CRUN_INLINE void CRunAdvance(CRun *run, int offset) {
    assert(!run->string);
    assert(run->length >= offset);
    NSSize *advances = [(CRunStorage*)run->storage advancesFromIndex:run->index];
    for (int i = 0; i < offset; i++) {
        run->x += advances[i].width;
    }
    run->index += offset;
    run->length -= offset;
    run->coord.x += offset;
}

CRUN_INLINE CRun *CRunSplit(CRun *run, int newStart) {
    if (run->length == 0) {
        return nil;
    }
    assert(newStart < run->length);
    CRun *newRun = malloc(sizeof(CRun));
    
    // Skip past |newStart| chars
    CRunAdvance(run, newStart);
    
    // Create a new string run from the first char
    CRunInitialize(newRun, &run->attrs, run->storage, run->coord, run->x);
    CRunAppendString(newRun,
                     &run->attrs,
                     [NSString stringWithCharacters:[(CRunStorage*)run->storage codesFromIndex:run->index]
                                             length:1],
                     -1,
                     [(CRunStorage*)run->storage advancesFromIndex:run->index][0].width,
                     run->x);
    
    // Skip past that one char.
    CRunAdvance(run, 1);
    
    return newRun;
}

CRUN_INLINE CGGlyph *CRunGetGlyphs(CRun *run, int *firstMissingGlyph) {
    assert(!run->string);
    assert(run->index >= 0);
    *firstMissingGlyph = -1;
    if (run->length == 0) {
        return nil;
    }
    CGGlyph *glyphs = [(CRunStorage*)run->storage glyphsFromIndex:run->index];
    BOOL foundAllGlyphs = CTFontGetGlyphsForCharacters((CTFontRef)run->attrs.fontInfo.font,
                                                       [(CRunStorage*)run->storage codesFromIndex:run->index],
                                                       glyphs,
                                                       run->length);
    if (!foundAllGlyphs) {
        for (int i = 0; i < run->length; i++) {
            if (!glyphs[i]) {
                *firstMissingGlyph = i;
                break;
            }
        }
    }
    return glyphs;
}

CRUN_INLINE void CRunTerminate(CRun *run) {
    run->terminated = YES;
}

CRUN_INLINE NSSize *CRunGetAdvances(CRun *run) {
    assert(run->index >= 0);
    return [(CRunStorage*)run->storage advancesFromIndex:run->index];
}

CRUN_INLINE void CRunAttrsSetColor(CAttrs *attrs, CRunStorage *storage, NSColor *color) {
    attrs->color = color;
    [storage addColor:color];
}

