class Init {
  static Future initialize() async {
    await _registerServices();
    await _loadSettings();
  }

  static _registerServices() async {
    await Future.delayed(Duration(seconds: 3));
  }

  static _loadSettings() async {
    await Future.delayed(Duration(seconds: 3));
  }
}
