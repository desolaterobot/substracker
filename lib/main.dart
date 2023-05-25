import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'objects.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

late GetStorage box;
var dateFormatter = DateFormat('dd-MMM-yyyy');


Map storedData = {
  "appTheme" : [255, 57, 77, 187],
  "list": [
    {
      "name" : "HBO Max", 
      "price" : 11.98,
      "period" : [1, "month"],
      "color" : col2list(Colors.lime),
      "date" : '13-Aug-2004',
      "other info" : "This is the HBO MAX subscription",
    },
    {
      "name" : "Netflix",
      "price" : 12.95,
      "period" : [1, "week"],
      "color" : [255, 45, 142, 77],
      "date" : '22-Dec-2001',
      "other info" : "This is the Netflix subscription",
    },
    {
      "name" : "Amazon Prime",
      "price" : 4.90,
      "period" : [1, "day"],
      "date" : '15-Nov-2014',
      "color" : [255, 4, 55, 89],
      "other info" : "This is the Amazon Prime subscription.",
    },
    {
      "name" : "Salary",
      "price" : -1500,
      "period" : [1, "month"],
      "date" : '15-Nov-2014',
      "color" : [255, 253,67,99],
      "other info" : "oh my gosh",
    },
  ],
};

Map initialData = {
  "appTheme" : [255, 63, 81, 181],
  "list" : [],
};

