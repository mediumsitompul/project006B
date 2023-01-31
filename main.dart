import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:io/io.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'upload_success.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Upload Image & Data to MySql/Server\n                (Multipart Request)')),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: const ImageUpload(),
    ));
  }
}

class ImageUpload extends StatefulWidget {
  const ImageUpload({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ImageUpload();
  }
}

class _ImageUpload extends State<ImageUpload> {
  TextEditingController cTitle = TextEditingController();
  TextEditingController cDescription = TextEditingController();

//=============================================================
  File? pictureFile;

  Future _imageCamera() async{
    try{
      var imageFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if(imageFile==null) return;
      var pictureTemp = File(imageFile.path);

      setState(() {
        pictureFile = File(pictureTemp.path);
      });

    }on PlatformException catch(e){
      print('Failed to pick image: $e');
    }
  }
  //=============================================================

  Future _upload(File imageFile) async {

    var stream = http.ByteStream(DelegatingStream(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse("http://192.168.100.100:8087/flutter01/upload.php");
    var request = http.MultipartRequest("POST", uri);
    var multipartFile = http.MultipartFile("image", stream, length, filename: basename(imageFile.path));
    request.fields['title']=cTitle.text;
    request.fields['description']=cDescription.text;
    request.files.add(multipartFile);
    var response = await request.send();

    if(response.statusCode==200){
      print('Upload Success');
      Navigator.push(this.context, MaterialPageRoute(builder: (context)=>MyApp1()));
    }else{
      print('Upload Failed');
    }




  }
  //=============================================================


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      ListView(
          children: [
            const SizedBox(height: 30,),

            Container(
              height: 70,
              padding: const EdgeInsets.all(8),
              child: ElevatedButton.icon(
                onPressed: () {
                _imageCamera();
                },
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text("TAKE PICTURE"),
              ),
            ),


            //SHOW pictureFile on the SizedBox SCREEN

            Container(
              child: pictureFile==null
              ? Container()
              :
              SizedBox(
                child: Image.file(pictureFile!),
                height: 100,
              ),
            ),




            Container(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: cTitle,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Title',
                ),
              ),
            ),


            Container(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: cDescription,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                ),
              ),
            ),

                  Container(
                    height: 70,
                    padding: const EdgeInsets.all(8),
                      //elese show uplaod button
                      child: ElevatedButton.icon(
                        onPressed: () {
                          print('Image & Data Uploaded');
                          _upload(pictureFile!);
                        },
                        icon: const Icon(Icons.file_upload),
                        label: const Text("UPLOAD IMAGE & DATA"),
                      ),
                    ),
          ],
        )
      );
  }
}
