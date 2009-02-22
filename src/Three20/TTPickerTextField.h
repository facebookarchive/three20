#import "Three20/TTSearchTextField.h"

@class TTPickerViewCell;

@interface TTPickerTextField : TTSearchTextField {
  NSMutableArray* _cellViews;
  TTPickerViewCell* _selectedCell;
  int _lineCount;
  CGPoint _cursorOrigin;
}

@property(nonatomic,readonly) NSArray* cellViews;
@property(nonatomic,readonly) NSArray* cells;
@property(nonatomic,assign) TTPickerViewCell* selectedCell;
@property(nonatomic,readonly) int lineCount;

- (void)addCellWithObject:(id)object;

- (void)removeCellWithObject:(id)object;

- (void)removeAllCells;

- (void)removeSelectedCell;

- (void)scrollToVisibleLine:(BOOL)animated;

- (void)scrollToEditingLine:(BOOL)animated;

@end

@protocol TTPickerTextFieldDelegate <TTSearchTextFieldDelegate>

- (void)textField:(TTPickerTextField*)textField didAddCellAtIndex:(NSInteger)index;

- (void)textField:(TTPickerTextField*)textField didRemoveCellAtIndex:(NSInteger)index;

- (void)textFieldDidResize:(TTPickerTextField*)textField;

@end
