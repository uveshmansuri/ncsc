import 'package:googleapis_auth/auth_io.dart';

class get_server_key{
  Future<String> get_ServerKeyToken() async{
    final scopes=[
      "https://www.googleapis.com/auth/firebase.messaging"
    ];
    
    try {
      final client=await clientViaServiceAccount(ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "ncsc-db",
        "private_key_id": "b8735842266db4d3723ae9b513b7236c2e98605b",
        "private_key":
        "-----BEGIN PRIVATE KEY-----\n"
            "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCunafxFvsCbD9U\n5nJOghAiV7c+J/"
            "GGEUtx3HcKnKbMM+iWcziUSM4zYJNCMWaI0CdQn7qLyALuv7Bl\n4dyFQwuYxjU8i3YJLeW3mGche5Z1Vv9Wt7tUN5oFmwODnJSvy952qq1IVZuH8q6J\n4jOnoUtoP5p82qkR7/"
            "8y5VcE+y9ylKOfGcTMrC7GNrLQyGrXLeNsmDZMM9q26Bgl\neHmFZNjoUm4DbUmL7mLrQjVo9/P9diw7wQiEh3cnwv4PA7JwnCBkO36O3/GfGS1T\nMDd7DuIC7r2zJWaJLrUHZsJ7fXhIHmMUncYSWcXnelugd+"
            "NN1CiIeY0EE5TRImGt\n5xrnNmEJAgMBAAECggEAGMdekaPFMu7RfebFycZDK9xusG9SosfJgPrcGbFpKgkj\ntFXdbY13VWsa+oWwGzIOoi5IdpWHdQHWsl5+wJpnBuL5owHXWi4dLxR9bg7vpu8V\n"
            "hOTFvIm3XZxFv2N05g10IDrQJDehvoT9p6tl0R/eZ4i/D4CoBVedS0eoNZi/fu7E\nWObULlH+ejDODC9uX8ovhNR+3ynHbGpkTZtxEsk/xlVPAhqeJBNS/zbStl8BwqMI\n"
            "bZmmL46jeVbZ9koBhoMaT6y8fQHUcuIEvI9FiIGH8eNcMDtTELeg/9WMVj0zvld4\nYC5GYsOemAg/wj4ZO9aXYN4fvgnR3D1VFjKDoCY0kQKBgQDwZpoK4oChCZgVKOuv\n"
            "6t6e9sqoUXyM2Jl3No5/amimZBZrloOPyOmRwyI10JPWyNt8IaSx90R0K0CqqAzb\n1DyEQU3xqAQPRpGuxfDYw+K4XuIlelHOGm+6R7iNESda0N9bWQtNdo3sDhvoMMiK\n"
            "A2WimxOXSXGx1HL5cSGBfv7ozwKBgQC58kXj1YUow1sdBdp1IuhV/o5ccLu/VC6t\nfEyPPWKG3tK1sliY4Cgv47K3/hVGApf2ALqRiUZzoIFao03UEGjWFi6CZMIUNHTJ\n"
            "WpkMzThDF3YFPVq3e1WPMEAYruQZZ4XBKdOxuczqJ5O/rBU2cYZT9BLP2Pqi2QhW\nabTsPqfepwKBgQCBgxUcJhicKVoIlEodNRCIXXaipXvPOWW8RuUQGdiVQ7icb7Mj\n"
            "BF9pCtJkYaE0BnPQdSOQSSFU4HRvPCfpSnbr3W7LcPP28tLLcJInhaigIWX+QN7P\nhYiJt9fiD8q+72ZVhSxEqEkfUh6Qwa9YQyo/JwKv735UCpuCbQNbC3rzGwKBgDUF\n"
            "4OgW+uGk01ZzVNgSHC5paC7z9pWYa7cMusgduPq8j1lAggMV6F+/jjbpPSe5lZuQ\nmaLmgjB2lGxEJO1TwJFLwfdsw+r/Ck5gh0QfQOvgxMa5uCSaBsvN9nkTZffYjUuH\n"
            "odYMJWKf5oHBkEr2FFfcQYEDXnURbk811WGIfFYBAoGBALk6V1H5UzpZ1WjgJCA+\nm4hQzXkQ3tNMj7JK1kU+o4mav6G4nIJRbwZuG20ZS/EYcjX9Ro8M2G45xJJQeKT1\n"
            "hs72WXa/iEcyM+2voJtyt6anNpfqig8Fygu/TYc4ul3UF2MlNM56vpBooJrchoeR\ng4s3d4HQCtw91eoh2tNww5Pg\n"
            "-----END PRIVATE KEY-----\n",
        "client_email": "firebase-adminsdk-n28hj@ncsc-db.iam.gserviceaccount.com",
        "client_id": "100059330948993513122",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-n28hj%40ncsc-db.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      }), scopes);

      final accssesServerKey=await client.credentials.accessToken.data;
      return accssesServerKey;
    } on Exception catch (e) {
      return "errror:${e.toString()}";
    }
  }
}