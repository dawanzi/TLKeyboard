//
//  TLServiceBar.m
//  TLServiceBar
//
//  Created by Wcg on 2017/5/2.
//  Copyright © 2017年 Wcg. All rights reserved.
//

#import "TLServiceBar.h"
#import "TLServiceBtnView.h"
#import "Masonry.h"
#import "TLServicePanel.h"
#import "TLKit.h"


@interface TLServiceBar () <TLServiceBtnViewDelegate>

//**背景图*/
@property (nonatomic, strong) UIView *backGroupImageView;
//**顶部线*/
@property (nonatomic, strong) UIView *topLine;
//**容器视图*/
@property (nonatomic, strong) UIView *contentView;
//**键盘按钮*/
@property (nonatomic, strong) UIButton *keyBoardBtn;

//**masnoryView*/
@property (nonatomic, strong) UIView *masnoryView; //做约束用的leftView

//**数组*/
@property (nonatomic, strong) NSMutableArray *menuBtns;
@property (nonatomic, strong) NSMutableArray *lines;

//**当前在显示的面板*/
@property (nonatomic, strong) TLServiceBtnView *currentBtnView;

@property (nonatomic, assign) BOOL isShow;

@end


@implementation TLServiceBar

static const CGFloat keyBoradW = 36;
static const CGFloat incrementTag = 100;
static const CGFloat lineW = 0.5;

#pragma mark - setter getter
- (NSMutableArray *)menuBtns
{
    if (!_menuBtns) {
        _menuBtns = [NSMutableArray array];
    }
    return _menuBtns;
}

- (NSMutableArray *)lines
{
    if (!_lines) {
        _lines = [NSMutableArray array];
    }
    return _lines;
}

- (void)setMenuArr:(NSArray *)menuArr
{
    if (self.menuArr.count > 0) {
        [self.menuBtns performSelector:@selector(removeFromSuperview) withObject:nil];
        [self.menuBtns removeAllObjects];

        [self.lines performSelector:@selector(removeFromSuperview) withObject:nil];
        [self.lines removeAllObjects];
    }

    _menuArr = menuArr;
    //菜单栏创建模型
    NSInteger sectionCount = self.menuArr.count;

    CGFloat btnW = (SCREEN_WIDTH - keyBoradW - 16 - sectionCount * lineW) / sectionCount * 1.0;

    NSInteger section = 0;
    for (NSDictionary *dict in self.menuArr) {
        TLServiceBtnView *btnV = [[TLServiceBtnView alloc] init];
        btnV.delegate = self;
        btnV.title = dict[@"title"];
        btnV.tag = section + incrementTag;
        [self.contentView addSubview:btnV];

        [self.menuBtns addObject:btnV];

        [btnV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(btnW);
            make.centerY.mas_equalTo(self.contentView);
            if (self.masnoryView == self.keyBoardBtn) {
                make.left.mas_equalTo(self.contentView);
            } else {
                make.left.mas_equalTo(self.masnoryView.mas_right);
            }
        }];
        _masnoryView = btnV;
        NSArray *subTitles = dict[@"subtitles"];
        btnV.subMenus = subTitles;

        if (self.menuArr.count - 1 > section) {
            UIView *line = [UIView new];
            line.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0];
            [self.contentView addSubview:line];
            [self.lines addObject:line];
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.masnoryView.mas_right);
                make.top.mas_equalTo(self.topLine.mas_bottom);
                make.bottom.mas_equalTo(self.contentView.mas_bottom).priorityLow();
                make.width.mas_equalTo(lineW);
            }];
            _masnoryView = line;
        }
        section++;
    }

    [self layoutIfNeeded];
}

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

+ (instancetype)serviceBarWithMenuArr:(NSArray *)menuArr
{
    TLServiceBar *bar = [[TLServiceBar alloc] init];
    bar.backgroundColor = [UIColor colorGrayForChatBar];
    bar.menuArr = menuArr;
    return bar;
}

