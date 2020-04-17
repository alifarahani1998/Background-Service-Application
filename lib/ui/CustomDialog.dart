import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class CustomDialog extends StatelessWidget {
  final String description, buttonText;
  final List<String> title;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
  });



  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }



  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        //...bottom card part,
        //...top circlular image part,
        Container(
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
//              Text(
//                title,
//                style: TextStyle(
//                  fontSize: 24.0,
//                  fontWeight: FontWeight.w700,
//                ),
//              ),
//              SizedBox(height: 16.0),
//              Text(
//                description,
//                textAlign: TextAlign.center,
//                style: TextStyle(
//                  fontSize: 16.0,
//                ),
//              ),
              Expanded(
                child: ListView.builder(
                  itemCount: title.length * 2,
                  itemBuilder: (BuildContext context, int position) {
                    if (position.isOdd) return Divider(thickness: 0.5, color: Colors.grey.shade700, indent: 5, endIndent: 5,);
                    final index = position ~/ 2;
                    return ListTile(
                      title: Text(
                        "${title[index]}",
                        textDirection: TextDirection.rtl,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.center,
                child: Center(
                  child: FlatButton(
                    color: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop(); // To close the dialog
                    },
                    child: Text(
                      buttonText,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
//          child: Column(
//            mainAxisSize: MainAxisSize.min,
//            children: <Widget>[
//              Expanded(
//                child: ListView.builder(
//                  itemCount: 2,
//                  itemBuilder: (BuildContext context, int index) {
//                    return ListTile(
//                      title: Text('Gujarat, India'),
//                    );
//                  },
//                ),
//              )
//            ],
//          )
        ),



        Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: CircleAvatar(
            backgroundColor: Colors.red,
            radius: Consts.avatarRadius,
            child: Center(
              child: Text(
                "اطلاعیه ها",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}




class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 50.0;
}