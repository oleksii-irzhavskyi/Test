
import SwiftUI
import SpriteKit
import UIKit

final class GameScene: SKScene, SKPhysicsContactDelegate {

    private var player: SKNode!
    private var moveDir: CGFloat = 0
    private let moveSpeed: CGFloat = 260
    private var lastUpdateTime: TimeInterval = 0
    
    @AppStorage("balance") private var balance: Int = 0

    private var groundY: CGFloat = 0
    private var vy: CGFloat = 0
    private let gravityY: CGFloat = -1600
    private let jumpSpeed: CGFloat = 560
    private var canJump: Bool = true
    private var lastJumpTime: TimeInterval = 0
    private let jumpCooldown: TimeInterval = 0.18

    private var spawnTimer: TimeInterval = 0

    private(set) var level: Int = 1
    private var maxBalls: Int = 10
    private var speedMin: CGFloat = 90
    private var speedMax: CGFloat = 180
    private var spawnInterval: TimeInterval = 2.0
    func applyLevel(_ newLevel: Int) {
        level = max(1, newLevel)
        let base: TimeInterval = 2.0
        let step: TimeInterval = 0.15
        spawnInterval = max(0.6, base - step * TimeInterval(level - 1))
        maxBalls = min(30, 8 + level * 2)
        speedMin = 80 + CGFloat(level) * 12
        speedMax = 140 + CGFloat(level) * 28
        if speedMax < speedMin { swap(&speedMin, &speedMax) }
        print("[Level] set to \(level) | spawn=\(spawnInterval)s maxBalls=\(maxBalls) speed=\(Int(speedMin))..\(Int(speedMax))")
        spawnTimer = 0
    }

    private enum GameState { case playing, won, lost }
    private var state: GameState = .playing
    private var score: Int = 0

    enum EndKind { case won, lost }
    var onGameEnd: ((EndKind, Int) -> Void)?
    var onScoreUpdate: ((Int) -> Void)?

    private var fireTimer: Timer?
    private var idleDelay: TimeInterval = 0.25
    private var fireRate: TimeInterval = 0.4 // ~2.5 bullets/sec
    private var lastMoveChange: TimeInterval = 0


