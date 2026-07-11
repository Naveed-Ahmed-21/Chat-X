import 'package:flutter/material.dart';

class NewContactTile extends StatelessWidget {
  final String btnName;
  final IconData icon;
  final VoidCallback ontap;
  const NewContactTile({
    super.key,
    required this.btnName,
    required this.icon,
    required this.ontap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(

      onTap: ontap,

      child: Container(
        padding: EdgeInsets.all(15),
        width: 1000,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Theme.of(context).colorScheme.primary
              ),
              child: Icon(
                      icon,
                size: 30,
              )
            ),

            SizedBox(width: 40,),

            Text(
              btnName,
              style: Theme.of(context).textTheme.bodyLarge,
            )
          ],
        ),
      ),
    );
  }
}
