import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class TimeSeries extends StatelessWidget {
  final List<Measure> data;
  final int max;

  TimeSeries(this.data, { this.max });

  /// Creates a [LineChart] with sample data and no transition.
  factory TimeSeries.withSampleData() {
    return new TimeSeries(_createSampleData(), max: 65);
  }

  @override
  Widget build(BuildContext context) {
    final List<charts.Series<Measure, DateTime>> seriesList = [
      new charts.Series(
        id: 'lines',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Measure m, _) => m.timestamp,
        measureFn: (Measure m, _) => m.value,
        data: data,
      )
        ..setAttribute(charts.rendererIdKey, 'lines'),
      new charts.Series(
        id: 'customPoint',
        colorFn: (Measure m, _) =>
        (max != 0 && m.value > max)
            ? charts.MaterialPalette.red.shadeDefault
            : charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Measure m, _) => m.timestamp,
        measureFn: (Measure m, _) => m.value,
        data: data,
      )
        ..setAttribute(charts.rendererIdKey, 'customPoint'),
    ];
    if (max != 0) {
      DateTime start;
      DateTime end;
      bool init = false;
      for (Measure m in data) {
        if (!init) {
          init = true;
          start = m.timestamp;
          end = m.timestamp;
        } else if (m.timestamp.isBefore(start)) {
          start = m.timestamp;
        } else if (m.timestamp.isAfter(end)) {
          end = m.timestamp;
        }
      }
      seriesList.add(
        new charts.Series(
          id: 'max',
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (Measure m, _) => m.timestamp,
          measureFn: (Measure m, _) => m.value,
          data: [new Measure(start, max), new Measure(end, max)],
        )..setAttribute(charts.rendererIdKey, 'max'),
      );
    }
    return new charts.TimeSeriesChart(
      seriesList,
      animate: true,
      customSeriesRenderers: [
        new charts.LineRendererConfig(
          customRendererId: 'lines',
          includeArea: true,
          stacked: true,
        ),
        new charts.LineRendererConfig(
          customRendererId: 'max',
        ),
        new charts.PointRendererConfig(
            customRendererId: 'customPoint'
        ),
      ],
    );
  }

  /// Create one series with sample hard coded data.
  static List<Measure> _createSampleData() {
    return [
      new Measure(DateTime.now(), 5),
      new Measure(DateTime.now().add(new Duration(seconds: 1)), 25),
      new Measure(DateTime.now().add(new Duration(seconds: 2)), 100),
      new Measure(DateTime.now().add(new Duration(seconds: 3)), 75),
    ];
  }
}

/// Sample linear data type.
class Measure {
  final DateTime timestamp;
  final int value;

  Measure(this.timestamp, this.value);
}