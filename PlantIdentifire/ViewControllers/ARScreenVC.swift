//
//  ARScreenVC.swift
//  PlantIdentifire
//
//  Created by Sagar Lukhi on 08/06/23.
//

/*

import ARKit
import Foundation
import SceneKit
import UIKit
import Photos

class ARScreenVC: UIViewController {

    var dragOnInfinitePlanesEnabled = false
    var currentGesture: Gesture?

    var use3DOFTrackingFallback = false
    var screenCenter: CGPoint?

    let session = ARSession()
    var sessionConfig: ARConfiguration = ARWorldTrackingConfiguration()

    var trackingFallbackTimer: Timer?

    // Use average of recent virtual object distances to avoid rapid changes in object scale.
    var recentVirtualObjectDistances = [CGFloat]()

    let DEFAULT_DISTANCE_CAMERA_TO_OBJECTS = Float(10)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupScene()
        setupDebug()
        setupUIControls()
        setupFocusSquare()
        updateSettings()
        resetVirtualObject()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true
//        restartPlaneDetection()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }

    // MARK: - ARKit / ARSCNView
    var use3DOFTracking = false {
        didSet {
            if use3DOFTracking {
                sessionConfig = ARWorldTrackingConfiguration()
            }
            session.run(sessionConfig)
        }
    }
    @IBOutlet var sceneView: ARSCNView!

    // MARK: - Ambient Light Estimation
    func toggleAmbientLightEstimation(_ enabled: Bool) {
        if enabled {
            if !sessionConfig.isLightEstimationEnabled {
                sessionConfig.isLightEstimationEnabled = true
                session.run(sessionConfig)
            }
        } else {
            if sessionConfig.isLightEstimationEnabled {
                sessionConfig.isLightEstimationEnabled = false
                session.run(sessionConfig)
            }
        }
    }

    // MARK: - Virtual Object Loading
    var isLoadingObject: Bool = false

    // MARK: - Planes

    var planes = [ARPlaneAnchor: Plane]()

    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {

        let pos = SCNVector3.positionFromTransform(anchor.transform)
//        textManager.showDebugMessage("NEW SURFACE DETECTED AT \(pos.friendlyString())")

        let plane = Plane(anchor, false)

        planes[anchor] = plane
        node.addChildNode(plane)

//        textManager.cancelScheduledMessage(forType: .planeEstimation)
//        textManager.showMessage("SURFACE DETECTED")
//        if !VirtualObjectsManager.shared.isAVirtualObjectPlaced() {
//            textManager.scheduleMessage("TAP + TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .contentPlacement)
//        }
    }

    func restartPlaneDetection() {
        // configure session
        if let worldSessionConfig = sessionConfig as? ARWorldTrackingConfiguration {
            worldSessionConfig.planeDetection = .horizontal
            session.run(worldSessionConfig, options: [.resetTracking, .removeExistingAnchors])
        }

        // reset timer
        if trackingFallbackTimer != nil {
            trackingFallbackTimer!.invalidate()
            trackingFallbackTimer = nil
        }

//        textManager.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .planeEstimation)
    }

    @IBAction func actionBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    // MARK: - Focus Square
    var focusSquare: FocusSquare?

    func setupFocusSquare() {
        focusSquare?.isHidden = true
        focusSquare?.removeFromParentNode()
        focusSquare = FocusSquare()
        sceneView.scene.rootNode.addChildNode(focusSquare!)
        addHexagonalGrid()
//        textManager.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
    }
    
    
    func addHexagonalGrid() {
        let radius: CGFloat = 0.1 // Radius of each hexagon
        let sideLength = radius * sqrt(3) // Length of each side
        
        let hexagonGeometry = SCNHexagonGeometry(radius: radius)
        let hexagonMaterial = SCNMaterial()
        hexagonMaterial.diffuse.contents = UIColor.red
        hexagonGeometry.materials = [hexagonMaterial]
        
        let numberOfRows = 5
        let numberOfColumns = 5
        
        for row in 0..<numberOfRows {
            for column in 0..<numberOfColumns {
                let x = Float(column) * Float(sideLength)
                let z = Float(row) * Float(radius) * 1.5
                let y: Float = 0.0
                
                let hexagonNode = SCNNode(geometry: hexagonGeometry)
                hexagonNode.position = SCNVector3(x, y, -z)
                sceneView.scene.rootNode.addChildNode(hexagonNode)
            }
        }
    }

    func updateFocusSquare() {
        guard let screenCenter = screenCenter else { return }

        let virtualObject = VirtualObjectsManager.shared.getVirtualObjectSelected()
        if virtualObject != nil && sceneView.isNode(virtualObject!, insideFrustumOf: sceneView.pointOfView!) {
            focusSquare?.hide()
        } else {
            focusSquare?.unhide()
        }
        let (worldPos, planeAnchor, _) = worldPositionFromScreenPosition(screenCenter, objectPos: focusSquare?.position)
        if let worldPos = worldPos {
            focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.session.currentFrame?.camera)
//            textManager.cancelScheduledMessage(forType: .focusSquare)
        }
    }

    // MARK: - Hit Test Visualization

    var hitTestVisualization: HitTestVisualization?

//    var showHitTestAPIVisualization = UserDefaults.standard.bool(for: .showHitTestAPI) {
//        didSet {
//            UserDefaults.standard.set(showHitTestAPIVisualization, for: .showHitTestAPI)
//            if showHitTestAPIVisualization {
//                hitTestVisualization = HitTestVisualization(sceneView: sceneView)
//            } else {
//                hitTestVisualization = nil
//            }
//        }
//    }

    // MARK: - Debug Visualizations

//    @IBOutlet var featurePointCountLabel: UILabel!

    func refreshFeaturePoints() {
//        guard showDebugVisuals else {
//            return
//        }

        guard let cloud = session.currentFrame?.rawFeaturePoints else {
            return
        }

        DispatchQueue.main.async {
//            self.featurePointCountLabel.text = "Features: \(cloud.__count)".uppercased()
        }
    }

//    var showDebugVisuals: Bool = UserDefaults.standard.bool(for: .debugMode) {
//        didSet {
//            featurePointCountLabel.isHidden = !showDebugVisuals
//            debugMessageLabel.isHidden = !showDebugVisuals
//            messagePanel.isHidden = !showDebugVisuals
//            planes.values.forEach { $0.showDebugVisualization(showDebugVisuals) }
//            sceneView.debugOptions = []
//            if showDebugVisuals {
//                sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
//            }
//            UserDefaults.standard.set(showDebugVisuals, for: .debugMode)
//        }
//    }

    func setupDebug() {
//        messagePanel.layer.cornerRadius = 3.0
//        messagePanel.clipsToBounds = true
    }

    // MARK: - UI Elements and Actions

//    @IBOutlet weak var messagePanel: UIView!
//    @IBOutlet weak var messageLabel: UILabel!
//    @IBOutlet weak var debugMessageLabel: UILabel!

//    var textManager: TextManager!

    func setupUIControls() {
//        textManager = TextManager(viewController: self)
//        debugMessageLabel.isHidden = true
//        featurePointCountLabel.text = ""
//        debugMessageLabel.text = ""
//        messageLabel.text = ""
    }

   

//    @IBAction func takeSnapShot() {
//        guard sceneView.session.currentFrame != nil else { return }
//        focusSquare?.isHidden = true
//
//        let imagePlane = SCNPlane(width: sceneView.bounds.width / 6000, height: sceneView.bounds.height / 6000)
//        imagePlane.firstMaterial?.diffuse.contents = sceneView.snapshot()
//        imagePlane.firstMaterial?.lightingModel = .constant
//
//        let planeNode = SCNNode(geometry: imagePlane)
//        sceneView.scene.rootNode.addChildNode(planeNode)
//
//        focusSquare?.isHidden = false
//    }

    // MARK: - Settings

    

    private func updateSettings() {
        let defaults = UserDefaults.standard

//        showDebugVisuals = defaults.bool(for: .debugMode)
        toggleAmbientLightEstimation(false)
        dragOnInfinitePlanesEnabled = false
//        showHitTestAPIVisualization = false
        use3DOFTracking    = false
        use3DOFTrackingFallback = false
        for (_, plane) in planes {
            plane.updateOcclusionSetting()
        }
    }

    // MARK: - Error handling

    func displayErrorMessage(title: String, message: String, allowRestart: Bool = false) {
        
    }
}

// MARK: - ARKit / ARSCNView
extension ARScreenVC {
    func setupScene() {
        sceneView.setUp(viewController: self, session: session)
        DispatchQueue.main.async {
            self.screenCenter = self.sceneView.bounds.mid
        }
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
//        textManager.showTrackingQualityInfo(for: camera.trackingState, autoHide: !self.showDebugVisuals)
//
//        switch camera.trackingState {
//        case .notAvailable:
//            textManager.escalateFeedback(for: camera.trackingState, inSeconds: 5.0)
//        case .limited:
//            if use3DOFTrackingFallback {
//                // After 10 seconds of limited quality, fall back to 3DOF mode.
//                trackingFallbackTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false, block: { _ in
//                    self.use3DOFTracking = true
//                    self.trackingFallbackTimer?.invalidate()
//                    self.trackingFallbackTimer = nil
//                })
//            } else {
//                textManager.escalateFeedback(for: camera.trackingState, inSeconds: 10.0)
//            }
//        case .normal:
//            textManager.cancelScheduledMessage(forType: .trackingStateEscalation)
//            if use3DOFTrackingFallback && trackingFallbackTimer != nil {
//                trackingFallbackTimer!.invalidate()
//                trackingFallbackTimer = nil
//            }
//        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        guard let arError = error as? ARError else { return }

        let nsError = error as NSError
        var sessionErrorMsg = "\(nsError.localizedDescription) \(nsError.localizedFailureReason ?? "")"
        if let recoveryOptions = nsError.localizedRecoveryOptions {
            for option in recoveryOptions {
                sessionErrorMsg.append("\(option).")
            }
        }

        let isRecoverable = (arError.code == .worldTrackingFailed)
        if isRecoverable {
            sessionErrorMsg += "\nYou can try resetting the session or quit the application."
        } else {
            sessionErrorMsg += "\nThis is an unrecoverable error that requires to quit the application."
        }

        displayErrorMessage(title: "We're sorry!", message: sessionErrorMsg, allowRestart: isRecoverable)
    }

    func sessionWasInterrupted(_ session: ARSession) {
//        textManager.blurBackground()
//        textManager.showAlert(title: "Session Interrupted",
//                              message: "The session will be reset after the interruption has ended.")
    }

    func sessionInterruptionEnded(_ session: ARSession) {
//        textManager.unblurBackground()
        session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
//        restartExperience(self)
//        textManager.showMessage("RESETTING SESSION")
    }
}

// MARK: Gesture Recognized
extension ARScreenVC {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let object = VirtualObjectsManager.shared.getVirtualObjectSelected() else {
            return
        }

        if currentGesture == nil {
            currentGesture = Gesture.startGestureFromTouches(touches, self.sceneView, object)
        } else {
            currentGesture = currentGesture!.updateGestureFromTouches(touches, .touchBegan)
        }

        displayVirtualObjectTransform()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !VirtualObjectsManager.shared.isAVirtualObjectPlaced() {
            return
        }
        currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchMoved)
        displayVirtualObjectTransform()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !VirtualObjectsManager.shared.isAVirtualObjectPlaced() {
            return
        }

        currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchEnded)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !VirtualObjectsManager.shared.isAVirtualObjectPlaced() {
            return
        }
        currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchCancelled)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension ARScreenVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        updateSettings()
    }
}

// MARK: - ARSCNViewDelegate
extension ARScreenVC: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        refreshFeaturePoints()

        DispatchQueue.main.async {
            self.updateFocusSquare()
            self.hitTestVisualization?.render()

            // If light estimation is enabled, update the intensity of the model's lights and the environment map
            if let lightEstimate = self.session.currentFrame?.lightEstimate {
                self.sceneView.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 40)
            } else {
                self.sceneView.enableEnvironmentMapWithIntensity(25)
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.addPlane(node: node, anchor: planeAnchor)
                self.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor)
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                if let plane = self.planes[planeAnchor] {
                    plane.update(planeAnchor)
                }
                self.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor)
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor, let plane = self.planes.removeValue(forKey: planeAnchor) {
                plane.removeFromParentNode()
            }
        }
    }
}

// MARK: Virtual Object Manipulation
extension ARScreenVC {
    func displayVirtualObjectTransform() {
        guard let object = VirtualObjectsManager.shared.getVirtualObjectSelected(),
            let cameraTransform = session.currentFrame?.camera.transform else {
            return
        }

        // Output the current translation, rotation & scale of the virtual object as text.
        let cameraPos = SCNVector3.positionFromTransform(cameraTransform)
        let vectorToCamera = cameraPos - object.position

        let distanceToUser = vectorToCamera.length()

        var angleDegrees = Int(((object.eulerAngles.y) * 180) / Float.pi) % 360
        if angleDegrees < 0 {
            angleDegrees += 360
        }

        let distance = String(format: "%.2f", distanceToUser)
        let scale = String(format: "%.2f", object.scale.x)
//        textManager.showDebugMessage("Distance: \(distance) m\nRotation: \(angleDegrees)°\nScale: \(scale)x")
    }

    func moveVirtualObjectToPosition(_ pos: SCNVector3?, _ instantly: Bool, _ filterPosition: Bool) {

        guard let newPosition = pos else {
//            textManager.showMessage("CANNOT PLACE OBJECT\nTry moving left or right.")
            // Reset the content selection in the menu only if the content has not yet been initially placed.
            if !VirtualObjectsManager.shared.isAVirtualObjectPlaced() {
                resetVirtualObject()
            }
            return
        }

        if instantly {
            setNewVirtualObjectPosition(newPosition)
        } else {
            updateVirtualObjectPosition(newPosition, filterPosition)
        }
    }

    func worldPositionFromScreenPosition(_ position: CGPoint,
                                         objectPos: SCNVector3?,
                                         infinitePlane: Bool = false) -> (position: SCNVector3?,
                                                                          planeAnchor: ARPlaneAnchor?,
                                                                          hitAPlane: Bool) {

        // -------------------------------------------------------------------------------
        // 1. Always do a hit test against exisiting plane anchors first.
        //    (If any such anchors exist & only within their extents.)

        let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {

            let planeHitTestPosition = SCNVector3.positionFromTransform(result.worldTransform)
            let planeAnchor = result.anchor

            // Return immediately - this is the best possible outcome.
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }

        // -------------------------------------------------------------------------------
        // 2. Collect more information about the environment by hit testing against
        //    the feature point cloud, but do not return the result yet.

        var featureHitTestPosition: SCNVector3?
        var highQualityFeatureHitTestResult = false

        let highQualityfeatureHitTestResults =
            sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)

        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }

        // -------------------------------------------------------------------------------
        // 3. If desired or necessary (no good feature hit test result): Hit test
        //    against an infinite, horizontal plane (ignoring the real world).

        if (infinitePlane && dragOnInfinitePlanesEnabled) || !highQualityFeatureHitTestResult {

            let pointOnPlane = objectPos ?? SCNVector3Zero

            let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
            if pointOnInfinitePlane != nil {
                return (pointOnInfinitePlane, nil, true)
            }
        }

        // -------------------------------------------------------------------------------
        // 4. If available, return the result of the hit test against high quality
        //    features if the hit tests against infinite planes were skipped or no
        //    infinite plane was hit.

        if highQualityFeatureHitTestResult {
            return (featureHitTestPosition, nil, false)
        }

        // -------------------------------------------------------------------------------
        // 5. As a last resort, perform a second, unfiltered hit test against features.
        //    If there are no features in the scene, the result returned here will be nil.

        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            let result = unfilteredFeatureHitTestResults[0]
            return (result.position, nil, false)
        }

        return (nil, nil, false)
    }

    func setNewVirtualObjectPosition(_ pos: SCNVector3) {

        guard let object = VirtualObjectsManager.shared.getVirtualObjectSelected(),
            let cameraTransform = session.currentFrame?.camera.transform else {
            return
        }

        recentVirtualObjectDistances.removeAll()

        let cameraWorldPos = SCNVector3.positionFromTransform(cameraTransform)
        var cameraToPosition = pos - cameraWorldPos
        cameraToPosition.setMaximumLength(DEFAULT_DISTANCE_CAMERA_TO_OBJECTS)

        object.position = cameraWorldPos + cameraToPosition

        if object.parent == nil {
            sceneView.scene.rootNode.addChildNode(object)
        }
    }

    func resetVirtualObject() {
        VirtualObjectsManager.shared.resetVirtualObjects()

//        addObjectButton.setImage(#imageLiteral(resourceName: "add"), for: [])
//        addObjectButton.setImage(#imageLiteral(resourceName: "addPressed"), for: [.highlighted])
    }

    func updateVirtualObjectPosition(_ pos: SCNVector3, _ filterPosition: Bool) {
        guard let object = VirtualObjectsManager.shared.getVirtualObjectSelected() else {
            return
        }

        guard let cameraTransform = session.currentFrame?.camera.transform else {
            return
        }

        let cameraWorldPos = SCNVector3.positionFromTransform(cameraTransform)
        var cameraToPosition = pos - cameraWorldPos
        cameraToPosition.setMaximumLength(DEFAULT_DISTANCE_CAMERA_TO_OBJECTS)

        // Compute the average distance of the object from the camera over the last ten
        // updates. If filterPosition is true, compute a new position for the object
        // with this average. Notice that the distance is applied to the vector from
        // the camera to the content, so it only affects the percieved distance of the
        // object - the averaging does _not_ make the content "lag".
        let hitTestResultDistance = CGFloat(cameraToPosition.length())

        recentVirtualObjectDistances.append(hitTestResultDistance)
        recentVirtualObjectDistances.keepLast(10)

        if filterPosition {
            let averageDistance = recentVirtualObjectDistances.average!

            cameraToPosition.setLength(Float(averageDistance))
            let averagedDistancePos = cameraWorldPos + cameraToPosition

            object.position = averagedDistancePos
        } else {
            object.position = cameraWorldPos + cameraToPosition
        }
    }

    func checkIfObjectShouldMoveOntoPlane(anchor: ARPlaneAnchor) {
        guard let object = VirtualObjectsManager.shared.getVirtualObjectSelected(),
            let planeAnchorNode = sceneView.node(for: anchor) else {
            return
        }

        // Get the object's position in the plane's coordinate system.
        let objectPos = planeAnchorNode.convertPosition(object.position, from: object.parent)

        if objectPos.y == 0 {
            return; // The object is already on the plane
        }

        // Add 10% tolerance to the corners of the plane.
        let tolerance: Float = 0.1

        let minX: Float = anchor.center.x - anchor.extent.x / 2 - anchor.extent.x * tolerance
        let maxX: Float = anchor.center.x + anchor.extent.x / 2 + anchor.extent.x * tolerance
        let minZ: Float = anchor.center.z - anchor.extent.z / 2 - anchor.extent.z * tolerance
        let maxZ: Float = anchor.center.z + anchor.extent.z / 2 + anchor.extent.z * tolerance

        if objectPos.x < minX || objectPos.x > maxX || objectPos.z < minZ || objectPos.z > maxZ {
            return
        }

        // Drop the object onto the plane if it is near it.
        let verticalAllowance: Float = 0.03
        if objectPos.y > -verticalAllowance && objectPos.y < verticalAllowance {
//            textManager.showDebugMessage("OBJECT MOVED\nSurface detected nearby")

            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            object.position.y = anchor.transform.columns.3.y
            SCNTransaction.commit()
        }
    }
}


enum Setting: String {
    // Bool settings with SettingsViewController switches
    case debugMode
    case scaleWithPinchGesture
    case ambientLightEstimation
    case dragOnInfinitePlanes
    case showHitTestAPI
    case use3DOFTracking
    case use3DOFFallback
    case useOcclusionPlanes

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Setting.ambientLightEstimation.rawValue: true,
            Setting.dragOnInfinitePlanes.rawValue: true
        ])
    }
}



class SCNHexagonGeometry: SCNGeometry {
    init(radius: CGFloat) {
        let sideLength = radius * sqrt(3)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: radius * cos(0), y: radius * sin(0)))

        for i in 1...6 {
            let angle = CGFloat.pi / 3 * CGFloat(i)
            let x = radius * cos(angle)
            let y = radius * sin(angle)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.close()

        let shape = SCNShape(path: path, extrusionDepth: 0.01)
        super.init()
//        self.geometry = shape
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


*/
