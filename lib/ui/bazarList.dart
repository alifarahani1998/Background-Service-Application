import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:notification/ui/FruitPage.dart';



class Bazaar extends StatelessWidget {

  List name = ['میوه', 'فرنگی', 'حبوبات غیر شرکتی', 'قارچ', 'برنج', 'گوشت'];
  List imagePath = [
    'assets/images/fruits.jpg',
    'assets/images/vegetable.jpg',
    'assets/images/beans.jpg',
    'assets/images/mushroom.jpg',
    'assets/images/rice.jpg',
    'assets/images/meat.jpg'];





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "نرخ نامه محصولات"
        ),
      ),

      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: name.length * 2,
          itemBuilder: (BuildContext context, int position) {
            if (position.isOdd)
              return Padding(
                padding: EdgeInsets.only(top: 20),
                child: Divider(thickness: 2,),
              );
            int index = position ~/ 2;
            return Padding(
              padding: EdgeInsets.only(top: 20),
              child: ListTile(
                onTap: () {
                  if (name[index] == "میوه")
                    Navigator.push(context,
                    MaterialPageRoute(
                      builder: (con) => FruitPage()
                    ));
                },
                leading: Icon(Icons.arrow_back_ios, color: Colors.grey.shade400,),
                title: Text(
                  name[index],
                  style: TextStyle(
                      fontSize: 20
                  ),
                  textAlign: TextAlign.right,

                ),
                trailing: CircleAvatar(
                  backgroundImage: ExactAssetImage(imagePath[index]),
                  backgroundColor: Colors.transparent,
                  radius: 30,
                ),
              ),
            );
          },




        )
      ),
    );
  }
}