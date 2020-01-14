//
//  ViewController.m
//  ZZWPencil
//
//  Created by zhaozw on 2020/1/14.
//  Copyright © 2020 zhaozw. All rights reserved.
//

#import "ViewController.h"
#import <PencilKit/PencilKit.h>
#import <Masonry.h>
@interface ViewController ()<PKCanvasViewDelegate,PKToolPickerObserver>
{
    NSUndoManager *undoManager;
}
@property (nonatomic, weak) UIImageView *airPodsImageView;
@property (nonatomic, weak) PKCanvasView *canvasView;
@property (nonatomic, weak) UIButton *undoButton;
@property (nonatomic, weak) UIButton *redoButton;
@property (nonatomic, weak) UIButton *saveButton;
@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];

    [self setupUndoManager];
}

- (void)setupUI {
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor blueColor];
    bgView.userInteractionEnabled = YES;
    [self.view addSubview:bgView];
    
    UIButton *undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [undoButton addTarget:self action:@selector(undoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [undoButton setTitle:@"undo" forState:UIControlStateNormal];
    [undoButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    undoButton.backgroundColor = [UIColor grayColor];
    undoButton.enabled = NO;
    undoButton.layer.cornerRadius = 22;
    [bgView addSubview:undoButton];
    self.undoButton = undoButton;
    
    UIButton *redoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [redoButton addTarget:self action:@selector(redoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [redoButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [redoButton setTitle:@"redo" forState:UIControlStateNormal];
    redoButton.backgroundColor = [UIColor grayColor];
    redoButton.enabled = NO;
    redoButton.layer.cornerRadius = 22;
    [bgView addSubview:redoButton];
    self.redoButton = redoButton;
    
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    saveButton.layer.cornerRadius = 22;
    saveButton.layer.masksToBounds = YES;
    saveButton.backgroundColor = [UIColor whiteColor];
    saveButton.backgroundColor = [UIColor grayColor];
    saveButton.enabled = NO;
    [bgView addSubview:saveButton];
    self.saveButton = saveButton;
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:17];
    [bgView addSubview:titleLabel];
    
    
    UIImageView *airPodsImageView = [[UIImageView alloc]init];
    airPodsImageView.backgroundColor = [UIColor whiteColor];
    airPodsImageView.userInteractionEnabled = YES;
    [bgView addSubview:airPodsImageView];
    self.airPodsImageView = airPodsImageView;
    
    
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.hidden = YES;
    [airPodsImageView addSubview:imageView];
    self.imageView = imageView;


    PKCanvasView *canvasView = [[PKCanvasView alloc]init];
    canvasView.backgroundColor = [UIColor whiteColor];
    canvasView.rulerActive = NO;
    canvasView.allowsFingerDrawing = YES;
    canvasView.delegate = self;
    canvasView.layer.cornerRadius = 10;
    canvasView.layer.masksToBounds = YES;
    [self.view addSubview:canvasView];
    self.canvasView = canvasView;
    
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(canvasView.mas_top).offset(40);
    }];
    
    [undoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bgView.mas_left).offset(30);
        make.top.equalTo(bgView.mas_top).offset(50);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(44);
    }];
    
    [redoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(undoButton.mas_right).offset(20);
        make.top.equalTo(bgView.mas_top).offset(50);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(44);
    }];
    
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView.mas_top).offset(50);
        make.right.equalTo(bgView.mas_right).offset(-30);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(44);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bgView.mas_centerX);
        make.top.equalTo(bgView.mas_top).offset(140);
        make.height.mas_equalTo(17);
    }];
    
    [airPodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bgView.mas_centerX);
        make.top.equalTo(titleLabel.mas_bottom).offset(150);
        make.height.mas_equalTo(200);
        make.width.mas_equalTo(400);
    }];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(airPodsImageView);
        make.bottom.equalTo(airPodsImageView.mas_bottom).offset(-20);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(150);
    }];
    
    [canvasView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-145);
        make.height.mas_equalTo(400);
    }];
    
    
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    
    PKToolPicker *toolPick = [PKToolPicker sharedToolPickerForWindow:window];
    toolPick.rulerActive = NO;
    [toolPick setVisible:YES forFirstResponder:canvasView];
        
    PKInkingTool *tool = [[PKInkingTool alloc]initWithInkType:PKInkTypePen color:[UIColor blackColor] width:10.0];
    toolPick.selectedTool = tool;
    [toolPick addObserver:canvasView];
    
    [canvasView becomeFirstResponder];

    
}


