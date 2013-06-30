//
//  HNHRoundedSecureTextFieldCell.m
//
//  Created by Michael Starke on 07.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#define BUTTON_WIDTH 25

#import "HNHRoundedSecureTextFieldCell.h"
#import "HNHSecureTextView.h"

@interface HNHRoundedSecureTextFieldCell () {
  id _fieldEditor;
}

/* ButtonCell used for Rendering and handling actions */
@property (nonatomic, retain) NSButtonCell *buttonCell;
@property (nonatomic, retain) NSSecureTextFieldCell *secureCell;

- (NSRect)_buttonCellForFrame:(NSRect)cellFrame;
- (NSRect)_textCellForFrame:(NSRect)cellFrame;
- (NSButtonCell *)_allocButtonCell;
- (NSSecureTextFieldCell *)_allocSecureCell;

@end

@implementation HNHRoundedSecureTextFieldCell

- (id)init {
  self = [super init];
  if(self) {
    _displayType = HNHSecureTextFieldAlwaysHide;
    _buttonCell = [self _allocButtonCell];
    _secureCell = [self _allocSecureCell];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if(self ) {
    if([aDecoder isKindOfClass:[NSKeyedUnarchiver class]]) {
      _displayType = [aDecoder decodeIntegerForKey:@"displayType"];
      _buttonCell = [aDecoder decodeObjectForKey:@"buttonCell"];
      _secureCell = [aDecoder decodeObjectForKey:@"secureCell"];
    }
    if(!_buttonCell) {
      _buttonCell = [self _allocButtonCell];
    }
    if(!_secureCell) {
      _secureCell = [self _allocSecureCell];
    }
    
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  if([aCoder isKindOfClass:[NSKeyedUnarchiver class]]) {
    [aCoder encodeInteger:_displayType forKey:@"displayType"];
    [aCoder encodeObject:_buttonCell forKey:@"buttonCell"];
    [aCoder encodeObject:_secureCell forKey:@"secureCell"];
  }
}

- (void)dealloc {
  [_buttonCell release];
  [_secureCell release];
  [_fieldEditor release];
  [super dealloc];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
  if([controlView respondsToSelector:@selector(currentEditor)]) {
    if(![(id)controlView currentEditor]) {
      [self.buttonCell setEnabled:[self isEnabled]];
      [self.buttonCell drawWithFrame:[self _buttonCellForFrame:cellFrame] inView:controlView];
    }
  }
  /* Decide when to display what */
  switch(_displayType) {
    case HNHSecureTextFieldClearTextWhileEdit:
      [super drawInteriorWithFrame:[self _textCellForFrame:cellFrame] inView:controlView];
      break;
      
    case HNHSecureTextFieldAlwaysHide:
    default:
      [self.secureCell setTitle:[self title] ? [self title] : @""];
      [self.secureCell drawInteriorWithFrame:[self _textCellForFrame:cellFrame] inView:controlView];
      break;
  }
}

#pragma mark -
#pragma mark TODO

- (void)addTrackingAreasForView:(NSView *)controlView inRect:(NSRect)cellFrame withUserInfo:(NSDictionary *)userInfo mouseLocation:(NSPoint)mouseLocation {
  NSRect infoButtonRect = [self _buttonCellForFrame:cellFrame];
  
  NSTrackingAreaOptions options = NSTrackingEnabledDuringMouseDrag | NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways;
  
  BOOL mouseIsInside = NSMouseInRect(mouseLocation, infoButtonRect, [controlView isFlipped]);
  if (mouseIsInside) {
    options |= NSTrackingAssumeInside;
    [controlView setNeedsDisplayInRect:cellFrame];
  }
  
  // We make the view the owner, and it delegates the calls back to the cell after it is properly setup for the corresponding row/column in the outlineview
  NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:infoButtonRect options:options owner:controlView userInfo:userInfo];
  [controlView addTrackingArea:area];
  [area release];
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
  NSPoint point = [controlView convertPoint:[event locationInWindow] fromView:nil];
  NSRect textRect = [self _textCellForFrame:cellFrame];
  NSRect buttonRect = [self _buttonCellForFrame:cellFrame];
  if( NSMouseInRect(point, textRect, [controlView isFlipped])) {
    return  NSCellHitContentArea | NSCellHitEditableTextArea;
  }
  if( NSMouseInRect(point, buttonRect, [controlView isFlipped])) {
    return NSCellHitContentArea | NSCellHitTrackableArea;
  }
  return NSCellHitNone;
}

#pragma mark -
#pragma mark Helper
- (NSSecureTextFieldCell *)_allocSecureCell {
  NSSecureTextFieldCell *secureCell = [[NSSecureTextFieldCell alloc] init];
  [secureCell setFont:[self font]];
  [secureCell setAlignment:[self alignment]];
  [secureCell setControlSize:[self controlSize]];
  [secureCell setBezelStyle:[self bezelStyle]];
  [secureCell setBordered:[self isBordered]];
  [secureCell setBezeled:[self isBezeled]];
  return secureCell;
}

- (NSButtonCell *)_allocButtonCell {
  NSButtonCell *buttonCell = [[NSButtonCell alloc] init];
  [buttonCell setImage:[NSImage imageNamed:NSImageNameQuickLookTemplate ]];
  [buttonCell setTitle:@""];
  [buttonCell setAction:@selector(togglePassword)];
  [buttonCell setTarget:self];
  [buttonCell setBackgroundStyle:NSBackgroundStyleRaised];
  [buttonCell setBezeled:NO];
  [buttonCell setBordered:NO];
  [buttonCell setImagePosition:NSImageOnly];
  return buttonCell;
}

- (NSRect)_buttonCellForFrame:(NSRect)cellFrame {
  NSRect textFrame, buttonFrame;
  NSDivideRect(cellFrame, &buttonFrame, &textFrame, BUTTON_WIDTH, NSMaxXEdge);
  NSInsetRect(buttonFrame, 2, 2);
  return buttonFrame;
}

- (NSRect)_textCellForFrame:(NSRect)cellFrame {
  NSRect textFrame, buttonFrame;
  NSDivideRect(cellFrame, &buttonFrame, &textFrame, BUTTON_WIDTH, NSMaxXEdge);
  return textFrame;
}

@end
