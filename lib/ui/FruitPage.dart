import 'package:flutter/material.dart';


class FruitPage extends StatelessWidget {



  List name = ['آناناس جنگلی', 'هلو', 'انار', 'هندوانه', 'گیلاس', 'انبه'];
  List imagePath = [
    'assets/images/pineapple.jpg',
    'assets/images/peach.jpg',
    'assets/images/anar.jpg',
    'assets/images/watermelon.jpg',
    'assets/images/gilas.jpg',
    'assets/images/anbe.jpg'];





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "میوه"
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
                  onTap: () => print(name[index]),
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