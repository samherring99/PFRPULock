//
//  ViewController.swift
//  PFRPULock
//
//  Created by Sam Herring, Kevin Peachman, and Kayla Collazo on 11/25/20.
//

import UIKit
import RealityKit
import Combine
import ARKit
import CoreGraphics

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    var mainView = UIView()
    
    var currentPair: [Entity] = []
    
    var score: Int = 0
    
    var progressView = UIProgressView(frame: CGRect(x: 90, y: 700, width: 200, height: 20))
    
    var globalNames = ["chair_swan", "tv_retro", "wheelbarrow", "fender_stratocaster", "gramophone", "teapot", "knife", "toy_drummer"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayInformationMessage()
        
    }
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: arView)
        if let tile = arView.entity(at: location) {
            
            if tile.transform.rotation.angle == .pi {
                var flipDown = tile.transform
                flipDown.rotation = simd_quatf(angle: 0, axis: [1, 0, 0])
                
                tile.children.first { (e) -> Bool in
                    print(e.name)
                    //e.move(to: flipDown, relativeTo: tile.parent, duration: 0.25, timingFunction: .easeInOut)
                    
                    if currentPair.count < 2 {
                        currentPair.append(e)
                        
                        if currentPair.count == 2 {
                            print(currentPair)
                            
                            if currentPair[0].name == currentPair[1].name {
                                // add point
                                flashScreen()
                                print("Point!")
                                score += 1
                                if score == 8  {
                                    // Show alert!
                                    
                                    let alert = UIAlertController(title: "Congratulations! You finished!", message: "You finished the puzzle with a score of 8/8. Thanks for using PRFPULock!", preferredStyle: .alert)

                                    alert.addAction(UIAlertAction(title: "Cool! I want to quit.", style: .default, handler: { (action) in
                                        exit(0)
                                    }))

                                    self.present(alert, animated: true)
                                }
                                progressView.setProgress(Float(score)/8.0, animated: true)
                            } else {
                                // flipDown
                                print("Flipper")
                                let seconds = 2.0
                                let pair1 = currentPair[0]
                                let pair2 = currentPair[1]
                                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                    // Put your code which should be executed with a delay here
                                    self.flip(entity: pair1)
                                    self.flip(entity: pair2)
                                }
                                
                                
                            }
                            
                            currentPair = []
                        }
                    }
                    
                    return globalNames.contains(e.name)
                }
                
                tile.move(to: flipDown, relativeTo: tile.parent, duration: 0.25, timingFunction: .easeInOut)
            } else {
                var flipUp = tile.transform
                flipUp.rotation = simd_quatf(angle: .pi, axis: [1, 0, 0])
                tile.children.first { (e) -> Bool in
                    print(e.name)
                    
                    
                    //e.move(to: flipUp, relativeTo: tile.parent, duration: 0.25, timingFunction: .easeInOut)
                    return globalNames.contains(e.name)
                }
                tile.move(to: flipUp, relativeTo: tile.parent, duration: 0.25, timingFunction: .easeInOut)
            }
        }
        
        
    }
    
    func flip(entity: Entity) {
        var flipT = entity.transform
        flipT.rotation = simd_quatf(angle: .pi, axis: [1, 0, 0])
        entity.move(to: flipT, relativeTo: entity.parent, duration: 0.25, timingFunction: .easeInOut)
    }
    
    func displayInformationMessage() {
        
        mainView = UIView(frame: CGRect(x: 40.0, y: 150.0, width: 300.0, height: 500.0))
        mainView.backgroundColor = UIColor.gray
        mainView.layer.cornerRadius = 10
        
        let closeButton = UIButton(frame: CGRect(x: 230, y: 20.0, width: 50.0, height: 20.0))
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.red, for: .normal)
        closeButton.addTarget(self, action: #selector(closeWindow), for: .touchUpInside)
        
        let topLabel = UILabel(frame: CGRect(x: mainView.frame.origin.x, y: 20.0, width: 200.0, height: 20.0))
        topLabel.text = "What this app does: "
        
        let topText = UITextView(frame: CGRect(x: topLabel.frame.origin.x, y: topLabel.frame.origin.y + 25.0, width: 220.0, height: 200.0))
        topText.isEditable = false
        topText.backgroundColor  = UIColor.lightGray
        topText.layer.cornerRadius = 10
        topText.text = "This application is designed to prevent overuse of your phone by encouraging physical activity and educational creative thinking in an augmented reality space before enabling access to your phone again. There are ranges of difficulties of puzzles, making possible new challenges for all ages. Once you complete the puzzle following the given instructions, the application will close."
        
        let bottomLabel = UILabel(frame: CGRect(x: mainView.frame.origin.x, y: 250.0, width: 200.0, height: 20.0))
        bottomLabel.text = "Why this app is useful: "
        
        let bottomText = UITextView(frame: CGRect(x: bottomLabel.frame.origin.x, y: bottomLabel.frame.origin.y + 25.0, width: 220.0, height: 200.0))
        bottomText.isEditable = false
        bottomText.backgroundColor  = UIColor.lightGray
        bottomText.layer.cornerRadius = 10
        bottomText.text = "This app is intended for people who have trouble regulating their phone use and want to limit it. Studies have shown that As phone usage increases mental health degrades, sometimes severely. We want the phone to be a tool a person uses to stay connected with people and achieve their goals, but we want the power to be in the user, not the phone. This tool can be used to lessen the time you spend on your phone and change your relationship with it."
        
        mainView.addSubview(closeButton)
        
        mainView.addSubview(topLabel)
        mainView.addSubview(topText)
        
        mainView.addSubview(bottomLabel)
        mainView.addSubview(bottomText)
        
        self.view.addSubview(mainView)
    }
    
    @objc func closeWindow(sender: UIButton!) {
        DispatchQueue.main.async {
            UIView.transition(with: self.mainView, duration: 5.0,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.mainView.isHidden = true
                                self.arView.addCoaching()
                                self.addUIOverlay()
                          })
        }
        // start everything else
    }
    
    func flashScreen() {
        let snapshotView = UILabel()
        snapshotView.textColor = UIColor.white
        snapshotView.text = "+1"
        //snapshotView.contentScaleFactor = 2.0
        snapshotView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(snapshotView)
        // Activate full screen constraints
        let constraints:[NSLayoutConstraint] = [
            snapshotView.topAnchor.constraint(equalTo: view.topAnchor),
            snapshotView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            snapshotView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            snapshotView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        // White because it's the brightest color
        snapshotView.backgroundColor = UIColor.white
        // Animate the alpha to 0 to simulate flash
        UIView.animate(withDuration: 1.3, animations: {
            snapshotView.alpha = 0
            //snapshotView.layoutIfNeeded()
        }) { _ in
            // Once animation completed, remove it from view.
            snapshotView.removeFromSuperview()
        }
    }
    
    func addUIOverlay() {
        print("Adding UI overlay here!")
        
        let rect1 = CGRect(x: self.view.frame.width - 75, y: 35, width: 100, height: 50)
        let rect2 = CGRect(x: 0, y: self.view.frame.height - 75, width: 100, height: 50)
        
        var menuButton = UIButton(frame: rect1)
        var emergencyButton = UIButton(frame: rect2)
        
        let helpLabel  = UILabel(frame: CGRect(x: 50.0, y: 350.0, width: 300.0, height: 50.0))
        helpLabel.text = "Tap to match pairs of tiles to progress!"
        helpLabel.textColor = UIColor.white
        
        menuButton.setImage(UIImage.init(systemName: "square.stack.3d.down.right"), for: .normal)
        menuButton.setTitleColor(.blue, for: .normal)
        menuButton.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
        
        emergencyButton.setImage(UIImage.init(systemName: "exclamationmark.triangle"), for: .normal)
        emergencyButton.tintColor = UIColor.red
        emergencyButton.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
        
        progressView.progressTintColor = UIColor.green
        progressView.setProgress(0.0, animated: true)
        
        emergencyButton.addTarget(self, action: #selector(emergencyQuitApp), for: .touchUpInside)
        
        self.view.addSubview(menuButton)
        self.view.addSubview(emergencyButton)
        self.view.addSubview(progressView)
        self.view.addSubview(helpLabel)
        
        helpLabel.blink()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            helpLabel.stopBlink()
            helpLabel.isHidden = true
        }
            
        
        
    }
    
    @objc func emergencyQuitApp(sender: UIButton!) {
        exit(0)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
}

extension ARView: ARCoachingOverlayViewDelegate {
    
    func addTiles() {
        
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2, 0.2])
        
        self.scene.addAnchor(anchor)
        
        var tiles: [Entity] = []
        
        for _ in 1...16 {
            let box = MeshResource.generateBox(width: 0.08, height: 0.002, depth: 0.08)
            let mat = SimpleMaterial(color: .darkGray, isMetallic: true)
            let model = ModelEntity(mesh: box, materials: [mat])
            model.name = "tile"
            model.generateCollisionShapes(recursive: true)
            tiles.append(model)
        }
        
        for (index, tile) in tiles.enumerated() {
            let x = Float(index % 4)
            let z = Float(index / 4)
            
            tile.position = [x*0.12, 0, z*0.12]
            anchor.addChild(tile)
        }
        
        let boxSize: Float = 0.85
        let occlusionMesh = MeshResource.generateBox(size: boxSize)
        
        let occlusionBox = ModelEntity(mesh: occlusionMesh, materials: [OcclusionMaterial()])
        
        occlusionBox.position.y = -boxSize/2
        
        anchor.addChild(occlusionBox)
        
        var cancellable: AnyCancellable? = nil
        var cancellable2: AnyCancellable? = nil
        
        let modelSequence = [ModelEntity.loadModelAsync(named: "tv_retro"),
                                       ModelEntity.loadModelAsync(named: "wheelbarrow"),
                                       ModelEntity.loadModelAsync(named: "fender_stratocaster"),
                                       ModelEntity.loadModelAsync(named: "gramophone"),
                                       ModelEntity.loadModelAsync(named: "teapot"),
                                       ModelEntity.loadModelAsync(named: "knife"),
                                       ModelEntity.loadModelAsync(named: "toy_drummer")]
        
        cancellable = ModelEntity.loadModelAsync(named: "chair_swan")
            .append(modelSequence[0])
            .append(modelSequence[1])
            .append(modelSequence[2])
            .append(modelSequence[3])
            .collect()
            .sink(receiveCompletion: { error in
                print("Unexpected error!")
                cancellable?.cancel()
            }, receiveValue: { entities in
                var objects: [ModelEntity] = []
                var names = ["chair_swan", "tv_retro", "wheelbarrow", "fender_stratocaster", "gramophone"]
                var count = 0
                for entity in entities {
                    entity.setScale(SIMD3<Float>(0.0007, 0.0007, 0.0007), relativeTo: anchor)
                    entity.generateCollisionShapes(recursive: true)
                    entity.name = names[count]
                    for _ in 1...2 {
                        objects.append(entity.clone(recursive: true))
                    }
                     count += 1
                }
                objects.shuffle()
                
                for (index, object) in objects.enumerated() {
                    tiles[index].addChild(object)
                    tiles[index].transform.rotation = simd_quatf(angle: .pi, axis: [1, 0, 0])
                }
                
                cancellable?.cancel()
            })
        
        cancellable2 = ModelEntity.loadModelAsync(named: "teapot")
            .append(modelSequence[5])
            .append(modelSequence[6])
            .collect()

            .sink(receiveCompletion: { error in
                print("Unexpected error!")
                cancellable2?.cancel()
            }, receiveValue: { entities in
                var objects: [ModelEntity] = []
                var names = ["teapot", "knife", "toy_drummer"]
                var count = 0
                for entity in entities {
                    entity.setScale(SIMD3<Float>(0.004, 0.004, 0.004), relativeTo: anchor)
                    entity.generateCollisionShapes(recursive: true)
                    entity.name = names[count]
                    for _ in 1...2 {
                        objects.append(entity.clone(recursive: true))
                    }
                    count += 1
                }
                objects.shuffle()
                
                for (index, object) in objects.enumerated() {
                    tiles[index+10].addChild(object)
                    tiles[index+10].transform.rotation = simd_quatf(angle: .pi, axis: [1, 0, 0])
                }
                
                cancellable2?.cancel()
            })
    }
    
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        //coachingOverlay.activatesAutomatically = false
        coachingOverlay.frame = self.frame

        coachingOverlay.autoresizingMask = [
            .flexibleWidth, .flexibleHeight
        ]
        self.addSubview(coachingOverlay)

        coachingOverlay.goal = .horizontalPlane

        coachingOverlay.session = self.session
        
        coachingOverlay.delegate = self
        
        coachingOverlay.setActive(true, animated: true)
    }
    // Example callback for the delegate object
    public func coachingOverlayViewDidDeactivate(
        _ coachingOverlayView: ARCoachingOverlayView
    ) {
        //self.addObjectsToScene()
        self.addTiles()
        coachingOverlayView.activatesAutomatically = false
        
    }
}

extension ARView {
}

extension ViewController: ARCoachingOverlayViewDelegate{
  
  //1. Called When The ARCoachingOverlayView Is Active And Displayed
  func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) { }
  
  //2. Called When The ARCoachingOverlayView Is No Active And No Longer Displayer
  func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
  }
  
  //3. Called When Tracking Conditions Are Poor Or The Seesion Needs Restarting
  func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) { }

}

extension UIView {
    func blink() {
        self.alpha = 0.0;
        UIView.animate(withDuration: 0.002, //Time duration you want,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: { [weak self] in self?.alpha = 1.0
                self?.layoutIfNeeded()
            },
            completion: { [weak self] _ in self?.alpha = 0.0 })
    }

    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 1
    }
}
