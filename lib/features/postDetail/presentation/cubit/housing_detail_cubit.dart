import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';
import 'package:welhome/features/postDetail/domain/usecases/get_post_details.dart';

part 'housing_detail_state.dart';

class HousingDetailCubit extends Cubit<HousingDetailState> {
  final GetPostDetails getPostDetails;

  HousingDetailCubit({required this.getPostDetails}) : super(const HousingDetailInitial());

  Future<void> fetchHousingPost(String postId) async {
    emit(const HousingDetailLoading());
    try {
      final post = await getPostDetails(postId: postId);
      if (post != null) {
        emit(HousingDetailLoaded(post));
      } else {
        emit(const HousingDetailError("Housing post not found."));
      }
    } catch (e) {
      emit(HousingDetailError("Failed to load housing details: ${e.toString()}"));
    }
  }
}
