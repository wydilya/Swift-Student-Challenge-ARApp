//
//  ContentView.swift
//  SwiftStudentChallengeARApp
//
//  Created by Ilya Zelkin on 08.05.2022.
//

import SwiftUI
import RealityKit
import ARKit
//import PlaygroundSupport

//I wrote this code on iPad and paste that here, i don't need to use PlaygroundSupport in Xcode

struct ContentView: View {
    var body: some View {
        return ARViewContainer()
    }
}

struct ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARView
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        arView.enableTapGesture()
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        //Doesn't Matter Now
    }
}

extension ARView {
    func enableTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(handleTap(recognizer:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self)
        
        guard let rayResult = self.ray(through: tapLocation) else { return }
        
        let results = self.scene.raycast(origin: rayResult.origin, direction: rayResult.direction)
        
        if let firstResult = results.first {
            //Intersected with AR obj
            // Place obj on top
            var position = firstResult.position
            position.y += 0.3/2
            
            placeCube(at: position)
            
        } else {
            //Raycast hasn't intersected with obj
            //Place a new obj (if it's ok)
            
            let results = self.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any)
            
            if let firstResult = results.first {
                let position = simd_make_float3(firstResult.worldTransform.columns.3)
                placeCube(at: position)
            }
        }
    }
    
    func placeCube(at position: SIMD3<Float>) {
        let mesh = MeshResource.generateBox(size: 0.3)
        let material = SimpleMaterial(color: UIColor.randomColor(), roughness: 0.3, isMetallic: true)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        modelEntity.generateCollisionShapes(recursive: true)
        
        let anchorEntity = AnchorEntity(world: position)
        anchorEntity.addChild(modelEntity)
        
        self.scene.addAnchor(anchorEntity)
    }
    
}

extension UIColor {
    class func randomColor() -> UIColor {
        let colors: [UIColor] = [.cyan, .green, .red, .purple, .orange, .yellow]
        let randomIndex = Int(arc4random_uniform(UInt32(colors.count)))
        
        return colors[randomIndex]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//I don't need to use it too because of Xcode
//PlaygroundPage.current.setLiveView(ContentView())
