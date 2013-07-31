//
//  HNHRoundedSecureTextField.m
//
//  Created by Michael Starke on 07.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//
//  Based on: KSPasswordField.h
//
//  Created by Mike Abdullah on 28/04/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//  http://karelia.com
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
//  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
//  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "HNHRoundedSecureTextField.h"
#import "HNHRoundedSecureTextFieldCell.h"
#import "HNHRoundedTextFieldCell.h"

@interface HNHRoundedSecureTextField () {
  NSTrackingArea *_trackingArea;
}

@end

@implementation HNHRoundedSecureTextField

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if(self) {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [[self cell] encodeWithCoder:archiver];
    [archiver finishEncoding];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    HNHRoundedSecureTextFieldCell *cell = [[HNHRoundedSecureTextFieldCell alloc] initWithCoder:unarchiver];
    [unarchiver finishDecoding];
    
    [self setCell:cell];
    _isMouseDown = NO;
    _isMouseOver = NO;
    
    [self setNeedsDisplay:YES];
  }
  return self;
}

- (void)toggleDisplay:(id)sender {
  self.showPassword = !_showPassword;
}

- (void)setShowPassword:(BOOL)showPassword {
  if(_showPassword != showPassword) {
    _showPassword = showPassword;
    [self _toggleCell];
  }
}

#pragma mark -
#pragma mark Private
- (void)_swapCellForOneOfClass:(Class)cellClass;
{
  // Rememeber current selection for restoration after the swap
  // -valueForKey: neatly gives nil if no currently selected
  BOOL isActive = (nil != [self currentEditor]);
  NSValue *selection = [[self currentEditor] valueForKey:@"selectedRange"];
  
  // Seems to me the best way to ensure all properties come along for the ride (e.g. border/editability) is to archive the existing cell
  NSMutableData *data = [[NSMutableData alloc] init];
  NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  [[self cell] encodeWithCoder:archiver];
  [archiver finishEncoding];
  
  NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
  NSTextFieldCell *cell = [[cellClass alloc] initWithCoder:unarchiver];
  [unarchiver finishDecoding];
  
  [self setCell:cell];
  [self setNeedsDisplay:YES];
  
  // Restore selection
  if(isActive) {
    [[self window] makeFirstResponder:self];
  }
  if (selection) [[self currentEditor] setSelectedRange:[selection rangeValue]];
}

- (void)_toggleCell {
  if([[self cell] isKindOfClass:[HNHRoundedTextFieldCell class]]) {
    [self _swapCellForOneOfClass:[HNHRoundedSecureTextFieldCell class]];
  }
  else {
    [self _swapCellForOneOfClass:[HNHRoundedTextFieldCell class]];
  }
}

- (void)setEditable:(BOOL)flag {
  [super setEditable:flag];
  [self _updateTrackingArea];
}

- (void)mouseEntered:(NSEvent *)theEvent {
  _isMouseOver = YES;
  [self setNeedsDisplay];
}

- (void)mouseExited:(NSEvent *)theEvent {
  _isMouseOver = NO;
  _isMouseDown = NO;
  [self setNeedsDisplay];
}

- (void)mouseDown:(NSEvent *)theEvent {
  _isMouseDown = YES;
  [self setNeedsDisplay];
}

- (void)mouseUp:(NSEvent *)theEvent {
  _isMouseDown = NO;
  [self setNeedsDisplay];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
  if(_trackingArea) {
    [self removeTrackingArea:_trackingArea];
  }
}

- (void)viewDidMoveToWindow {
  [self _updateTrackingArea];
}

- (void)setFrame:(NSRect)frameRect {
  [super setFrame:frameRect];
  [self _updateTrackingArea];
}

- (void)_updateTrackingArea {
  if(_trackingArea) {
    [self removeTrackingArea:_trackingArea];
    _trackingArea = nil;
  }
  if(![self isEditable] && ![self isSelectable]) {
    _trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:NSTrackingMouseEnteredAndExited|NSTrackingInVisibleRect|NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
  }
}

@end
