import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../Models/hr_employee_model.dart';
import '../constants/colors.dart';
import '../constants/theme.dart';
import '../providers/picker_filler_data_provider.dart';
import '../reusebleWidgets/loading_btn.dart';

class FillerOperationConfirmationFormSheet {
  void openDraggableSheet(BuildContext context, {
    required List selectedProducts,
    required int totalPickedItem,
    required String role,
    required Function onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: FillerConfirmationForm(
                scrollController: scrollController,
                selectedProducts: selectedProducts,
                totalPickedItem: totalPickedItem,
                role: role,
                onConfirm: onConfirm,
              ),
            );
          },
        );
      },
    );
  }
}

class FillerConfirmationForm extends StatefulWidget {
  final ScrollController scrollController;
  final List selectedProducts;
  final int totalPickedItem;
  final String role;
  final Function onConfirm;

  const FillerConfirmationForm({
    Key? key,
    required this.scrollController,
    required this.selectedProducts,
    required this.totalPickedItem,
    required this.role,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<FillerConfirmationForm> createState() => _FillerConfirmationFormState();
}

class _FillerConfirmationFormState extends State<FillerConfirmationForm> {
  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _machineIdController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _fillDateController = TextEditingController();
  final _coinsController = TextEditingController();
  final _notesController = TextEditingController();
  final _freeProductsController = TextEditingController();
  final _refundController = TextEditingController();
  final _clientFeedbackController = TextEditingController();
  final _coinsFilledController = TextEditingController();
  final _finalCoinMechController = TextEditingController();
  final _cashBagIdController = TextEditingController(text: 'ARV00');

  // Checkbox states
  bool _navaxCashCollection = false;
  bool _machineCleaned = false;
  bool _meltedChocCookieCheck = false;
  bool _machineFilledAsPerPicklist = false;
  bool _checkAllTraysAreClosed = false;
  bool _checkMissingPriceTags = false;
  bool _coinMechCheckWith50c = false;

  // Loading states for individual image uploads
  Map<int, bool> _imageUploadLoading = {};

  // Dropdown values - SEPARATE VARIABLES FOR EACH DROPDOWN
  DropDownModel? _selectedEmployee;
  DropDownModel? _selectedCoinsOption;
  DropDownModel? _selectedNotesOption;

  static List<DropDownModel> coins = [
    DropDownModel(id: 1, name: "yes" ,string_id: "yes"),
    DropDownModel(id: 2, name: "NO",string_id: "no"),
    DropDownModel(id: 3, name: "Not Checked",string_id: "not_checked"),
  ];

  static List<DropDownModel> notes = [
    DropDownModel(id: 1, name: "Empty",string_id: "empty"),
    DropDownModel(id: 2, name: "Needs Attention",string_id: "needs_attention"),
    DropDownModel(id: 3, name: "Ok",string_id: "ok"),
  ];

  List<PictureDescriptionDetail> pictureDescDetails = [
    PictureDescriptionDetail(name: "1. Tray 1 pic - for stock check"),
    PictureDescriptionDetail(name: "2. Tray 2 pic - for stock check"),
    PictureDescriptionDetail(name: "3. Tray 3 pic - for stock check", isRequired: false),
    PictureDescriptionDetail(name: "4. Tray 4 pic - for stock check", isRequired: false),
    PictureDescriptionDetail(name: "5. Tray 5 pic - for stock check", isRequired: false),
    PictureDescriptionDetail(name: "6. Tray 6 pic - for stock check", isRequired: false),
    PictureDescriptionDetail(name: "7. Door open front pic to see full machine products", isRequired: false),
    PictureDescriptionDetail(name: "8. Drop box pic", isRequired: false),
    PictureDescriptionDetail(name: "9. Cash bag pic", isRequired: false),
    PictureDescriptionDetail(name: "10. Coin Mech pic (press door switch and get the pic)", isRequired: false),
    PictureDescriptionDetail(name: "11. Coin mech change on display pic", isRequired: false),
    PictureDescriptionDetail(name: "12. Machine pic just before leaving after machine is locked", isRequired: false),
    PictureDescriptionDetail(name: "13. Spoiled product picture", isRequired: false),
  ];

  @override
  void initState() {
    super.initState();
    // Set default date to today
    _fillDateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _machineIdController.dispose();
    _locationNameController.dispose();
    _fillDateController.dispose();
    _coinsController.dispose();
    _notesController.dispose();
    _freeProductsController.dispose();
    _refundController.dispose();
    _clientFeedbackController.dispose();
    _coinsFilledController.dispose();
    _finalCoinMechController.dispose();
    _cashBagIdController.dispose();
    super.dispose();
  }

  // Optimized: Convert to base64 immediately when file is selected
  Future<String?> _convertToBase64Immediately(String filePath) async {
    try {
      File file = File(filePath);
      Uint8List bytes = await file.readAsBytes();
      String base64String = base64Encode(bytes);
      return base64String;
    } catch (e) {
      print('Error converting file to base64: $e');
      return null;
    }
  }

  // Optimized: Convert PlatformFile to base64 immediately when file is selected
  Future<String?> _convertPlatformFileToBase64Immediately(PlatformFile platformFile) async {
    try {
      Uint8List? bytes = platformFile.bytes;
      if (bytes != null) {
        String base64String = base64Encode(bytes);
        return base64String;
      } else if (platformFile.path != null) {
        File file = File(platformFile.path!);
        Uint8List fileBytes = await file.readAsBytes();
        String base64String = base64Encode(fileBytes);
        return base64String;
      }
      return null;
    } catch (e) {
      print('Error converting platform file to base64: $e');
      return null;
    }
  }

  // Optimized: Handle image upload with immediate conversion and loading state
  Future<void> _handleImageUpload(int index, PictureDescriptionDetail detail) async {
    // Set loading state
    setState(() {
      _imageUploadLoading[index] = true;
    });

    try {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Upload Option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Picture'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.upload_file),
                title: Text('Pick a File'),
                onTap: () => Navigator.pop(context, null),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        // Camera selected
        final XFile? photo = await ImagePicker().pickImage(
          source: source,
          imageQuality: 70, // Reduce quality for better performance
          maxWidth: 1920,   // Limit resolution
          maxHeight: 1080,
        );

        if (photo != null) {
          // Show immediate feedback
          detail.controller.text = photo.name;
          setState(() {});

          // Convert to base64 in background
          String? base64String = await _convertToBase64Immediately(photo.path);
          if (base64String != null) {
            detail.base64Image = base64String;
            detail.fileName = photo.name;
            detail.isUploaded = true;

            // Show success feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image uploaded successfully: ${photo.name}'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        // File picker selected
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result != null && result.files.isNotEmpty) {
          PlatformFile file = result.files.first;

          // Show immediate feedback
          detail.controller.text = file.name;
          setState(() {});

          // Convert to base64 in background
          String? base64String = await _convertPlatformFileToBase64Immediately(file);
          if (base64String != null) {
            detail.base64Image = base64String;
            detail.fileName = file.name;
            detail.isUploaded = true;

            // Show success feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File uploaded successfully: ${file.name}'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      // Clear loading state
      setState(() {
        _imageUploadLoading[index] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Drag Handle
        Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.assignment_turned_in, color: AppColors.primary, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filler Form',
                      style: AppTextStyles.heading2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Complete the form before confirming',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),

        Divider(height: 1),

        // Form Content
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              controller: widget.scrollController,
              padding: EdgeInsets.all(20),
              children: [
                // Selection Summary
                _buildSelectionSummary(),
                SizedBox(height: 24),

                // Form Fields
                _buildEmployeeDropdownField(
                  label: 'Service Manager/Filler*',
                  selectedValue: _selectedEmployee,
                  mandatoryField: true,
                  options: Provider.of<PickerDataProvider>(context, listen: false).hrEmployeeData,
                  onChanged: (value) {
                    setState(() {
                      _selectedEmployee = value;
                    });
                  },
                  icon: Icons.person,
                ),

                SizedBox(height: 16),

                _buildFormField(
                  'Machine ID*',
                  _machineIdController,
                  required: true,
                  icon: Icons.devices,
                ),
                SizedBox(height: 16),

                _buildFormField(
                  'Location Name*',
                  _locationNameController,
                  required: true,
                  icon: Icons.location_on,
                ),
                SizedBox(height: 16),

                _buildDateField(),
                SizedBox(height: 16),

                // Checkboxes Section 1
                _buildCheckboxGroup('Operations Checklist', [
                  _buildCheckbox('NAVAX Cash Collection', _navaxCashCollection, (value) {
                    setState(() => _navaxCashCollection = value!);
                  }),
                  _buildCheckbox('Machine Cleaned', _machineCleaned, (value) {
                    setState(() => _machineCleaned = value!);
                  }),
                ]),
                SizedBox(height: 16),

                // Coins dropdown
                _buildEmployeeDropdownField(
                  label: 'Coins',
                  selectedValue: _selectedCoinsOption,
                  options: coins,
                  onChanged: (value) {
                    setState(() {
                      print("valuemm...>${value?.id}");
                      _selectedCoinsOption = value;
                    });
                  },
                  icon: Icons.currency_bitcoin_sharp,
                ),
                SizedBox(height: 16),

                // Notes dropdown
                _buildEmployeeDropdownField(
                  label: 'Notes',
                  selectedValue: _selectedNotesOption,
                  options: notes,
                  onChanged: (value) {
                    setState(() {
                      _selectedNotesOption = value;
                    });
                  },
                  icon: Icons.notes,
                ),
                SizedBox(height: 16),

                // More Checkboxes
                _buildCheckboxGroup('Quality Checks', [
                  _buildCheckbox('Melted Choc/Cookie Check', _meltedChocCookieCheck, (value) {
                    setState(() => _meltedChocCookieCheck = value!);
                  }),
                  _buildCheckbox('Machine Filled as per picklist', _machineFilledAsPerPicklist, (value) {
                    setState(() => _machineFilledAsPerPicklist = value!);
                  }),
                  _buildCheckbox('Check All Trays Are Closed', _checkAllTraysAreClosed, (value) {
                    setState(() => _checkAllTraysAreClosed = value!);
                  }),
                  _buildCheckbox('Check Missing Price Tags', _checkMissingPriceTags, (value) {
                    setState(() => _checkMissingPriceTags = value!);
                  }),
                ]),
                SizedBox(height: 16),

                // Text Fields
                _buildFormField(
                  'Free Products given',
                  _freeProductsController,
                  hint: 'Please mention for stock accuracy',
                  icon: Icons.redeem,
                  maxLines: 2,
                ),
                SizedBox(height: 16),

                _buildFormField(
                  'Refund given',
                  _refundController,
                  hint: 'Please mention for reconciliation',
                  icon: Icons.attach_money,
                  maxLines: 2,
                ),
                SizedBox(height: 16),

                _buildFormField(
                  'Client Feedback',
                  _clientFeedbackController,
                  hint: 'Please mention for future developments',
                  icon: Icons.feedback,
                  maxLines: 3,
                ),
                SizedBox(height: 16),

                // Final Checkbox
                _buildCheckbox('COIN Mech check with 50c', _coinMechCheckWith50c, (value) {
                  setState(() => _coinMechCheckWith50c = value!);
                }),
                SizedBox(height: 16),

                _buildFormField(
                  'Coins filled',
                  _coinsFilledController,
                  hint: 'Enter currency',
                  icon: Icons.monetization_on,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),

                _buildFormField(
                  'Final Coin Mech Value',
                  _finalCoinMechController,
                  hint: 'Enter currency',
                  icon: Icons.account_balance_wallet,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),

                _buildFormField(
                  'Cash Bag ID',
                  _cashBagIdController,
                  icon: Icons.work,
                ),
                SizedBox(height: 16),

                // File Upload Section
                SizedBox(child: _buildFileUploadSection()),
              ],
            ),
          ),
        ),

        // Bottom Action Buttons
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: Icon(Icons.check),
                  label: Text('Confirm Filler Operation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_cart, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Selection Summary',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            widget.role == "picker"
                ? 'Items selected for picking: ${widget.selectedProducts.length}'
                : 'Items selected for filling: ${widget.selectedProducts.length}',
            style: AppTextStyles.body2,
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.role == "picker"
                        ? 'Total items to pick: ${widget.totalPickedItem}'
                        : 'Total items to fill: ${widget.totalPickedItem}',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
      String label,
      TextEditingController controller, {
        bool required = false,
        String? hint,
        IconData? icon,
        int maxLines = 1,
        TextInputType? keyboardType,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: required ? (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          } : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  // Enhanced upload field with loading indicator and success state
  Widget _buildFUploadField(
      TextEditingController controller,
      int index, {
        bool required = false,
        String? hint,
        IconData? icon,
        int maxLines = 1,
        TextInputType? keyboardType,
        bool enabled = true,
        required VoidCallback onIconPressed,
      }) {
    bool isLoading = _imageUploadLoading[index] ?? false;
    bool isUploaded = pictureDescDetails[index].isUploaded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        GestureDetector(
          onTap: enabled && !isLoading ? onIconPressed : null,
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              readOnly: true,
              enabled: enabled && !isLoading,
              maxLines: maxLines,
              keyboardType: keyboardType,
              validator: (required)
                  ? (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              }
                  : null,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: isLoading
                    ? Container(
                  width: 24,
                  height: 24,
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
                    : Icon(
                    isUploaded ? Icons.check_circle : (icon ?? Icons.cloud_upload),
                    color: isUploaded ? Colors.green : AppColors.primary
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isUploaded ? Colors.green : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isUploaded ? Colors.green : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isUploaded ? Colors.green : AppColors.primary,
                  ),
                ),
                filled: true,
                fillColor: isUploaded ? Colors.green[50] : Colors.grey[50],
              ),
              style: TextStyle(
                color: enabled ? AppColors.onSurface : AppColors.disabled,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fill Date & Time*',
          style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _fillDateController,
          readOnly: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(Duration(days: 7)),
              lastDate: DateTime.now().add(Duration(days: 1)),
            );
            if (date != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                _fillDateController.text = dateTime.toString().substring(0, 16);
              }
            }
          },
          decoration: InputDecoration(
            hintText: 'Select date',
            prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
            suffixIcon: Icon(Icons.arrow_drop_down),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeDropdownField({
    required String label,
    required DropDownModel? selectedValue,
    required IconData icon,
    mandatoryField = false,
    required List<DropDownModel> options,
    required Function(DropDownModel?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<DropDownModel>(
          value: selectedValue,
          onChanged: onChanged,
          validator: (value) {
            if (value == null && mandatoryField ==true) {
              return 'Please select an option';
            }
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: options.map((DropDownModel employee) {
            return DropdownMenuItem<DropDownModel>(
              value: employee,
              child: Text(employee.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCheckboxGroup(String title, List<Widget> checkboxes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: checkboxes),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title, style: AppTextStyles.body2),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PLEASE ATTACH BELOW PICTURES*',
          style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600),
        ),
        Divider(),
        SizedBox(height: 8),
        Column(
          children: pictureDescDetails.asMap().entries.map((entry) {
            int index = entry.key;
            PictureDescriptionDetail detail = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildFUploadField(
                detail.controller,
                index,
                hint: detail.name,
                required: detail.isRequired,
                icon: Icons.cloud_upload,
                onIconPressed: () => _handleImageUpload(index, detail),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Optimized submit form - no heavy operations during submission
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      Navigator.pop(context);

      // Images are already converted to base64, just collect them
      List<String> imagesList = [];
      for (PictureDescriptionDetail detail in pictureDescDetails) {
        if (detail.base64Image != null && detail.base64Image!.isNotEmpty) {
          imagesList.add(detail.base64Image!);
        }
      }

      // Collect form data - this is now very fast
      final formData = {
        'filler_employee_id': _selectedEmployee?.name,
        'filler_machine_id': _machineIdController.text,
        'filler_location_name': _locationNameController.text,
        'filler_fill_datetime': _fillDateController.text,
        'filler_nayax_cash_collected': _navaxCashCollection,
        'filler_machine_cleaned': _machineCleaned,
        'filler_coins': _selectedCoinsOption?.string_id,
        'filler_notes': _selectedNotesOption?.string_id,
        'filler_melted_check': _meltedChocCookieCheck,
        'filler_filled_as_per_picklist': _machineFilledAsPerPicklist,
        'filler_trays_closed': _checkAllTraysAreClosed,
        'filler_missing_tags': _checkMissingPriceTags,
        'filler_free_products': _freeProductsController.text,
        'filler_refund_given': _refundController.text,
        'filler_client_feedback': _clientFeedbackController.text,
        'filler_coin_mech_50c': _coinMechCheckWith50c,
        'filler_coins_filled': _coinsFilledController.text,
        'filler_final_coin_mech_value': _finalCoinMechController.text,
        'filler_cash_bag_id': _cashBagIdController.text,
        'filler_attachment_ids': imagesList,
      };

      print('Form submitted with ${imagesList.length} images (already converted)');

      // Call the onConfirm callback with form data - this should be fast now
      await widget.onConfirm(formData);

    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting form: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Enhanced PictureDescriptionDetail class with upload status
class PictureDescriptionDetail {
  final String name;
  final TextEditingController controller;
  final bool isRequired;
  String? base64Image;
  String? fileName;
  bool isUploaded; // Track upload status

  PictureDescriptionDetail({
    required this.name,
    this.isRequired = true,
  }) : controller = TextEditingController(),
        isUploaded = false; // Initialize as not uploaded
}