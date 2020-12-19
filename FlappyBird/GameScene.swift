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



	// MARK: - Stored Property


	private var scrollNode: SKNode!


	// MARK: - didMove Method


	// Called when this scene is displayed on the view
	override func didMove(to view: SKView) {

		// Set scene's background
		self.backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)

		// Create parent node of sprite to stop scrolling anytime
		self.scrollNode = SKNode()
		self.addChild(scrollNode)

		// Call methods to set up sprites
		self.setupGround()
		self.setupCloud()
	}


	// MARK: - Instance Method


	private func setupGround() -> Void {

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

		// Place the ground sprites on scene
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

		// Load ground image into texture
		let cloudTexture = SKTexture(imageNamed: "cloud")
		cloudTexture.filteringMode = .nearest

		// Calculate repeatable scene background
		let needNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2

		// Create action to be scrolled
		let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)
		let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)

		// Repeat two antions
		let repeartScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))

		// Place the sprite on scene
		for i in 0 ..< needNumber {

			// Create sprite using texture
			let cloudSprite = SKSpriteNode(texture: cloudTexture)
			cloudSprite.zPosition = -100

			// Configure position of the sprite
			cloudSprite.position = CGPoint(
				x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
				y: self.size.height - cloudTexture.size().height / 2
			)

			// Set the action to sprite
			cloudSprite.run(repeartScrollCloud)

			// Place the sprite on scene
			scrollNode.addChild(cloudSprite)
		}
	}

} //End
