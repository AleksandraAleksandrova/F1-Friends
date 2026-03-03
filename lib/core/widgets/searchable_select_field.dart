import "package:flutter/material.dart";

class SearchableSelectItem {
  const SearchableSelectItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}

class SearchableSelectField extends StatelessWidget {
  const SearchableSelectField({
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.hintText,
    this.width,
    super.key,
  });

  final String label;
  final String? hintText;
  final double? width;
  final List<SearchableSelectItem> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedLabel = items
        .where((it) => it.value == selectedValue)
        .map((it) => it.label)
        .firstWhere(
          (value) => true,
          orElse: () => "",
        );

    return RawAutocomplete<SearchableSelectItem>(
      key: ValueKey("$label-$selectedValue-${items.length}"),
      initialValue: TextEditingValue(text: selectedLabel),
      displayStringForOption: (option) => option.label,
      optionsBuilder: (textValue) {
        final query = textValue.text.trim().toLowerCase();
        if (query.isEmpty) {
          return items;
        }
        return items.where((option) => option.label.toLowerCase().contains(query));
      },
      onSelected: (option) => onChanged(option.value),
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: textController,
          focusNode: focusNode,
          onChanged: (_) => onChanged(null),
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText ?? "Type to filter",
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 240,
                minWidth: width ?? 300,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(option.label),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
