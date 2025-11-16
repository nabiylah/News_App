import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/home_controller.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import '../routes/app_routes.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (controller.errorMessage.isNotEmpty) {
            return _buildErrorState();
          }

          return ListView(
            padding: const EdgeInsets.only(top: 12),
            children: [
              // HEADER
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  "Discover News",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: "Search news...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) => controller.searchNews(value),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // SECTION PER CATEGORY (NETFLIX STYLE)
              for (final cat in controller.categoryData) _buildCategoryRow(cat),

              const SizedBox(height: 40),
            ],
          );
        }),
      ),
    );
  }

  // ----------------------------------------------------------
  // CATEGORY → Netflix Horizontal Row
  // ----------------------------------------------------------
  Widget _buildCategorySection({
    required String category,
    required List articles,
  }) {
    if (articles.isEmpty) return const SizedBox();

    final sectionTitle = _prettyCategory(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TITLE ala Netflix
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          child: Text(
            sectionTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: articles.length,
            itemBuilder: (_, i) {
              final a = articles[i];
              return _buildNetflixCard(a);
            },
          ),
        ),

        const SizedBox(height: 26),
      ],
    );
  }

  // ----------------------------------------------------------
  // NETFLIX STYLE CARD
  // ----------------------------------------------------------
  Widget _buildNetflixCard(article) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.detail, arguments: article),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: article.urlToImage ?? "",
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 150,
                color: Colors.grey.shade200,
              ),
              errorWidget: (_, __, ___) => Container(
                height: 150,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported, size: 35),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  article.title ?? "",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // CATEGORY NAME
  // ----------------------------------------------------------
  String _prettyCategory(String c) {
    switch (c) {
      case "business":
        return "Business Today";
      case "technology":
        return "Tech Spotlight";
      case "entertainment":
        return "Entertainment Picks";
      case "health":
        return "Healthy Living";
      case "science":
        return "Science Discoveries";
      case "sports":
        return "Sports Highlights";
      default:
        return "Trending Now";
    }
  }

  // ----------------------------------------------------------
  // ERROR STATE UI
  // ----------------------------------------------------------
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 70, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.fetchNews,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Coba Lagi"),
          )
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // DYNAMIC CATEGORY ROW BUILDER
  // ----------------------------------------------------------
  Widget _buildCategoryRow(Map<String, String> cat) {
    return FutureBuilder(
      future: controller.fetchCategoryNews(cat['category']!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final articles = snapshot.data!;

        if (articles.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Text(
                cat['title']!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: articles.length,
                itemBuilder: (_, i) => _buildNetflixCard(articles[i]),
              ),
            ),

            const SizedBox(height: 26),
          ],
        );
      },
    );
  }
}
