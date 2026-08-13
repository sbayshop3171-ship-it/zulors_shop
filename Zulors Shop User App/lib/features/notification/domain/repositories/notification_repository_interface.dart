import 'package:zulors_shop/interface/repo_interface.dart';

abstract class NotificationRepositoryInterface implements RepositoryInterface{
  Future<dynamic>  seenNotification(int id);

}