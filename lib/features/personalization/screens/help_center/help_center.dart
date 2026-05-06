import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/core/api_response.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  late Future<ApiResponse<List<HelpTopicItem?>>> _topicsFuture;
  String? _selectedCategory; // null => All

  @override
  void initState() {
    super.initState();
    _topicsFuture = ApiMiddleware.helpCenter.getTopics();
  }

  Future<void> _refresh() async {
    setState(() {
      _topicsFuture = ApiMiddleware.helpCenter.getTopics();
    });
    await _topicsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = IAMHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: const IAMAppBar(
        showBackArrow: true,
        title: Text('Help Center'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<ApiResponse<List<HelpTopicItem?>>>(
          future: _topicsFuture,
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final res = snapshot.data;

            if (isLoading && res == null) {
              return const _HelpCenterLoadingView();
            }

            if (snapshot.hasError) {
              return _HelpCenterMessageView(
                title: 'Something went wrong',
                message: 'Please try again.',
                onRetry: _refresh,
              );
            }

            if (res == null) {
              return _HelpCenterMessageView(
                title: 'No data',
                message: 'Pull down to refresh.',
                onRetry: _refresh,
              );
            }

            if (!res.success) {
              return _HelpCenterMessageView(
                title: 'Unable to load FAQs',
                message: res.message.isNotEmpty ? res.message : 'Please try again.',
                onRetry: _refresh,
              );
            }

            final allTopics = (res.data ?? const <HelpTopicItem?>[])
                .whereType<HelpTopicItem>()
                .toList();

            allTopics.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

            if (allTopics.isEmpty) {
              return _HelpCenterMessageView(
                title: 'No FAQs yet',
                message: 'Please check back later.',
                onRetry: _refresh,
              );
            }

            String normalizeCategory(String raw) {
              final trimmed = raw.trim();
              return trimmed.isEmpty ? 'General' : trimmed;
            }

            final allCategories = {
              for (final t in allTopics) normalizeCategory(t.category),
            }.toList()
              ..sort();

            final filteredTopics = _selectedCategory == null
                ? allTopics
                : allTopics
                    .where(
                      (t) => normalizeCategory(t.category) == _selectedCategory,
                    )
                    .toList();

            final grouped = <String, List<HelpTopicItem>>{};
            for (final t in filteredTopics) {
              final category = normalizeCategory(t.category);
              grouped.putIfAbsent(category, () => <HelpTopicItem>[]).add(t);
            }

            final categoriesToShow = _selectedCategory == null
                ? allCategories
                : <String>[_selectedCategory!];

            if (_selectedCategory != null && filteredTopics.isEmpty) {
              return _HelpCenterMessageView(
                title: 'No FAQs in this category',
                message: 'Try selecting a different category.',
                onRetry: _refresh,
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(IAMSizes.defaultSpace),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(IAMSizes.md),
                  decoration: BoxDecoration(
                    color: darkMode ? IAMColors.dark : Colors.white,
                    borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
                    border: Border.all(
                      color: darkMode ? IAMColors.darkerGrey : const Color(0xFFF1E8D2),
                    ),
                  ),
                  child: Text(
                    'Find quick answers to common questions.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: IAMSizes.spaceBtwSections),
                // Category dropdown
                Container(
                  padding: const EdgeInsets.all(IAMSizes.md),
                  decoration: BoxDecoration(
                    color: darkMode ? IAMColors.dark : Colors.white,
                    borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
                    border: Border.all(
                      color: darkMode ? IAMColors.darkerGrey : const Color(0xFFF1E8D2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter by category',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: IAMSizes.xs),
                      DropdownButtonFormField<String?>(
                        value: _selectedCategory,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All categories'),
                          ),
                          ...allCategories.map(
                            (c) => DropdownMenuItem<String?>(
                              value: c,
                              child: Text(c),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _selectedCategory = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: IAMSizes.spaceBtwSections),
                for (final category in categoriesToShow)
                  if ((grouped[category] ?? const <HelpTopicItem>[]).isNotEmpty) ...[
                    IAMSectionHeading(
                      title: category,
                      showActionButton: false,
                    ),
                    const SizedBox(height: IAMSizes.spaceBtwItems),
                    ...grouped[category]!.map((t) => _HelpTopicTile(topic: t)),
                    const SizedBox(height: IAMSizes.spaceBtwSections),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HelpTopicTile extends StatelessWidget {
  const _HelpTopicTile({required this.topic});

  final HelpTopicItem topic;

  @override
  Widget build(BuildContext context) {
    final darkMode = IAMHelperFunctions.isDarkMode(context);

    return Card(
      elevation: 0,
      color: darkMode ? IAMColors.dark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
        side: BorderSide(
          color: darkMode ? IAMColors.darkerGrey : const Color(0xFFF1E8D2),
        ),
      ),
      margin: const EdgeInsets.only(bottom: IAMSizes.md),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: IAMSizes.md,
            vertical: IAMSizes.xs,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            IAMSizes.md,
            0,
            IAMSizes.md,
            IAMSizes.md,
          ),
          iconColor: IAMColors.primary,
          collapsedIconColor: IAMColors.primary,
          title: Text(
            topic.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SelectableText(
                topic.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpCenterLoadingView extends StatelessWidget {
  const _HelpCenterLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(IAMSizes.defaultSpace),
      children: const [
        SizedBox(height: IAMSizes.spaceBtwSections),
        LinearProgressIndicator(),
        SizedBox(height: IAMSizes.spaceBtwSections),
      ],
    );
  }
}

class _HelpCenterMessageView extends StatelessWidget {
  const _HelpCenterMessageView({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(IAMSizes.defaultSpace),
      children: [
        const SizedBox(height: IAMSizes.spaceBtwSections * 2),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: IAMSizes.sm),
        Text(message, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: IAMSizes.spaceBtwSections),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => onRetry(),
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}

