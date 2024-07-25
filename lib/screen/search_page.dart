import 'package:fistikpazar/models/colors.dart';
import 'package:fistikpazar/screen/app_colors.dart';
import 'package:fistikpazar/screen/app_defaults.dart';
import 'package:fistikpazar/screen/app_icons.dart';
import 'package:fistikpazar/screen/app_routes.dart';
import 'package:fistikpazar/screen/product_filters_dialog.dart';
import 'package:fistikpazar/screen/ui_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _SearchPageHeader(),
            SizedBox(height: 8),
            _RecentSearchList(),
          ],
        ),
      ),
    );
  }
}

class _RecentSearchList extends StatelessWidget {
  const _RecentSearchList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Search',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black,
                    ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 16),
              itemBuilder: (context, index) {
                return const SearchHistoryTile();
              },
              separatorBuilder: (context, index) => const Divider(
                thickness: 0.1,
              ),
              itemCount: 16,
            ),
          )
        ],
      ),
    );
  }
}

class _SearchPageHeader extends StatelessWidget {
  const _SearchPageHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Row(
        children: [
          IconButton(
            icon: SvgPicture.asset(AppIcons.arrowBackward),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Stack(
              children: [
                /// Search Box
                Form(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(AppDefaults.padding),
                        child: SvgPicture.asset(
                          AppIcons.search,
                          color: AppColors.primary,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(),
                      contentPadding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    textInputAction: TextInputAction.search,
                    autofocus: true,
                    onChanged: (String? value) {},
                    onFieldSubmitted: (v) {
                      Navigator.pushNamed(context, AppRoutes.searchResult);
                    },
                  ),
                ),
                Positioned(
                  right: 0,
                  height: 56,
                  child: SizedBox(
                    width: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        UiUtil.openBottomSheet(
                          context: context,
                          widget:  ProductFiltersDialog(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2F6F3),
                        shape: const CircleBorder(),
                      ),
                      child: SvgPicture.asset(
                        'icons/search.svg',
                        width: 20,
                        height: 20,
                        color: Colors.green,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchHistoryTile extends StatelessWidget {
  const SearchHistoryTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        child: Row(
          children: [
            Text(
              'Vegetables',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            SvgPicture.asset(AppIcons.searchTileArrow),
          ],
        ),
      ),
    );
  }
}
