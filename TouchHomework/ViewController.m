//
//  ViewController.m
//  TouchHomework
//
//  Created by Stepan Paholyk on 8/16/16.
//  Copyright © 2016 Stepan Paholyk. All rights reserved.
//

#import "ViewController.h"

typedef enum {
    firstKindOfCheckerTag = 1,
    secondKindOfCheckerTag = 2,
    restrictedAreaTag = 3,
    allowedAreaTag = 4
} ViewTag;

@interface ViewController ()

@property (weak, nonatomic) UIView* boardView;
@property (assign, nonatomic) CGFloat boardEdge;
@property (assign, nonatomic) CGRect cellRect;

@property (weak, nonatomic) UIView* draggingView;

@property (assign, nonatomic) CGPoint touchOffset;
@property (assign, nonatomic) CGPoint prevPoint;
@property (assign, nonatomic) CGPoint nearestPoint;
@property (weak, nonatomic) UIView *hittedCell;

@property (strong, nonatomic) NSMutableArray *firstKindOfCheckers;
@property (strong, nonatomic) NSMutableArray *secondKindOfCheckers;
@property (strong, nonatomic) NSMutableArray *cells;


@end

@implementation ViewController

# pragma mark - Create views

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self updateTags];
    
    [self createBoardOnMainView];
    [self createCellsOnBoardView];
    [self createCheckersOnCellView];
}

- (void) createBoardOnMainView {
    
    /*** Board create ***/
    
    UIViewAutoresizing stableMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    self.boardEdge = CGRectGetWidth(self.view.frame);
    CGSize boardSize = CGSizeMake(self.boardEdge, self.boardEdge);
    
    CGRect boardRect;
    boardRect.origin.x = 0;
    boardRect.origin.y = (CGRectGetHeight(self.view.frame) - self.boardEdge)/2;
    boardRect.size = boardSize;
    
    self.boardView = [self createViewWithRect:boardRect withColor:[UIColor whiteColor] withParentView:self.view andMask:stableMask];
    [self.boardView setTag:restrictedAreaTag];
}

- (void) createCellsOnBoardView {
    
    /*** Cells create ***/
    
    UIViewAutoresizing stableMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    
    CGFloat cellEdge = self.boardEdge / 8;
    CGSize cellSize = CGSizeMake(cellEdge, cellEdge);
    
    CGRect cellRect;
    cellRect.size = cellSize;
    
    self.cells = [NSMutableArray array];
    
    
    for (int rows = 0; rows < 8; rows++) {
        for (int columns = 0; columns < 8; columns++) {
            if ((rows + columns) % 2 != 0) {
                
                cellRect.origin.x = columns*cellEdge;
                cellRect.origin.y = rows*cellEdge;
                
                UIView *cellView = [self createViewWithRect:cellRect withColor:[[UIColor blackColor] colorWithAlphaComponent:0.85f] withParentView:self.boardView andMask:stableMask];
                
                [cellView setTag:allowedAreaTag];
                [self.cells addObject:cellView];
                
            }
        }
    }
    
    self.cellRect = cellRect;
}

- (void) createCheckersOnCellView {
    
    UIViewAutoresizing stableMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    CGRect checkerRect = CGRectInset(self.cellRect, 10, 10);
    
    // init Mutables
    self.firstKindOfCheckers = [NSMutableArray array];
    self.secondKindOfCheckers = [NSMutableArray array];
    
    
    for (int i = 0; i < [self.cells count]; i++) {
        if (i < 12) {
            UIView *tempCell = self.cells[i];
            UIView *firstKindOfChecker = [self createViewWithRect:checkerRect withColor:[UIColor yellowColor] withParentView:_boardView andMask:stableMask];
            
            [tempCell setTag:restrictedAreaTag];
            
            firstKindOfChecker.center = tempCell.center;
            [firstKindOfChecker setTag:firstKindOfCheckerTag];
            
            firstKindOfChecker.layer.cornerRadius = 5;
            [self.firstKindOfCheckers addObject:firstKindOfChecker];
            
            
        } else if (i > 19) {
            UIView *tempCell = self.cells[i];
            UIView *secondKindOfChecker = [self createViewWithRect:checkerRect withColor:[UIColor redColor] withParentView:_boardView andMask:stableMask];
            
            [tempCell setTag:restrictedAreaTag];
            
            secondKindOfChecker.center = tempCell.center;
            [secondKindOfChecker setTag:secondKindOfCheckerTag];
            
            
            secondKindOfChecker.layer.cornerRadius = 5;
            [self.secondKindOfCheckers addObject:secondKindOfChecker];
            
        }
    } 
    
    
}