    override func didMove(to view: SKView) {
        backgroundColor = .black
        isUserInteractionEnabled = true
        isPaused = false
        view.isMultipleTouchEnabled = true

        if let p = childNode(withName: "//player") {
            player = p
            player.removeAllActions()
            player.constraints = nil
        } else {
            let rect = SKShapeNode(rectOf: CGSize(width: 40, height: 22), cornerRadius: 4)
            rect.fillColor = .white
            rect.strokeColor = .clear
            rect.position = CGPoint(x: size.width/2, y: 100)
            addChild(rect)
            player = rect
            player.removeAllActions()
            player.constraints = nil
        }
        if player.physicsBody == nil {
            player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: max(20, player.frame.width), height: max(20, player.frame.height)))
        }
        if let body = player.physicsBody {
            body.isDynamic = false
            body.affectedByGravity = false
            body.allowsRotation = false
            body.linearDamping = 0
            body.angularDamping = 0
            body.categoryBitMask = PhysicsCategory.player
            body.collisionBitMask = 0
            body.contactTestBitMask = PhysicsCategory.bigBall | PhysicsCategory.smallBall
        }
        groundY = player.position.y
        vy = 0
        canJump = true
        lastUpdateTime = 0

        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = PhysicsCategory.wall
        physicsBody?.restitution = 1.0
        physicsBody?.friction = 0.0
        physicsBody?.linearDamping = 0
        physicsBody?.angularDamping = 0
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if state != .playing { return }
        guard let t = touches.first else { return }
        let x = t.location(in: self).x
        let mid = frame.midX
        moveDir = x < mid ? -1 : 1
        lastMoveChange = CACurrentMediaTime()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let x = t.location(in: self).x
        let mid = frame.midX
        moveDir = x < mid ? -1 : 1
        lastMoveChange = CACurrentMediaTime()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveDir = 0
        lastMoveChange = CACurrentMediaTime()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveDir = 0
        lastMoveChange = CACurrentMediaTime()
    }

    func jump() {
        let now = CACurrentMediaTime()
        guard canJump, (now - lastJumpTime) > jumpCooldown else { return }
        vy = jumpSpeed
        canJump = false
        lastJumpTime = now
    }

    private func spawnBall(isBig: Bool) {
        let textureName = isBig ? "bigBall" : "smallBall"
        let tex = SKTexture(imageNamed: textureName)
        let sizeFactor: CGFloat = isBig ? 1.0 : 0.5
        let intendedSize = CGSize(width: 60 * sizeFactor, height: 60 * sizeFactor)

        let node: SKNode
        if tex.size().width > 0, tex.size().height > 0 {
            let sprite = SKSpriteNode(texture: tex)
            sprite.size = intendedSize
            node = sprite
        } else {
            let radius = intendedSize.width * 0.5
            let shape = SKShapeNode(circleOfRadius: radius)
            shape.fillColor = isBig ? .red : .orange
            shape.strokeColor = .clear
            node = shape
        }

        node.name = isBig ? "bigBall" : "smallBall"
        let halfW = intendedSize.width * 0.5
        let minX = frame.minX + halfW + 2
        let maxX = frame.maxX - halfW - 2
        let x = CGFloat.random(in: minX...maxX)
        let y = frame.maxY - halfW - 2
        node.position = CGPoint(x: x, y: y)
        (node as? SKSpriteNode)?.zPosition = 10
        (node as? SKShapeNode)?.zPosition = 10

        let radius = intendedSize.width * 0.5
        let offset = CGVector(dx: CGFloat.random(in: -radius*0.15...radius*0.15),
                              dy: CGFloat.random(in: -radius*0.15...radius*0.15))
        let body = SKPhysicsBody(circleOfRadius: radius, center: CGPoint(x: offset.dx, y: offset.dy))
        body.categoryBitMask = isBig ? PhysicsCategory.bigBall : PhysicsCategory.smallBall
        body.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.bigBall | PhysicsCategory.smallBall
        body.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player
        body.usesPreciseCollisionDetection = true
        body.restitution = max(0.86, min(0.96, 0.92 + CGFloat.random(in: -0.02...0.02)))
        body.friction = 0.0
        body.linearDamping = 0
        body.angularDamping = 0
        node.physicsBody = body
        node.physicsBody?.affectedByGravity = true
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.usesPreciseCollisionDetection = true

        let mag = CGFloat.random(in: speedMin...speedMax)
        let vx: CGFloat = (Bool.random() ? 1 : -1) * mag
        node.physicsBody?.velocity = CGVector(dx: vx, dy: 0)
        node.physicsBody?.usesPreciseCollisionDetection = true

        addChild(node)
    }

    private func makeBallNode(isBig: Bool, intendedSize: CGSize) -> SKNode {
        let textureName = isBig ? "bigBall" : "smallBall"
        let tex = SKTexture(imageNamed: textureName)
        let node: SKNode
        if tex.size().width > 0, tex.size().height > 0 {
            let sp = SKSpriteNode(texture: tex)
            sp.size = intendedSize
            node = sp
        } else {
            let shape = SKShapeNode(circleOfRadius: intendedSize.width * 0.5)
            shape.fillColor = isBig ? .red : .orange
            shape.strokeColor = .clear
            node = shape
        }
        node.name = isBig ? "bigBall" : "smallBall"
        let radius = intendedSize.width * 0.5
        let offset = CGVector(dx: CGFloat.random(in: -radius*0.15...radius*0.15),
                              dy: CGFloat.random(in: -radius*0.15...radius*0.15))
        let body = SKPhysicsBody(circleOfRadius: radius, center: CGPoint(x: offset.dx, y: offset.dy))
        body.categoryBitMask = isBig ? PhysicsCategory.bigBall : PhysicsCategory.smallBall
        body.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.bigBall | PhysicsCategory.smallBall
        body.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player
        body.usesPreciseCollisionDetection = true
        let baseRest: CGFloat = isBig ? 0.92 : 0.9
        body.restitution = max(0.85, min(0.96, baseRest + CGFloat.random(in: -0.02...0.02)))
        body.friction = 0.0
        body.linearDamping = 0
        body.angularDamping = 0

        node.physicsBody = body
        node.physicsBody?.affectedByGravity = true
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.usesPreciseCollisionDetection = true
        return node
    }
    
    func nudgeIfBouncingInPlace(_ node: SKNode) {
        guard let body = node.physicsBody else { return }
        let vx = body.velocity.dx
        let vy = body.velocity.dy
        let halfH = node.frame.height * 0.5
        let nearFloor = node.position.y <= (frame.minY + halfH + 6)
        if nearFloor && abs(vx) < 8 && abs(vy) < 40 {
            let dir: CGFloat = Bool.random() ? 1 : -1
            let jx: CGFloat = dir * 60 * body.mass
            body.applyImpulse(CGVector(dx: jx, dy: 0))
        }
    }

    private func splitBigBall(_ big: SKNode) {
        let pos = big.position
        big.removeFromParent()
        let smallSize = CGSize(width: 30, height: 30)
        let left = makeBallNode(isBig: false, intendedSize: smallSize)
        let right = makeBallNode(isBig: false, intendedSize: smallSize)

        left.position = pos + CGPoint(x: -smallSize.width * 0.8, y: 2)
        right.position = pos + CGPoint(x: smallSize.width * 0.8, y: 2)

        addChild(left)
        addChild(right)

        let base = CGFloat.random(in: speedMin...speedMax)
        let dxL: CGFloat = -(CGFloat.random(in: 0.6...1.0) * base)
        let dxR: CGFloat =  (CGFloat.random(in: 0.6...1.0) * base)
        let dy:  CGFloat =  CGFloat.random(in: 140...240)
        left.physicsBody?.velocity  = CGVector(dx: dxL, dy: dy)
        right.physicsBody?.velocity = CGVector(dx: dxR, dy: dy)
        left.physicsBody?.usesPreciseCollisionDetection = true
        right.physicsBody?.usesPreciseCollisionDetection = true
        if left.userData == nil { left.userData = NSMutableDictionary() }
        if right.userData == nil { right.userData = NSMutableDictionary() }
    }

    private func fire() {
        let r: CGFloat = 4
        let bullet = SKShapeNode(circleOfRadius: r)
        bullet.fillColor = .yellow
        bullet.strokeColor = .clear
        bullet.name = "bullet"
        bullet.position = CGPoint(x: player.position.x, y: player.position.y + player.frame.height/2 + 6)
        let body = SKPhysicsBody(circleOfRadius: r)
        body.affectedByGravity = false
        body.categoryBitMask = PhysicsCategory.bullet
        body.collisionBitMask = 0
        body.contactTestBitMask = PhysicsCategory.bigBall | PhysicsCategory.smallBall
        body.usesPreciseCollisionDetection = true
        bullet.physicsBody = body
        addChild(bullet)
        bullet.physicsBody?.velocity = CGVector(dx: 0, dy: 520)
        bullet.run(.sequence([.wait(forDuration: 3.0), .removeFromParent()]))
    }

    private func manageAutoFire(currentTime: TimeInterval) {
        let isMoving = abs(moveDir) > 0.01
        if isMoving {
            fireTimer?.invalidate(); fireTimer = nil
            lastMoveChange = currentTime
            return
        }
        if fireTimer == nil && (currentTime - lastMoveChange) > idleDelay {
            fireTimer = Timer.scheduledTimer(withTimeInterval: fireRate, repeats: true) { [weak self] _ in
                self?.fire()
            }
        }
    }


    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 0
        lastUpdateTime = currentTime
        guard dt > 0, let player = player else { return }
        if state != .playing { return }
        let deltaX = moveDir * moveSpeed * CGFloat(dt)
        player.position.x += deltaX
        let halfW = max(10, player.frame.width * 0.5)
        let minX = frame.minX + halfW
        let maxX = frame.maxX - halfW
        player.position.x = min(max(player.position.x, minX), maxX)

        let dtf = CGFloat(dt)
        vy += gravityY * dtf
        var newY = player.position.y + vy * dtf
        if newY <= groundY {
            newY = groundY
            vy = 0
            canJump = true
        }
        player.position.y = newY

        self.enumerateChildNodes(withName: "bigBall") { node, _ in
            self.nudgeIfBouncingInPlace(node)
        }
        self.enumerateChildNodes(withName: "smallBall") { node, _ in
            self.nudgeIfBouncingInPlace(node)
        }

        manageAutoFire(currentTime: currentTime)

        spawnTimer += dt
        if spawnTimer >= spawnInterval {
            spawnTimer = 0
            let currentBalls = children.filter { ($0.name == "bigBall") || ($0.name == "smallBall") }.count
            if currentBalls < maxBalls {
                let isBig = true
                spawnBall(isBig: isBig)
            } else {
            }
        }
    }
    

    func didBegin(_ contact: SKPhysicsContact) {
        if state != .playing { return }

        let a = contact.bodyA
        let b = contact.bodyB

        if a.categoryBitMask == PhysicsCategory.bullet {
            a.node?.removeFromParent()
            if b.categoryBitMask == PhysicsCategory.bigBall, let big = b.node { splitBigBall(big) }
            else if b.categoryBitMask == PhysicsCategory.smallBall { b.node?.removeFromParent(); addPoint(); checkWin() }
            return
        }
        if b.categoryBitMask == PhysicsCategory.bullet {
            b.node?.removeFromParent()
            if a.categoryBitMask == PhysicsCategory.bigBall, let big = a.node { splitBigBall(big) }
            else if a.categoryBitMask == PhysicsCategory.smallBall { a.node?.removeFromParent(); addPoint(); checkWin() }
            return
        }

        let aIsBall = (a.categoryBitMask == PhysicsCategory.bigBall || a.categoryBitMask == PhysicsCategory.smallBall)
        let bIsBall = (b.categoryBitMask == PhysicsCategory.bigBall || b.categoryBitMask == PhysicsCategory.smallBall)
        if (aIsBall && b.categoryBitMask == PhysicsCategory.player) || (bIsBall && a.categoryBitMask == PhysicsCategory.player) {
            gameOver(lost: true)
            return
        }
    }

    private func addPoint() {
        score += 1
        balance += 1
        onScoreUpdate?(score)
    }

    private func checkWin() {
        let anyBig = childNode(withName: "//bigBall") != nil
        let anySmall = childNode(withName: "//smallBall") != nil
        if !anyBig && !anySmall {
            gameOver(lost: false)
        }
    }

    private func gameOver(lost: Bool) {
        state = lost ? .lost : .won
        fireTimer?.invalidate(); fireTimer = nil
        isPaused = true
        spawnTimer = 0
        if lost { onGameEnd?(.lost, score) } else { onGameEnd?(.won, score) }
    }

    func resetGame() {
        enumerateChildNodes(withName: "bigBall") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "smallBall") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "bullet") { node, _ in node.removeFromParent() }
        score = 0
        onScoreUpdate?(score)
        state = .playing
        spawnTimer = 0
    }
}

fileprivate struct PhysicsCategory {
    static let player: UInt32   = 1 << 0
    static let bullet: UInt32   = 1 << 1
    static let bigBall: UInt32  = 1 << 2
    static let smallBall: UInt32 = 1 << 3
    static let ground: UInt32   = 1 << 4
    static let wall: UInt32     = 1 << 5
}

fileprivate func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint { CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y) }
