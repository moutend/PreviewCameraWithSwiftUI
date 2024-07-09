import AVFoundation
import SwiftUI
import UIKit

class PreviewView: UIView {
  override class var layerClass: AnyClass {
    AVCaptureVideoPreviewLayer.self
  }

  var previewLayer: AVCaptureVideoPreviewLayer {
    layer as! AVCaptureVideoPreviewLayer
  }

  var session: AVCaptureSession? {
    get { previewLayer.session }
    set { previewLayer.session = newValue }
  }
}

struct CameraView: UIViewRepresentable {
  let session: AVCaptureSession

  func makeUIView(context: Context) -> PreviewView {
    let preview = PreviewView()

    preview.session = self.session
    preview.previewLayer.connection?.videoOrientation = .portrait

    return preview
  }
  func updateUIView(_ uiView: PreviewView, context: Context) {
    // Do nothing
  }
}

struct ContentView: View {
  let cameraController = CameraController()

  var body: some View {
    VStack {
      Text("Camera Preview")
        .font(.largeTitle)
        .padding()
      CameraView(session: self.cameraController.captureSession)
        .frame(width: UIScreen.main.bounds.size.width)
      HStack {
        Button(action: {
          self.cameraController.startStream()
        }) {
          Text("Start")
            .padding()
            .foregroundColor(Color.white)
            .background(Color.indigo)
        }
        Button(action: {
          self.cameraController.stopStream()
        }) {
          Text("Stop")
            .padding()
            .foregroundColor(Color.white)
            .background(Color.indigo)
        }
      }
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
