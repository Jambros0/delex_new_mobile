import 'package:equatable/equatable.dart';

abstract class ExInspectionsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExInspectionInitial extends ExInspectionsState {}

class ExInspectionLoading extends ExInspectionsState {}

class ExInspectionLoaded extends ExInspectionsState {
  final Map<String, dynamic>? allDropDowns;
  final Map<String, dynamic>? checklistData;

  ExInspectionLoaded({
    this.allDropDowns,
    this.checklistData,
  });

  @override
  List<Object?> get props => [allDropDowns, checklistData];
}

class ExInspectionError extends ExInspectionsState {
  final String error;
  ExInspectionError(this.error);
  @override
  List<Object?> get props => [error];
}

class ExInspectionSubmitting extends ExInspectionsState {}

class ExInspectionSuccess extends ExInspectionsState {
  final String message;
  final String? id;
  final bool? clearFlag;
  final bool userUpdateSign;
  ExInspectionSuccess(this.message, this.id, this.clearFlag,
      {this.userUpdateSign = false});

  String? get locationId => id;

  @override
  List<Object?> get props => [message, id, clearFlag];
}

class FileUploadSuccess extends ExInspectionsState {
  final dynamic uploadData; // Change this to dynamic
  final String fileOf;
  FileUploadSuccess(this.uploadData, this.fileOf);

  @override
  List<Object?> get props => [uploadData, fileOf];
}

class FileUploadFunctionalAreaSuccess extends ExInspectionsState {
  final dynamic uploadData; // Change this to dynamic
  final String fileOf;
  final int index;
  FileUploadFunctionalAreaSuccess(this.uploadData, this.fileOf, this.index);

  @override
  List<Object?> get props => [uploadData, fileOf];
}
