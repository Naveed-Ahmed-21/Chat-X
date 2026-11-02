import 'package:flutter/material.dart';

PreferredSize myTabBar(TabController tabController, BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(50),
    child: Container(
      padding: const EdgeInsets.all(10),
      child: TabBar(
        indicatorWeight: 3,
        unselectedLabelStyle: Theme.of(context).textTheme.labelMedium,
        labelStyle: Theme.of(context).textTheme.bodyLarge,
        dividerColor: Colors.transparent,
        controller: tabController,
        tabs: const [Text('Chats'), Text('Groups')],
      ),
    ),
  );
}