#pragma mark - Calculation

- (BOOL) isDraggingViewHitCellInPoint:(CGPoint)point {
    
    BOOL contains = nil;
    
    for (UIView *cell in self.cells) {
        contains = CGRectContainsPoint(cell.frame, point);
        if (contains) {
            NSLog(@"Cell %@", NSStringFromCGRect(cell.frame));
            self.hittedCell = cell;
            break;
        } else {
            NSLog(@"Cell not Found");
            
        }
    }
    
    return contains;
}

- (BOOL) cellIsFree:(UIView*)hittedCell {
    if (hittedCell.tag == allowedAreaTag) {
        return YES;
    } else {
        return NO;
    }
}

- (void) updateTags {
    // THIS FUNCTION!!!
}


- (CGPoint) putInNearestFreePlace:(UIView *) view {
    double minDistance = 1000;
    
    for (UIView *cell in self.cells) {
        double tmpDistance = [self calculateDistanceBetweenPoint:view.center andPoint:cell.center];
        if ((tmpDistance < minDistance) && (cell.tag == allowedAreaTag)) {
            minDistance = tmpDistance;
            self.nearestPoint = cell.center;
        }
    }
    
    return self.nearestPoint;
}


- (double) calculateDistanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2 {
    double dx = point1.x - point2.x;
    double dy = point1.y - point2.y;
    return sqrt(dx*dx + dy*dy);
}



# pragma mark - CreateViewFromRectWithProperties

- (UIView*) createViewWithRect:(CGRect)rect withColor:(UIColor*)color withParentView:(UIView*)parentView andMask:(UIViewAutoresizing)mask
{
    UIView* view = [[UIView alloc] initWithFrame:rect];
    [parentView addSubview:view];
    view.backgroundColor = color;
    [view setAutoresizingMask:mask];
    
    return view;
}


#pragma mark - Touches

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pointOnMainView = [touch locationInView:self.boardView];
    
    UIView *view = [self.boardView hitTest:pointOnMainView withEvent:event];
    
    if (view.tag == firstKindOfCheckerTag || view.tag == secondKindOfCheckerTag){
        self.draggingView = view;
        CGPoint touchPoint = [touch locationInView:self.draggingView];
        
        self.touchOffset = CGPointMake(CGRectGetMidX(self.draggingView.bounds) - touchPoint.x,
                                       CGRectGetMidY(self.draggingView.bounds) - touchPoint.y);
        
        [self.draggingView.layer removeAllAnimations];
        
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.draggingView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                             self.draggingView.alpha = 0.4f;
                         }];
        
        
        self.prevPoint = CGPointMake(pointOnMainView.x + self.touchOffset.x, pointOnMainView.y + self.touchOffset.y);
        
    } else {
        
        self.draggingView = nil;
    }

}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (self.draggingView) {
        UITouch* touch = [touches anyObject];
        
        CGPoint pointOnMainView = [touch locationInView:self.boardView];
        CGPoint correction = CGPointMake(pointOnMainView.x + self.touchOffset.x,
                                         pointOnMainView.y + self.touchOffset.y);
        NSLog(@"%@", NSStringFromCGPoint(pointOnMainView));
        
        self.draggingView.center = correction;
        
    }
    
    
    
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self onTouchEnded];
    if (![self.boardView pointInside:self.draggingView.center withEvent:event]) {
        self.draggingView.center = self.prevPoint;
        
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self onTouchEnded];
    
    CGPoint endTouchPoint = self.draggingView.center;
    NSLog(@"draggingView center = %@", NSStringFromCGPoint(endTouchPoint));
    
    if ([self isDraggingViewHitCellInPoint:endTouchPoint] && [self cellIsFree:self.hittedCell]) {
        [UIView animateWithDuration:1
                         animations:^{
                             self.draggingView.center = self.hittedCell.center;
                             self.draggingView.transform = CGAffineTransformMakeRotation(0.5*M_PI);
                         }];
    } else {
        [UIView animateWithDuration:2 animations:^{
            
            CGPoint nearestPoint = [self putInNearestFreePlace:self.draggingView];
            self.draggingView.center = nearestPoint;
            
        }];
        
    }
    
    self.draggingView.transform = CGAffineTransformIdentity;
    
}

- (void) onTouchEnded {
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.draggingView.transform = CGAffineTransformIdentity;
                         self.draggingView.alpha = 1;
                     }];
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
