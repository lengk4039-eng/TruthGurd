import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../providers/auth_controller.dart';

/// The dialog a guest sees when they reach something that needs an account.
/// [resumeRoute] is remembered only once the guest commits to signing in, so
/// dismissing the dialog leaves no stale route for a later login to chase.
void promptGuestToSignIn(
  BuildContext context,
  WidgetRef ref, {
  required String titleKey,
  required String bodyKey,
  String? resumeRoute,
}) {
  final l10n = context.l10n;
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      void openAuthScreen(String authRoute) {
        if (resumeRoute != null) {
          ref.read(pendingAuthRouteProvider.notifier).save(resumeRoute);
        }
        Navigator.pop(dialogContext);
        context.push(authRoute);
      }

      return AlertDialog(
        icon: const Icon(Icons.person_add_alt_1_rounded),
        title: Text(l10n.tr(titleKey)),
        content: Text(l10n.tr(bodyKey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.tr('guest.notNow')),
          ),
          TextButton(
            onPressed: () => openAuthScreen('/login'),
            child: Text(l10n.tr('guest.logIn')),
          ),
          FilledButton(
            onPressed: () => openAuthScreen('/register'),
            child: Text(l10n.tr('guest.signUp')),
          ),
        ],
      );
    },
  );
}
