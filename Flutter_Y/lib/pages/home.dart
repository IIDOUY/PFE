import 'package:easelink/pages/profile_page.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:easelink/pages/profile.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easelink/models/category_model.dart';


// ignore: must_be_immutable
class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  List<CategoryModel> categories = [];

  void _getCategories(){
    categories = CategoryModel.getCategories(); 
  }


  @override
  Widget build(BuildContext context) {
    _getCategories();
    return Scaffold(
      appBar: buildAppBar(context),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _searchField(),
          const SizedBox(height: 40,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                'Hot Services',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ),
              const SizedBox(height: 15,),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(width: 15),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  padding: const EdgeInsets.only(left: 20,right: 20),
                  itemBuilder: (context, index){
                    return Container(
                      width: 150,
                      decoration: BoxDecoration(
                        color: categories[index].boxColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: SvgPicture.asset(categories[index].iconPath),
                            ),
                          ),
                          Text(categories[index].name, style: const TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold),),
                        ]
                        ),

                    );
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }

Container _searchField(){
  return Container(
            margin: const EdgeInsets.only(top: 40,left: 20,right: 20),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(0, 0, 0, 0).withOpacity(0.11),
                  blurRadius: 40, 
                  spreadRadius: 0.0 
                )
              ],
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            child: TextField(
            decoration: InputDecoration(
              filled: true, // accept coloring inside the box
              fillColor: Colors.white, // fill color
              contentPadding: const EdgeInsets.all(15),
              prefixIcon: const Icon(Icons.search, color: Colors.black),
              suffixIcon: const Icon(Icons.filter_list, color: Colors.black),
              hintText: 'Search For Services', // hint text
              hintStyle: const TextStyle(
                color: Color.fromARGB(116, 0, 0, 0),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15), // border radius
                borderSide: BorderSide.none,// border sides 
                ),
  
            ),
          ),
        );
        
}


  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Text(
        "ServiceLink",
        style: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
        ),
        Text(
        
        "All You Need In One Place",
        style: TextStyle(
          color: Color.fromARGB(122, 0, 0, 0),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
        ],
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0.0, // remove shadow
      leading: GestureDetector(
        onTap: () {
          // Add code here to navigate to the profile page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage2()),
                    );
        },
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.person, color: Colors.black),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            // Add code here to navigate to the search page
          },
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_open, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
