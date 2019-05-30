//
//  MJReceiveTagsView.m
//  Fetion
//
//  Created by apple on 2019/5/9.
//  Copyright © 2019年 MJ. All rights reserved.
//

#import "MJReceiveTagsView.h"

@interface MJReceiveTagsView() <UITextViewDelegate>

@property (nonatomic, strong) UILabel *placeholderLabel;

/* 光标位置 */
@property (nonatomic, assign) NSInteger cursorLocation;

/* 标签数组 */
@property (nonatomic, strong) NSMutableArray *tagRangeArray;

/** 插入的名字  */
@property (nonatomic, copy) NSString *appendName;

@end

@implementation MJReceiveTagsView


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configDefaults];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configDefaults];
    }
    return self;
}


- (void)configDefaults {
    
    self.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textDidChange:) name:UITextViewTextDidChangeNotification object:self];
    
    _isMulInput = true;
    _tagRangeArray = @[].mutableCopy;
    _tags = @[].mutableCopy;
    self.tagColor = [UIColor blueColor];
    self.font = [UIFont systemFontOfSize:15];
    self.inputColor = [UIColor blackColor];
}

#pragma mark - setter

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.placeholderLabel.font = font;
    _tagFont = font;
}

- (void)setTags:(NSMutableArray<NSString *> *)tags {
    _tags = tags;
    [self reload];
}


- (void)setText:(NSString *)text {
    [super setText:text];
    [self showPlaceholderIfNeeded];
}


- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self showPlaceholderIfNeeded];
}


- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    self.placeholderLabel.textColor = placeholderColor;
}


- (void)setPlaceholder:(NSString *)placeholder  {
    self.placeholderLabel.text = placeholder;
    [self setNeedsLayout];
}

#pragma mark - get


- (UIColor *)placeholderColor {
    return self.placeholderLabel.textColor;
}


- (NSString *)placeholder {
    return self.placeholderLabel.text;
}


- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        _placeholderLabel.font = self.font;
        _placeholderLabel.textColor = [UIColor lightGrayColor];
        _placeholderLabel.hidden = YES;
        
        [self addSubview:_placeholderLabel];
    }
    return _placeholderLabel;
}


#pragma mark - placeholderLabel处理

- (void)showPlaceholderIfNeeded {
    if ([self shouldShowPlaceholder]) {
        [self showPlaceholder];
    } else {
        [self hidePlaceholder];
    }
}


- (BOOL)shouldShowPlaceholder {
    if ([self.text length] == 0 && [self.placeholder length] > 0) {
        return YES;
    }
    return NO;
}


- (void)showPlaceholder {
    self.placeholderLabel.hidden = NO;
}


- (void)hidePlaceholder {
    self.placeholderLabel.hidden = YES;
}


- (CGRect)placeholderFrame {
    UIEdgeInsets insets = [self retainedContentInsets];
    CGRect bounds = _RectInsetEdges(self.bounds, insets);
    
    
    CGSize placeholderSize = [self.placeholder boundingRectWithSize:CGSizeMake(bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.placeholderLabel.font}  context:nil].size;
    
    CGRect caretRect = [self caretRectForPosition:self.beginningOfDocument];
    
    CGFloat topMarge = (self.bounds.size.height - placeholderSize.height) / 2;
    if (topMarge < 0) {
        topMarge = 0;
    }
    
    CGRect frame;
    frame.size = placeholderSize;
    frame.origin.x = caretRect.origin.x;
    frame.origin.y = _verticalCenter ? topMarge : caretRect.origin.y; //因caretRect的origin.y有几像素偏差，故而在居中模式下不使用
    return frame;
}


CGRect _RectInsetEdges(CGRect rect, UIEdgeInsets edgeInsets) {
    rect.origin.x += edgeInsets.left;
    rect.size.width -= edgeInsets.left + edgeInsets.right;
    
    rect.origin.y += edgeInsets.top;
    rect.size.height -= edgeInsets.top + edgeInsets.bottom;
    
    if (rect.size.width < 0) {
        rect.size.width = 0;
    }
    
    if (rect.size.height < 0) {
        rect.size.height = 0;
    }
    return rect;
}


- (UIEdgeInsets)retainedContentInsets {
    return UIEdgeInsetsMake(8, 4, 8, 4);
}