void main() async {
  await GetStorage.init();
  box = GetStorage();
  if(box.read('key') == null){
    box.write('key', initialData);
  }
  storedData = box.read('key');
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color themeColor = list2col(storedData["appTheme"]);
  late Color lighterTheme = lighterCol(themeColor);

  void saveInfo(){
    box.write('key', storedData);
  }

  //function for adding subscription
  void addSub(String name, double price, int number, String period, Color color, String otherInfo, DateTime startSub,
  {int? index}){
    setState(() {
      Map<String, Object> toAdd = {
        'name' : name,
        'price' : double.parse(price.toStringAsFixed(2)),
        'period' : [number, period],
        'color' : col2list(color),
        'date' : dateFormatter.format(startSub),
        'other info' : otherInfo,
      };
      saveInfo();
      if(index != null){
        storedData['list'][index] = toAdd;
      }else{
        storedData['list'].add(toAdd);
      }
    });
  }

  //function for removing subsctiption
  void removeSub(String name){
    setState(() {
      for(int x = 0; x<storedData['list'].length; x++){
        if(storedData['list'][x]['name'] == name){
          storedData['list'].removeAt(x);
          saveInfo();
          return;
        }
      }
      saveInfo();
      return;
    });
  }

  //fucntion to change system color.
  void changeCol(Color col){ 
    setState(() {
      themeColor = col; //set the global themeColor to the set color,
      storedData["appTheme"] = col2list(col); //then store it into storedData
      saveInfo();
    });
  }

  //ADD SUBSCRIPTION WINDOW
  Future<dynamic> addWindow(BuildContext context, {Map sub = const {}, int? index}){
    String name = '';
    double price = 0;
    int number = 1;
    String period = 'month';
    Color color = const Color.fromARGB(255, 202, 202, 202);
    DateTime startSub = DateTime.now();
    String otherInfo = "";

    String windowTitle = "Create new subscription";
    String buttonTitle = 'ADD';

    TextEditingController nameCont =  TextEditingController();
    TextEditingController priceCont =  TextEditingController();
    TextEditingController otherInfoCont = TextEditingController();

    if(index != null){
      name = sub['name'];
      price = sub['price'];
      number = sub['period'][0];
      period = sub['period'][1];
      color = list2col(sub['color']);
      startSub = dateFormatter.parse(sub['date']);
      otherInfo = sub['other info'];
      windowTitle = 'Edit $name';

      nameCont.text = name;
      priceCont.text = price.toString();
      otherInfoCont.text = otherInfo;
      
      buttonTitle = 'EDIT';
    }

    void pickDate(){ //display date picker
      showDatePicker(
        context: context, 
        initialDate: DateTime.now(), 
        firstDate: DateTime(1970), 
        lastDate: DateTime.now(),
      ).then((value){
        setState(() {
          startSub = value!;
        });
      });
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => AlertDialog(
        title: showText(windowTitle, scale: 1),
        content: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              TextField( //NAME TEXTFIELD
                controller: nameCont,
                decoration: const InputDecoration(
                  labelStyle: TextStyle(
                    fontFamily: 'Wix'
                  ),
                  labelText: 'Subscription name',
                ),
              ),
              TextField( //PRICE TEXTFIELD
                controller: priceCont,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelStyle: TextStyle(
                    fontFamily: 'Wix'
                  ),
                  labelText: 'Price',
                ),
              ),
              const SizedBox(height: 20),
              //showText('PAYMENT INTERVAL'),
              SizedBox( //MONTH TEXT FIELD
                height: 60,
                width: 145,
                child: DropdownButton<String>(
                  iconSize: 50,
                  isExpanded: true,
                  style: TextStyle(color: themeColor, fontSize: 20),
                  value: period,
                  underline: Container(height: 2, color: themeColor),
                  items: [
                    DropdownMenuItem(child: showText('daily'), value: 'day'),
                    DropdownMenuItem(child: showText('weekly'), value: 'week'),
                    DropdownMenuItem(child: showText('monthly'), value: 'month'),
                    DropdownMenuItem(child: showText('yearly'), value: 'year'),
                    DropdownMenuItem(child: showText('decadely'), value: 'decade'),
                    DropdownMenuItem(child: showText('centurily'), value: 'century'),
                  ],
                  onChanged: (String? value){
                    setState(() {
                      period = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox( //CARD COLOR BUTTON
                height: 50,
                width: 250,
                child: ElevatedButton(
                  onPressed: (){ 
                    showDialog(
                      context: context, 
                      builder: (context) => AlertDialog(
                        title: showText('Choose a color for the card.'), //this window has this title
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ColorPicker( //with a color picker inside.
                              pickerColor: color,
                              onColorChanged: (col)=>{
                                setState(() {
                                  color = col;
                                })
                              },
                            ),
                            SizedBox(
                              width: 175.0,
                              height: 50.0,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey[200]
                                ),
                                onPressed: closeWindowFunc(context),
                                child: showText('SELECT COLOR', scale: 1.3, col: Colors.black)
                              ),
                            ),
                          ],
                        ),
                      )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                  ),
                  child: showText('CARD COLOR', scale: 1.5, col: darklighttext(color)), 
                ),
              ),
              const SizedBox(height: 20),
              showText('SUBSCRIPTION START DATE'),
              const SizedBox(height:4),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  showText(dateFormatter.format(startSub), scale: 1.5),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 150,
                    height: 35,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[200],
                      ),
                      onPressed: ()=>{
                        showDatePicker(
                          context: context, 
                          initialDate: DateTime.now(), 
                          firstDate: DateTime(1970), 
                          lastDate: DateTime.now(),
                        ).then((value){
                          setState(() {
                            startSub = value!;
                          });
                        })
                      },
                      child: showText('CHANGE DATE', scale: 1.15),
                    )
                  )
                ],
              ),
              const SizedBox(height: 20),
              TextField( //OTHER NOTES TEXT FIELD
                controller: otherInfoCont,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'usernames, passwords or whatever...',
                  labelStyle: TextStyle(
                    fontFamily: 'Wix'
                  ),
                  labelText: 'Other notes',
                ),
              )
            ],)
          ),
        actions: [
            TextButton(
              onPressed: (){
                name = nameCont.text;
                if(name == ''){
                  messageWindow(context, 'Invalid Input', 'Please enter a name.');
                  return;
                }
                if(num.tryParse(priceCont.text) == null){
                  messageWindow(context, 'Invalid Input', 'Price must be numerical and non-zero.');
                  return;
                }
                price = double.parse(priceCont.text);
                if(num.parse(priceCont.text) == 0){
                  messageWindow(context, 'Invalid Input', 'Price must be non-zero.');
                  return;
                }
                otherInfo = otherInfoCont.text;
                if(index != null){
                  addSub(name, price, number, period, color, otherInfo, startSub, index: index);
                  closeWindow(context);
                  closeWindow(context);
                }else{
                  addSub(name, price, number, period, color, otherInfo, startSub);
                  closeWindow(context);
                }
              },
              child: showText(buttonTitle, scale: 2.3),
            ),
          ],
        )
      )
    );
  }

  //CARD LIST BUILDER
  List<InkWell> cardList(){
    List<InkWell> answer = [];
    for(int x = 0; x<storedData['list'].length; x++){
      answer.add(
        singleCard(storedData['list'][x])
      );
    }
    return answer;
  }

  //CARD
  InkWell singleCard(Map subInfo){
    Color colA = list2col(subInfo['color']);
    Color colB = darklighttext(colA);
    return InkWell(
      hoverColor: lighterCol(themeColor, alpha: 70),
      splashColor: colA,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        alignment: Alignment.center,
        height: 180,
        width: 300,
        decoration: BoxDecoration(
          color: colA,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black54,
              offset: Offset(5, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 0
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    showText(subInfo['name'], scale: 1.8, col: colB),
                    showText(("\$${subInfo['price']}"), scale: 3, col: colB),
                    showText(priceFormat(subInfo['period']), scale: 1.4, col: colB),
                    const SizedBox(height: 15),
                    showText(subInfo['date'], col: colB, scale: 1.2),
                  ],
                ),
              ),
              /*
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: SingleChildScrollView(
                      child: showText(
                        subInfo['other info'], 
                        scale: 1.2, 
                        align: TextAlign.right,
                        col: darklighttext(colA)
                      ),
                  )
                ),
              ),
              */
            ],
          ),
        )
      ),
      onTap: ()=>showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: showText(subInfo['name'], scale: 1.5, align: TextAlign.center),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(child: window(subInfo)),
                const SizedBox(height: 20),
                Divider(thickness: 2, color:  lighterCol(themeColor)),
                const SizedBox(height: 20),
                showText('NEXT PAYMENT', scale: 1.4),
                showText(dateFormatter.format(nextPayment(subInfo)), scale: 2),
                showText(DateFormat('EEEE').format(nextPayment(subInfo)), scale: 1.6),
              ]
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: 
              [
                TextButton( //DELETE BUTTON
                  onPressed: ()=>showDialog(
                    context: context, builder: (context) => AlertDialog(
                      title: showText('Are you sure?', scale: 1.6),
                      content: showText('You are about to remove ${subInfo['name']}.', scale: 1.4),
                      actions: [
                        TextButton(
                          onPressed: (){
                            removeSub(subInfo['name']);
                            closeWindow(context);
                            closeWindow(context);
                          },
                          child: showText("YES, I'M SURE", scale: 2, col: const Color.fromARGB(255, 235, 25, 10))
                        ),
                      ],
                    )
                  ),
                  child: showText("DELETE", scale: 1.5, col: const Color.fromARGB(255, 235, 25, 10))
                ),
                const SizedBox(width: 5),
                TextButton( //EDIT BUTTON
                  onPressed:()=>addWindow(context, sub: subInfo, index: storedData['list'].indexOf(subInfo)),
                  child: showText("EDIT", scale: 1.5)
                ),
                const SizedBox(width: 5),
                TextButton( //CLOSE BUTTON
                  onPressed: closeWindowFunc(context),
                  child: showText("CLOSE", scale: 1.5)
                ),
              ],
            )
          ]
        ),
      )
    );
  }

  //HELP WINDOW
  Future<dynamic> helpWindow(BuildContext context){ 
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: showText("What is this?"), //this is the title
        content: ListView(
          shrinkWrap: true,
          children: [
            showText(aboutParagraph, scale: 0.9, align: TextAlign.center),
            SizedBox(
              width: 100,
              height: 50,
              child: ElevatedButton( //button for changing color
                onPressed:(){ 
                  showDialog(
                    context: context, 
                    builder: (context) => AlertDialog(
                      title: showText('Choose a color!'), //this window has this title
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ColorPicker( //with a color picker inside.
                            pickerColor: list2col(storedData['appTheme']),
                            onColorChanged: changeCol,
                          ),
                          SizedBox(
                            width: 175.0,
                            height: 50.0,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey[200],
                              ),
                              onPressed: ()=>Navigator.of(context).pop(),
                              child: showText('SELECT COLOR', scale: 1.3, col: Colors.black)
                            ),
                          ),
                        ],
                      ),
                    )
                  );
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[200]
                ),
                child: showText('CHANGE COLOR THEME', scale: 1.2, col: Colors.black)
              ),
            ),
          ] 
        ),
        actions: [
          TextButton(
              onPressed: ()=>Navigator.of(context).pop(),
              child: showText("CLOSE", scale: 1.6),
          ),
        ],
      ),
    );
  }

  //DASHBOARD
  Container dashboard(){
    return Container(
      margin: const EdgeInsets.all(30),
      alignment: Alignment.center,
      height: 280,
      width: 300,
      decoration: BoxDecoration(
        boxShadow: shadow(),
        border: border(themeColor),
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          showText("EXPENDITURE", scale: 1.5),
          FittedBox(child: showText('\$${double.parse(monthly(storedData).toStringAsFixed(2))}/month', scale: 2.4)),
          FittedBox(child: showText('\$${double.parse((monthly(storedData)*12).toStringAsFixed(2))}/year', scale: 1.7)),
          const SizedBox(height: 15),
          Divider(color: lighterCol(themeColor, alpha: 100), thickness: 2),
          const SizedBox(height: 15),
          dashFix(),
        ]),
      ),
    );
  }

  //SCAFFOLD
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: lighterCol(themeColor),
        appBar: AppBar(
          backgroundColor: themeColor,
          title: showText('Track Subscriptions', scale: 1.1, col: darklighttext(themeColor), font: 'Wix'),
          actions: [IconButton(onPressed: ()=>helpWindow(context), 
          icon: Icon(Icons.question_mark, color: darklighttext(themeColor)))
          ],
          bottomOpacity: 0.5,
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            dashboard(),
            showText("${storedData['list'].length} TOTAL SUBSCRIPTIONS", scale: 1.3, col: Colors.white24, align: TextAlign.center),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              verticalDirection: VerticalDirection.up,
              children: cardList(),
            ),
        ]),
        floatingActionButton: FloatingActionButton(
          backgroundColor: themeColor,
          onPressed: (){addWindow(context);},
          tooltip: 'Add new subscription',
          child: Icon(Icons.add, color: darklighttext(themeColor)),
        ),
      ),
    );
  }
}