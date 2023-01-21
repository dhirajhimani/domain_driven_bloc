import 'dart:developer';

import 'package:chopper/chopper.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:very_good_core/app/constants/enum.dart';
import 'package:very_good_core/app/utils/extensions.dart';
import 'package:very_good_core/core/data/model/user.dto.dart';
import 'package:very_good_core/core/data/service/user_service.dart';
import 'package:very_good_core/core/domain/interface/i_user_repository.dart';
import 'package:very_good_core/core/domain/model/user.dart';

@LazySingleton(as: IUserRepository)
class UserRepository implements IUserRepository {
  UserRepository(
    this._userService,
  );

  final UserService _userService;

  @override
  Future<Option<User>> get user async {
    try {
      final Response<dynamic> response = await _userService.getCurrentUser();

      final StatusCode statusCode = response.statusCode.statusCode;

      if (statusCode.isSuccess && response.body != null) {
        final UserDTO userDTO =
            UserDTO.fromJson(response.body!['data'] as Map<String, dynamic>);

        return _validateUserData(userDTO);
      }

      return none();
    } catch (error) {
      log(error.toString());

      return none();
    }
  }

  Option<User> _validateUserData(UserDTO? userDTO) {
    final User? user = userDTO?.toDomain();

    return user?.failureOption.isNone() ?? false // validate user data
        ? some(user!)
        : none();
  }
}
