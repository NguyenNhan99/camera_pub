part of pub_camera;


class PreviewScreen extends StatefulWidget {
   String imgPath;
   bool compress;
   ValueChanged<File> fileImage;

  PreviewScreen({this.fileImage,this.imgPath, this.compress = false});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  File cropped;
  bool check = false;
  // final List<List<double>> filters = [
  //   SEPIA_MATRIX,
  //   GREYSCALE_MATRIX,
  //   VINTAGE_MATRIX,
  //   SWEET_MATRIX,
  //   SWEET_MATRIX1,
  //   BLACK_WHITE
  // ];
  final GlobalKey _globalKey = GlobalKey();
  // Uint8List imageData;
  int indexs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.compress == true) {
      compressImage(widget.imgPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              (cropped == null) ?Positioned.fill(
                  child: Image.file(File(widget.imgPath),fit: BoxFit.cover,))
                  :Positioned(
                top: 150,
                bottom: 150,
                child: Image.file(
                  File(cropped.path),
                  width: 500,
                  height: 500,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                top: 0,
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black12.withOpacity(0.5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.clear,
                            color: Colors.white,
                          )),
                      Spacer(),
                      GestureDetector(
                          onTap: () {
                            cropImage(widget.imgPath);
                          },
                          child: Icon(
                            Icons.crop,
                            color: Colors.white,
                          )),
                      SizedBox(
                        width: 15,
                      ),
                    ],
                  ),
                ),
              ),
              // Positioned(
              //   bottom: 150,
              //   child: (check != false)
              //       ? Container(
              //           height: 100,
              //           width: MediaQuery.of(context).size.width,
              //           color: Colors.black12.withOpacity(0.5),
              //           child: RepaintBoundary(
              //             key: _globalKey,
              //             child: ListView.builder(
              //                 scrollDirection: Axis.horizontal,
              //                 itemCount: filters.length,
              //                 itemBuilder: (context, index) {
              //                   return GestureDetector(
              //                     onTap: () {
              //                       // convertWidgetToImage();
              //
              //                       setState(() {
              //                         indexs = index;
              //                       });
              //                     },
              //                     child: Padding(
              //                       padding: const EdgeInsets.all(8.0),
              //                       child: ColorFiltered(
              //                         colorFilter:
              //                             ColorFilter.matrix(filters[index]),
              //                         child: Image.file(
              //                           File(widget.imgPath),
              //                           width: 80,
              //                         ),
              //                       ),
              //                     ),
              //                   );
              //                 }),
              //           ))
              //       : SizedBox.shrink(),
              // ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black12.withOpacity(0.5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              check = !check;
                            });
                          },
                          child: Icon(
                            Icons.filter,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),
              ),
              Positioned(
                  bottom: 25,
                  right: 15,
                  child: GestureDetector(
                    onTap: () {
                      if (cropped != null) {
                        widget.fileImage(File(cropped.path));
                      } else {
                        widget.fileImage(File(widget.imgPath));
                      }
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(
                                50.0) //                 <--- border radius here
                            ),
                      ), //             <--- BoxDecoration here
                      child: Center(
                        child: Icon(
                          Icons.send_sharp,
                          color: Colors.blue,
                          size: 35,
                        ),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Future cropImage(String patch) async {
    cropped = await ImageCropper.cropImage(
        sourcePath: patch,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        maxWidth: 700,
        maxHeight: 700,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: "Cắt ảnh",
          // toolbarColor: Colors.deepOrange,
          // statusBarColor: Colors.deepOrange.shade900,
          backgroundColor: Colors.white,
        ));
    print(cropped.path);
    this.setState(() {
      widget.imgPath = cropped.path;
    });
  }

  void compressImage(String patch) async {
    final filePath = patch;
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    final compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath, outPath,
        minWidth: 1000, minHeight: 1000, quality: 20);
    this.setState(() {
      widget.imgPath = compressedImage.absolute.path;
    });
  }

  // void convertWidgetToImage() async {
  //   RenderRepaintBoundary repaintBoundary = indexs as RenderRepaintBoundary;
  //   ui.Image boxImage = await repaintBoundary.toImage(pixelRatio: 1);
  //   ByteData byteData = await boxImage.toByteData(format: ui.ImageByteFormat.png);
  //   Uint8List uint8list = byteData.buffer.asUint8List();
  //   print(uint8list);
  //   // Get.to(FilterScreen(
  //   //  imageData: uint8list,
  //   // ));
  //
  //
  //   // Navigator.of(_globalKey.currentContext).push(MaterialPageRoute(
  //   //     builder: (context) => FilterScreen(
  //   //       imageData: uint8list,
  //   //     )));
  // }
}