/// 绘画已经改变了
/// @param canvasView canvasView
- (void)canvasViewDrawingDidChange:(PKCanvasView *)canvasView {
    
    NSLog(@"==%s",__func__);
    
    [self.undoManager prepareWithInvocationTarget:self];

    self.undoButton.backgroundColor = [UIColor whiteColor];
    self.undoButton.enabled = YES;
    
    self.redoButton.backgroundColor = [UIColor grayColor];
    self.redoButton.enabled = NO;
    
    
    
    if (canvasView.drawing) {
        self.saveButton.backgroundColor = [UIColor whiteColor];
        self.saveButton.enabled = YES;
    }else {
        self.saveButton.backgroundColor = [UIColor grayColor];
        self.saveButton.enabled = NO;
    }
}

/// 结束绘画
/// @param canvasView canvasView
- (void)canvasViewDidFinishRendering:(PKCanvasView *)canvasView {
    NSLog(@"==%s",__func__);
    
}

/// 已经开始使用工具了
/// @param canvasView canvasView
- (void)canvasViewDidBeginUsingTool:(PKCanvasView *)canvasView {
     NSLog(@"==%s",__func__);
}

/// 已经结束使用工具
/// @param canvasView canvasView
- (void)canvasViewDidEndUsingTool:(PKCanvasView *)canvasView {
     NSLog(@"==%s",__func__);
}


/// saveButton点击事件
- (void)saveButtonClick:(UIButton *)button {
    
    self.imageView.hidden = NO;
    
    CGRect rect = self.canvasView.drawing.bounds;
    UIImage *image = [self.canvasView.drawing imageFromRect:rect scale:1];
    UIImage *resultImage = [self imageCompressWithSimple:image];
    self.imageView.image = resultImage;
    self.canvasView.drawing = [[PKDrawing alloc]init];
    
    [self cleanUpUndoManger];
    
    self.saveButton.backgroundColor = [UIColor grayColor];
    self.saveButton.enabled = NO;

    self.undoButton.enabled = NO;
    self.undoButton.backgroundColor = [UIColor grayColor];
    
    self.redoButton.enabled = NO;
    self.redoButton.backgroundColor = [UIColor grayColor];
    
}


/// 取消按钮
- (void)undoButtonClick {
    
    NSLog(@"canUndo===%d",self.undoManager.canUndo);
    
    [self.undoManager undo];
}

/// 重做按钮
- (void)redoButtonClick {
    
    NSLog(@"canRedo===%d",self.undoManager.canRedo);
    
    [self.undoManager redo];
    
}


/// 监听UndoManager
- (void)setupUndoManager {
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(undoManagerDidUndoChange:) name:NSUndoManagerDidUndoChangeNotification object:self.undoManager];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(undoManagerDidRedoChange:) name:NSUndoManagerDidRedoChangeNotification object:self.undoManager];
}


/// 移除undoManger
- (void)cleanUpUndoManger {
    
    [self.undoManager removeAllActions];
    [self.undoManager removeAllActionsWithTarget:self];
}

/// 已经执行撤销操作
- (void)undoManagerDidUndoChange:(NSNotification *)notification {
    NSLog(@"undo==%s",__func__);
    
    if (self.undoManager.canUndo == NO) {
        self.undoButton.backgroundColor = [UIColor grayColor];
        self.undoButton.enabled = NO;
    }else {
        self.undoButton.backgroundColor = [UIColor whiteColor];
        self.undoButton.enabled = YES;
    }
    
    
    if (self.undoManager.canRedo == NO) {
        self.redoButton.backgroundColor = [UIColor grayColor];
        self.redoButton.enabled = NO;
    }else {
        self.redoButton.backgroundColor = [UIColor whiteColor];
        self.redoButton.enabled = YES;
    }
}


/// 已经执行重复操作
- (void)undoManagerDidRedoChange:(NSNotification *)notification {
    
    NSLog(@"undo==%s",__func__);
    
    if (self.undoManager.canRedo == NO) {
        self.redoButton.backgroundColor = [UIColor grayColor];
        self.redoButton.enabled = NO;
    }else {
        self.redoButton.backgroundColor = [UIColor whiteColor];
        self.redoButton.enabled = YES;
    }
}

/// 压缩图片
- (UIImage*)imageCompressWithSimple:(UIImage*)image{
    
    CGSize size = image.size;
    CGFloat scale = 1.0;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    if (size.width > screenWidth || size.height > screenHeight) {
        if (size.width > size.height) {
            scale = screenWidth / size.width;
        }else {
            scale = screenHeight / size.height;
        }
    }
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat scaledWidth = width * scale;
    CGFloat scaledHeight = height * scale;
    CGSize secSize =CGSizeMake(scaledWidth, scaledHeight);
    
    //设置新图片的宽高
    UIGraphicsBeginImageContext(secSize);
    [image drawInRect:CGRectMake(0,0,scaledWidth,scaledHeight)];
    UIImage* newImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
