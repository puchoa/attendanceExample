import 'package:flutter/material.dart';
import 'package:attend_app/blocs/attendancebloc.dart';
import 'package:provider/provider.dart';
import 'package:attend_app/screens/loginscreen.dart';
import 'package:attend_app/screens/setupcamerascreen.dart';
import 'package:attend_app/screens/setupattendancescreen.dart';
import 'package:attend_app/SizeConfig.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:attend_app/screens/student_dash.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  TextEditingController classNameCtrl = TextEditingController();
  static int index;

  Widget _buildRow(int id, String className, bool completed, int n) {
    AttendanceBloc bloc = Provider.of<AttendanceBloc>(context);
    return new Slidable(
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        color: Colors.white,
        child: new RadioListTile(
          title: new Text(className),
          value: n,
          groupValue: index,
          onChanged: (int val) {
            setState(() {
              index = val;
            });
            print(bloc.my_classes[index].class_name);
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
            caption: 'Edit',
            color: Colors.blue,
            icon: Icons.edit,
            onTap: () {
              classNameCtrl = new TextEditingController();
              classNameCtrl.text = className;
              Alert(
                  context: context,
                  title: "Edit Class name",
                  content: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Class name',
                        ),
                        controller: classNameCtrl,
                      ),
                    ],
                  ),
                  buttons: [
                    DialogButton(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24),
                      ),
                      color: Color.fromRGBO(255, 98, 65, 1),
                      onPressed: () async {
                        bool s = await bloc.editClassName(
                            classNameCtrl.text, id.toString(), n);
                        if (s == true) {
                          Navigator.pop(context);
                        }
                      },
                    )
                  ]).show();
            }),
        new IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              Alert(context: context, title: "Are you Sure?", buttons: [
                DialogButton(
                  child: Text(
                    "Delete",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24),
                  ),
                  color: Color.fromRGBO(255, 98, 65, 1),
                  onPressed: () async {
                    bool s = await bloc.deleteClass(id.toString(), n);
                    if (s == true) {
                      Navigator.pop(context);
                    }
                  },
                )
              ]).show();
            }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    AttendanceBloc bloc = Provider.of<AttendanceBloc>(context);

    SizeConfig().init(context);

    var hor = SizeConfig.safeBlockHorizontal;
    var ver = SizeConfig.safeBlockVertical;

    if (bloc.myAccount.admin == true) {
      return Scaffold(
          backgroundColor: Color.fromRGBO(240, 242, 244, 1),
          body: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(hor * 7, ver * 12, 0, ver * 3),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          color: Colors.white,
                          elevation: 3,
                          child: Container(
                            width: hor * 90,
                            height: ver * 60,
                            child: new ListView.builder(
                              itemCount: bloc.my_classes.length,
                              itemBuilder: (context, n) {
                                return _buildRow(bloc.my_classes[n].id,
                                    bloc.my_classes[n].class_name, false, n);
                              },
                            ),
                          )),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: hor * 4),
                        child: new GestureDetector(
                          child: new Container(
                            width: hor * 90,
                            height: ver * 10,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              color: Color.fromRGBO(255, 98, 65, 1),
                              elevation: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "CREATE A CLASS",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24),
                                  )
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            classNameCtrl = new TextEditingController();
                            classNameCtrl.text = "";
                            Alert(
                                context: context,
                                title: "Add a Class",
                                content: Column(
                                  children: <Widget>[
                                    TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Class name',
                                      ),
                                      controller: classNameCtrl,
                                    ),
                                  ],
                                ),
                                buttons: [
                                  DialogButton(
                                    child: Text(
                                      "Submit",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24),
                                    ),
                                    color: Color.fromRGBO(255, 98, 65, 1),
                                    onPressed: () async {
                                      bool s = await bloc
                                          .addClass(classNameCtrl.text);

                                      if (s == true) {
                                        Navigator.pop(context);
                                      }
                                    },
                                  )
                                ]).show();
                          },
                        )),
                    Padding(
                        padding: EdgeInsets.only(top: hor * 4),
                        child: new GestureDetector(
                          child: new Container(
                            width: hor * 90,
                            height: ver * 10,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              color: Color.fromRGBO(255, 98, 65, 1),
                              elevation: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "TAKE ATTENDANCE",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24),
                                  )
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            if (index != null) {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (context, anim1, anim2) =>
                                        AttendanceSetup(
                                            class_id:
                                                bloc.my_classes[index].id,
                                                class_Name: bloc.my_classes[index].class_name),),
                              );
                            } else {
                              Alert(
                                  context: context,
                                  title: "Please select a class",
                                  buttons: [
                                    DialogButton(
                                      child: Text(
                                        "OK",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24),
                                      ),
                                      color: Color.fromRGBO(255, 98, 65, 1),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    )
                                  ]).show();
                            }
                          },
                        )),
                    Padding(
                        padding: EdgeInsets.only(top: hor * 4, bottom: ver * 4),
                        child: new GestureDetector(
                          child: new Container(
                            width: hor * 90,
                            height: ver * 10,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              color: Color.fromRGBO(255, 98, 65, 1),
                              elevation: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "SIGN OFF",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24),
                                  )
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            bloc.logout();
                            Navigator.of(context).pushReplacement(
                                new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        LoginScreen()));
                          },
                        ))
                  ],
                ),
              ),
            ],
          )));
    } else {
      return Student_Dash();
    }
  }
}
