//
//  GameScene.swift
//  FlappyBird
//
//  Created by 櫻井将太郎 on 2020/12/17.
//  Copyright © 2020 shoutarou.sakurai. All rights reserved.
//

import UIKit
import SpriteKit

final class GameScene: SKScene {


	// MARK: - Stored Property


	// Parent node for sprite : ground, cloud
	private var scrollNode: SKNode!

	// Parent node for sprite : wall
	private var wallNode: SKNode!

	// Player bird
	private var bird: SKSpriteNode!


	// MARK: - didMove Method


	// Called when this scene is displayed on the view
	override func didMove(to view: SKView) {

		// Set scene's background
		self.backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)

		// Create parent node of scrolling sprites
		self.scrollNode = SKNode()
		self.addChild(self.scrollNode)

		// Parent node for wall sprite in scroll node
		self.wallNode = SKNode()
		scrollNode.addChild(self.wallNode)

		// Call methods to set up sprites
		self.setupGround()
		self.setupCloud()
		self.setupWalls()
		self.setupBird()
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

	private func setupWalls() -> Void {

		// <Setting for texture>
		// Load image for sprite
		let wallTexture = SKTexture(imageNamed: "wall")

		// Set texture quality
		wallTexture.filteringMode = .linear

		//<Setting for wall moving>
		// 1. Calculate distance wall sprite move
		let movingDistance = self.frame.size.width + (wallTexture.size().width * 2)

		// 2. Create move action
		let moveAction = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)

		// 3. Create action that remove wall from scene
		let removeAction = SKAction.removeFromParent()

		// 4. Create sequence action
		let wallAnimation = SKAction.sequence([moveAction, removeAction])

		//<Setting for random slit>
		// 1. Get bird texture size
		let birdTextureSize = SKTexture(imageNamed: "bird_a").size()

		// 2. Define slit size the bird throughout
		let slit_length = birdTextureSize.height * 3

		// 3. Define range of slit
		let random_y_range = birdTextureSize.height * 3

		// 4. Get center y position for wall
		let groundSize = SKTexture(imageNamed: "ground").size()
		let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
		let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2

		// <Define action: creation for wall>
		let createWallAnimation = SKAction.run {

			// Configure the wall position
			let wall = SKNode()
			wall.position = CGPoint(
				x: self.frame.size.width + wallTexture.size().width / 2,
				y: 0
			)
			wall.zPosition = -50

			// Generate random slit value
			let random_y = CGFloat.random(in: 0 ..< random_y_range)
			let under_wall_y = under_wall_lowest_y + random_y

			// Create under wall sprite
			let underWall = SKSpriteNode(texture: wallTexture)
			underWall.position = CGPoint(
				x: 0,
				y: under_wall_y
			)

			let upperWall = SKSpriteNode(texture: wallTexture)
			upperWall.position = CGPoint(
				x: 0,
				y: under_wall_y + wallTexture.size().height + slit_length
			)

			wall.addChild(upperWall)
			wall.addChild(underWall)

			// Run animation
			wall.run(wallAnimation)

			// Add child to parent wall node
			self.wallNode.addChild(wall)
		}


		// <Define action: waiting for next wall creation>
		let waitAnimation = SKAction.wait(forDuration: 2)

		// Combine action for wait-create animation
		let repreatAction = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))

		// Run the action
		wallNode.run(repreatAction)

	}

	private func setupBird() -> Void {

		// Load 2 bird images
		let birdTextureA = SKTexture(imageNamed: "bird_a")
		let birdTextureB = SKTexture(imageNamed: "bird_b")

		// Set texture quality
		birdTextureA.filteringMode = .linear
		birdTextureB.filteringMode = .linear

		// Defin action: switching texture, every 0.2sec birdA - B
		let texturesAnimation = SKAction.animate(with: [birdTextureA
			,  birdTextureB], timePerFrame: 0.2)

		// Make the action repeatable
		let flap = SKAction.repeatForever(texturesAnimation)

		// Create sprite for bird
		self.bird = SKSpriteNode(texture: birdTextureA)

		// Place the bird sprite
		self.bird.position = CGPoint(
			x: self.frame.size.width * 0.2,
			y: self.frame.size.height * 0.5
		)

		// Add the animation to the bird sprite
		self.bird.run(flap)

		// Add the bird sprite to parent
		self.addChild(self.bird)

	}


} //End
