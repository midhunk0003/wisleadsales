      // // const SizedBox(height: 5),
      //                             ListView.separated(
      //                               shrinkWrap: true,
      //                               physics:
      //                                   const NeverScrollableScrollPhysics(),
      //                               itemCount:
      //                                   attendanceProvider
      //                                       .leaveData
      //                                       ?.leaveHistory
      //                                       ?.length ??
      //                                   0,
      //                               itemBuilder: (context, index) {
      //                                 final leaveData =
      //                                     attendanceProvider
      //                                         .leaveData!
      //                                         .leaveHistory![index];

      //                                 final fromD = leaveData.fromDate;
      //                                 final toD = leaveData.toDate;

      //                                 // ------------------------------------------------------------
      //                                 // 1️⃣ SAFE DATE PARSER FUNCTION (supports dd-MM-yyyy)
      //                                 // ------------------------------------------------------------
      //                                 DateTime? parseCustomDate(String? date) {
      //                                   if (date == null || date.isEmpty)
      //                                     return null;

      //                                   try {
      //                                     return DateFormat(
      //                                       'dd-MM-yyyy',
      //                                     ).parse(date);
      //                                   } catch (e) {
      //                                     try {
      //                                       return DateFormat(
      //                                         'yyyy-MM-dd',
      //                                       ).parse(date);
      //                                     } catch (e) {
      //                                       return null;
      //                                     }
      //                                   }
      //                                 }

      //                                 final fromDate = parseCustomDate(fromD);
      //                                 final toDate = parseCustomDate(toD);

      //                                 // ------------------------------------------------------------
      //                                 // 2️⃣ CALCULATE TOTAL DAYS (inclusive count)
      //                                 // ------------------------------------------------------------
      //                                 int? totalDays;
      //                                 if (fromDate != null && toDate != null) {
      //                                   totalDays =
      //                                       toDate.difference(fromDate).inDays +
      //                                       1;
      //                                 }

      //                                 print("start date : $fromD");
      //                                 print("end date : $toD");

      //                                 // ------------------------------------------------------------
      //                                 // 3️⃣ FORMAT DATE RANGE FOR DISPLAY
      //                                 // ------------------------------------------------------------
      //                                 String formattedRange = 'N/A';

      //                                 if (fromDate != null && toDate != null) {
      //                                   formattedRange =
      //                                       '${DateFormat('MMM d, yyyy').format(fromDate)} - ${DateFormat('MMM d, yyyy').format(toDate)}';
      //                                 } else if (fromDate != null) {
      //                                   formattedRange = DateFormat(
      //                                     'MMM d, yyyy',
      //                                   ).format(fromDate);
      //                                 }

      //                                 return Container(
      //                                   decoration: BoxDecoration(
      //                                     borderRadius: BorderRadius.circular(
      //                                       12,
      //                                     ),
      //                                     border: Border.all(
      //                                       color: const Color(
      //                                         0xFF82AE09,
      //                                       ).withOpacity(0.15),
      //                                     ),
      //                                     color: const Color(
      //                                       0xFF82AE09,
      //                                     ).withOpacity(0.15),
      //                                   ),
      //                                   child: Padding(
      //                                     padding: const EdgeInsets.all(14.0),
      //                                     child: Column(
      //                                       crossAxisAlignment:
      //                                           CrossAxisAlignment.start,
      //                                       children: [
      //                                         Row(
      //                                           mainAxisAlignment:
      //                                               MainAxisAlignment
      //                                                   .spaceBetween,
      //                                           crossAxisAlignment:
      //                                               CrossAxisAlignment.end,
      //                                           children: [
      //                                             Column(
      //                                               crossAxisAlignment:
      //                                                   CrossAxisAlignment
      //                                                       .start,
      //                                               children: [
      //                                                 const Text(
      //                                                   'Date',
      //                                                   style: TextStyle(
      //                                                     fontFamily:
      //                                                         "MontrealSerial",
      //                                                     color: Colors.white,
      //                                                     fontSize: 14,
      //                                                     fontWeight:
      //                                                         FontWeight.w500,
      //                                                   ),
      //                                                 ),
      //                                                 const SizedBox(
      //                                                   height: 10,
      //                                                 ),
      //                                                 Text(
      //                                                   formattedRange,
      //                                                   style: const TextStyle(
      //                                                     fontFamily:
      //                                                         "MontrealSerial",
      //                                                     color: Colors.white60,
      //                                                     fontSize: 14,
      //                                                     fontWeight:
      //                                                         FontWeight.w500,
      //                                                   ),
      //                                                 ),
      //                                               ],
      //                                             ),
      //                                             Container(
      //                                               decoration: BoxDecoration(
      //                                                 color: getStatusColor(
      //                                                   leaveData.status!,
      //                                                 ),
      //                                                 borderRadius:
      //                                                     BorderRadius.circular(
      //                                                       8,
      //                                                     ),
      //                                               ),
      //                                               child: Padding(
      //                                                 padding:
      //                                                     const EdgeInsets.all(
      //                                                       10,
      //                                                     ),
      //                                                 child: Text(
      //                                                   leaveData.status ?? '',
      //                                                   style: const TextStyle(
      //                                                     fontFamily:
      //                                                         "MontrealSerial",
      //                                                     color: Colors.white,
      //                                                     fontSize: 14,
      //                                                     fontWeight:
      //                                                         FontWeight.w500,
      //                                                   ),
      //                                                 ),
      //                                               ),
      //                                             ),
      //                                           ],
      //                                         ),
      //                                         const SizedBox(height: 20),
      //                                         Text(
      //                                           'Leave Type : ${leaveData.leaveType}',
      //                                           style: const TextStyle(
      //                                             fontFamily: "MontrealSerial",
      //                                             color: Colors.white,
      //                                             fontSize: 14,
      //                                             fontWeight: FontWeight.w500,
      //                                           ),
      //                                         ),
      //                                         const SizedBox(height: 20),
      //                                         Row(
      //                                           mainAxisAlignment:
      //                                               MainAxisAlignment
      //                                                   .spaceBetween,
      //                                           children: [
      //                                             Column(
      //                                               crossAxisAlignment:
      //                                                   CrossAxisAlignment
      //                                                       .start,
      //                                               children: [
      //                                                 const Text(
      //                                                   'Apply Days',
      //                                                   style: TextStyle(
      //                                                     fontFamily:
      //                                                         "MontrealSerial",
      //                                                     color: Colors.white,
      //                                                     fontSize: 14,
      //                                                     fontWeight:
      //                                                         FontWeight.w500,
      //                                                   ),
      //                                                 ),
      //                                                 const SizedBox(
      //                                                   height: 10,
      //                                                 ),
      //                                                 Text(
      //                                                   '${totalDays ?? 'N/A'} Days',
      //                                                   style: const TextStyle(
      //                                                     fontFamily:
      //                                                         "MontrealSerial",
      //                                                     color: Colors.white60,
      //                                                     fontSize: 14,
      //                                                     fontWeight:
      //                                                         FontWeight.w500,
      //                                                   ),
      //                                                 ),
      //                                               ],
      //                                             ),
      //                                             Column(
      //                                               crossAxisAlignment:
      //                                                   CrossAxisAlignment
      //                                                       .start,
      //                                               children: [
      //                                                 const Text(
      //                                                   'Leave Balance',
      //                                                   style: TextStyle(
      //                                                     fontFamily:
      //                                                         "MontrealSerial",
      //                                                     color: Colors.white,
      //                                                     fontSize: 14,
      //                                                     fontWeight:
      //                                                         FontWeight.w500,
      //                                                   ),
      //                                                 ),
      //                                                 const SizedBox(
      //                                                   height: 10,
      //                                                 ),
      //                                                 Text(
      //                                                   '${attendanceProvider.leaveData!.leaveBalance ?? 'N/A'} Days',
      //                                                   style: const TextStyle(
      //                                                     fontFamily:
      //                                                         "MontrealSerial",
      //                                                     color: Colors.white60,
      //                                                     fontSize: 14,
      //                                                     fontWeight:
      //                                                         FontWeight.w500,
      //                                                   ),
      //                                                 ),
      //                                               ],
      //                                             ),
      //                                             Column(
      //                                               crossAxisAlignment:
      //                                                   CrossAxisAlignment
      //                                                       .start,
      //                                               children: [
      //                                                 const Text(
      //                                                   'Approved by',
      //                                                   style: TextStyle(
      //                                                     fontFamily:
      //                                                         "MontrealSerial",
      //                                                     color: Colors.white,
      //                                                     fontSize: 14,
      //                                                     fontWeight:
      //                                                         FontWeight.w500,
      //                                                   ),
      //                                                 ),
      //                                                 const SizedBox(
      //                                                   height: 10,
      //                                                 ),
      //                                                 Text(
      //                                                   leaveData.status ==
      //                                                           'Approved'
      //                                                       ? 'Admin'
      //                                                       : '--------',
      //                                                   style: const TextStyle(
      //                                                     fontFamily:
      //                                                         "MontrealSerial",
      //                                                     color: Colors.white60,
      //                                                     fontSize: 14,
      //                                                     fontWeight:
      //                                                         FontWeight.w500,
      //                                                   ),
      //                                                 ),
      //                                               ],
      //                                             ),
      //                                           ],
      //                                         ),
      //                                       ],
      //                                     ),
      //                                   ),
      //                                 );
      //                               },
      //                               separatorBuilder: (context, index) {
      //                                 return const SizedBox(height: 10);
      //                               },
      //                             ),
                                  
                                  
      //                             const SizedBox(height: 90),