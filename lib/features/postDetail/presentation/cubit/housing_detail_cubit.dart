import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:welhome/core/data/repositories/housing_repository.dart';
import 'package:welhome/core/data/models/housing_post.dart';
part 'housing_detail_state.dart';

class HousingDetailCubit extends Cubit<HousingDetailState> {
  final HousingRepository housingRepository;

  HousingDetailCubit({required this.housingRepository})
      : super(HousingDetailInitial());

  Future<void> fetchHousingPost(String postId) async {
    try {
      emit(const HousingDetailLoading());
      final post = await housingRepository.getHousingPostById(postId);
      if (post != null) {
        emit(HousingDetailLoaded(post));
      } else {
        emit(const HousingDetailError('Housing post not found.'));
      }
    } catch (e) {
      emit(HousingDetailError(e.toString()));
    }
  }
}
