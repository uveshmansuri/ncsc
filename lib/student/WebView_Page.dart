import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class WebView_Page extends StatefulWidget {
  String url;
  var title;

  WebView_Page({this.title,required this.url});

  @override
  State<WebView_Page> createState() => _WebView_PageState();
}

class _WebView_PageState extends State<WebView_Page> {
  //WebViewController wb=WebViewController();
  bool isLoading=true;
  @override
  void initState() {
    super.initState();
    // wb = WebViewController()
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setNavigationDelegate(
    //     NavigationDelegate(
    //       onNavigationRequest: (NavigationRequest request) async {
    //         final Uri uri = Uri.parse(request.url);
    //         // Check for common file extensions that you consider downloadable.
    //         if (uri.path.endsWith('.pdf') ||
    //             uri.path.endsWith('.doc') ||
    //             uri.path.endsWith('.docx')) {
    //           if (await canLaunchUrl(uri)) {
    //             await launchUrl(uri, mode: LaunchMode.externalApplication);
    //             // Prevent the WebView from navigating to the URL.
    //             return NavigationDecision.prevent;
    //           }
    //         }
    //         return NavigationDecision.navigate;
    //       },
    //       onPageStarted: (url) {
    //         setState(() {
    //           isLoading = true;
    //         });
    //       },
    //       onPageFinished: (url) {
    //         setState(() {
    //           isLoading = false;
    //         });
    //       },
    //     ),
    //   )
    //   ..loadRequest(Uri.parse(widget.url));
  }

  // Future<bool> _handleBackPress() async {
  //   if (await wb.canGoBack()) {
  //     await wb.goBack();
  //     return false; // Prevents app from closing
  //   }
  //   return true; // Allows app to close
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //onWillPop: _handleBackPress,
      onWillPop: null,
      child: Scaffold(
        appBar: AppBar(
          title: (widget.title!=null)?Text(widget.title):null,
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri.uri(
                  Uri.parse(
                    widget.url,
                  ),
                ),
              ),
            ),
            //WebViewWidget(controller: wb),
          ],
        ),
      ),
    );
  }
}