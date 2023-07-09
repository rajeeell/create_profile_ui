import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String title;
  final Function()? onTap;
  const AuthButton({Key? key,  required this.title, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: 285,
      child: MaterialButton(
        onPressed: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding:
        const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
        color: Colors.indigo.shade600,
        textColor: Theme.of(context).primaryTextTheme.button!.color,
        child: Text(
          title,
        ),
      ),
    );
  }
}
