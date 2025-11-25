import 'package:equatable/equatable.dart';
import '../../../domain/entities/profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

class LoadUserProfile extends ProfileEvent {}

class UpdateUserProfile extends ProfileEvent {
  final Profile profile;
  
  const UpdateUserProfile(this.profile);
  
  @override
  List<Object> get props => [profile];
}
