abstract final class ApiEndpoints {
  // Auth
  static const authRegister = '/auth/register';
  static const authLogin = '/auth/login';
  static const authRefresh = '/auth/refresh';
  static const authLogout = '/auth/logout';
  static String authSocial(String provider) => '/auth/social/$provider';

  // Users
  static const usersMe = '/users/me';
  static String usersById(String id) => '/users/$id';
  static String usersFollow(String id) => '/users/$id/follow';
  static String usersUnfollow(String id) => '/users/$id/unfollow';
  static String usersBlock(String id) => '/users/$id/block';
  static const usersCheckUsername = '/users/check-username';
  static const usersCheckEmail = '/users/check-email';

  // Feed
  static const feed = '/feed';
  static const posts = '/posts';
  static String postsById(String id) => '/posts/$id';
  static String postReactions(String id) => '/posts/$id/reactions';
  static String postComments(String id) => '/posts/$id/comments';
  static String postCommentById(String postId, String commentId) =>
      '/posts/$postId/comments/$commentId';

  // Stories
  static const stories = '/stories';
  static String storiesById(String id) => '/stories/$id';

  // PRs
  static const prs = '/prs';
  static String prsById(String id) => '/prs/$id';
  static String prsByExercise(String exerciseId) =>
      '/prs/exercise/$exerciseId/history';

  // Exercises
  static const exercises = '/exercises';
  static String exercisesById(String id) => '/exercises/$id';

  // Goals
  static const goals = '/goals';
  static String goalsById(String id) => '/goals/$id';
  static String goalsCheckin(String id) => '/goals/$id/checkin';

  // Chat
  static const wsChat = '/ws/chat';
  static const conversations = '/conversations';
  static String conversationsById(String id) => '/conversations/$id';
  static String conversationMessages(String id) =>
      '/conversations/$id/messages';
  static String conversationMembers(String id) =>
      '/conversations/$id/members';

  // Nearby
  static const nearbyUsers = '/nearby/users';
  static const nearbyGyms = '/nearby/gyms';

  // Notifications
  static const notifications = '/notifications';
  static const notificationsMarkAllRead = '/notifications/read-all';
  static String notificationsById(String id) => '/notifications/$id';
  static const fcmToken = '/users/fcm-token';

  // Search
  static const search = '/search';
  static const searchTrending = '/search/trending';
}
