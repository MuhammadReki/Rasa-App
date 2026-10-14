import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/models/article.dart';
import '../../features/article/article_screen.dart';
import '../../features/article/edit_article_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/bookmark/bookmarks_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/submit/submit_story_screen.dart';
import '../../features/comments/comments_screen.dart';
import '../../features/notifications/notifications_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (c, s) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (c, s) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
      GoRoute(
        path: '/article/:id',
        builder: (c, s) {
          final id = s.pathParameters['id'] ?? '';
          return ArticleScreen(articleId: id);
        },
      ),
      GoRoute(
        path: '/edit-article',
        builder: (c, s) {
          final article = s.extra as Article;
          return EditArticleScreen(article: article);
        },
      ),
      GoRoute(path: '/search', builder: (c, s) => const SearchScreen()),
      GoRoute(
        path: '/bookmarks',
        builder: (c, s) => const BookmarksScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (c, s) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (c, s) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (c, s) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/submit-story',
        builder: (c, s) => const SubmitStoryScreen(),
      ),
      GoRoute(
        path: '/comments/:id',
        builder: (c, s) {
          final id = s.pathParameters['id'] ?? '';
          return CommentsScreen(articleId: id);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (c, s) => const NotificationsScreen(),
      ),
    ],
  );
}