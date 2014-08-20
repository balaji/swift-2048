//
//  ViewController.swift
//  swift-2048
//
//  Created by Austin Zheng on 6/3/14.
//  Copyright (c) 2014 Austin Zheng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBAction func startGameButtonTapped(sender : UIButton) {
    self.presentViewController(NumberTileGameViewController(),
      animated: true,
      completion: nil)
  }
}

