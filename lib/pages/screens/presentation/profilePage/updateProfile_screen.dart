import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
            onPressed: (){
              Get.back();
            },
            icon: Icon(
                Icons.arrow_back_ios
            )
        ),
        title: Text(
          "Update Profile",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),

              ),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {

                                  },
                                  icon: Icon(
                                    Icons.person_add_alt_rounded,
                                    size: 40,
                                  ),
                                )
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 20,),
                          
                          Row(
                            children: [
                              Text(
                                  "Personal Info",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ],
                          ),

                          SizedBox(height: 10,),

                          Row(
                            children: [
                              Text(
                                "Name",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          TextField(
                            decoration: InputDecoration(
                                hintText: "Naveed ",
                                prefixIcon: Icon(Icons.person),
                                fillColor: Theme.of(context).colorScheme.surface,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8),
                                )
                            ),
                          ),
                          SizedBox(height: 10,),

                          Row(
                            children: [
                              Text(
                                "Email",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          TextField(
                            decoration: InputDecoration(
                                hintText: "nav@gmail.com ",
                                prefixIcon: Icon(Icons.email_rounded),
                                fillColor: Theme.of(context).colorScheme.surface,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8),
                                )
                            ),
                          ),
                          SizedBox(height: 10,),

                          Row(
                            children: [
                              Text(
                                "Phone",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          TextField(
                            decoration: InputDecoration(
                                hintText: "9823958274 ",
                                prefixIcon: Icon(Icons.phone),
                                fillColor: Theme.of(context).colorScheme.surface,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8),
                                )
                            ),
                          ),
                          SizedBox(height: 30,),


                          InkWell(
                            onTap: (){

                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.save,
                                        color: Color(0xffFFFFFF) ,
                                      ),
                            
                                      SizedBox(width: 5,),
                            
                                      Text(
                                        "Save",
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
