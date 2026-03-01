import 'package:credito_app/src/config/prod_config.dart';
import 'package:credito_app/main.dart' as app;

void main() async {
  app.appConfig = prodConfig;
  await app.main();
}
