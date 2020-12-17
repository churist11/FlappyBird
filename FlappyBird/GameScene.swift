//
//  GameScene.swift
//  FlappyBird
//
//  Created by 櫻井将太郎 on 2020/12/17.
//  Copyright © 2020 shoutarou.sakurai. All rights reserved.
//

import UIKit
import SpriteKit

class GameScene: SKScene {

	override func didMove(to view: SKView) {
		super.didMove(to: view)

		// Set scene's background
		self.backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)

		// Load ground image into texture
		let groundTexture = SKTexture(imageNamed: "ground")
		groundTexture.filteringMode = .nearest

		// Create sprite using texture
		let groundSprite = SKSpriteNode(texture: groundTexture)



	}

} //End