- (void)verticalCenterContent {
    NSTextContainer *container = self.textContainer;
    NSLayoutManager *layoutManager = container.layoutManager;
    
    CGRect textRect = [layoutManager usedRectForTextContainer:container];
    
    UIEdgeInsets inset = self.textContainerInset;
    inset.top = self.bounds.size.height >= textRect.size.height ? (self.bounds.size.height - textRect.size.height) / 2 : inset.top;
    
    self.textContainerInset = inset;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self showPlaceholderIfNeeded];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.placeholderLabel.frame = [self placeholderFrame];
        [self sendSubviewToBack:self.placeholderLabel];
        
        if (self.verticalCenter) {
            [self verticalCenterContent];
        }
    });
}


//监听textView文字变化
- (void)_textDidChange:(NSNotification *)noti {
    
    [self showPlaceholderIfNeeded];
    CGRect line = [self caretRectForPosition:self.selectedTextRange.start];
    CGRect bounds = self.bounds;
    CGPoint currentOffset = self.contentOffset;
    UIEdgeInsets currentInsets = self.contentInset;
    CGFloat overflow = line.origin.y + line.size.height - (currentOffset.y + bounds.size.height - currentInsets.bottom - currentInsets.top);
    
    if (overflow > 0) {
        CGPoint toOffset = [self _maximumContentOffset];
        [self setContentOffset:toOffset animated:YES];
    }
    
    if (!self.text.length) {
        return;
    }
    
    UITextRange *markedTextRange = [self markedTextRange];
    UITextPosition *position = [self positionFromPosition:markedTextRange.start offset:0];
    if (position) {
        return;// 正处于输入拼音还未点确定的中间状态
    }
    
    [self reload];
}


- (void)reload {
    //不使用正则去匹配，文字过于复杂
    [self.tagRangeArray removeAllObjects];
    NSMutableAttributedString *attributedComment = [[NSMutableAttributedString alloc] init];
    
    NSInteger index = 0;
    for (NSString *string in self.tags) {
        NSString *itemString = [NSString stringWithFormat:@" %@ ", string];
        [attributedComment appendAttributedString:[[NSAttributedString alloc] initWithString:itemString]];
        NSRange bindingRange = NSMakeRange(index, itemString.length);
        [attributedComment setAttributes:@{NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.tagColor} range:bindingRange];
        [self.tagRangeArray addObject:NSStringFromRange(bindingRange)];
        index += bindingRange.length;
    }
    
    _appendName = [self getNotTagtext];
    if (_appendName.length > 0) {
        [attributedComment appendAttributedString:[[NSAttributedString alloc] initWithString:_appendName]];
        NSRange range = NSMakeRange(index, _appendName.length);
        [attributedComment setAttributes:@{NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.inputColor} range:range];
        _appendName = @"";
    }
    
    self.attributedText = attributedComment;
    self.selectedRange = NSMakeRange(attributedComment.length, 0);
    
    [self scrollRangeToVisible:self.selectedRange];
    
    [self showPlaceholderIfNeeded];
}

- (void)reloadTags {
    //不使用正则去匹配，文字过于复杂
    [self.tagRangeArray removeAllObjects];
    NSMutableAttributedString *attributedComment = [[NSMutableAttributedString alloc] init];
    
    NSInteger index = 0;
    for (NSString *string in self.tags) {
        NSString *itemString = [NSString stringWithFormat:@" %@ ", string];
        [attributedComment appendAttributedString:[[NSAttributedString alloc] initWithString:itemString]];
        NSRange bindingRange = NSMakeRange(index, itemString.length);
        [attributedComment setAttributes:@{NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.tagColor} range:bindingRange];
        [self.tagRangeArray addObject:NSStringFromRange(bindingRange)];
        index += bindingRange.length;
    }
    
    self.attributedText = attributedComment;
    self.selectedRange = NSMakeRange(attributedComment.length, 0);
    
    [self scrollRangeToVisible:self.selectedRange];
    
    [self showPlaceholderIfNeeded];
}


- (CGPoint)_maximumContentOffset {
    CGRect bounds             = self.bounds;
    CGSize contentSize        = self.contentSize;
    UIEdgeInsets contentInset = self.contentInset;
    
    CGFloat x = MAX(-contentInset.left, contentSize.width + contentInset.right - bounds.size.width);
    CGFloat y = MAX(-contentInset.top, contentSize.height + contentInset.bottom - bounds.size.height);
    
    return CGPointMake(x, y);
}


#pragma mark - override


// 继承UITextView重写这个方法
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
//    if(action ==@selector(copy:) ||
//
//       action ==@selector(selectAll:)||
//
//       action ==@selector(cut:)||
//
//       action ==@selector(select:)||
//
//       action ==@selector(paste:)) {
//        return [super canPerformAction:action withSender:sender];
//    }
//    if (action == @selector(selectAll:)) {
//        return true;
//    }
    return false;
}


