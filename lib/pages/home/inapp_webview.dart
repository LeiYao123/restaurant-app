import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class InAppwebview extends StatefulWidget {
  final String url;
  const InAppwebview({super.key, required this.url});

  @override
  State<InAppwebview> createState() => _InAppwebviewState();
}

class _InAppwebviewState extends State<InAppwebview> {
  final GlobalKey webViewKey = GlobalKey();

  String _pageTitle = "";

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
    supportMultipleWindows: true,
  );

  PullToRefreshController? pullToRefreshController;

  double progress = 0;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(color: Colors.blue),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: _handleRightMenu,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            PopScope(
              canPop: false,
              onPopInvoked: (didPop) async {
                if (await webViewController?.canGoBack() ?? false) {
                  webViewController?.goBack();
                  return;
                }
                if (!mounted) return;
                Get.back();
              },
              child: _buildInAppView(),
            ),
            progress < 1.0
                ? LinearProgressIndicator(value: progress)
                : Container(),
          ],
        ),
      ),
    );
  }

  InAppWebView _buildInAppView() {
    return InAppWebView(
      key: webViewKey,
      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
      initialSettings: settings,
      pullToRefreshController: pullToRefreshController,
      onWebViewCreated: (controller) => webViewController = controller,
      onLoadStart: (controller, url) async {},
      onPermissionRequest: (controller, request) async {
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
      onLoadStop: (controller, url) async {
        pullToRefreshController?.endRefreshing();
      },
      onReceivedError: _handleWebviewError,
      onReceivedHttpError: _handleWebviewError,
      onTitleChanged: (controller, title) {
        setState(() {
          _pageTitle = title ?? '';
        });
      },
      onProgressChanged: (controller, progress) {
        if (progress == 100) {
          pullToRefreshController?.endRefreshing();
        }
        setState(() {
          this.progress = progress / 100;
        });
      },
    );
  }

  void _handleWebviewError(
    InAppWebViewController controller,
    WebResourceRequest request,
    error,
  ) {
    Get.snackbar('Error', '${request.url} $error');
    print('发生错误--> ${request.url} $error');
    pullToRefreshController?.endRefreshing();
  }

  _handleRightMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      webViewController?.reload();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                  const Text('refresh')
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
