#import "Three20/T3SearchTextField.h"

@class T3MenuViewCell, T3MenuTextFieldInternal;

@interface T3MenuTextField : T3SearchTextField {
  T3MenuTextFieldInternal* _internal;
  NSMutableArray* _cellViews;
  T3MenuViewCell* _selectedCell;
  int _visibleLineCount;
  int _lineCount;
  CGPoint _cursorOrigin;
}

@property(nonatomic,readonly) NSArray* cellViews;
@property(nonatomic,readonly) NSArray* cells;
@property(nonatomic,assign) T3MenuViewCell* selectedCell;
@property(nonatomic) int visibleLineCount;
@property(nonatomic,readonly) int lineCount;
@property(nonatomic,readonly) BOOL hasText;

- (void)addCellWithObject:(id)object label:(NSString*)label;

- (void)removeCellWithObject:(id)object;

- (void)removeAllCells;

- (void)removeSelectedCell;

- (CGFloat)lineTop:(int)lineNumber;

- (CGFloat)lineCenter:(int)lineNumber;

- (CGFloat)heightWithLines:(int)lines;

- (void)scrollToVisibleLine:(BOOL)animated;

- (void)scrollToEditingLine:(BOOL)animated;

@end

@protocol T3MenuTextFieldDelegate

- (void)menuTextField:(T3MenuTextField*)textField didAddCell:(T3MenuViewCell*)cell
  atIndex:(NSInteger)index;

- (void)menuTextField:(T3MenuTextField*)textField didRemoveCell:(T3MenuViewCell*)cell
  atIndex:(NSInteger)index;

@end
