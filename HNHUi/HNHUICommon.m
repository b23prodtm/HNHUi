//
//  HNHCommon.m
//  MacPass
//
//  Created by Michael Starke on 27/08/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "HNHUICommon.h"

/**
 *  Returns a state for bool flag
 *
 *  @param flag flag to indicate for Off or On state
 *
 *  @return NSStateOn state when flag is YES, NSOffState when flag is NO
 */
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 101100
NSCellStateValue HNHUIStateForBool(BOOL flag) {
    return flag ? NSOnState : NSOffState;
}

BOOL HNHUIBoolForState(NSCellStateValue state) {
    switch (state) {
        case NSOnState:
            return YES;
        default:
        case NSMixedState:
            NSLog(@"Indetermined state!");
        case NSOffState:
            return NO;
            break;
    }
}
#else
NSControlStateValue HNHUIStateForBool(BOOL flag) {
  return flag ? NSControlStateValueOn : NSControlStateValueOff;
}

BOOL HNHUIBoolForState(NSControlStateValue state) {
  switch (state) {
    case NSControlStateValueOn:
      return YES;
    default:
    case NSControlStateValueMixed:
      NSLog(@"Indetermined state!");
    case NSControlStateValueOff:
      return NO;
      break;
  }
}
#endif
void HNHUISetStateFromBool(id stateItem, BOOL isOn) {
  if([stateItem respondsToSelector:@selector(setState:)]) {
    [stateItem setState:HNHUIStateForBool(isOn)];
  }
  else {
    NSLog(@"%@ does not respond to setState:", stateItem);
    assert(false);
  }
}


