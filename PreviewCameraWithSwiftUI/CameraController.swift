import AVFoundation
import CoreImage

class CameraController: NSObject {
  enum ConfigurationError: Error {
    case cameraUnavailable
    case requiredFormatUnavailable
  }

  private let preferredWidthResolution = 1920
  private let videoQueue = DispatchQueue(
    label: "com.example.PreviewCameraWithSwiftUI.VideoQueue", qos: .userInteractive)

  private var videoDataOutput: AVCaptureVideoDataOutput!

  var captureSession: AVCaptureSession!

  override init() {
    super.init()

    do {
      try setupSession()
    } catch {
      fatalError("Unable to configure the video stream session: \(error)")
    }
  }
  private func setupSession() throws {
    self.captureSession = AVCaptureSession()
    self.captureSession.sessionPreset = .inputPriority
    self.captureSession.beginConfiguration()

    try setupCaptureDevice()

    self.captureSession.commitConfiguration()
  }
  private func setupCaptureDevice() throws {
    guard
      let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    else {
      throw ConfigurationError.cameraUnavailable
    }
    guard
      let format =
        (device.formats.last { format in
          format.formatDescription.dimensions.width == preferredWidthResolution
            && format.formatDescription.mediaSubType.rawValue
              == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            && !format.isVideoBinned
        })
    else {
      throw ConfigurationError.requiredFormatUnavailable
    }

    try device.lockForConfiguration()
    device.activeFormat = format
    device.unlockForConfiguration()

    let deviceInput = try AVCaptureDeviceInput(device: device)

    self.videoDataOutput = AVCaptureVideoDataOutput()
    self.videoDataOutput.setSampleBufferDelegate(self, queue: self.videoQueue)
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = true

    self.captureSession.addInput(deviceInput)
    self.captureSession.addOutput(self.videoDataOutput)
  }
  func startStream() {
    self.captureSession.startRunning()
  }
  func stopStream() {
    self.captureSession.stopRunning()
  }
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(
    _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    // Implement per-frame processing here as needed.
  }
}
