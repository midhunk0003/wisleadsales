import 'package:flutter/material.dart';
import 'package:wisdeals/core/colors.dart';

class SearchAndFilterFieldWidget extends StatelessWidget {
  final String? title;
  final TextEditingController textEditingController;
  final VoidCallback onChange;
  final VoidCallback? onTap;
  final bool showFilter;
  const SearchAndFilterFieldWidget({
    super.key,
    required this.isTablet,
    required this.title,
    required this.textEditingController,
    required this.onChange,
    this.onTap,
    this.showFilter = true,
  });

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: isTablet ? 6 : 5,
          child: Container(
            width: double.infinity,
            height: isTablet ? 60 : 50,
            decoration: BoxDecoration(
              color: kButtonColor2,
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextField(
              controller: textEditingController,
              onChanged: (_) => onChange(), // ✅ fixed
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, size: isTablet ? 28 : 18),
                hintText: "${title}",
                hintStyle: TextStyle(fontSize: isTablet ? 18 : 14),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(
                  vertical: isTablet ? 15 : 10,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: isTablet ? 5 : 10),
        showFilter
            ? Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: isTablet ? 60 : 50,
                  height: isTablet ? 60 : 50,
                  decoration: BoxDecoration(
                    color: kButtonColor2,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/filter.png',
                      width: 18,
                      height: 18,
                    ),
                  ),
                ),
              ),
            )
            : SizedBox.shrink(),
      ],
    );
  }
}
