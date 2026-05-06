class CommunityJoinRequest {
  final String invitationCode;
  final int userId;

  CommunityJoinRequest({
    required this.invitationCode,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
    'invitation_code': invitationCode,
    'user_id': userId,
  };
}