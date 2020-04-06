import 'package:flutter/material.dart';

// Define a custom Form widget.
class SettingsForm extends StatefulWidget {
  void Function(BuildContext) onUpdate;
  SettingsForm({ @required this.onUpdate });

  @override
  SettingsFormState createState() {
    return SettingsFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class SettingsFormState extends State<SettingsForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  double fio2 = 60.0;
  double freq = 10.0;
  double tidal = 250.0;
  double peep = 10.0;
  double rate = 3.0;

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
        key: _formKey,
        child: ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(16.0),
                child: Text(
                  'Settings',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline,
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                'FiO2: ${fio2.round()} %',
                style: Theme
                    .of(context)
                    .textTheme
                    .body2,
              ),
              Slider.adaptive(
                min: 21.0,
                max: 100.0,
                divisions: 100 - 21,
                value: fio2,
                onChanged: (value) {
                  setState(() {
                    fio2 = value;
                  });
                },
              ),
              Text(
                'Respiratory cycles: ${freq.round()} cycles / minute',
                style: Theme
                    .of(context)
                    .textTheme
                    .body2,
              ),
              Slider.adaptive(
                min: 8.0,
                max: 30.0,
                divisions: 30 - 8,
                value: freq,
                onChanged: (value) {
                  setState(() {
                    freq = value;
                  });
                },
              ),
              Text(
                'Tidal volume: ${tidal.round()} ml',
                style: Theme
                    .of(context)
                    .textTheme
                    .body2,
              ),
              Slider.adaptive(
                min: 240.0,
                max: 800.0,
                divisions: ((800 - 240) / 10).round(),
                value: tidal,
                onChanged: (value) {
                  setState(() {
                    tidal = value;
                  });
                },
              ),
              Text(
                'PEEP: ${peep.round()} cm of H2O',
                style: Theme
                    .of(context)
                    .textTheme
                    .body2,
              ),
              Slider.adaptive(
                min: 0.0,
                max: 15.0,
                divisions: 15 - 0,
                value: peep,
                onChanged: (value) {
                  setState(() {
                    peep = value;
                  });
                },
              ),
              Text(
                'Inspiratory rate: ${((rate * 10).round() % 10 == 5) ? 2 : 1}:${((rate * 10).round() % 10 == 5) ? (rate * 2).round() : rate.round()}',
                style: Theme
                    .of(context)
                    .textTheme
                    .body2,
              ),
              Slider.adaptive(
                min: 1.0,
                max: 5.0,
                divisions: (5 - 1) * 2,
                value: rate,
                onChanged: (value) {
                  setState(() {
                    rate = value;
                  });
                },
              ),
              RaisedButton(
                child: Text('Update'),
                onPressed: () {
                  // Validate returns true if the form is valid, otherwise false.
                  if (_formKey.currentState.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.

                    Scaffold
                        .of(context)
                        .showSnackBar(SnackBar(content: Text('Updated parameters')));
                    widget.onUpdate(context);
                  }
                },
              ),
            ]
        )
    );
  }
}
