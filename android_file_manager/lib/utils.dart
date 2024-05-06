import 'dart:convert';
import 'dart:typed_data';

import 'package:charset_converter/charset_converter.dart';
import 'package:convert/convert.dart';

String bytesToHex(List<int> bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
}

List<int> hexToBytes(String hexString) {
  hexString = hexString.replaceAll(" ", "");
  return hex.decode(hexString);
}

Future<String> bytesToAnsi(List<int> bytes) async {
  return CharsetConverter.decode("windows-1252", Uint8List.fromList(bytes));
}

Future<List<int>> ansiToBytes(String text) async {
  return CharsetConverter.encode("windows-1252", text);
}

Future<String> hexToAnsi(String hex) {
  List<int> bytes = hexToBytes(hex);
  return bytesToAnsi(bytes);
}

Future<String> ansiToHex(String text) async {
  List<int> bytes = await ansiToBytes(text);
  return bytesToHex(bytes);
}
