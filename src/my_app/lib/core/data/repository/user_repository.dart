import 'dart:developer';

import 'package:chopper/chopper.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:very_good_core/app/constants/enum.dart';
import 'package:very_good_core/app/helpers/extensions/int_ext.dart';
import 'package:very_good_core/app/helpers/extensions/status_code_ext.dart';
import 'package:very_good_core/core/data/model/user.dto.dart';
import 'package:very_good_core/core/data/service/user_service.dart';
import 'package:very_good_core/core/domain/interface/i_user_repository.dart';
import 'package:very_good_core/core/domain/model/failure.dart';
import 'package:very_good_core/core/domain/model/user.dart';

@LazySingleton(as: IUserRepository)
class UserRepository implements IUserRepository {
  UserRepository(
    this._userService,
  );

  final UserService _userService;

  @override
  Future<Either<Failure, User>> get user async {
    try {
      final Response<dynamic> response = await _userService.getCurrentUser();

      final StatusCode statusCode = response.statusCode.statusCode;

      if (statusCode.isSuccess && response.body != null) {
        final {'data': Map<String, dynamic> data} =
            response.body as Map<String, dynamic>;
        final UserDTO userDTO = UserDTO.fromJson(data);

        return _validateUserData(userDTO);
      }

      return left(Failure.serverError(statusCode, response.error.toString()));
    } catch (error) {
      log(error.toString());

      return left(Failure.unexpected(error.toString()));
    }
  }

  Either<Failure, User> _validateUserData(UserDTO userDTO) {
    final User user = userDTO.toDomain();

    return user.failureOption.fold(() => right(user), left);
  }
}
