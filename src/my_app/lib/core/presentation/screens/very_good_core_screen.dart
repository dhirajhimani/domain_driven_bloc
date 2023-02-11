import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:very_good_core/app/constants/constant.dart';
import 'package:very_good_core/app/constants/route.dart';
import 'package:very_good_core/app/themes/spacing.dart';
import 'package:very_good_core/app/utils/dialog_utils.dart';
import 'package:very_good_core/app/utils/error_message_utils.dart';
import 'package:very_good_core/app/utils/injection.dart';
import 'package:very_good_core/core/domain/bloc/very_good_core/very_good_core_bloc.dart';
import 'package:very_good_core/core/presentation/screens/error_screen.dart';
import 'package:very_good_core/core/presentation/screens/loading_screen.dart';
import 'package:very_good_core/core/presentation/widgets/connectivity_checker.dart';
import 'package:very_good_core/core/presentation/widgets/very_good_core_app_bar.dart';
import 'package:very_good_core/core/presentation/widgets/very_good_core_avatar.dart';
import 'package:very_good_core/core/presentation/widgets/very_good_core_nav_bar.dart';
import 'package:very_good_core/features/home/domain/bloc/post/post_bloc.dart';

class VeryGoodCoreScreen extends StatelessWidget {
  const VeryGoodCoreScreen({
    super.key,
    required this.child,
  });

  final Widget child;
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () => DialogUtils.showExitDialog(context),
        child: MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<PostBloc>(
              create: (BuildContext context) => getIt<PostBloc>(),
            ),
          ],
          child: BlocBuilder<VeryGoodCoreBloc, VeryGoodCoreState>(
            builder: (BuildContext context, VeryGoodCoreState state) {
              if (state.failure != null) {
                return ErrorScreen(
                  onRefresh: () =>
                      context.read<VeryGoodCoreBloc>().initialize(),
                  errorMessage:
                      ErrorMessageUtils.generate(context, state.failure),
                );
              } else if (state.user != null) {
                return ConnectivityChecker(
                  child: Scaffold(
                    appBar: PreferredSize(
                      preferredSize:
                          Size.fromHeight(AppBar().preferredSize.height),
                      child: VeryGoodCoreAppBar(
                        actions: <Widget>[
                          IconButton(
                            onPressed: () => context
                                .read<VeryGoodCoreBloc>()
                                .switchTheme(Theme.of(context).brightness),
                            icon:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Icon(Icons.light_mode)
                                    : const Icon(Icons.dark_mode),
                          ),
                          GestureDetector(
                            onTap: () => GoRouter.of(context)
                                .goNamed(RouteName.profile.name),
                            child: VeryGoodCoreAvatar(
                              size: 32,
                              imageUrl: state.user!.avatar?.getOrCrash(),
                              padding: EdgeInsets.all(Insets.sm),
                            ),
                          ),
                        ],
                        leading: GoRouter.of(context)
                                .location
                                .contains('/home/')
                            ? BackButton(
                                onPressed: () => GoRouter.of(context).canPop()
                                    ? GoRouter.of(context).pop()
                                    : null,
                              )
                            : null,
                      ),
                    ),
                    body: SafeArea(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: Constant.mobileBreakpoint,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                    bottomNavigationBar: const VeryGoodCoreNavBar(),
                  ),
                );
              } else {
                return LoadingScreen.scaffold();
              }
            },
          ),
        ),
      );
}
