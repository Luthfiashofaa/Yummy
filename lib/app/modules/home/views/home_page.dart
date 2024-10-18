import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:demo_yummy/app/modules/home/views/food_cart_page.dart';
import 'package:demo_yummy/app/modules/profile/views/account_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../webview/views/recipe_webview.dart';
import '../controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:demo_yummy/app/data/services/api_services.dart';
import 'package:demo_yummy/app/data/models/recipe_model.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController =
        Get.find<ProfileController>(); // Get ProfileController

    final items = <Widget>[
      SvgPicture.asset('assets/home.svg', width: 40, height: 40),
      SvgPicture.asset('assets/search.svg', width: 40, height: 40),
      GestureDetector(
        onTap: () {
          // Navigasi ke halaman WebView atau halaman resep
          Get.to(() => RecipeWebView(
                url:
                    'https://www.spoonacular.com', // Ganti dengan URL resep dari API
              ));
        },
        child: SvgPicture.asset('assets/Chef.svg', width: 40, height: 40),
      ),
      SvgPicture.asset('assets/notification.svg', width: 40, height: 40),
      GestureDetector(
        onTap: () {
          Get.to(AccountPage()); // Navigate to AccountPage
        },
        child: SvgPicture.asset('assets/user.svg', width: 40, height: 40),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Food Recipes"), // Title for clarity
      ),
      body: FutureBuilder<List<Recipe>>(
        future: fetchRecipes(), // Call method to fetch recipes
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage('assets/Sun.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Good Morning !",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              // Using Obx to monitor profile changes
                              Obx(() {
                                if (profileController.profiles.isNotEmpty) {
                                  return Text(
                                    profileController.profiles[0]
                                        .nama, // Show the first profile's name
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                } else {
                                  return Text(
                                    "No Profile", // If no profile
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                              }),
                              SizedBox(height: 25),
                              Text(
                                "Recipes",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15), // Spacing after header
                      // GridView for displaying FoodCard
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: snapshot.data!.length,
                        shrinkWrap: true, // Allows GridView to adjust
                        physics:
                            NeverScrollableScrollPhysics(), // Non-scrollable
                        itemBuilder: (context, index) {
                          final recipe = snapshot.data![index];
                          return GestureDetector(
                            onTap: () {
                              if (recipe.spoonacularSourceUrl != null) {
                                Get.to(
                                  RecipeWebView(
                                    url: recipe.spoonacularSourceUrl!,
                                  ),
                                ); // Navigate to RecipeWebView with URL
                              } else {
                                Get.snackbar('Error',
                                    'No URL available for this recipe');
                              }
                            },
                            child: FoodCard(
                              title: recipe.title ?? 'No Title',
                              imagePath: recipe.imageUrl ??
                                  'assets/default_image.png', // Default image if none
                              author:
                                  'Author Name', // You can add author information if needed
                              profileImagePath:
                                  "assets/profile1.jpg", // Add author's profile image if needed
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(child: Text('No data found'));
          }
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Shadow color
              spreadRadius: 3,
              blurRadius: 50,
              offset: Offset(0, 10), // Shadow position
            ),
          ],
        ),
        child: CurvedNavigationBar(
          items: items,
          buttonBackgroundColor: Color(0xFF042628),
          backgroundColor: Colors.transparent, // Transparent background
        ),
      ),
    );
  }

  Future<List<Recipe>> fetchRecipes() async {
    List<Recipe> recipes = [];
    // Replace with your desired recipe IDs
    for (String id in ['1', '2', '3', '4']) {
      try {
        Recipe recipe = await ApiService.instance.fetchRecipe(id);
        recipes.add(recipe);
      } catch (e) {
        print(
            'Error fetching recipe with id $id: $e'); // Log error for debugging
      }
    }
    return recipes;
  }
}
