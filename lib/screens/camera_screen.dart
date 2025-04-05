import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class CameraScreen extends StatefulWidget {
  final Function(File) onImageCaptured;

  const CameraScreen({super.key, required this.onImageCaptured});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCameraReady = false;
  bool _isCapturing = false;
  bool _isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        setState(() {
          _isInitialized = true;
          _isCameraReady = false;
        });
        return;
      }

      // Initialize camera controller with back camera first
      await _setupCamera(_cameras![0]);
      setState(() {
        _isInitialized = true;
        _isCameraReady = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
      setState(() {
        _isInitialized = true;
        _isCameraReady = false;
      });
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      // Enable flash by default for better ingredient reading
      await _controller!.setFlashMode(FlashMode.auto);
    } catch (e) {
      print('Error initializing camera controller: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isCameraReady || _cameras == null || _cameras!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera Error')),
        body: const Center(
          child: Text(
            'Unable to access the camera.\nPlease check camera permissions and try again.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Capture Image'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Camera preview
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child:
                _controller!.value.isInitialized
                    ? CameraPreview(_controller!)
                    : const Center(child: CircularProgressIndicator()),
          ),

          // Overlay interface
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Instruction text at the top
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: AppConstants.defaultPadding * 2,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(
                        AppConstants.defaultBorderRadius,
                      ),
                    ),
                    child: const Text(
                      'Position the ingredients list within the frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const Spacer(),

                // Camera controls at the bottom
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.largePadding,
                  ),
                  color: Colors.black.withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Flash button
                      _buildCameraControlButton(
                        icon: Icons.flash_auto,
                        onPressed: _toggleFlashMode,
                      ),

                      // Capture button
                      _buildCaptureButton(),

                      // Switch camera
                      _buildCameraControlButton(
                        icon: Icons.flip_camera_ios,
                        onPressed: _toggleCamera,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 28),
      onPressed: onPressed,
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _captureImage,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Center(
          child:
              _isCapturing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Container(
                    width: 55,
                    height: 55,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
        ),
      ),
    );
  }

  Future<void> _toggleFlashMode() async {
    if (_controller == null) return;

    try {
      // Cycle through flash modes
      final FlashMode newMode;
      switch (_controller!.value.flashMode) {
        case FlashMode.auto:
          newMode = FlashMode.always;
          break;
        case FlashMode.always:
          newMode = FlashMode.off;
          break;
        case FlashMode.off:
        default:
          newMode = FlashMode.auto;
          break;
      }

      await _controller!.setFlashMode(newMode);
      setState(() {});
    } catch (e) {
      print('Error toggling flash mode: $e');
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    try {
      _isFrontCamera = !_isFrontCamera;
      final cameraIndex = _isFrontCamera ? 1 : 0;
      await _setupCamera(_cameras![cameraIndex]);
      setState(() {});
    } catch (e) {
      print('Error toggling camera: $e');
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      // Take picture
      final XFile photo = await _controller!.takePicture();
      final File imageFile = File(photo.path);

      if (mounted) {
        // Return to previous screen with the captured image
        Navigator.of(context).pop();
        widget.onImageCaptured(imageFile);
      }
    } catch (e) {
      print('Error capturing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }
}
