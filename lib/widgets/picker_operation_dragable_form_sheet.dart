import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:staff_mangement/constants/padding.dart';
import '../Models/hr_employee_model.dart';
import '../constants/colors.dart';
import '../constants/theme.dart';
import '../providers/picker_data_provider.dart';

class PickerOperationConfirmationFormSheet {
  void openDraggableSheet(BuildContext context, {
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
              child: PickerConfirmationForm(
                scrollController: scrollController,
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

class PickerConfirmationForm extends StatefulWidget {
  final ScrollController scrollController;
  final String role;
  final Function onConfirm;

  const PickerConfirmationForm({
    Key? key,
    required this.scrollController,
    required this.role,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<PickerConfirmationForm> createState() => _PickerConfirmationFormState();
}

class _PickerConfirmationFormState extends State<PickerConfirmationForm> {
  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _pickerNameController = TextEditingController();
  final _pickingDateController = TextEditingController();
  final _serviceRunDateController = TextEditingController();

  // Checkbox states for picker checklist
  bool _vansParkedInSideWarehouse = false;
  bool _allBoxesLoadedInVans = false;
  bool _chocolatesAndCookiesInFridge = false;
  bool _toolBoxAndFloatInVans = false;
  bool _checkFuelCardInVans = false;
  bool _cardboardsInBailor = false;
  bool _check3FillersPhones = false;
  bool _alarmDoneAndVideo = false;
  bool _checkDamagesForVehicle = false;
  bool _checkVehicleInsideClean = false;
  bool _checkUpstairsLights = false;
  bool _allLightsOff = false;

  DropDownModel? _selectedEmployee;


  @override
  void initState() {
    super.initState();
    // Set default date to today
    _pickingDateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _pickerNameController.dispose();
    _pickingDateController.dispose();
    _serviceRunDateController.dispose();
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
                      'Picker Form',
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

                // Basic Information
                _buildEmployeeDropdownField(
                  label: 'Picker*',
                  selectedValue: _selectedEmployee,
                  options: Provider.of<PickerDataProvider>(context, listen: false).hrEmployeeData,
                  onChanged: (value) {
                    setState(() {
                      _selectedEmployee = value;
                    });
                  },
                  icon: Icons.person,
                ),
                SizedBox(height: 16),

                _buildDateField('Picking Date*', _pickingDateController, required: true),
                SizedBox(height: 16),

                _buildDateField('Service Run Date', _serviceRunDateController),
                SizedBox(height: 16),

                // Picker Checklist Section
                _buildCheckboxGroup('Warehouse & Vehicle Preparation', [
                  _buildCheckbox('Vans parked in side warehouse', _vansParkedInSideWarehouse, (value) {
                    setState(() => _vansParkedInSideWarehouse = value!);
                  }),
                  _buildCheckbox('All Boxes Loaded in Vans', _allBoxesLoadedInVans, (value) {
                    setState(() => _allBoxesLoadedInVans = value!);
                  }),
                  _buildCheckbox('Chocolates and cookies in fridge', _chocolatesAndCookiesInFridge, (value) {
                    setState(() => _chocolatesAndCookiesInFridge = value!);
                  }),
                  _buildCheckbox('Tool box and float in the vans', _toolBoxAndFloatInVans, (value) {
                    setState(() => _toolBoxAndFloatInVans = value!);
                  }),
                  _buildCheckbox('Check fuel card in the vans', _checkFuelCardInVans, (value) {
                    setState(() => _checkFuelCardInVans = value!);
                  }),
                  _buildCheckbox('Cardboards in bailor', _cardboardsInBailor, (value) {
                    setState(() => _cardboardsInBailor = value!);
                  }),
                ]),
                SizedBox(height: 16),

                // Communication & Security Checks
                _buildCheckboxGroup('Communication & Security', [
                  _buildCheckbox('Check 3 fillers phones and 4 ipads in charger', _check3FillersPhones, (value) {
                    setState(() => _check3FillersPhones = value!);
                  }),
                  _buildCheckbox('Alarm done and video of door lock to ARV team', _alarmDoneAndVideo, (value) {
                    setState(() => _alarmDoneAndVideo = value!);
                  }),
                  _buildCheckbox('Check damages for vehical and inform John', _checkDamagesForVehicle, (value) {
                    setState(() => _checkDamagesForVehicle = value!);
                  }),
                  _buildCheckbox('Check vehical inside is clean if not inform', _checkVehicleInsideClean, (value) {
                    setState(() => _checkVehicleInsideClean = value!);
                  }),
                ]),
                SizedBox(height: 16),

                // Final Safety Checks
                _buildCheckboxGroup('Final Safety Checks', [
                  _buildCheckbox('Check upstairs lights AC OFF', _checkUpstairsLights, (value) {
                    setState(() => _checkUpstairsLights = value!);
                  }),
                  _buildCheckbox('All lights off', _allLightsOff, (value) {
                    setState(() => _allLightsOff = value!);
                  }),
                ]),
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
                  label: Text('Submit Form'),
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
                'Picking Summary',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Items selected for picking:',
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
                    'Total items to pick: ',
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
          validator: required
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
        ),
      ],
    );
  }

  Widget _buildEmployeeDropdownField({
    required String label,
    required DropDownModel? selectedValue,
    required IconData icon,
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
            if (value == null) {
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
  Widget _buildDateField(String label, TextEditingController controller, {bool required = false}) {
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
          readOnly: true,
          validator: required
              ? (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          }
              : null,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(Duration(days: 30)),
              lastDate: DateTime.now().add(Duration(days: 30)),
            );
            if (date != null) {
              controller.text = date.toString().split(' ')[0];
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Collect form data
      final formData = {
        'picker_id': _selectedEmployee?.id,
        'picking_date': _pickingDateController.text,
        'service_run_date': _serviceRunDateController.text,
        'vans_parked': _vansParkedInSideWarehouse,
        'boxes_loaded': _allBoxesLoadedInVans,
        'chocolates_in_fridge': _chocolatesAndCookiesInFridge,
        'tool_box_float': _toolBoxAndFloatInVans,
        'fuel_card_checked': _checkFuelCardInVans,
        'cardboards_in_bailor': _cardboardsInBailor,
        'phones_ipads_charged': _check3FillersPhones,
        'alarm_video_done': _alarmDoneAndVideo,
        'damages_informed': _checkDamagesForVehicle,
        'vehicle_clean_check': _checkVehicleInsideClean,
        'upstairs_lights_off': _checkUpstairsLights,
        'all_lights_off': _allLightsOff,
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