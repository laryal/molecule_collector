// molecule_data.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoleculeData {
  final String position;
  final String symbol;
  final int number;
  bool playerOwns;  // Made it mutable for simplicity
  final String png;
  final String jwt;

  MoleculeData({
    required this.position,
    required this.symbol,
    required this.number,
    required this.playerOwns,
    required this.png,
    required this.jwt,
  });

  static Future<List<MoleculeData>> fromJsonAsset(String assetName) async {
    final data = await rootBundle.loadString(assetName);
    final List<dynamic> jsonData = json.decode(data);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<MoleculeData> molecules = jsonData.map((item) {
      String position = item['position'];
      bool playerOwns = prefs.getBool('collected_$position') ?? false; // Check if the user owns this molecule

      return MoleculeData(
        position: position,
        symbol: item['symbol'],
        number: item['number'],
        playerOwns: playerOwns,
        png: item['png'],
        jwt: item['jwt'],
      );
    }).toList();

    return molecules;
  }

  static Future<void> collectMolecule(String position) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('collected_$position', true);
    print('Molecule $position collected. Value: ${prefs.getBool('collected_$position')}'); 
  }

  static Future<void> collectMoleculeByNumber(int moleculeNumber) async {
  // Get the position related to the molecule number
  List<MoleculeData> allMolecules = await fromJsonAsset('assets/molecule_data.json');
  String? position = allMolecules.firstWhere((molecule) => molecule.number == moleculeNumber)?.position;

  if (position != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('collected_$position', true);
  }
}

}