#pragma mark - UITextViewDelegate

// 这个方法一般在实际开发中很少用到，当用户选择text view中的部分内容，或者更改文本选择的范围，或者在text view中粘贴入文本时，函数textViewDidChangeSelection:将会被调用。虽然它很少被使用，但是在某些业务场景下还是非常有用的。
- (void)textViewDidChangeSelection:(UITextView *)textView {
    [self t_textViewDidChangeSelection];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return [self t_shouldChangeTextInRange:range replacementText:text];
}


- (void)t_textViewDidChangeSelection {
    BOOL inRange = NO;
    //当前要选中的光标
    NSUInteger selectedLocation = self.selectedRange.location;
    
    //选中range
    NSRange selectedRange = NSMakeRange(self.selectedRange.location, 0);
    
    for (NSInteger i = 0; i < self.tagRangeArray.count; i++) {
        NSRange range = NSRangeFromString(self.tagRangeArray[i]);
        if (selectedLocation > range.location && selectedLocation < range.location + range.length) {
            //选中光标 > 标签起点 && 选中光标 < 标签终点 即是在选中光标在标签范围内
            inRange = YES;
            selectedRange = range;
            break;
        }
    }
    if (inRange) {
        //选中光标在标签范围内 直接选中整一段
        //self.selectedRange = NSMakeRange(self.cursorLocation, self.selectedRange.length);
        self.selectedRange = selectedRange;
        return;
    }
    self.cursorLocation = self.selectedRange.location;
}


- (BOOL)t_shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@""]) { // 删除
        
        //实现全选有bug
//        if (range.location == 0 && range.location + range.length == self.text.length) {
//            //全选删除
//            return YES;
//        }
        
        for (NSInteger i = 0; i < self.tagRangeArray.count; i++) {
            NSRange tmpRange = NSRangeFromString(self.tagRangeArray[i]);
            NSInteger deleteLocation = range.location + range.length;
            if (deleteLocation > tmpRange.location && deleteLocation < tmpRange.location + tmpRange.length) {
                //在标签中删除
                self.selectedRange = tmpRange;
                return NO;
            }
            
            if ((range.location + range.length) == (tmpRange.location + tmpRange.length)) {
                if ([NSStringFromRange(tmpRange) isEqualToString:NSStringFromRange(self.selectedRange)]) {
                    // 第二次点击删除按钮 删除
                    [self.tagRangeArray removeObject:NSStringFromRange(tmpRange)];
                    //同时删除对应联系人
                    [self.tags removeObjectAtIndex:i];
                    if (self.tagsViewDelegate && [self.tagsViewDelegate respondsToSelector:@selector(deleteTagIndex:)]) {
                        [self.tagsViewDelegate deleteTagIndex:i];
                    }
                    return YES;
                } else {
                    // 第一次点击删除按钮 选中整段文字
                    self.selectedRange = tmpRange;
                    return NO;
                }
            }
        }
    } else { // 增加
        if ([text isEqualToString:@"\n"]) {
            //换行 这里用来判断用户自己输入的手机号码是否是正确的
            
            NSString *phoneString = [self getNotTagtext];
            if ([self isNumber:phoneString]) {
                if (!_isMulInput) {
                    [self.tags removeAllObjects];
                }
                [self.tags addObject:phoneString];
                if (self.tagsViewDelegate && [self.tagsViewDelegate respondsToSelector:@selector(inputPhone:)]) {
                    [self.tagsViewDelegate inputPhone:phoneString];
                }
            }
            NSLog(@"----%@---%@---", text, phoneString);
            [self reloadTags];
            return false;
        }
    }
    return YES;
}

- (BOOL)isNumber:(NSString *)text {
    if (text.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:text]) {
        return YES;
    }
    return NO;
}

- (NSString *)getNotTagtext {
    NSString *string = @"";
    if (self.tagRangeArray.count > 0) {
        NSRange lastRange = NSRangeFromString(self.tagRangeArray.lastObject);
        NSInteger start = lastRange.location + lastRange.length;
        if (self.text.length > start) {
            //表示在n个标签还存在用户输入的文字
            NSRange range = NSMakeRange(start, self.text.length - start);
            string = [self.text substringWithRange:range];
        }
    } else {
        //没有标签，只有用户输入的文字
        string = self.text;
    }
    return string;
}


@end
