import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkAvatar extends StatelessWidget {
  final double radius;
  final String imageUrl;
  NetworkAvatar({@required this.radius, @required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(
          'assets/images/placeholder.png',
        ),
      ),
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius ?? 20,
        backgroundImage: imageProvider,
      ),
      progressIndicatorBuilder: (context, string, progress) {
        return CircularProgressIndicator(
          value: progress.progress,
        );
      },
      fit: BoxFit.cover,
    );
  }
}
