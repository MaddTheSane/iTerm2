//
//  iTermImageInfo.m
//  iTerm2
//
//  Created by George Nachman on 5/11/15.
//
//

#import "iTermImageInfo.h"
#import "iTermAnimatedImageInfo.h"
#import "NSData+iTerm.h"
#import "NSImage+iTerm.h"
#import "NSWorkspace+iTerm.h"

static NSString *const kImageInfoSizeKey = @"Size";
static NSString *const kImageInfoImageKey = @"Image";  // data
static NSString *const kImageInfoPreserveAspectRatioKey = @"Preserve Aspect Ratio";
static NSString *const kImageInfoFilenameKey = @"Filename";
static NSString *const kImageInfoCodeKey = @"Code";

@interface iTermImageInfo ()

@property(nonatomic, strong) NSMutableDictionary *embeddedImages;  // frame number->downscaled image
@property(nonatomic, assign) unichar code;
@property(nonatomic, strong) iTermAnimatedImageInfo *animatedImage;  // If animated GIF, this is nonnil
@end

@implementation iTermImageInfo {
    NSData *_data;
}

- (instancetype)initWithCode:(unichar)code {
    self = [super init];
    if (self) {
        _code = code;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _size = [dictionary[kImageInfoSizeKey] sizeValue];
        _data = dictionary[kImageInfoImageKey];
        _animatedImage = [[iTermAnimatedImageInfo alloc] initWithData:_data];
        if (!_animatedImage) {
            _image = [[NSImage alloc] initWithData:dictionary[kImageInfoImageKey]];
        }
        _preserveAspectRatio = [dictionary[kImageInfoPreserveAspectRatioKey] boolValue];
        _filename = [dictionary[kImageInfoFilenameKey] copy];
        _code = [dictionary[kImageInfoCodeKey] shortValue];
        if (!_size.width ||
            !_size.height ||
            (!_image && !_animatedImage)) {
            return nil;
        }
    }
    return self;
}


- (void)setImageFromImage:(NSImage *)image data:(NSData *)data {
    _animatedImage = [[iTermAnimatedImageInfo alloc] initWithData:data];

    _data = data;

    _image = image;
}

- (NSString *)imageType {
    NSString *type = [_data uniformTypeIdentifierForImageData];
    if (type) {
        return type;
    }

    return (NSString *)kUTTypeImage;
}

- (NSDictionary *)dictionary {
    return @{ kImageInfoSizeKey: [NSValue valueWithSize:_size],
              kImageInfoImageKey: _data ?: [NSData data],
              kImageInfoPreserveAspectRatioKey: @(_preserveAspectRatio),
              kImageInfoFilenameKey: _filename ?: @"",
              kImageInfoCodeKey: @(_code)};
}


- (BOOL)animated {
    return _animatedImage != nil;
}

- (NSImage *)image {
    if (_animatedImage) {
        return [_animatedImage currentImage];
    } else {
        return _image;
    }
}

- (NSImage *)imageEmbeddedInRegionOfSize:(NSSize)region {
    if (!_image && !_animatedImage) {
        return nil;
    }
    if (!_embeddedImages) {
        _embeddedImages = [[NSMutableDictionary alloc] init];
    }
    int frame = _animatedImage.currentFrame;  // 0 if not animated
    NSImage *embeddedImage = _embeddedImages[@(frame)];

    if (!NSEqualSizes(embeddedImage.size, region)) {
        NSImage *canvas = [[NSImage alloc] init];
        NSSize size;
        NSImage *theImage;
        if (_animatedImage) {
            theImage = [_animatedImage imageForFrame:frame];
        } else {
            theImage = _image;
        }
        if (!_preserveAspectRatio) {
            size = region;
        } else {
            double imageAR = theImage.size.width / theImage.size.height;
            double canvasAR = region.width / region.height;
            if (imageAR > canvasAR) {
                // image is wider than canvas, add black bars on top and bottom
                size = NSMakeSize(region.width, region.width / imageAR);
            } else {
                // image is taller than canvas, add black bars on sides
                size = NSMakeSize(region.height * imageAR, region.height);
            }
        }
        [canvas setSize:region];
        [canvas lockFocus];
        [theImage drawInRect:NSMakeRect((region.width - size.width) / 2,
                                        (region.height - size.height) / 2,
                                        size.width,
                                        size.height)];
        [canvas unlockFocus];

        self.embeddedImages[@(frame)] = canvas;
    }
    return _embeddedImages[@(frame)];
}

- (NSString *)nameForNewSavedTempFile {
    NSString *name = nil;
    if (_filename.pathExtension.length) {
        // The filename has an extension. Preserve its name in the tempfile's name,
        // and especially importantly, preserve its extension.
        NSString *suffix = [@"." stringByAppendingString:_filename.lastPathComponent];
        name = [[NSWorkspace sharedWorkspace] temporaryFileNameWithPrefix:@"iTerm2."
                                                                   suffix:suffix];
    } else {
        // Empty extension case. Try to guess the exetnsion.
        NSString *extension = [NSImage extensionForUniformType:self.imageType];
        if (extension) {
            extension = [@"." stringByAppendingString:extension];
        }
        name = [[NSWorkspace sharedWorkspace] temporaryFileNameWithPrefix:@"iTerm2."
                                                                   suffix:extension];
    }
    [self.data writeToFile:name atomically:NO];
    return name;
}

- (NSPasteboardItem *)pasteboardItem {
    NSPasteboardItem *pbItem = [[NSPasteboardItem alloc] init];
    NSArray *types;
    NSString *imageType = self.imageType;
    if (imageType) {
        types = @[ (NSString *)kUTTypeFileURL, (NSString *)imageType ];
    } else {
        types = @[ (NSString *)kUTTypeFileURL ];
    }
    [pbItem setDataProvider:self forTypes:types];

    return pbItem;
}

#pragma mark - NSPasteboardItemDataProvider

- (void)pasteboard:(NSPasteboard *)pasteboard item:(NSPasteboardItem *)item provideDataForType:(NSString *)type {
    if ([type isEqualToString:(NSString *)kUTTypeFileURL]) {
        // Write image to a temp file and provide its location.
        [item setString:[[NSURL fileURLWithPath:self.nameForNewSavedTempFile] absoluteString]
                forType:(NSString *)kUTTypeFileURL];
    } else {
        if ([type isEqualToString:(NSString *)kUTTypeImage] && ![_data uniformTypeIdentifierForImageData]) {
            [item setData:_data forType:type];
        } else {
            // Provide our data, which is already in the format requested by |type|.
            [item setData:self.data forType:type];
        }
    }
}

@end
