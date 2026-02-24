import 'package:equatable/equatable.dart';

abstract class CaseDetailsEvent extends Equatable {
  const CaseDetailsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCaseDetailsEvent extends CaseDetailsEvent {
  final int caseId;

  const FetchCaseDetailsEvent(this.caseId);

  @override
  List<Object?> get props => [caseId];
}

class ToggleFavoriteEvent extends CaseDetailsEvent {
  final int caseId;
  final bool isCurrentlyFavorited;

  const ToggleFavoriteEvent({
    required this.caseId,
    required this.isCurrentlyFavorited,
  });

  @override
  List<Object?> get props => [caseId, isCurrentlyFavorited];
}

class ShareCaseEvent extends CaseDetailsEvent {
  final int caseId;

  const ShareCaseEvent(this.caseId);

  @override
  List<Object?> get props => [caseId];
}

class DownloadAttachmentEvent extends CaseDetailsEvent {
  final String url;
  final String fileName;

  const DownloadAttachmentEvent({
    required this.url,
    required this.fileName,
  });

  @override
  List<Object?> get props => [url, fileName];
}
