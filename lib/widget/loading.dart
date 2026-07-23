import 'package:flutter/material.dart';
import 'package:jasec/utilidades/publico.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
              child: Container(
                  padding: const EdgeInsets.all(5),
                  height: 90,
                  width: 100,
                  decoration: const BoxDecoration(
                      color: colorAzulPrimario, shape: BoxShape.circle),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: FadeInImage(
                            placeholder:
                                AssetImage('assets/images/hojaverde.png'),
                            image: AssetImage('assets/images/hojaverde.png'),
                            fit: BoxFit.cover,
                            fadeInDuration: Duration(milliseconds: 300),
                            placeholderColor: colorBlanco,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Expanded(
                            child: CircularProgressIndicator(
                          backgroundColor: colorAzulPrimario,
                          strokeWidth: 2,
                          color: colorBlanco,
                        ))
                      ],
                    ),
                  ))),
        ),
      ),
    );
  }
}
