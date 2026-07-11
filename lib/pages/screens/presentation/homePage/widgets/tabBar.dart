
import 'package:flutter/material.dart';

PreferredSize myTabBar(TabController tabController, BuildContext context){
  return PreferredSize(
    preferredSize: Size.fromHeight(50),
    child: Container(
      padding: EdgeInsets.all(10),
      child: TabBar(
        indicatorWeight: 3,
        unselectedLabelStyle: Theme.of(context).textTheme.labelMedium,
          labelStyle: Theme.of(context).textTheme.bodyLarge,
          dividerColor: Colors.transparent,
          controller: tabController,
          tabs: [
            Text("Chats"),
            Text("Groups"),
            Text("Calls"),
          ]
      ),
    ),
  );
}
