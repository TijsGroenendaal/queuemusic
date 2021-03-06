import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:queuemusic/common/QueueMusicColor.dart';
import 'package:queuemusic/helper/SnackbarHelper.dart';
import 'package:queuemusic/widgets/QrScannerWidget.dart';
import 'package:queuemusic/widgets/TextFieldWidget.dart';

import '../models/Session.dart';

class JoinWidget extends StatefulWidget {
  const JoinWidget({Key? key}) : super(key: key);

  @override
  _JoinWidgetState createState() => _JoinWidgetState();
}

class _JoinWidgetState extends State<JoinWidget> {
  final TextEditingController sessionCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Join Session"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
          child: SizedBox(
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 10)),
                          backgroundColor: MaterialStateProperty.all(QueueMusicColor.green)
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => QrScannerWidget(sessionCodeController: sessionCodeController)
                          ));
                        },
                        icon: Icon(Icons.camera),
                        label: Text("Scan QR session code")
                      ),
                    ),
                    TextFieldWidget(
                        sessionCodeController,
                        "Type Session code",
                        12,
                        BoolWrapper(true)
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(QueueMusicColor.green750),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 20))
                    ),
                    onPressed: () => _join(),
                    icon: Icon(Icons.login),
                    label: Text("Join")
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
  
  void _join() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("sessions")
        .doc(sessionCodeController.value.text).get();

    print(doc.data());
    if (!doc.exists || doc.get("open") == false || Timestamp.now().compareTo(doc.get("activeUntil")) == 1) {
      SnackbarHelper.deploy(Text("Invalid Session Code"), context);
      return;
    }
    Provider.of<Session>(context, listen: false).joinSession(doc.get("host"), doc.id);
    Navigator.pop(context);
  }
}
