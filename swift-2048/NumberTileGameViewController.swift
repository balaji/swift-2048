//
//  NumberTileGame.swift
//  swift-2048
//
//  Created by Austin Zheng on 6/3/14.
//  Copyright (c) 2014 Austin Zheng. All rights reserved.
//

import UIKit

/// A view controller representing the swift-2048 game. It serves mostly to tie a GameModel and a GameboardView
/// together. Data flow works as follows: user input reaches the view controller and is forwarded to the model. Move
/// orders calculated by the model are returned to the view controller and forwarded to the gameboard view, which
/// performs any animations to update its state.
class NumberTileGameViewController : UIViewController, GameModelDelegate {

  var dimension: Int
  var threshold: Int

  var gameBoardView: GameboardView?
  var gameModel: GameModel?
  var scoreBoardView: ScoreViewProtocol?
  
  let boardWidth: CGFloat = 230.0
  let thinPadding: CGFloat = 3.0
  let thickPadding: CGFloat = 6.0
  let viewPadding: CGFloat = 10.0
  let verticalViewOffset: CGFloat = 0.0

  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }

  override init() {
    dimension = 4
    threshold = 2048
    super.init(nibName: nil, bundle: nil)
    gameModel = GameModel(dimension: dimension, threshold: threshold, delegate: self)
    view.backgroundColor = UIColor.whiteColor()
    setupSwipeControls()
  }
  
  func setupSwipeControls() {
    let swipeOptions: Dictionary<String, UISwipeGestureRecognizerDirection> = ["up:": .Up, "down:": .Down, "left:": .Left, "right:": .Right]
    for (selector, direction) in swipeOptions {
      let swipe = UISwipeGestureRecognizer(target: self, action: Selector(selector))
      swipe.numberOfTouchesRequired = 1
      swipe.direction = direction
      view.addGestureRecognizer(swipe)
    }
  }
  
  @objc(up:)
  func upCommand(r: UIGestureRecognizer!) {
    moveCommand(r, .Up)
  }
  
  @objc(down:)
  func downCommand(r: UIGestureRecognizer!) {
    moveCommand(r, .Down)
  }
  
  @objc(left:)
  func leftCommand(r: UIGestureRecognizer!) {
    moveCommand(r, .Left)
  }
  
  @objc(right:)
  func rightCommand(r: UIGestureRecognizer!) {
    moveCommand(r, .Right)
  }
  
  func moveCommand(r: UIGestureRecognizer!, _ moveDirection: MoveDirection) {
    assert(gameModel != nil)
    gameModel!.queueMove(moveDirection,
      completion: { (changed: Bool) -> () in
        if changed {
          self.followUp()
        }
    })
  }
  
  func followUp() {
    assert(gameModel != nil)
    let (userWon, winningCoords) = gameModel!.userHasWon()
    if userWon {
      // TODO: alert delegate we won
      UIAlertView(title: "Victory", message: "You won!", delegate: self, cancelButtonTitle: "Cancel").show()
      // TODO: At this point we should stall the game until the user taps 'New Game' (which hasn't been implemented yet)
    } else {
      // Now, insert more tiles
      let randomVal = Int(arc4random_uniform(10))
      gameModel!.insertTileAtRandomLocation(randomVal == 1 ? 4 : 2)
    
      // At this point, the user may lose
      if gameModel!.userHasLost() {
        // TODO: alert delegate we lost
        UIAlertView(title: "Defeat", message: "You lost!", delegate: self, cancelButtonTitle: "Cancel").show()
      }
    }
  }

  // View Controller
  override func viewDidLoad()  {
    super.viewDidLoad()
    setupGame()
  }

  func setupGame() {
    // This nested function provides the x-position for a component view
    func xPositionToCenterView(v: UIView) -> CGFloat {
      let tentativeX = 0.5 * (view.bounds.size.width - v.bounds.size.width)
      return tentativeX >= 0 ? tentativeX : 0
    }
    
    // This nested function provides the y-position for a component view
    func yPositionForViewAtPosition(order: Int, views: [UIView]) -> CGFloat {
      assert(views.count > 0)
      assert(order >= 0 && order < views.count)
      let totalHeight = CGFloat(views.count - 1) * viewPadding + views.map{ $0.bounds.size.height }.reduce(verticalViewOffset) {  $0 + $1 }
      let top = 0.5 * (view.bounds.size.height - totalHeight)
      return (top >= 0 ? top : 0) + views[0..<order].map{ $0.bounds.size.height }.reduce(0.0) {  $0 + $1 + self.viewPadding }
    }

    // Create the score view
    let scoreBoard = ScoreView(backgroundColor: UIColor.blackColor(),
                              textColor: UIColor.whiteColor(),
                              font: UIFont(name: "HelveticaNeue-Bold", size: 16.0),
                              radius: 6)
    scoreBoard.score = 0 //TODO:sets the label.
    
    // Create the gameboard
    let padding: CGFloat = dimension > 5 ? thinPadding : thickPadding
    let v1 = boardWidth - padding * CGFloat(dimension + 1)
    let width: CGFloat = CGFloat(floorf(CFloat(v1)))/CGFloat(dimension)
    let gameBoard = GameboardView(dimension: dimension,
                                  tileWidth: width,
                                  tilePadding: padding,
                                  cornerRadius: 6,
                                  backgroundColor: UIColor.blackColor(),
                                  foregroundColor: UIColor.darkGrayColor())

    // Set up the frames
    let views = [scoreBoard, gameBoard]

    scoreBoard.frame.origin = CGPoint(x: xPositionToCenterView(scoreBoard), y: yPositionForViewAtPosition(0, views))
    gameBoard.frame.origin = CGPoint(x: xPositionToCenterView(gameBoard), y: yPositionForViewAtPosition(1, views))
    self.gameBoardView = gameBoard
    self.scoreBoardView = scoreBoard
    
    // Add to game state
    view.addSubview(gameBoard)
    view.addSubview(scoreBoard)

    assert(gameModel != nil)
    for _ in (1...2) { gameModel!.insertTileAtRandomLocation(2) }
  }

  // Protocol
  func scoreChanged(score: Int) {
    if let s = scoreBoardView {
      s.scoreChanged(newScore: score)
    }
  }

  func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
    assert(gameBoardView != nil)
    gameBoardView!.moveOneTile(from, to: to, value: value)
  }

  func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
    assert(gameBoardView != nil)
    gameBoardView!.moveTwoTiles(from, to: to, value: value)
  }

  func insertTile(location: (Int, Int), value: Int) {
    assert(gameBoardView != nil)
    gameBoardView!.insertTile(location, value: value)
  }
}
