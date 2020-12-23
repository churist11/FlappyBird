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


	// Parent node for all scrolling sprite , child of scene
	private var scrollNode: SKNode!

	// Parent node for sprite : wall, child of scroll node
	private var wallNode: SKNode!

	// Player bird
	private var bird: SKSpriteNode!

	// Parent node for item
	private var itemParentNode: SKNode!

	// Collision categories
	private let birdCategory: UInt32 = 1 << 0
	private let groundCategory: UInt32 = 1 << 1
	private let wallCategory: UInt32 = 1 << 2
	private let scoreCategory: UInt32 = 1 << 3 // For slit space between walls
	private let itemCategory: UInt32 = 1 << 4

	// <Score properties>

	/// $ User defaults to store best scrore
	private var userDefaults: UserDefaults = UserDefaults.standard

	/// $ Label displayed on scene for item score
	private var itemLabelNode: SKLabelNode!

	/// $ Label displayed on scene for current score
	private var scoreLabelNode: SKLabelNode!

	/// $ Label displayed on scene for Best score
	private var bestLabelNode: SKLabelNode!


	// MARK: - Computed Property


	/// $ Item score increase when the bird get item
	private var itemScore: Int = 0 {
		willSet {
			print("Item: \(newValue)")
		}
	}

	/// $ Score increase when the bird through the wall slit
	private var score: Int = 0 {
		willSet {
			print("Score: \(newValue)")
		}
	}

	/// $ Best score to be stored into user defaults
	private var bestScore: Int {
		get {
			return self.userDefaults.integer(forKey: C.BEST_SCORE_KEY)
		}
		set {
			// Store value with key into user defaults
			self.userDefaults.set(newValue, forKey: C.BEST_SCORE_KEY)

			// Save immediately
			self.userDefaults.synchronize()

			// Log the best score
			print("BEST: \(newValue)")
		}
	}


	// MARK: - didMove Method


	// Called when this scene is displayed on the view
	override func didMove(to view: SKView) {

		// Set self as delegate to implement contact
		self.physicsWorld.contactDelegate = self

		// Set gravity
		self.physicsWorld.gravity = CGVector(dx: 0, dy: -4)

		// Set scene's background
		self.backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)

		// Create parent node of scrolling sprites
		self.scrollNode = SKNode()
		self.addChild(self.scrollNode)

		// Parent node for wall sprite in scroll node
		self.wallNode = SKNode()
		self.scrollNode.addChild(self.wallNode)

		// Initialize item node container
		self.itemParentNode = SKNode()
		self.scrollNode.addChild(self.itemParentNode)

		// Call methods to set up sprites
		self.setupGround()
		self.setupCloud()
		self.setupWalls()
		self.setupBird()
		self.setupItems()

		// Call Method to display labels
		self.setupLabels()
	}


	// MARK: - Custom Method


	// MARK: - Setup Methods

	private func setupGround() -> Void {

		// Load ground image into texture
		let groundTexture = SKTexture(imageNamed: C.IMG_ASSET_GROUND)
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

			// Set physic to the ground sprite that same size as texture
			groundSprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())

			// Add static physics on the ground not tobe influenced by gravity
			groundSprite.physicsBody?.isDynamic = false

			// Configure physics of ground
			groundSprite.physicsBody?.categoryBitMask = self.groundCategory

			// Set the action to sprite
			groundSprite.run(repeatScrollGround)

			// Place the sprite on scene
			scrollNode.addChild(groundSprite)
		}
	}

	private func setupCloud() -> Void {

		// Load ground image into texture
		let cloudTexture = SKTexture(imageNamed: C.IMG_ASSET_CLOUD)
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
		let wallTexture = SKTexture(imageNamed: C.IMG_ASSET_WALL)

		// Set texture quality
		wallTexture.filteringMode = .linear

		//<Setting for wall moving>
		// 1. Calculate distance wall sprite move
		let movingDistance = self.frame.size.width + (wallTexture.size().width)

		// 2. Create move action
		let moveAction = SKAction.moveBy(x: -movingDistance, y: 0, duration: 5)

		// 3. Create action that remove wall from scene
		let removeAction = SKAction.removeFromParent()

		// 4. Create sequence action
		let wallAnimation = SKAction.sequence([moveAction, removeAction])

		//<Setting for random slit>
		// 1. Get bird texture size
		let birdTextureSize = SKTexture(imageNamed: C.IMG_ASSET_BIRD_A).size()

		// 2. Define slit size the bird throughout
		let slit_length = birdTextureSize.height * 3

		// 3. Define range of slit
		let random_y_range = birdTextureSize.height * 3

		// 4. Get center y position for wall
		let groundSize = SKTexture(imageNamed: C.IMG_ASSET_GROUND).size()
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

			// Add physics to individual wall
			underWall.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
			upperWall.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())

			// Set all wall is static
			underWall.physicsBody?.isDynamic = false
			upperWall.physicsBody?.isDynamic = false

			// Set category
			underWall.physicsBody?.categoryBitMask = self.wallCategory
			upperWall.physicsBody?.categoryBitMask = self.wallCategory

			// Set as wall node's child
			wall.addChild(underWall)
			wall.addChild(upperWall)

			// Create score node
			let scoreNode = SKNode()

			// Configure the node
			scoreNode.position = CGPoint(x: upperWall.size.width + birdTextureSize.width / 2, y: self.frame.size.height / 2)
			scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upperWall.size.width, height: self.frame.size.height))
			scoreNode.physicsBody?.isDynamic = false
			scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
			scoreNode.physicsBody?.contactTestBitMask = self.birdCategory

			// Add to it as child
			wall.addChild(scoreNode)

			// Run animation
			wall.run(wallAnimation)

			// Add child to parent wall node
			self.wallNode.addChild(wall)
		}


		// <Define action: waiting for next wall creation>
		let waitAnimation = SKAction.wait(forDuration: 3)

		// Combine action for wait-create animation
		let repreatAction = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))

		// Run the action
		self.wallNode.run(repreatAction)

	}

	private func setupBird() -> Void {

		// Load 2 bird images
		let birdTextureA = SKTexture(imageNamed: C.IMG_ASSET_BIRD_A)
		let birdTextureB = SKTexture(imageNamed: C.IMG_ASSET_BIRD_B)

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
			y: self.frame.size.height * 0.6
		)

		// Set physics to the bird
		self.bird.physicsBody = SKPhysicsBody(circleOfRadius: self.bird.size.height / 2)

		// Configure physics of bird
		self.bird.physicsBody?.allowsRotation = false
		self.bird.physicsBody?.categoryBitMask = self.birdCategory
		self.bird.physicsBody?.contactTestBitMask = self.wallCategory | self.groundCategory
		self.bird.physicsBody?.collisionBitMask = self.wallCategory | self.groundCategory

		// Add the animation to the bird sprite
		self.bird.run(flap)

		// Add the bird sprite to parent
		self.addChild(self.bird)

	}

	private func setupItems() -> Void {

		// <Setting for texture>
		// Load image for sprite
		let itemTexture = SKTexture(imageNamed: C.IMG_ASSET_ITEM)

		// Set texture quality
		itemTexture.filteringMode = .linear

		//<Setting for item moving>
		// 1. Calculate distance item sprite move
		let movingDistance = self.frame.size.width + (itemTexture.size().width)

		// 2. Create move action
		let moveAction = SKAction.moveBy(x: -movingDistance, y: 0, duration: 5)

		// 3. Create action that remove item from scene
		let removeAction = SKAction.removeFromParent()

		// 4. Create sequence action
		let itemAnimation = SKAction.sequence([moveAction, removeAction])

		//<Setting for random slit>
		// 1. Get bird texture size
		let birdTextureSize = SKTexture(imageNamed: C.IMG_ASSET_BIRD_A).size()

		// 2. Define slit size the bird throughout
		let slit_length = birdTextureSize.height * 3

		// 3. Define range of slit
		let random_y_range = birdTextureSize.height * 5

		// 4. Get center y position for wall
		let groundSize = SKTexture(imageNamed: C.IMG_ASSET_GROUND).size()
		let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
		let under_wall_lowest_y = center_y - slit_length / 2 - itemTexture.size().height / 2 - random_y_range / 2

		// <Define action: creation for item>
		let createItemAnimation = SKAction.run {

			// Configure the item container position
			let itemContainer = SKNode()
			itemContainer.position = CGPoint(
				x: self.frame.size.width + itemTexture.size().width / 2,
				y: 0
			)
			itemContainer.zPosition = -50

			// Generate random slit value
			let random_y = CGFloat.random(in: 0 ..< random_y_range)
			let under_wall_y = under_wall_lowest_y + random_y

			// Create item sprite
			let item = SKSpriteNode(texture: itemTexture)
			item.position = CGPoint(
				x: 0,
				y: (under_wall_y + (under_wall_y + itemTexture.size().height + slit_length)) / 2
			)


			// Add physics to individual item
			item.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: itemTexture.size().width * 0.7, height: itemTexture.size().height * 0.7))

			// Set all item is static
			item.physicsBody?.isDynamic = false

			// Set category
			item.physicsBody?.categoryBitMask = self.itemCategory

			// And contact
			item.physicsBody?.contactTestBitMask = self.birdCategory

			// Set as wall node's child
			itemContainer.addChild(item)

			// Run animation
			itemContainer.run(itemAnimation)

			// Add child to parent item node
			self.itemParentNode.addChild(itemContainer)
		}


		// Define action: waiting for next item creation
		let waitAnimation = SKAction.wait(forDuration: 3)

		// Combine action for wait-create animation
		let repreatAction = SKAction.repeatForever(SKAction.sequence([createItemAnimation, waitAnimation]))

		// Delay action by 1.5 sec timer
		Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (timer) in

			// Run the action
			self.itemParentNode.run(repreatAction)

			// Remove runnig timer
			timer.invalidate()
		}

		
	}

	private func setupLabels() -> Void {

		// Establish Current score label
		self.score = 0
		self.scoreLabelNode = SKLabelNode()
		self.scoreLabelNode.fontColor = .black
		self.scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
		self.scoreLabelNode.zPosition = 100
		self.scoreLabelNode.horizontalAlignmentMode = .left
		self.scoreLabelNode.text = "Current score: \(self.score)"

		// Establish Best score label
		self.bestLabelNode = SKLabelNode()
		self.bestLabelNode.fontColor = .black
		self.bestLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
		self.bestLabelNode.zPosition = 100
		self.bestLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
		self.bestLabelNode.text = "Best score: \(self.bestScore)"

		// Establish item score label
		self.itemLabelNode = SKLabelNode()
		self.itemLabelNode.fontColor = .blue
		self.itemLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 150)
		self.itemLabelNode.zPosition = 100
		self.itemLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
		self.itemLabelNode.text = "Item score: \(self.itemScore)"

		// Add labels to scene as child
		self.addChild(self.scoreLabelNode)
		self.addChild(self.bestLabelNode)
		self.addChild(self.itemLabelNode)
	}

	// MARK: - Game cycle method

	private func restart() -> Void {

		// Turn the score 0
		self.score = 0
		self.scoreLabelNode.text = "Current score: \(self.score)"

		// Reset the bird to initiial state and position
		self.bird.position = CGPoint(
			x: self.frame.size.width * 0.2,
			y: self.frame.size.height * 0.6
		)
		self.bird.physicsBody?.velocity = CGVector.zero
		self.bird.physicsBody?.collisionBitMask = self.wallCategory | self.groundCategory
		self.bird.zRotation = 0

		// Clear all walls
		self.wallNode.removeAllChildren()
		self.itemParentNode.removeAllChildren()

		// Have stopped sprites restart scrolling
		self.scrollNode.speed = 1
		self.bird.speed = 1
	}


	// MARK: - Overrides


	// Called when user started touching screen
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

		// Flap in only gaming situation
		if self.scrollNode.speed > 0 {

			// Turn the bird's speed zero
			self.bird.physicsBody?.velocity = CGVector.zero

			// Give the bird power to go upper
			self.bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))

		} else if self.bird.speed == 0 {

			// Tap to restart the game
			self.restart()
		}

	}


} //End

