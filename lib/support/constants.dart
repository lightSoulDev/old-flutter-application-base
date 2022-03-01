class NetProtocol {
  static const CODE = {
    INIT: 0,
    LOGIN: 1
  };

  static const INIT = "INIT";
  static const LOGIN = "LOGIN";
  static const CONNECTION_ERROR = "CONNECTION_ERROR";

  static const LOGIN_ERROR_PHONE = "{l|LOGIN_ERROR_PHONE}";
  static const LOGIN_ERROR_DATA= "{l|LOGIN_ERROR_DATA}";
}