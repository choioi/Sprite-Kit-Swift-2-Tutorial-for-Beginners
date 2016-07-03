//
//  GameScene.swift
//  Sprite Kit Swift 2 Tutorial for Beginners
//
//  Created by phung on 7/2/16.
//  Copyright (c) 2016 phung. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    //static let Monster   : UInt32 = 0b1       // 1
    //static let Projectile: UInt32 = 0b10      // 2
    static let Monster   : UInt32 = 1       // 1
    static let Projectile: UInt32 = 2      // 2
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    
    var monstersDestroyed = 0
    let player = SKSpriteNode(imageNamed: "player")
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
    backgroundColor = SKColor.whiteColor()
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    addChild(player)
        
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(1.0)
                ])
            ))
        
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        
        
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        
        
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
         //1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
//        
//        for touch in touches {
//            let touchLocation = touch.locationInNode(self)
        

        
        
        // 2 - Khởi tạo đạn và vị trí đạn
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        
        // 3 - khai báo khoảng cách của đạn và khoảng cách touch
        let offset = touchLocation - projectile.position
        
        // 4 - Nếu khoảng cách này có ví trị x <
        if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        //}
    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
        monstersDestroyed++
        if (monstersDestroyed > 30) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
//        
//        // 1
//        var firstBody: SKPhysicsBody
//        var secondBody: SKPhysicsBody
//        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
//            firstBody = contact.bodyA
//            secondBody = contact.bodyB
//        } else {
//            firstBody = contact.bodyB
//            secondBody = contact.bodyA
//        }
//        
//        // 2
//        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
//            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
//                projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
//        }
        
        //Hàm didBeginContact có biến contact để xac định 2 body A va B chạm nhau, nên ta phải xác dịnh mặc nạ body A có thể là player hoặc quái vật, thì sẽ làm 1 hành đông gì đó
        
        //Trong ví dụ này : body là là phi tiêu Projectile và body B là Monster, hoặc ngượi lại, tức là có sự va chạm 2 con thực thể này thì ta gọi hàm projectileDidCollideWithMonster, hàm nào cũng đều remove hết.
        if (contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 2)
            || (contact.bodyA.categoryBitMask == 2 && contact.bodyB.categoryBitMask == 1)
        {
        
       // projectileDidCollideWithMonster(contact.bodyA.node as! SKSpriteNode, monster: contact.bodyB.node as! SKSpriteNode)
            projectileDidCollideWithMonster(contact.bodyA.node as! SKSpriteNode, monster: contact.bodyB.node as! SKSpriteNode)

        
        }

        
        
        
    }
    
    
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        
        
        
        // add hình cho node
        let monster = SKSpriteNode(imageNamed: "monster")
        
        // Đảm bảo actualY luôn luôn thấy được full hình con monster khi xuất hiện trên trục y
       // let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        let actualY = size.height * 0.5 // Monster xuat hien giua man hinh, de test thoi

        
        // Vị trí x của monter mới sinh ra luôn nằm trong góc cạnh phải màn hình
        // vị trị y thì lấy ở trên
        
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Tốc dộ của monter cũng random từ 2s đến 4s
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // x: -monster.size.width/2 : di chuyển về sát màn hình bên trái, đi xuyên bảo đảm mất hình con monter
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        //di chuyển xong remove luôn
        monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        // khai báo va chạm :
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size) // 1
        monster.physicsBody?.dynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        monster.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
//      1: Creates a physics body for the sprite. In this case, the body is defined as a rectangle of the same size of the sprite, because that’s a decent approximation for the monster.
//      2:  Sets the sprite to be dynamic. This means that the physics engine will not control the movement of the monster – you will through the code you’ve already written (using move actions).
//      3: Sets the category bit mask to be the monsterCategory you defined earlier.
//      4:  The contactTestBitMask indicates what categories of objects this object should notify the contact listener when they intersect. You choose projectiles here.
//      5:  The collisionBitMask indicates what categories of objects this object that the physics engine handle contact responses to (i.e. bounce off of). You don’t want the monster and projectile to bounce off each other – it’s OK for them to go right through each other in this game – so you set this to 0.
        
    }
    
    
    
}
