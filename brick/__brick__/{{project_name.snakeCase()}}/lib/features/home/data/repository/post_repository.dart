import 'dart:developer';

import 'package:chopper/chopper.dart' as chopper;
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:{{project_name.snakeCase()}}/app/constants/enum.dart';
import 'package:{{project_name.snakeCase()}}/app/helpers/extensions/int_ext.dart';
import 'package:{{project_name.snakeCase()}}/app/helpers/extensions/status_code_ext.dart';
import 'package:{{project_name.snakeCase()}}/core/domain/model/failure.dart';
import 'package:{{project_name.snakeCase()}}/features/home/data/model/post.dto.dart';
import 'package:{{project_name.snakeCase()}}/features/home/data/service/post_service.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/interface/i_post_repository.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/model/post.dart';

// ignore_for_file: avoid_dynamic_calls
@LazySingleton(as: IPostRepository)
class PostRepository implements IPostRepository {
  PostRepository(this._postService);

  final PostService _postService;

  @override
  Future<Either<Failure, List<Post>>> getPosts() async {
    try {
      final chopper.Response<dynamic> response = await _postService.getPosts();
      final StatusCode statusCode = response.statusCode.statusCode;

      if (statusCode.isSuccess && response.body != null) {
        final dynamic rawPostDTOs = response.body['data']['children']
            .map(
              (dynamic element) =>
                  PostDTO.fromJson(element['data'] as Map<String, dynamic>),
            )
            .toList();
        final List<PostDTO> postDTOs =
            List<PostDTO>.from(rawPostDTOs as List<dynamic>);

        return _validatePostData(postDTOs);
      } else {
        return left(Failure.serverError(statusCode, response.error.toString()));
      }
    } catch (error) {
      log(error.toString());

      return left(Failure.unexpected(error.toString()));
    }
  }

  Either<Failure, List<Post>> _validatePostData(List<PostDTO> postDTOs) {
    final List<Post> posts =
        postDTOs.map((PostDTO postDTO) => postDTO.toDomain()).toList();
    // check if the post data does not have invalid values(if list is empty
    // then there are no invalid posts)
    final bool isPostsValid = posts
        .where((Post post) => post.failureOption.isSome())
        .toList()
        .isEmpty;

    return isPostsValid
        ? right(posts)
        : left(
            Failure.invalidValue(
              failedValue:
                  posts.firstWhere((Post post) => post.failureOption.isSome()),
            ),
          ); // return the first invalid post
  }
}
