import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

double monthly(Map storedData){
  DateTime todayDate = DateTime.now();
  double total = 0;
  for(int x = 0; x<storedData['list'].length; x++){
    double price = storedData['list'][x]['price'];
    int number = storedData['list'][x]['period'][0];
    String unit = storedData['list'][x]['period'][1];
    if(unit == 'day'){
      int daysinMonth = DateUtils.getDaysInMonth(todayDate.year, todayDate.month);
      total = total + (price/number)*daysinMonth;
      continue;
    }
    if(unit == 'week'){
      total = total + (price/number)*4;
      continue;
    }
    if(unit == 'month'){
      total = total + price/number;
      continue;
    }
    if(unit == 'year'){
      total = total + price/(number*12);
      continue;
    }
    if(unit == 'decade'){
      total = total + price/(number*12*10);
      continue;
    }
    if(unit == 'century'){
      total = total + price/(number*12*100);
      continue;
    }
  }
  return total;
}

/*
String nextPayment(Map subInfo){
  DateTime today = DateTime.now();
  DateTime start = dateFormatter.parse(subInfo['date']);
  int number = subInfo['period'][0];
  String unit = subInfo['period'][1];
  if(unit == 'day'){
    return dateFormatter.format(today.add(Duration(days: number)));
  }
  if(unit == 'week'){
    return dateFormatter.format(start.add(Duration(days: 7*number)));
  }
  if(unit == 'month'){
    total = total + price/number;
    continue;
  }
  if(unit == 'year'){
    total = total + price/(number*12);
    continue;
  }
  if(unit == 'decade'){
    total = total + price/(number*12*10);
    continue;
  }
  if(unit == 'century'){
    total = total + price/(number*12*100);
    continue;
  }
}
*/

//call this function in any part of your function if you want to show a message window.
Future messageWindow(BuildContext context, String title, String body){
  return showDialog(
    context: context, 
    builder: (builder)=>AlertDialog(
      title: showText(title, scale: 1.5),
      content: showText(body, scale: 1.3),
      actions: [
        TextButton(
          onPressed: closeWindowFunc(context),
          child: showText('CLOSE', scale: 2),
        )
      ],
    )
  );
}

Color darklighttext(Color bg){
  return bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

String priceFormat(List<Object> list){
  if(list[0] != 1){
    return "/ ${list[0]} ${list[1]}s";
  }else{
    return "/${list[1]}";
  }
}

//creates a BoxBorder, usually for boxdecorations.
BoxBorder border(Color col, {double width = 3}){
  return Border.all(
    color: col,
    strokeAlign: BorderSide.strokeAlignOutside,
    width: width,
  );
}

//creates a good list of BoxShadows
List<BoxShadow> shadow({Color col = Colors.black54, double thickness = 10}){
  return [BoxShadow(
      blurRadius: thickness,
      color: col,
      offset: Offset(thickness/2, thickness/2),
    ),
  ];
}

//returns a lighter shade of a given color
Color lighterCol(Color col, {int alpha = 75}){
  return Color.fromARGB(alpha, col2list(col)[1], col2list(col)[2], col2list(col)[3]);
}

//returns Text in a specified font
Text showText (String text, {
  double spacing = 0, 
  double scale = 1, 
  Color col = Colors.black, 
  String font = 'Wix',
  TextAlign align = TextAlign.left,
}) {
  return Text(
    text,
    textAlign: align,
    textScaleFactor: scale,
    style: TextStyle(
      color: col,
      fontFamily: font,
      letterSpacing: spacing,
    ),
  );
}

//Closes whatever the current window is.
void Function()? closeWindowFunc(BuildContext context){
  return ()=>Navigator.of(context).pop();
}

void closeWindow(BuildContext context){
  return Navigator.of(context).pop();
}

JsonCodec json = const JsonCodec();

//converts a map to a string
String map2str(Map object){
  return json.encode(object);
}

//converts a string to a map
Map str2map(String s){
  return json.decode(s);
}

//converts a list to a color
Color list2col(List<int> list){
  return Color.fromARGB(list[0], list[1], list[2], list[3]);
}


//converts a color to a list
List<int> col2list(Color col){
  return [col.alpha, col.red, col.green, col.blue];
}

String aboutParagraph = 
"""
This is an app that tracks your financial subscriptions. Subscriptions be daily, monthly, yearly or any other custom period. The app will then show the total expenditure for the month, along with other data.

To add a subscription, tap the circular button on the bottom right area of the screen, and fill in the details. 

To delete, click on the subscription card and press DELETE.
""";