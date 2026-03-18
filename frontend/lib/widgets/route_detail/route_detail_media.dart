import 'package:flutter/material.dart';

class RouteImageDialog extends StatelessWidget {
  final String url;

  const RouteImageDialog(this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20.0),
        minScale: 0.1,
        maxScale: 4.0,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Image.network(
            url,
            fit: BoxFit.contain,
            webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          ),
        ),
      ),
    );
  }
}

class RouteImage extends StatelessWidget {
  final double? width;
  final String url;

  const RouteImage(this.url, {super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: GestureDetector(
        onTap: () async {
          await showDialog(
            context: context,
            builder: (_) => RouteImageDialog(url),
          );
        },
        child: Image.network(
          url,
          width: width,
          fit: BoxFit.contain,
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        ),
      ),
    );
  }
}
