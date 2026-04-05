import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_game/screens/game/snake_cubit.dart';

import 'dependency_injection/get_it_setup.dart';

providerList() {
  return [
     BlocProvider(
      create: (_) => getIt<SnakeCubit>(),
    ),
  ];
}
