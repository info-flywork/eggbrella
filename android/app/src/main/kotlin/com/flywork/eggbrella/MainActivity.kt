package com.flywork.eggbrella

import android.graphics.Bitmap
import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.view.Surface
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.nio.ByteBuffer

class MainActivity : FlutterFragmentActivity() {
    private val encoderThread = HandlerThread("clip-encoder").apply { start() }
    private val encoderHandler = Handler(encoderThread.looper)
    private val mainHandler = Handler(Looper.getMainLooper())
    private var encoder: ClipEncoder? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "eggbrella/clip_encoder")
            .setMethodCallHandler { call, result ->
                encoderHandler.post {
                    try {
                        val value: Any? = when (call.method) {
                            "start" -> {
                                encoder?.cancel()
                                encoder = ClipEncoder(
                                    path = call.argument<String>("path")!!,
                                    width = call.argument<Int>("width")!!,
                                    height = call.argument<Int>("height")!!,
                                    fps = call.argument<Int>("fps")!!,
                                )
                                null
                            }
                            "addFrame" -> {
                                val bytes = call.arguments as ByteArray
                                (encoder ?: error("encoder not started")).append(bytes)
                                null
                            }
                            "finish" -> {
                                val current = encoder ?: error("encoder not started")
                                encoder = null
                                current.finish()
                            }
                            "cancel" -> {
                                encoder?.cancel()
                                encoder = null
                                null
                            }
                            else -> error("unknown method ${call.method}")
                        }
                        mainHandler.post { result.success(value) }
                    } catch (e: Exception) {
                        encoder?.cancel()
                        encoder = null
                        mainHandler.post { result.error("encode_failed", e.message, null) }
                    }
                }
            }
    }

    override fun onDestroy() {
        encoderThread.quitSafely()
        super.onDestroy()
    }
}

/** Dart'ın çizdiği RGBA kareleri H.264 MP4'e yazar (MediaCodec + giriş yüzeyi). */
class ClipEncoder(private val path: String, width: Int, height: Int, private val fps: Int) {
    private val codec: MediaCodec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
    private val surface: Surface
    private val muxer: MediaMuxer
    private val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
    private val info = MediaCodec.BufferInfo()
    private var track = -1
    private var muxerStarted = false
    private var written = 0L

    init {
        val format = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, width, height).apply {
            setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface)
            setInteger(MediaFormat.KEY_BIT_RATE, 2_500_000)
            setInteger(MediaFormat.KEY_FRAME_RATE, fps)
            setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1)
        }
        codec.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        surface = codec.createInputSurface()
        codec.start()
        File(path).delete()
        muxer = MediaMuxer(path, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
    }

    fun append(rgba: ByteArray) {
        bitmap.copyPixelsFromBuffer(ByteBuffer.wrap(rgba))
        val canvas = surface.lockHardwareCanvas()
        canvas.drawBitmap(bitmap, 0f, 0f, null)
        surface.unlockCanvasAndPost(canvas)
        drain(endOfStream = false)
    }

    fun finish(): String {
        codec.signalEndOfInputStream()
        drain(endOfStream = true)
        release()
        return path
    }

    fun cancel() {
        try {
            release()
        } catch (_: Exception) {
        }
        File(path).delete()
    }

    private fun drain(endOfStream: Boolean) {
        while (true) {
            val index = codec.dequeueOutputBuffer(info, 10_000)
            when {
                index == MediaCodec.INFO_TRY_AGAIN_LATER -> if (!endOfStream) return
                index == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                    track = muxer.addTrack(codec.outputFormat)
                    muxer.start()
                    muxerStarted = true
                }
                index >= 0 -> {
                    val buffer = codec.getOutputBuffer(index)!!
                    if (info.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0) info.size = 0
                    if (info.size > 0 && muxerStarted) {
                        // Yüzey zaman damgası gerçek zamandır; kare sırasına göre yeniden yazılır.
                        info.presentationTimeUs = written * 1_000_000L / fps
                        written++
                        buffer.position(info.offset)
                        buffer.limit(info.offset + info.size)
                        muxer.writeSampleData(track, buffer, info)
                    }
                    codec.releaseOutputBuffer(index, false)
                    if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) return
                }
            }
        }
    }

    private fun release() {
        codec.stop()
        codec.release()
        surface.release()
        if (muxerStarted) muxer.stop()
        muxer.release()
        bitmap.recycle()
    }
}