extension GameScene: SKPhysicsContactDelegate {

	// Called when two physic bodies contacted
	func didBegin(_ contact: SKPhysicsContact) {

		// Do nothing when gameover
		if self.scrollNode.speed <= 0 {
			return
		}

		// Contact with score node
		if (contact.bodyA.categoryBitMask & self.scoreCategory) == self.scoreCategory || (contact.bodyB.categoryBitMask & self.scoreCategory) == self.scoreCategory {

			// Did contact with score node, get 1 score
			self.score += 1

			// Update current score label
			self.scoreLabelNode.text = "Current score: \(self.score)"

			// Check current score is the best score
			if self.bestScore < self.score {

				// Update the best score to current score
				self.bestScore = self.score

				// Update best score label
				self.bestLabelNode.text = "Best score: \(self.bestScore)"
			}

			// When contact with item
		} else if (contact.bodyA.categoryBitMask & self.itemCategory) == self.itemCategory || (contact.bodyB.categoryBitMask & self.itemCategory) == self.itemCategory {

			// Get item node related to the body
			if let itemNode = contact.bodyA.node {

				// print log
				print(itemNode)

				// Remove contacted item
				itemNode.removeFromParent()
			}

			// Did contact with wall or ground
		} else {

			// Log message
			print("Gameover")

			// Stop scrolling
			self.scrollNode.speed = 0

			// Modify collision only between the bird and ground to not bounce on wall
			self.bird.physicsBody?.collisionBitMask = self.groundCategory

			// Rotate lose bird and turn speed 0
			let rotate = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(self.bird.position.y) * 0.01, duration: 1)

			self.bird.run(rotate) {
				// Stop the bird's moving
				self.bird.speed = 0
			}
		}
	}
}
