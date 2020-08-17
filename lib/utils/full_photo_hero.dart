import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullPhotoHero extends StatelessWidget {
  final String url;
  final String tag;

  FullPhotoHero({Key key, @required this.url, this.tag = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: FullPhotoHeroScreen(
        url: url,
      ),
    );
  }
}

class FullPhotoHeroScreen extends StatefulWidget {
  final String url;
  final String tag;

  FullPhotoHeroScreen({Key key, @required this.url, this.tag = ''})
      : super(key: key);

  @override
  State createState() => FullPhotoHeroScreenState(url: url);
}

class FullPhotoHeroScreenState extends State<FullPhotoHeroScreen> {
  final String url;

  FullPhotoHeroScreenState({Key key, @required this.url});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Hero(
            tag: widget.tag.isEmpty ? widget.tag : "Hero",
            child: PhotoView(imageProvider: NetworkImage(url))));
  }
}
