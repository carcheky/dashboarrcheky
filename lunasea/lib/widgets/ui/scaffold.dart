import 'package:flutter/material.dart';
import 'package:lunasea/database/tables/lunasea.dart';
import 'package:lunasea/modules.dart';
import 'package:lunasea/system/platform.dart';

class LunaScaffold extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final LunaModule? module;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  /// Called when [LunaSeaDatabase.ENABLED_PROFILE] has changed. Triggered within the build function.
  final void Function(BuildContext)? onProfileChange;

  // ignore: use_key_in_widget_constructors
  const LunaScaffold({
    required this.scaffoldKey,
    this.module,
    this.appBar,
    this.body,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.onProfileChange,
  });

  @override
  Widget build(BuildContext context) {
    if (LunaPlatform.isAndroid) return android(context);
    return scaffold;
  }

  Widget android(BuildContext context) {
    // PopScope with canPop:false + manual Navigator.pop() reads drawer state
    // at pop time (not build time), so ANDROID_BACK_OPENS_DRAWER + isDrawerOpen
    // are always current. Replaces the deprecated WillPopScope.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        if (!LunaSeaDatabase.ANDROID_BACK_OPENS_DRAWER.read()) {
          Navigator.of(context).pop();
          return;
        }
        final state = scaffoldKey.currentState;
        if (state?.hasDrawer ?? false) {
          if (state!.isDrawerOpen) {
            Navigator.of(context).pop();
          } else {
            state.openDrawer();
          }
          return;
        }
        Navigator.of(context).pop();
      },
      child: scaffold,
    );
  }

  Widget get scaffold {
    return LunaSeaDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) {
        onProfileChange?.call(context);
        return Scaffold(
          key: scaffoldKey,
          appBar: appBar,
          body: body,
          drawer: drawer,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          extendBody: extendBody,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          onDrawerChanged: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        );
      },
    );
  }
}
