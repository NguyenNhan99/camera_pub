part of pub_camera;


class ChewieVideo extends StatefulWidget {
  String videoPath;
  final VideoPlayerController videoPlayerController;
  final bool looping;
  final bool autoPlay;
  bool compress;

  ChewieVideo({
    @required this.videoPlayerController,
    this.looping,
    this.autoPlay,
    this.videoPath,
    this.compress = false,
    Key key,
  }) : super(key: key);

  @override
  _ChewieVideoState createState() => _ChewieVideoState();
}

class _ChewieVideoState extends State<ChewieVideo> {
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      aspectRatio: 1.0,
      autoInitialize: true,
      autoPlay: widget.autoPlay,
      looping: widget.looping,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _chewieController.dispose();
    widget.videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SafeArea(
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  Positioned(
                    top: 50,
                    bottom: 100,
                    child: Chewie(
                      controller: _chewieController,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey.withOpacity(0.5),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                              onTap: () {
                                widget.videoPlayerController.pause();
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.clear,
                                color: Colors.white,
                              )),
                          Spacer(),
                          SizedBox(
                            width: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey.withOpacity(0.5),
                      child: Row(
                        children: [
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 25,
                      right: 15,
                      child: GestureDetector(
                        onTap: (){
                          //print('video ${widget.videoPath}');
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
          )
        // Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Chewie(
        //     controller: _chewieController,
        //   ),
        // ),
      ),
    );
  }

  Future video() async{

    // final thumbnailFile = await VideoCompress.getFileThumbnail(
    //     widget.videoPath,
    //     quality: 40, // default(100)
    //     position: -1 // default(-1)
    // );
    if(widget.compress == true){
      final info = await VideoCompress.compressVideo(
        widget.videoPath,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      //Get.to(() => ChewieVideo(videoPlayerController: VideoPlayerController.file(File(info.path)),autoPlay: true,looping: true,));
    }else{

    }


  }
}