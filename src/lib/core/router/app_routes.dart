abstract final class AppRoutes {
  // Auth
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const forgotPassword = '/forgot-password';

  // Shell tabs
  static const feed = '/feed';
  static const prs = '/prs';
  static const nearby = '/nearby';
  static const chat = '/chat';
  static const profile = '/profile';

  // Feed nested
  static const postDetail = '/feed/post/:postId';
  static const postComments = '/feed/post/:postId/comments';
  static const createPost = '/feed/create';
  static const storyView = '/feed/story/:userId';

  static String postCommentsPath(String postId) =>
      '/feed/post/$postId/comments';

  // PR nested
  static const prDetail = '/prs/exercise/:exerciseId';
  static const addPr = '/prs/add';

  // Chat nested
  static const chatConversation = '/chat/:conversationId';
  static const chatGroupInfo = '/chat/:conversationId/info';
  static const newConversation = '/chat/new';

  // Profile nested
  static const userProfile = '/profile/:userId';
  static const editProfile = '/profile/edit';
  static const notifications = '/notifications';
  static const notificationSettings = '/notifications/settings';
  static const search = '/search';
  static const explore = '/explore';
  static const goals = '/goals';

  // Helpers for parameterized routes
  static String postDetailPath(String postId) => '/feed/post/$postId';
  static String userProfilePath(String userId) => '/profile/$userId';
  static String chatConversationPath(String conversationId) =>
      '/chat/$conversationId';
  static String prDetailPath(String exerciseId) => '/prs/exercise/$exerciseId';
  static String storyViewPath(String userId) => '/feed/story/$userId';
}
