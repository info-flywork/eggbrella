import AVFoundation
import Accelerate
import Flutter
import LinkPresentation
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ClipEncoderChannel") {
      ClipEncoderChannel.register(messenger: registrar.messenger())
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ClipShareChannel") {
      ClipShareChannel.register(messenger: registrar.messenger())
    }
  }
}

/// `eggbrella/clip_encoder`: Dart'ın çizdiği RGBA kareleri H.264 MP4'e yazar.
/// Çağrılar: start {path,width,height,fps} · addFrame <bytes> · finish · cancel
final class ClipEncoderChannel {
  private static var instance: ClipEncoderChannel?
  private let queue = DispatchQueue(label: "eggbrella.clip-encoder")
  private var encoder: ClipEncoder?

  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "eggbrella/clip_encoder", binaryMessenger: messenger)
    let handler = ClipEncoderChannel()
    instance = handler
    channel.setMethodCallHandler { call, result in handler.handle(call, result: result) }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    queue.async {
      do {
        let value = try self.run(call)
        DispatchQueue.main.async { result(value) }
      } catch {
        self.encoder?.cancel()
        self.encoder = nil
        DispatchQueue.main.async {
          result(FlutterError(code: "encode_failed", message: error.localizedDescription, details: nil))
        }
      }
    }
  }

  private func run(_ call: FlutterMethodCall) throws -> Any? {
    switch call.method {
    case "start":
      guard let args = call.arguments as? [String: Any],
        let path = args["path"] as? String,
        let width = args["width"] as? Int,
        let height = args["height"] as? Int,
        let fps = args["fps"] as? Int
      else { throw ClipEncoderError.badArguments }
      encoder?.cancel()
      encoder = try ClipEncoder(path: path, width: width, height: height, fps: Int32(fps))
      return nil
    case "addFrame":
      guard let data = call.arguments as? FlutterStandardTypedData, let encoder else {
        throw ClipEncoderError.notStarted
      }
      try encoder.append(rgba: data.data)
      return nil
    case "finish":
      guard let encoder else { throw ClipEncoderError.notStarted }
      self.encoder = nil
      return try encoder.finish()
    case "cancel":
      encoder?.cancel()
      encoder = nil
      return nil
    default:
      throw ClipEncoderError.badArguments
    }
  }
}

enum ClipEncoderError: LocalizedError {
  case badArguments, notStarted, writerFailed(String)

  var errorDescription: String? {
    switch self {
    case .badArguments: return "bad arguments"
    case .notStarted: return "encoder not started"
    case .writerFailed(let reason): return reason
    }
  }
}

final class ClipEncoder {
  private let writer: AVAssetWriter
  private let input: AVAssetWriterInput
  private let adaptor: AVAssetWriterInputPixelBufferAdaptor
  private let width: Int
  private let height: Int
  private let fps: Int32
  private let path: String
  private var frame: Int64 = 0

  init(path: String, width: Int, height: Int, fps: Int32) throws {
    self.path = path
    self.width = width
    self.height = height
    self.fps = fps
    let url = URL(fileURLWithPath: path)
    try? FileManager.default.removeItem(at: url)
    writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
    input = AVAssetWriterInput(
      mediaType: .video,
      outputSettings: [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: width,
        AVVideoHeightKey: height,
        AVVideoCompressionPropertiesKey: [
          AVVideoAverageBitRateKey: 2_500_000,
          AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
        ],
      ])
    input.expectsMediaDataInRealTime = false
    adaptor = AVAssetWriterInputPixelBufferAdaptor(
      assetWriterInput: input,
      sourcePixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        kCVPixelBufferWidthKey as String: width,
        kCVPixelBufferHeightKey as String: height,
      ])
    writer.add(input)
    guard writer.startWriting() else {
      throw ClipEncoderError.writerFailed(writer.error?.localizedDescription ?? "startWriting")
    }
    writer.startSession(atSourceTime: .zero)
  }

  func append(rgba: Data) throws {
    guard rgba.count >= width * height * 4 else { throw ClipEncoderError.badArguments }
    while !input.isReadyForMoreMediaData {
      if writer.status == .failed {
        throw ClipEncoderError.writerFailed(writer.error?.localizedDescription ?? "failed")
      }
      usleep(2_000)
    }
    guard let pool = adaptor.pixelBufferPool else { throw ClipEncoderError.writerFailed("no pool") }
    var buffer: CVPixelBuffer?
    CVPixelBufferPoolCreatePixelBuffer(nil, pool, &buffer)
    guard let pixelBuffer = buffer else { throw ClipEncoderError.writerFailed("no buffer") }

    CVPixelBufferLockBaseAddress(pixelBuffer, [])
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
    rgba.withUnsafeBytes { raw in
      var src = vImage_Buffer(
        data: UnsafeMutableRawPointer(mutating: raw.baseAddress!),
        height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: width * 4)
      var dst = vImage_Buffer(
        data: CVPixelBufferGetBaseAddress(pixelBuffer),
        height: vImagePixelCount(height), width: vImagePixelCount(width),
        rowBytes: CVPixelBufferGetBytesPerRow(pixelBuffer))
      // RGBA -> BGRA
      let map: [UInt8] = [2, 1, 0, 3]
      vImagePermuteChannels_ARGB8888(&src, &dst, map, vImage_Flags(kvImageNoFlags))
    }
    if !adaptor.append(pixelBuffer, withPresentationTime: CMTime(value: frame, timescale: fps)) {
      throw ClipEncoderError.writerFailed(writer.error?.localizedDescription ?? "append")
    }
    frame += 1
  }

  func finish() throws -> String {
    input.markAsFinished()
    let done = DispatchSemaphore(value: 0)
    writer.finishWriting { done.signal() }
    done.wait()
    guard writer.status == .completed else {
      throw ClipEncoderError.writerFailed(writer.error?.localizedDescription ?? "finish")
    }
    return path
  }

  func cancel() {
    if writer.status == .writing { writer.cancelWriting() }
  }
}

