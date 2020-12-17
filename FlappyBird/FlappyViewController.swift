//
//  FlappyViewController.swift
//  FlappyBird
//
//  Created by 櫻井将太郎 on 2020/12/18.
//  Copyright © 2020 shoutarou.sakurai. All rights reserved.
//

import UIKit
import SpriteKit

class FlappyViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Convert UIview into Skview
		guard let skView = self.view as? SKView else {
			return
		}

		// Indicate FPS on the view
		skView.showsFPS = true

		// Indicate number of nodes in the view
		skView.showsNodeCount = true

		// Create scene sized same as the view
		let scene = GameScene(size: skView.frame.size)

		// Display the scene in the view
		skView.presentScene(scene)
	}


}
