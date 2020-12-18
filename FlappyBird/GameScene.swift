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

	// Called when this scene is displayed on the view
	override func didMove(to view: SKView) {
		self.setupGround()
	}


	// MARK: - Instance Method

	private func setupGround() -> Void {

		// Set scene's background
		self.backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)

		// Create parent node of sprite to stop scrolling anytime
		let scrollNode = SKNode()
		self.addChild(scrollNode)

		// Load ground image into texture
		let groundTexture = SKTexture(imageNamed: "ground")
		groundTexture.filteringMode = .nearest

		// Calculate repeatable scene background
		let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2

		// Create action to be scrolled
		let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
		let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)

		// Repeat two antions
		let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))

		// Place the ground sprite on scene
		for i in 0 ..< needNumber {

			// Create sprite using texture
			let groundSprite = SKSpriteNode(texture: groundTexture)

			// Configure position of the sprite
			groundSprite.position = CGPoint(
				x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
				y: groundTexture.size().height / 2
			)

			// Set the action to sprite
			groundSprite.run(repeatScrollGround)

			// Place the sprite on scene
			scrollNode.addChild(groundSprite)
		}


	}

	private func setupCloud() -> Void {

	}

} //End
