import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  
  const LoadingIndicator({Key? key, this.message}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                message!,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
        ],
      ),
    );
  }
}
