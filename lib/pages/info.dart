
class User{
  String? name;
  String? address;
  String? number;
  String? password;
  String? generalward;
  String? privateward;
  String? maternalward;
  String? emergencyroom;
  String? ambulance;
  String? type;
  String? image;


  User();

  User.fromJson(Map<String,dynamic>json){
    name = json['Name'];
    address = json['Address'];
    number = json['Contact_num'];
    password = json['password'];
    generalward = json['general_ward'];
    maternalward = json['maternal_ward'];
    privateward = json['private_ward'];
    emergencyroom = json['emergency_room'];
    ambulance = json['ambulance'];
    type = json['type'];
    image = json['Pic_url'];
  }
}