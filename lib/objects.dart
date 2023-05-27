import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'main.dart';

void editData(Map editedData, int index){
  storedData['list'][index] = editedData;
}

Widget window(Map subInfo){
  if(subInfo['other info'] != ""){ 
    return showText(subInfo['other info'], scale: 1.3, align: TextAlign.center);
  }else{
    return showText('(no other notes given)', scale: 1.3, align: TextAlign.center);
  }
}

Widget dashFix(){
  if(storedData['list'].length == 0){
    return showText(
      'Press the button on the bottom-right to add your first subscription.', 
      align: TextAlign.center,
      scale: 1.6
    );
  }else{  
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
      showText("NEXT PAYMENT", scale: 1.5),
      showText(getEarliest()[0], scale: 2.6),
      showText(getEarliest()[1], scale: 1.7),
    ]);
  }
}

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

DateTime nextPayment(Map subInfo){
  DateTime today = DateTime.now();
  DateTime start = dateFormatter.parse(subInfo['date']);
  String unit = subInfo['period'][1];
  int rep = subInfo['period'][0];
  if(unit == 'day'){
    while(today.isAfter(start)){
      start = DateTime(start.year, start.month, start.day + rep);
    }
    return start;
  }
  if(unit == 'week'){
    /*
    int day = start.weekday;
    int todayDay = today.weekday;
    if(todayDay < day){
      return today.add(Duration(days: day-todayDay));
    }else{
      return today.add(Duration(days: (7-todayDay+day)));
    }
    */
    while(today.isAfter(start)){
      start = DateTime(start.year, start.month, start.day + 7*rep);
    }
    return start;
  }
  if(unit == 'month'){
    /*
    int subDay = start.day;
    int todayDay = today.day;
    if(todayDay < subDay){
      return DateTime(today.year, today.month, subDay);
    }else{
      return DateTime(today.year, today.month + 1, subDay);
    }
    */
    while(today.isAfter(start)){
      start = DateTime(start.year, start.month + rep, start.day);
    }
    return start;
  }
  if(unit == 'year'){
    while(today.isAfter(start)){
      start = DateTime(start.year + rep, start.month, start.day);
    }
    return start;
  }
  if(unit == 'decade'){
    while(today.isAfter(start)){
      start = DateTime(start.year + 10*rep, start.month, start.day);
    }
    return start;
  }
  if(unit == 'century'){
    while(today.isAfter(start)){
      start = DateTime(start.year + 100*rep, start.month, start.day);
    }
    return start;
  }
  return today;
}

List<String> getEarliest(){
  List<DateTime> datelist = [];
  for(int x = 0; x<storedData['list'].length; x++){
    datelist.add(nextPayment(storedData['list'][x]));
  }
  DateTime earliest = datelist[0];
  int earliestIndex = 0;
  for(int x = 0; x<datelist.length; x++){
    if(datelist[x].isBefore(earliest)){
      earliest = datelist[x];
      earliestIndex = x;
    }
  }
  return [dateFormatter.format(earliest), storedData['list'][earliestIndex]['name']];
}

//call this function in any part of your function if you want to show a message window.
Future messageWindow(BuildContext context, String title, String body, {double scale = 1.3, TextAlign align = TextAlign.left}){
  return showDialog(
    context: context, 
    builder: (builder)=>AlertDialog(
      title: showText(title, scale: 1.5),
      content: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: showText(body, scale: scale, align: align)
      ),
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

String priceFormat(List<dynamic> list){
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
    overflow: TextOverflow.fade,
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
Color list2col(List<dynamic> list){
  return Color.fromARGB(list[0], list[1], list[2], list[3]);
}


//converts a color to a list
List<int> col2list(Color col){
  return [col.alpha, col.red, col.green, col.blue];
}

String aboutParagraph = 
"""
This is an app that tracks your financial subscriptions. Subscriptions be daily, monthly, yearly or any other custom period. The app will then show the average total expenditure for the month, along with other data. 

To add a subscription, tap the circular button on the bottom right area of the screen, and fill in the details. 

Subscriptions are laid out below the dashboard as a list of cards with your choice of colors.

To delete a subscription, click on the subscription card and press DELETE.
""";

String helpParagraph = 
"""
SUBSCRIPTION NAME
Give a name for this subscription.

PRICE
Prices must be numerical, decimals allowed but no commas please.

PAYMENT MADE EVERY
2 values: 'Number' and 'Unit'.
If Number = 2, Unit = 'month', 
payment is made every 2 months.
Number is usually 1 unless used for irregular intervals, such as school semesters, which can be 4-5 months long.

SUBSCRIPTION START DATE
Used to calculate when the next payment is. Defaults to today, but to choose another date, tap CHANGE DATE.

OTHER NOTES
Used to store more information about this payment, such as passwords or reminders. Once subscription is created, tap on its card to show this information.

CARD COLOR
All the subscriptions are shown as cards. Tap this button to change the color of the card representing this particular subscription.
""";