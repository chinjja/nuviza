import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nuviza/app/app_bloc_ovserver.dart';
import 'package:nuviza/app/view/app_page.dart';
import 'package:nuviza/repository/nuviza_repository.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BlocOverrides.runZoned(
    () async {
      runApp(RepositoryProvider(
        create: (context) => NuvizaRepository(),
        child: const App(),
      ));
    },
    blocObserver: AppBlocObserver(),
  );
}
