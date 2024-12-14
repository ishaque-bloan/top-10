import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:playcricplatinum/features/widgets/permission_handlers.dart';
import 'package:playcricplatinum/features/widgets/pop_up.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomInAppBrowser extends StatefulWidget {
  final String url;

  const CustomInAppBrowser({super.key, required this.url});

  @override
  State<CustomInAppBrowser> createState() => _CustomInAppBrowserState();
}

class _CustomInAppBrowserState extends State<CustomInAppBrowser> {
  final GlobalKey webViewKey = GlobalKey();

  String url = '';
  String title = '';
  bool? isSecure;
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    url = widget.url;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (webViewController != null && await webViewController!.canGoBack()) {
          await webViewController!.goBack();
          return;
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Column(children: <Widget>[
            Expanded(
                child: Stack(
              children: [
                InAppWebView(
                  onGeolocationPermissionsShowPrompt:
                      (controller, origin) async {
                    if (await Permission.location.request().isGranted) {
                      return Future.value(
                          GeolocationPermissionShowPromptResponse(
                        allow: true,
                        origin: origin,
                      ));
                    }
                    return Future.value(GeolocationPermissionShowPromptResponse(
                      allow: false,
                      origin: origin,
                    ));
                  },
                  onPermissionRequest: handlePermissions,
                  key: webViewKey,
                  onCreateWindow: (controller, createWindowAction) async {
                    WindowPopup(
                      createWindowAction: createWindowAction,
                    );
                    return true;
                  },
                  initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                  initialSettings: inAppWebViewSettings,
                  onWebViewCreated: (controller) async {
                    webViewController = controller;
                    if (!kIsWeb &&
                        defaultTargetPlatform == TargetPlatform.android) {
                      await controller.startSafeBrowsing();
                    }
                  },
                  onLoadStart: (controller, url) async {
                    if (url != null) {
                      setState(() {
                        this.url = url.toString();
                        isSecure = urlIsSecure(url);
                      });
                    }
                  },
                  onLoadStop: (controller, url) async {
                    if (url != null) {
                      setState(() {
                        this.url = url.toString();
                      });
                    }

                    final sslCertificate = await controller.getCertificate();
                    setState(() {
                      isSecure = sslCertificate != null ||
                          (url != null && urlIsSecure(url));
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, isReload) {
                    if (url != null) {
                      setState(() {
                        this.url = url.toString();
                      });
                    }
                  },
                  onTitleChanged: (controller, title) {
                    if (title != null) {
                      setState(() {
                        this.title = title;
                      });
                    }
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    final url = navigationAction.request.url;
                    if (navigationAction.isForMainFrame &&
                        url != null &&
                        ![
                          'http',
                          'https',
                          'file',
                          'chrome',
                          'data',
                          'javascript',
                          'about'
                        ].contains(url.scheme)) {
                      if (await canLaunchUrl(url)) {
                        launchUrl(url);
                        return NavigationActionPolicy.CANCEL;
                      }
                    }
                    return NavigationActionPolicy.ALLOW;
                  },
                ),
              ],
            )),
          ]),
        ),
      ),
    );
  }

  static bool urlIsSecure(Uri url) {
    return (url.scheme == "https") || isLocalizedContent(url);
  }

  static bool isLocalizedContent(Uri url) {
    return (url.scheme == "file" ||
        url.scheme == "chrome" ||
        url.scheme == "data" ||
        url.scheme == "javascript" ||
        url.scheme == "about");
  }
}
