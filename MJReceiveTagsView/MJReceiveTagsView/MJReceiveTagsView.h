//
//  MJReceiveTagsView.h
//  Fetion
//
//  Created by apple on 2019/5/9.
//  Copyright © 2019年 MJ. All rights reserved.
//  

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MJReceiveTagsViewDelegate <NSObject>


/**
 删除某个标签，用来与外部数据同步

 @param index <#index description#>
 */
- (void)deleteTagIndex:(NSInteger)index;


/**
 自己手动输入号码

 @param phone <#phone description#>
 */
- (void)inputPhone:(NSString *)phone;

@end

/**
 注意不要在外部实现UITextViewDelegate
 */
@interface MJReceiveTagsView : UITextView

@property (nonatomic, weak) id<MJReceiveTagsViewDelegate> tagsViewDelegate;

@property (nonatomic, strong) NSString *placeholder;

@property (nonatomic, strong) UIColor *placeholderColor;

@property (nonatomic) BOOL verticalCenter;

/** 是否可以输入多个标签 默认true */
@property (nonatomic, assign) BOOL isMulInput;

/** 联系人的名字表  */
@property (nonatomic, strong) NSMutableArray <NSString *> *tags;

/* 标签字体默认等于self.font */
@property (nonatomic, strong) UIFont *tagFont;

/* 标签颜色 */
@property (nonatomic, strong) UIColor *tagColor;

/** 输入颜色 */
@property (nonatomic, strong) UIColor *inputColor;

/* 光标位置 */
@property (nonatomic, assign, readonly) NSInteger cursorLocation;

/* 标签数组 range */
@property (nonatomic, strong, readonly) NSMutableArray *tagRangeArray;


/**
 刷新数据，保留用户输入的文字
 */
- (void)reload;


/**
 刷新标签数据，不保留用户输入的文字
 */
- (void)reloadTags;

@end


NS_ASSUME_NONNULL_END
