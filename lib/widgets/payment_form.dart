// import 'package:dogo/core/theme/AppColors.dart';
// import 'package:dogo/data/models/PaymentMethodInfo.dart' show PaymentMethod, PaymentMethodHelper;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'common_widgets.dart';

// class PaymentForm extends StatelessWidget {
//   final PaymentMethod? selectedPaymentMethod;
//   final Function(PaymentMethod) onPaymentMethodSelected;
//   final TextEditingController phoneController;

//   const PaymentForm({
//     Key? key,
//     required this.selectedPaymentMethod,
//     required this.onPaymentMethodSelected,
//     required this.phoneController,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Text(
//           'Select Payment Method',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         SizedBox(height: 16),
        
//         // Payment options
//         ...PaymentMethod.values.map((method) => PaymentOption(
//           method: method,
//           isSelected: selectedPaymentMethod == method,
//           onTap: () => onPaymentMethodSelected(method),
//         )),
        
//         SizedBox(height: 24),
        
//         // Payment details form based on selected method
//         if (selectedPaymentMethod != null)
//           AnimatedContainer(
//             duration: Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             child: PaymentDetailsForm(
//               method: selectedPaymentMethod!,
//               phoneController: phoneController,
//             ),
//           ),
//       ],
//     );
//   }
// }

// class PaymentOption extends StatelessWidget {
//   final PaymentMethod method;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const PaymentOption({
//     Key? key,
//     required this.method,
//     required this.isSelected,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final paymentInfo = PaymentMethodHelper.getPaymentMethodInfo(method);
    
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: EdgeInsets.only(bottom: 12),
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected ? AppColors.infoLight : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? Theme.of(context).colorScheme.secondary : AppColors.border,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 24,
//               height: 24,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: isSelected 
//                     ? Theme.of(context).colorScheme.secondary 
//                     : Color(0xFF94A3B8),
//                   width: 2,
//                 ),
//               ),
//               child: isSelected
//                 ? Center(
//                     child: Container(
//                       width: 12,
//                       height: 12,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Theme.of(context).colorScheme.secondary,