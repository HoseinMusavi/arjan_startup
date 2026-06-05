import 'package:flutter/material.dart';

class OrderSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onClear;

  const OrderSearchBar({
    super.key,
    required this.onSearch,
    required this.onClear,
  });

  @override
  State<OrderSearchBar> createState() => _OrderSearchBarState();
}

class _OrderSearchBarState extends State<OrderSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _isSearching = false;
    });
    widget.onClear();
    _focusNode.unfocus();
  }

  void _submitSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
      widget.onSearch(query);
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'جستجوی سفارش (شماره سفارش یا نام فروشگاه)',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            prefixIcon: _isSearching
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _clearSearch,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                : null,
            suffixIcon: IconButton(
              icon: Icon(Icons.search, color: Colors.grey.shade600, size: 22),
              onPressed: _submitSearch,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onSubmitted: (_) => _submitSearch(),
        ),
      ),
    );
  }
}