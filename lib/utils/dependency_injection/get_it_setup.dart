import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:snake_game/utils/dependency_injection/get_it_setup.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() async => getIt.init();