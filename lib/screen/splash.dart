import 'package:flutter/material.dart';
import 'package:jasec/screen/login.dart';
import 'package:jasec/utilidades/publico.dart';

// ignore: must_be_immutable
class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    var duracion = const Duration(seconds: 3);

    Future.delayed(duracion, () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (contex) => const Login()),
          (route) => false);
      /* Navigator.popAndPushNamed(context, "inicio", arguments: {
        lblopcionprincipal: 1,
        lblnombreopcion: lblMenu,
        lblllave: 0,
        lblimagenopcion: urlimagensolicitud
      });*/
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: colorAzulPrimario,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(50),
            child: FadeInImage(
              placeholder: AssetImage("assets/images/hojaverde.png"),
              image: AssetImage("assets/images/hojaverde.png"),
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 300),
            ),
          ),
        ),
      ),
    );
  }
}
