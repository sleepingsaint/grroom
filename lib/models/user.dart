class UserModel {
  final String role;
  final bool isVerified;
  final String createdAt;
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  UserModel(
      {this.role,
      this.isVerified,
      this.createdAt,
      this.firstName,
      this.id,
      this.lastName,
      this.email});

  static fromResp(var resp) {
    return UserModel(
        role: resp["role"],
        isVerified: resp["isVerified"],
        createdAt: resp["createdAt"],
        firstName: resp["firstName"],
        lastName: resp["lastName"],
        email: resp["email"], 
        id: resp["_id"]);
  }
}
