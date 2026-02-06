import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/data/model/leave_attendance_model/leave_attendance_model.dart';
import 'package:wisdeals/presentation/provider/leave_and_attendance_provider.dart';
import 'package:wisdeals/presentation/screens/attendanceandleave/widgets/select_Image_File_widget.dart';
import 'package:wisdeals/widgets/success_diloge_widget.dart';

class ApplayLeaveWidget extends StatefulWidget {
  final LeaveHistory? leaveData;
  final bool isExpanded;
  final bool isEdit;
  final LeaveAndAttendanceProvider leaveprovider;

  final TextEditingController dateFromController;
  final TextEditingController dateToController;
  final TextEditingController noteController;

  final String? attachMent;

  const ApplayLeaveWidget({
    super.key,
    this.leaveData,
    required this.isExpanded,
    required this.leaveprovider,
    required this.dateFromController,
    required this.dateToController,
    required this.noteController,
    required this.attachMent,
    required this.isEdit,
  });

  @override
  State<ApplayLeaveWidget> createState() => _ApplayLeaveWidgetState();
}

class _ApplayLeaveWidgetState extends State<ApplayLeaveWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;

  @override
  void didUpdateWidget(covariant ApplayLeaveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isExpanded && !_initialized) {
      _initialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.isEdit && widget.leaveData != null) {
          // EDIT MODE
          widget.dateFromController.text = widget.leaveData?.fromDate ?? "";
          widget.dateToController.text = widget.leaveData?.toDate ?? "";
          widget.noteController.text = widget.leaveData?.reason ?? "";

          widget.leaveprovider.setSelectedLeave(
            widget.leaveData?.leaveTypeId.toString(),
          );
          print('id XXXXXXXXXXX : ${widget.leaveData?.leaveTypeId}');
          print('id XXXXXXXXXXX : ${widget.leaveData?.leaveType}');
        } else {
          // APPLY MODE - Only clear once
          widget.leaveprovider.clearMeetingDataleave();

          // Restore selected dates if user chooses again
          widget.dateFromController.text =
              widget.leaveprovider.selectedLeaveDateFrom ?? "";

          widget.dateToController.text =
              widget.leaveprovider.selectedLeaveDateTo ?? "";

          widget.noteController.clear();
          widget.leaveprovider.setSelectedLeave(null);
        }
      });
    }

    if (!widget.isExpanded) {
      _initialized = false;
    }
  }

  void _refreshLeaveList() {
    final formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    widget.leaveprovider.getLeaveAndAttendancePro(formattedDate);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: widget.isExpanded ? 550 : 0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEDFCC5),
        borderRadius: BorderRadius.circular(15),
      ),
      child:
          !widget.isExpanded
              ? null
              : Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 10),

                        /// LEAVE TYPE
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Select Leave Type"),
                            const SizedBox(height: 10),
                            DropdownButtonFormField(
                              value:
                                  widget
                                              .leaveprovider
                                              .selectedLeave
                                              ?.isNotEmpty ==
                                          true
                                      ? widget.leaveprovider.selectedLeave
                                      : null,
                              decoration: const InputDecoration(
                                labelText: "Select Leave Type",
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  (widget.leaveprovider.LeaveTypeList ?? [])
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type.id.toString(),
                                          child: Text(type.name ?? ''),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                widget.leaveprovider.setSelectedLeave(value);
                                print('Selected Leave Type ID: $value');
                              },
                              validator:
                                  (value) =>
                                      value == null
                                          ? "Please select leave type"
                                          : null,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// DATE FROM / DATE TO
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Date From"),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: widget.dateFromController,
                                    readOnly: true,
                                    onTap: () async {
                                      await widget.leaveprovider
                                          .setSelectedDatefrom(context);

                                      widget.dateFromController.text =
                                          widget
                                              .leaveprovider
                                              .selectedLeaveDateFrom ??
                                          "";
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Date From",
                                      suffixIcon: const Icon(
                                        Icons.calendar_today,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    validator:
                                        (value) =>
                                            value!.isEmpty
                                                ? "Please select date"
                                                : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Date To"),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: widget.dateToController,
                                    readOnly: true,
                                    onTap: () async {
                                      await widget.leaveprovider
                                          .setSelectedDateTo(context);

                                      widget.dateToController.text =
                                          widget
                                              .leaveprovider
                                              .selectedLeaveDateTo ??
                                          "";
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Date To",
                                      suffixIcon: const Icon(
                                        Icons.calendar_today,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    validator:
                                        (value) =>
                                            value!.isEmpty
                                                ? "Please select date"
                                                : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// REASON
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Reason"),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: widget.noteController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "Write a Reason",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? "Please enter reason"
                                          : null,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        const Text("Attach File"),
                        const SizedBox(height: 10),

                        SelectImageFileAndCameraWidget(
                          leaveData: widget.leaveData,
                          isEdit: widget.isEdit,
                          leaveprovider: widget.leaveprovider,
                        ),
                        const SizedBox(height: 20),

                        /// SUBMIT BUTTON
                        InkWell(
                          onTap:
                              widget.leaveprovider.isLoadingAddLeave
                                  ? null
                                  : () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (widget.isEdit &&
                                          widget.leaveData != null) {
                                        print(
                                          '11111112222222222 :  ${widget.leaveData!.id.toString()}',
                                        );
                                        print(
                                          '11111112222222222 :  ${widget.leaveprovider.selectedLeave}',
                                        );
                                        await widget.leaveprovider
                                            .updateLeaveProvider(
                                              widget.leaveData!.id.toString(),
                                              widget
                                                  .leaveprovider
                                                  .selectedLeave,
                                              widget.dateFromController.text,
                                              widget.dateToController.text,
                                              widget.noteController.text,
                                              widget.leaveData?.attachment ??
                                                  widget.attachMent,
                                            );
                                      } else {
                                        await widget.leaveprovider
                                            .addLeaveProvider(
                                              widget
                                                  .leaveprovider
                                                  .selectedLeave,
                                              widget.dateFromController.text,
                                              widget.dateToController.text,
                                              widget.noteController.text,
                                              widget.attachMent,
                                            );
                                      }

                                      if (widget.leaveprovider.success !=
                                          null) {
                                        widget.leaveprovider
                                            .hideAndShowContainer(true, 0);

                                        showSuccessDialog(
                                          context,
                                          "assets/images/successicons.png",
                                          "Success",
                                          widget.leaveprovider.success!.message,
                                        );

                                        widget.leaveprovider
                                            .clearMeetingDataleave();
                                        _refreshLeaveList();
                                      }
                                    }
                                  },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color:
                                  widget.leaveprovider.isLoadingAddLeave
                                      ? Colors.black
                                      : kButtonColor2,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.leaveprovider.isLoadingAddLeave
                                  ? "Loading..."
                                  : widget.isEdit
                                  ? "Update"
                                  : "Apply",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    widget.leaveprovider.isLoadingAddLeave
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
