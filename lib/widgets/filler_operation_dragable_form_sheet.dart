import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staff_mangement/constants/padding.dart';
import '../constants/colors.dart';
import '../constants/theme.dart';

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
  final _serviceManagerController = TextEditingController();
  final _machineIdController = TextEditingController(text: 'ARV-');
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

  // Dropdown values
  String? _selectedCoinsOption;
  String? _selectedNotesOption;

  List<PictureDescriptionDetail> pictureDescDetails = [
    PictureDescriptionDetail(name: "1. Tray 1 pic - for stock check"),
    PictureDescriptionDetail(name: "2. Tray 2 pic - for stock check"),
    PictureDescriptionDetail(name: "3. Tray 3 pic - for stock check"),
    PictureDescriptionDetail(name: "4. Tray 4 pic - for stock check"),
    PictureDescriptionDetail(name: "5. Tray 5 pic - for stock check"),
    PictureDescriptionDetail(name: "6. Tray 6 pic - for stock check"),
    PictureDescriptionDetail(name: "7. Door open front pic to see full machine products"),
    PictureDescriptionDetail(name: "8. Drop box pic"),
    PictureDescriptionDetail(name: "9. Cash bag pic"),
    PictureDescriptionDetail(name: "10. Coin Mech pic (press door switch and get the pic)"),
    PictureDescriptionDetail(name: "11. Coin mech change on display pic"),
    PictureDescriptionDetail(name: "12. Machine pic just before leaving after machine is locked"),
    PictureDescriptionDetail(name: "13. Spoiled product picture"),
  ];


  @override
  void initState() {
    super.initState();
    // Set default date to today
    _fillDateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _serviceManagerController.dispose();
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
                      'Confirmation Form',
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
                _buildFormField(
                  'Service Manager/Filler*',
                  _serviceManagerController,
                  required: true,
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

                // Dropdown Fields
                _buildDropdownField('COINS*', _selectedCoinsOption, [
                  'Collected',
                  'No Coins',
                ], (value) {
                  setState(() => _selectedCoinsOption = value);
                }),
                SizedBox(height: 16),

                _buildDropdownField('NOTES*', _selectedNotesOption, [
                  'Collected',
                  'No Notes',
                ], (value) {
                  setState(() => _selectedNotesOption = value);
                }),
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
                SizedBox(
                    child: _buildFileUploadSection()),
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
                    backgroundColor:  AppColors.primary.withOpacity(0.2),
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


  Widget _buildFUploadField(
      TextEditingController controller, {
        bool required = false,
        String? hint,
        IconData? icon,
        int maxLines = 1,
        TextInputType? keyboardType,
        bool enabled = true,
        required VoidCallback onIconPressed,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        GestureDetector(
          onTap: enabled ? onIconPressed : null,
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              readOnly: true,
              enabled: enabled,
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

  Widget _buildDropdownField(
      String label,
      String? value,
      List<String> options,
      Function(String?) onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          validator: (value) {
            if (value == null) {
              return 'Please select an option';
            }
            return null;
          },
          decoration: InputDecoration(
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
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
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
          children: pictureDescDetails.map((detail) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildFUploadField(
                detail.controller,
                hint: detail.name,
                required: true,
                icon: Icons.cloud_upload,
                  onIconPressed: () async {
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
                      final XFile? photo = await ImagePicker().pickImage(source: source);
                      if (photo != null) {
                        detail.controller.text = photo.name;
                        // Save the path or file
                      }
                    } else {
                      // File picker selected
                      FilePickerResult? result = await FilePicker.platform.pickFiles();
                      if (result != null) {
                        detail.controller.text = result.files.single.name;
                        // Save the path or file
                      }
                    }
                  }

              ),
            );
          }).toList(),
        ),

      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Collect form data
      final formData = {
        'serviceManager': _serviceManagerController.text,
        'machineId': _machineIdController.text,
        'locationName': _locationNameController.text,
        'fillDate': _fillDateController.text,
        'navaxCashCollection': _navaxCashCollection,
        'machineCleaned': _machineCleaned,
        'coins': _selectedCoinsOption,
        'notes': _selectedNotesOption,
        'meltedChocCookieCheck': _meltedChocCookieCheck,
        'machineFilledAsPerPicklist': _machineFilledAsPerPicklist,
        'checkAllTraysAreClosed': _checkAllTraysAreClosed,
        'checkMissingPriceTags': _checkMissingPriceTags,
        'freeProducts': _freeProductsController.text,
        'refund': _refundController.text,
        'clientFeedback': _clientFeedbackController.text,
        'coinMechCheckWith50c': _coinMechCheckWith50c,
        'coinsFilled': _coinsFilledController.text,
        'finalCoinMechValue': _finalCoinMechController.text,
        'cashBagId': _cashBagIdController.text,
      };

      // Call the onConfirm callback with form data
      widget.onConfirm(formData);
      Navigator.pop(context);
    }
  }
}

class PictureDescriptionDetail {
  final String name;
  final TextEditingController controller;

  PictureDescriptionDetail({required this.name})
      : controller = TextEditingController();
}