#import "Three20/TTSearchTextField.h"

@class TTMenuViewCell;

@interface TTMenuTextField : TTSearchTextField {
  NSMutableArray* _cellViews;
  TTMenuViewCell* _selectedCell;
  int _visibleLineCount;
  int _lineCount;
  CGPoint _cursorOrigin;
}

@property(nonatomic,readonly) NSArray* cellViews;
@property(nonatomic,readonly) NSArray* cells;
@property(nonatomic,assign) TTMenuViewCell* selectedCell;
@property(nonatomic) int visibleLineCount;
@property(nonatomic,readonly) int lineCount;

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

@protocol TTMenuTextFieldDelegate <UITextFieldDelegate>

- (void)textField:(TTMenuTextField*)textField didAddCellAtIndex:(NSInteger)index;

- (void)textField:(TTMenuTextField*)textField didRemoveCellAtIndex:(NSInteger)index;

@end
