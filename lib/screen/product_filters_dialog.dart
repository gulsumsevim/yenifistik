import 'package:fistikpazar/models/product_model.dart';
import 'package:fistikpazar/screen/app_colors.dart';
import 'package:fistikpazar/screen/categories_chip.dart';
import 'package:flutter/material.dart';

class ProductFiltersDialog extends StatefulWidget {
  final Function(List<String> categories, List<String> productSizes, RangeValues price)? onFilteredTap;

  const ProductFiltersDialog({
    Key? key,
    this.onFilteredTap,
  }) : super(key: key);

  @override
  _ProductFiltersDialogState createState() => _ProductFiltersDialogState();
}

class _ProductFiltersDialogState extends State<ProductFiltersDialog> {
  List<String> _selectedCategories = [];
  List<String> _selectedProductSizes = [];
  RangeValues _currentRangeValues = const RangeValues(40, 80);
  List<Products> _products = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _FilterHeader(),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Kategori',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.spaceAround,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 16,
                runSpacing: 16,
                children: [
                  'Siirt Fıstığı',
                  'Antep Fıstığı',
                  'Ceviz',
                  'Fındık',
                  'Elma',
                  'Badem',
                  'Yer Fıstığı',
                ].map((String value) {
                  return CategoriesChip(
                    label: value,
                    isActive: _selectedCategories.contains(value),
                    onPressed: () {
                      setState(() {
                        if (_selectedCategories.contains(value)) {
                          _selectedCategories.remove(value);
                        } else {
                          _selectedCategories.add(value);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Boyut',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.spaceAround,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 16,
                runSpacing: 16,
                children: [
                  CategoriesChip(
                    label: 'Küçük',
                    isActive: _selectedProductSizes.contains('Küçük'),
                    onPressed: () {
                      setState(() {
                        if (_selectedProductSizes.contains('Küçük')) {
                          _selectedProductSizes.remove('Küçük');
                        } else {
                          _selectedProductSizes.add('Küçük');
                        }
                      });
                    },
                  ),
                  CategoriesChip(
                    label: 'Orta',
                    isActive: _selectedProductSizes.contains('Orta'),
                    onPressed: () {
                      setState(() {
                        if (_selectedProductSizes.contains('Orta')) {
                          _selectedProductSizes.remove('Orta');
                        } else {
                          _selectedProductSizes.add('Orta');
                        }
                      });
                    },
                  ),
                  CategoriesChip(
                    label: 'Büyük',
                    isActive: _selectedProductSizes.contains('Büyük'),
                    onPressed: () {
                      setState(() {
                        if (_selectedProductSizes.contains('Büyük')) {
                          _selectedProductSizes.remove('Büyük');
                        } else {
                          _selectedProductSizes.add('Büyük');
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Fiyat Aralığı',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
            ),
            RangeSlider(
              max: 1000,
              min: 0,
              labels: RangeLabels(
                _currentRangeValues.start.round().toString(),
                _currentRangeValues.end.round().toString(),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                });
              },
              activeColor: Colors.green,
              inactiveColor: Colors.grey,
              values: _currentRangeValues,
              divisions: 1000,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _applyFilters(context);
              },
              child: Text(
                'Uygula',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _applyFilters(BuildContext context) async {
    widget.onFilteredTap?.call(_selectedCategories, _selectedProductSizes, _currentRangeValues);
    Navigator.pop(context);
  }
}

class _FilterHeader extends StatelessWidget {
  const _FilterHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 56,
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 40,
            width: 40,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.scaffoldWithBoxBackground,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
