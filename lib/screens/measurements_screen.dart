// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:notdle/db/database_helper.dart';
// import 'package:notdle/models/customer.dart';
// import 'package:notdle/models/measurement.dart';
//
// class MeasurementsScreen extends StatefulWidget {
//   final Customer customer;
//
//   const MeasurementsScreen({super.key, required this.customer});
//
//   @override
//   State<MeasurementsScreen> createState() => _MeasurementsScreenState();
// }
//
// class _MeasurementsScreenState extends State<MeasurementsScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final Map<String, TextEditingController> _controllers = {};
//   late Measurement measurement;
//
//   final ImagePicker _picker = ImagePicker();
//   File? _profileImage;
//
//   Future<void> _pickImage(ImageSource source) async {
//     final picked = await _picker.pickImage(source: source);
//     if (picked != null) {
//       setState(() {
//         _profileImage = File(picked.path);
//         widget.customer.imagePath = picked.path;
//       });
//
//       // ✅ Save update to SQLite
//       await DatabaseHelper.instance.updateCustomer(widget.customer);
//     }
//   }
//
//   Future<void> _showImageSourceActionSheet() async {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.camera_alt, color: Colors.indigo),
//                 title: Text("Take Photo", style: GoogleFonts.poppins()),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library, color: Colors.green),
//                 title: Text(
//                   "Choose from Gallery",
//                   style: GoogleFonts.poppins(),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.gallery);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   // Keep track of selected dropdown values
//   late Map<String, String> _selectedDropdowns;
//
//   final List<String> _femaleFields = [
//     "Bust",
//     "Niple to Niple",
//     "Under Bust",
//     "Waist",
//     "Shoulder to Shoulder",
//     "Full Blouse Length",
//     "Across Back",
//     "Around Arm",
//     "Sleeve Length",
//     "Trouser Waist",
//     "Thigh",
//     "Hip",
//     "Knee",
//     "Base",
//     "Cloth", // dropdown field
//   ];
//
//   final List<String> _femaleClothTypes = ["Trouser", "Skirt", "Full Dress"];
//
//   final List<String> _maleFields = [
//     "Chest",
//     "Across Back",
//     "Sleeve",
//     "Cuff",
//     "Shirt", // dropdown field
//     "Waist",
//     "Thigh",
//     "Knee",
//     "Base",
//     "Trouser", // dropdown field
//     "Chin",
//   ];
//
//   final Map<String, List<String>> _maleDropdownOptions = {
//     "Shirt": ["Shirt", "Kaftan"],
//     "Trouser": ["Trouser", "Shorts"],
//   };
//
//   List<String> get _fields =>
//       widget.customer.gender.toLowerCase() == "female"
//           ? _femaleFields
//           : _maleFields;
//
//   @override
//   void initState() {
//     super.initState();
//     super.initState();
//     for (var field in _fields) {
//       _controllers[field] = TextEditingController();
//     }
//
//     // Initialize selected dropdown values
//     _selectedDropdowns = {};
//     for (var field in _fields) {
//       if (field == "Cloth" &&
//           widget.customer.gender.toLowerCase() == "female") {
//         _selectedDropdowns[field] = _femaleClothTypes[0];
//       } else if (_maleDropdownOptions.containsKey(field)) {
//         _selectedDropdowns[field] = _maleDropdownOptions[field]![0];
//       }
//     }
//   }
//
//   Future<void> _saveMeasurement() async {
//     final values = <String, double>{};
//     for (var entry in _controllers.entries) {
//       final val = double.tryParse(entry.value.text);
//       if (val != null) {
//         values[entry.key] = val;
//       }
//     }
//
//     if (widget.customer.id == null) {
//       throw Exception("Customer must be saved before adding measurement.");
//     }
//
//     final measurement = Measurement(
//       customerId: widget.customer.id!,
//       measurementValues: values,
//       createdDate: DateTime.now(),
//     );
//
//     await DatabaseHelper.instance.insertMeasurement(measurement);
//
//     if (mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Measurement saved")));
//       Navigator.pop(context);
//     }
//   }
//
//   @override
//   void dispose() {
//     for (var controller in _controllers.values) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final fields = _controllers.keys.toList();
//
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           title: Row(
//             children: [
//               // Profile avatar with upload
//               GestureDetector(
//                 onTap: _showImageSourceActionSheet,
//                 child: CircleAvatar(
//                   radius: 20,
//                   backgroundColor: Colors.indigo.shade100,
//                   backgroundImage:
//                       _profileImage != null
//                           ? FileImage(_profileImage!)
//                           : (widget.customer.imagePath != null
//                               ? FileImage(File(widget.customer.imagePath!))
//                               : null),
//                   child:
//                       (_profileImage == null &&
//                               widget.customer.imagePath == null)
//                           ? Text(
//                             widget.customer.name.isNotEmpty
//                                 ? widget.customer.name[0].toUpperCase()
//                                 : "?",
//                             style: GoogleFonts.poppins(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.indigo,
//                             ),
//                           )
//                           : null,
//                 ),
//               ),
//               const SizedBox(width: 12),
//
//               // Name + subtitle
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.customer.name,
//                     style: GoogleFonts.poppins(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16,
//                       color: Colors.black,
//                     ),
//                   ),
//                   Text(
//                     "${widget.customer.gender} • ${widget.customer.phone}",
//                     style: GoogleFonts.poppins(
//                       fontSize: 12,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//
//         body: Form(
//           key: _formKey,
//           child: ListView.separated(
//             padding: const EdgeInsets.all(16),
//             itemCount: fields.length,
//             itemBuilder: (context, index) {
//               final field = fields[index];
//
//               if (widget.customer.gender.toLowerCase() == "female" &&
//                   field == "Cloth") {
//                 return _buildDropdownField(field, _femaleClothTypes);
//               } else if (_maleDropdownOptions.containsKey(field)) {
//                 return _buildDropdownField(field, _maleDropdownOptions[field]!);
//               }
//
//               return _buildNormalField(field);
//
//               // return TextFormField(
//               //   controller: _controllers[field],
//               //   decoration: InputDecoration(
//               //     labelText: field,
//               //     labelStyle: GoogleFonts.poppins(),
//               //     border: OutlineInputBorder(
//               //       borderRadius: BorderRadius.circular(12),
//               //     ),
//               //     filled: true,
//               //     fillColor: Colors.grey.shade50,
//               //   ),
//               //   keyboardType: TextInputType.number,
//               //   validator:
//               //       (value) =>
//               //           value == null || value.isEmpty ? "Enter $field" : null,
//               // );
//             },
//             separatorBuilder: (_, __) => const SizedBox(height: 16),
//           ),
//         ),
//
//         // ✅ Save button pinned at bottom
//         bottomNavigationBar: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 8,
//                 offset: const Offset(0, -2),
//               ),
//             ],
//           ),
//           child: SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: _saveMeasurement,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.indigo,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//               icon: const Icon(Icons.check, color: Colors.white),
//               label: Text(
//                 "Save Measurements",
//                 style: GoogleFonts.poppins(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   //Building fields
//   Widget _buildNormalField(String field) {
//     return TextFormField(
//       controller: _controllers[field],
//       decoration: InputDecoration(
//         labelText: field,
//         labelStyle: GoogleFonts.poppins(),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         filled: true,
//         fillColor: Colors.grey.shade50,
//       ),
//       keyboardType: TextInputType.number,
//       validator:
//           (value) => value == null || value.isEmpty ? "Enter $field" : null,
//     );
//   }
//
//   // Custom Builder
//   Widget _buildDropdownField(String field, List<String> options) {
//     return Row(
//       children: [
//         Expanded(
//           flex: 4,
//           child: DropdownButtonFormField<String>(
//             value: _selectedDropdowns[field],
//             items:
//                 options
//                     .map(
//                       (type) => DropdownMenuItem(
//                         value: type,
//                         child: Text(type, style: GoogleFonts.poppins()),
//                       ),
//                     )
//                     .toList(),
//             onChanged:
//                 (val) => setState(() => _selectedDropdowns[field] = val!),
//             decoration: InputDecoration(
//               labelText: "Type",
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               filled: true,
//               fillColor: Colors.grey.shade50,
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           flex: 6,
//           child: TextFormField(
//             controller: _controllers[field],
//             decoration: InputDecoration(
//               labelText: "Measurement",
//               labelStyle: GoogleFonts.poppins(),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               filled: true,
//               fillColor: Colors.grey.shade50,
//             ),
//             keyboardType: TextInputType.number,
//             validator:
//                 (value) =>
//                     value == null || value.isEmpty ? "Enter value" : null,
//           ),
//         ),
//       ],
//     );
//   }
// }
