import '../models/lost_found_model.dart';

class MockLostFound {
  static List<LostFoundModel> get initialItems => [
        LostFoundModel(
          id: 'lf_1',
          title: 'Casio fx-991EX Scientific Calculator',
          description:
              'Found on Bus 1 (Mirpur) seat row 4 left side during the 8:00 AM trip. Has a small blue sticker on the back.',
          type: LostFoundType.found,
          location: 'Left with Driver Md. Rafiqul / AUST Transport Office',
          contact: '01712-345678 (Driver Rafiq)',
          authorName: 'Siam Chowdhury (CSE 20)',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        LostFoundModel(
          id: 'lf_2',
          title: 'AUST Student ID Card & Red Lanyard',
          description:
              'Lost my ID card (ID: 21-04567-2, EEE Dept) possibly near the Farmgate stoppage or on Bus 3.',
          type: LostFoundType.lost,
          location: 'Bus 3 / Farmgate stoppage',
          contact: '01811-998877 (Anik)',
          authorName: 'Anik Datta',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        LostFoundModel(
          id: 'lf_3',
          title: 'Black Umbrella with Wooden Handle',
          description:
              'Found on Bus 2 (Uttara) yesterday evening in the overhead baggage rack.',
          type: LostFoundType.found,
          location: 'Kept at AUST Campus Motor Pool desk',
          contact: '01819-876543 (Driver Anwar)',
          authorName: 'Transport Staff',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
}