/// `eggbrella/clip_share`: klibi sistem paylaşım sayfasıyla paylaşır.
/// Figma "paylasim": başlıkta uygulama ikonu, "Eggbrella klibi · N. kat" ve
/// "Video · 8 sn" görünür; asıl öğe video olduğu için "Kaydet" videoyu
/// fotoğraflara yazar. Metin (ve CDN bağlantısı) yalnızca mesajlaşma
/// hedeflerine eklenir, böylece başlık "Düz metin ve 1 belge" olmaz.
/// Çağrı: share {path, title, subtitle, text?, origin?: [x, y, w, h]} → nil
final class ClipShareChannel {
  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "eggbrella/clip_share", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "share",
        let args = call.arguments as? [String: Any],
        let path = args["path"] as? String,
        let title = args["title"] as? String,
        let subtitle = args["subtitle"] as? String
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      share(
        url: URL(fileURLWithPath: path),
        title: title,
        subtitle: subtitle,
        text: args["text"] as? String,
        origin: args["origin"] as? [Double],
        result: result
      )
    }
  }

  private static func share(
    url: URL,
    title: String,
    subtitle: String,
    text: String?,
    origin: [Double]?,
    result: @escaping FlutterResult
  ) {
    guard let root = topController() else {
      result(FlutterError(code: "no_window", message: nil, details: nil))
      return
    }
    var items: [Any] = [ClipItemSource(url: url, title: title, subtitle: subtitle)]
    if let text, !text.isEmpty { items.append(ClipTextSource(text: text)) }
    let sheet = UIActivityViewController(activityItems: items, applicationActivities: nil)
    if let popover = sheet.popoverPresentationController {
      popover.sourceView = root.view
      if let origin, origin.count == 4 {
        popover.sourceRect = CGRect(x: origin[0], y: origin[1], width: origin[2], height: origin[3])
      } else {
        popover.sourceRect = CGRect(x: root.view.bounds.midX, y: root.view.bounds.midY, width: 0, height: 0)
      }
    }
    sheet.completionWithItemsHandler = { _, _, _, _ in result(nil) }
    root.present(sheet, animated: true)
  }

  private static func topController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let window = scenes.flatMap(\.windows).first { $0.isKeyWindow } ?? scenes.first?.windows.first
    var top = window?.rootViewController
    while let presented = top?.presentedViewController { top = presented }
    return top
  }
}

/// Asıl öğe: MP4 dosyası + paylaşım sayfası başlığı (ikon, başlık, alt yazı).
private final class ClipItemSource: NSObject, UIActivityItemSource {
  private let url: URL
  private let metadata: LPLinkMetadata

  init(url: URL, title: String, subtitle: String) {
    self.url = url
    metadata = LPLinkMetadata()
    metadata.title = title
    // Alt yazı için bilinen yol: originalURL'in metni başlığın altında görünür.
    metadata.originalURL = URL(fileURLWithPath: subtitle)
    if let icon = UIImage(named: "ShareIcon") {
      // Yalnızca imageProvider: kutuyu tam doldurur (iconProvider küçük
      // simge olarak beyaz zeminin ortasına yerleşir).
      metadata.imageProvider = NSItemProvider(object: icon)
    }
    super.init()
  }

  func activityViewControllerPlaceholderItem(_ controller: UIActivityViewController) -> Any { url }

  func activityViewController(
    _ controller: UIActivityViewController,
    itemForActivityType activityType: UIActivity.ActivityType?
  ) -> Any? { url }

  func activityViewController(
    _ controller: UIActivityViewController,
    subjectForActivityType activityType: UIActivity.ActivityType?
  ) -> String { metadata.title ?? "" }

  func activityViewController(
    _ controller: UIActivityViewController,
    dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?
  ) -> String { "public.mpeg-4" }

  func activityViewControllerLinkMetadata(_ controller: UIActivityViewController) -> LPLinkMetadata? {
    metadata
  }
}

/// Eşlik eden metin: yalnızca mesaj / posta / üçüncü parti uygulamalara.
private final class ClipTextSource: NSObject, UIActivityItemSource {
  private let text: String

  init(text: String) {
    self.text = text
    super.init()
  }

  private static let skipped: Set<UIActivity.ActivityType> = [
    .saveToCameraRoll, .airDrop, .copyToPasteboard, .print, .assignToContact,
    .addToReadingList, .openInIBooks,
  ]

  func activityViewControllerPlaceholderItem(_ controller: UIActivityViewController) -> Any {
    text
  }

  func activityViewController(
    _ controller: UIActivityViewController,
    itemForActivityType activityType: UIActivity.ActivityType?
  ) -> Any? {
    guard let activityType else { return text }
    if Self.skipped.contains(activityType) { return nil }
    if activityType.rawValue.contains("SaveToFiles") { return nil }
    return text
  }
}
