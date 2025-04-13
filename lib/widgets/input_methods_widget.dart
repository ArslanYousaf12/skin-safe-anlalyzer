import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../screens/camera_screen.dart';
import '../blocs/input_method/input_method.dart';

class InputMethodsWidget extends StatelessWidget {
  const InputMethodsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<InputMethodBloc, InputMethodState>(
      listener: (context, state) {
        if (state is InputMethodLoading) {
          // Show loading indicator if needed
          _showLoadingDialog(context);
        } else if (state is InputMethodError) {
          // Close loading dialog if open and show error
          Navigator.of(context, rootNavigator: true)
              .popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else {
          // Close loading dialog if open for all other states
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Text(
              'How would you like to analyze your product?',
              style: AppTheme.subheadingStyle,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          _buildSearchByNameTile(context),
          _buildScanProductTile(context),
          _buildScanIngredientsTile(context),
          _buildUploadImageTile(context),
        ],
      ),
    );
  }

  Widget _buildSearchByNameTile(BuildContext context) {
    return _buildMethodTile(
      context: context,
      icon: Icons.search,
      title: 'Search by Product Name',
      subtitle: 'Type the name of the product to analyze',
      onTap: () {
        _showSearchDialog(context);
      },
    );
  }

  Widget _buildScanProductTile(BuildContext context) {
    return _buildMethodTile(
      context: context,
      icon: Icons.camera_alt,
      title: 'Scan Product',
      subtitle: 'Take a photo of the product to identify it',
      onTap: () {
        _navigateToCameraScreen(context, isProduct: true);
      },
    );
  }

  Widget _buildScanIngredientsTile(BuildContext context) {
    return _buildMethodTile(
      context: context,
      icon: Icons.document_scanner,
      title: 'Scan Ingredients List',
      subtitle: 'Take a photo of the ingredients list on packaging',
      onTap: () {
        _navigateToCameraScreen(context, isProduct: false);
      },
    );
  }

  Widget _buildUploadImageTile(BuildContext context) {
    return _buildMethodTile(
      context: context,
      icon: Icons.upload_file,
      title: 'Upload from Gallery',
      subtitle: 'Select an existing photo from your device',
      onTap: () {
        context.read<InputMethodBloc>().add(const UploadGalleryImageEvent());
        _pickImageFromGallery(context);
      },
    );
  }

  Widget _buildMethodTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
        leading: Container(
          padding: const EdgeInsets.all(AppConstants.smallPadding),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 28),
        ),
        title: Text(
          title,
          style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: AppTheme.captionStyle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _showSearchDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Product'),
        content: TextField(
          controller: controller,
          decoration: AppTheme.inputDecoration(
            'Product Name',
            hint: 'Enter product name',
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                context
                    .read<InputMethodBloc>()
                    .add(SearchByProductNameEvent(controller.text.trim()));
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _navigateToCameraScreen(
    BuildContext context, {
    required bool isProduct,
  }) async {
    final File? imageFile = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          onImageCaptured: (file) => Navigator.pop(context, file),
        ),
      ),
    );

    if (imageFile != null) {
      if (isProduct) {
        // Product image was captured, send event to bloc
        context.read<InputMethodBloc>().add(ScanProductEvent(imageFile));
      } else {
        // Ingredients image was captured, send event to bloc
        context.read<InputMethodBloc>().add(ScanIngredientsEvent(imageFile));
      }
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final File imageFile = File(image.path);

        // Show options dialog for how to process the image
        _showImageProcessingOptionsDialog(context, imageFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString()}')),
      );
    }
  }

  Future<void> _showImageProcessingOptionsDialog(
    BuildContext context,
    File imageFile,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Image'),
        content: const Text('How would you like to process this image?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<InputMethodBloc>().add(ScanProductEvent(imageFile));
            },
            child: const Text('As Product Image'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<InputMethodBloc>()
                  .add(ProcessIngredientImageEvent(imageFile));
            },
            child: const Text('Extract Ingredients'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }
}