- (void)createUI
{
    _backGroupImageView = [[UIImageView alloc] init];
    _backGroupImageView.backgroundColor = [UIColor colorGrayForChatBar];
    [self addSubview:_backGroupImageView];
    [_backGroupImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
    }];

    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"TLServiceBar")];
    NSURL *url = [bundle URLForResource:@"TLServiceBar" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    NSString *path = [imageBundle pathForResource:@"keyBoardUp@3x" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];

    _keyBoardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_keyBoardBtn setImage:image forState:UIControlStateNormal];
    [_keyBoardBtn addTarget:self action:@selector(keyBoardClick:) forControlEvents:UIControlEventTouchUpInside];
    [_keyBoardBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _keyBoardBtn.opaque = YES;
    [self addSubview:_keyBoardBtn];

    [_keyBoardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8).priorityHigh();
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.mas_equalTo(keyBoradW);
    }];
    _masnoryView = _keyBoardBtn;

    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0];
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.masnoryView.mas_right).offset(8);
        make.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(lineW);
    }];

    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.opaque = YES;
    [self addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_equalTo(self);
        make.left.mas_equalTo(line.mas_right);
    }];

    _topLine = [[UIView alloc] init];
    _topLine.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    [self.contentView addSubview:_topLine];
    [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(lineW);
    }];
}

- (void)keyBoardClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickKeyBoradBtn:btn:)]) {
        [self.delegate didClickKeyBoradBtn:self btn:btn];
    }
    [self hiddenToolBar];
}

//事件传递更正，panel超出父控件的依旧传递给panel
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];

    if (view == nil) {
        CGPoint panelP = [self.currentBtnView.panel convertPoint:point fromView:self];
        if ([self.currentBtnView.panel pointInside:panelP withEvent:event]) {
            return [self.currentBtnView.panel hitTest:panelP withEvent:event];
        }
    }

    return view;
}

#pragma mark - public
- (void)hiddenSubMenu
{
    if (self.currentBtnView && self.currentBtnView.isShowPanel) {
        [self.currentBtnView hiddenPanel:nil];
    }
}

- (void)hiddenToolBar
{
    if (self.currentBtnView && self.currentBtnView.isShowPanel) {
        [self.currentBtnView hiddenPanel:nil];
    }

    TLWeakSelf(self);
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        [weakself mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakself.superview.mas_bottom);
        }];
        [weakself.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        weakself.hidden = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(didHiddenKeyBoradBtn:)]) {
            [self.delegate didHiddenKeyBoradBtn:self];
        }
    }];
}
- (void)showToolBar
{
    TLWeakSelf(self);
    self.hidden = NO;
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        [weakself mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakself.superview.mas_bottom).offset(-TABBAR_HEIGHT - INDICATOR_HEIGHT);
        }];
        [weakself.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didShowKeyBoradBtn:)]) {
            [self.delegate didShowKeyBoradBtn:self];
        }
    }];
}

#pragma mark - TLServiceBtnViewDelegate
//只有在没有子菜单的时候才会调用
- (void)didClickServiceBtnView:(TLServiceBtnView *)btnView
{
    NSInteger section = btnView.tag - incrementTag;

    //隐藏之前
    if (self.currentBtnView && self.currentBtnView.isShowPanel) {
        [self.currentBtnView hiddenPanel:^(BOOL finished) {
            if (finished) self.currentBtnView = btnView;
        }];
    }

    if (btnView.subMenus.count == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedMenuInSection:row:)]) {
            [self.delegate didSelectedMenuInSection:section row:0];
        }

        return;
    }

    //显示现在
    @weakify(self);
    if (btnView && !btnView.isShowPanel && _isShow == NO) {
        _isShow = YES;
        [btnView showPanel:^(BOOL finished) {
            @strongify(self);
            self.isShow = NO;
            if (finished) self.currentBtnView = btnView;
        }];
    }
}
//点击了子菜单上的标题时调用
- (void)didClickServiceBtnView:(TLServiceBtnView *)btnView subMenuRow:(NSInteger)row
{
    NSInteger section = btnView.tag - incrementTag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedMenuInSection:row:)]) {
        [self.delegate didSelectedMenuInSection:section row:row];
    }
}

@end
