import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/presentation/provider/notification_provider.dart';

class CustomAppBarWidget extends StatefulWidget {
  final String? title;
  final bool drawerIconImage;
  final bool notificationIconImage;
  final VoidCallback? onDrawerTap;
  final bool editButton;
  final VoidCallback? onTap;
  const CustomAppBarWidget({
    super.key,
    required this.title,
    this.drawerIconImage = true,
    this.notificationIconImage = true,
    this.onDrawerTap,
    this.editButton = false,
    this.onTap,
  });

  @override
  State<CustomAppBarWidget> createState() => _CustomAppBarWidgetState();
}

class _CustomAppBarWidgetState extends State<CustomAppBarWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialData();
  }

  void initialData() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final provider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      provider.filterDatas();
      provider.getNotification();
      // print('count........ ${provider.notifiCount}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        return Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(color: Colors.transparent),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.drawerIconImage
                    ? InkWell(
                      onTap: () {
                        // this is drawer function
                        Scaffold.of(context).openDrawer();
                      },
                      child: Image.asset('assets/images/drawericon.png'),
                    )
                    : InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back, color: kTextColorPrimary),
                    ),

                Text(
                  '${widget.title ?? 'No Title'}',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontFamily: "MontrealSerial",
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),

                widget.notificationIconImage
                    ? Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/notificationscreen');
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            child: Image.asset(
                              'assets/images/bell.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        (notificationProvider.notifiCount == null ||
                                notificationProvider.notifiCount == "0")
                            ? SizedBox()
                            : Positioned(
                              right: 1,
                              top: 1,
                              child: Container(
                                width: 13,
                                height: 13,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${notificationProvider.notifiCount ?? '0'}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                      ],
                    )
                    : widget.editButton
                    ? IconButton(
                      onPressed: widget.onTap,
                      icon: Icon(Icons.edit_square, color: Colors.white),
                    )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }
}
