part of 'housing_detail_cubit.dart';

abstract class HousingDetailState extends Equatable {
  const HousingDetailState();

  @override
  List<Object?> get props => [];
}

class HousingDetailInitial extends HousingDetailState {
  const HousingDetailInitial();
}

class HousingDetailLoading extends HousingDetailState {
  const HousingDetailLoading();
}

class HousingDetailLoaded extends HousingDetailState {
  final HousingPost post;

  const HousingDetailLoaded(this.post);

  @override
  List<Object?> get props => [post];
}

class HousingDetailError extends HousingDetailState {
  final String message;

  const HousingDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
