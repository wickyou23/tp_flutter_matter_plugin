import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_control_manager.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device_thermostat.dart';
import 'package:tp_flutter_matter_package_example/managers/tp_device_manager.dart';
import 'package:vector_math/vector_math.dart' as vmath;

class TPThermostatWidget extends StatefulWidget {
  const TPThermostatWidget({super.key, required this.device});

  final ValueNotifier<TPDevice> device;

  @override
  State<TPThermostatWidget> createState() => _TPThermostatWidgetState();
}

class _TPThermostatWidgetState extends State<TPThermostatWidget> {
  TPThermostat get thermostat {
    return widget.device.value as TPThermostat;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.device,
      builder: (context, value, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 60,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    thermostat.getDeviceName(),
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .textStyle
                        .copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 2),
                  Visibility(
                    visible: thermostat.subDevices.values.isNotEmpty ||
                        !thermostat.isMainDevice,
                    child: Text(
                      '(Endpoint ${thermostat.endpoint})',
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .copyWith(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _ThermostatSliderWidget(
                thermostat: thermostat,
                onSelectedMode: (p0) async {
                  final response = await thermostat.controlSystemMode(p0);
                  if (response is TPDeviceControlError) {
                    return;
                  }

                  await TPDeviceManager().updateDevice(thermostat);
                },
                onMinTempurateCompletion: (p0) async {
                  dynamic response;
                  if (thermostat.systemMode == TPThermostatMode.cool) {
                    response = await thermostat.controlMinCool(p0);
                  } else if (thermostat.systemMode == TPThermostatMode.heat) {
                    response = await thermostat.controlMinHeat(p0);
                  }

                  if (response is TPDeviceControlError || response == null) {
                    return;
                  }

                  await TPDeviceManager().updateDevice(thermostat);
                },
                onMaxTempurateCompletion: (p0) async {
                  dynamic response;
                  if (thermostat.systemMode == TPThermostatMode.cool) {
                    response = await thermostat.controlMaxCool(p0);
                  } else if (thermostat.systemMode == TPThermostatMode.heat) {
                    response = await thermostat.controlMaxHeat(p0);
                  }

                  if (response is TPDeviceControlError || response == null) {
                    return;
                  }

                  await TPDeviceManager().updateDevice(thermostat);
                },
              ),
            )
          ],
        );
      },
    );
  }
}

enum _TPThermostatDirectionThumb { min, max }

class _ThermostatSliderWidget extends StatefulWidget {
  const _ThermostatSliderWidget({
    Key? key,
    required this.thermostat,
    this.onMinTempurateCompletion,
    this.onMaxTempurateCompletion,
    this.onSelectedMode,
  }) : super(key: key);

  final TPThermostat thermostat;
  final void Function(double)? onMinTempurateCompletion;
  final void Function(double)? onMaxTempurateCompletion;
  final void Function(TPThermostatMode)? onSelectedMode;

  @override
  State<_ThermostatSliderWidget> createState() =>
      __ThermostatSliderWidgetState();
}

class __ThermostatSliderWidgetState extends State<_ThermostatSliderWidget> {
  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController(initialItem: 0);
  final minValue = ValueNotifier(0.0);
  final maxValue = ValueNotifier(0.0);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final indexModeSelected = TPThermostatMode.values
          .indexWhere((element) => element == widget.thermostat.systemMode);
      if (indexModeSelected != -1 &&
          indexModeSelected != _scrollController.selectedItem) {
        _scrollController.animateToItem(
          indexModeSelected,
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        );
      }

      if (widget.thermostat.systemMode == TPThermostatMode.cool) {
        minValue.value = widget.thermostat.minCool;
        maxValue.value = widget.thermostat.maxCool;
      } else if (widget.thermostat.systemMode == TPThermostatMode.heat) {
        minValue.value = widget.thermostat.minHeat;
        maxValue.value = widget.thermostat.maxHeat;
      }
    });

    super.initState();
  }

  @override
  void didUpdateWidget(covariant _ThermostatSliderWidget oldWidget) {
    if (oldWidget.thermostat != widget.thermostat) {
      if (widget.thermostat.systemMode == TPThermostatMode.cool) {
        minValue.value = widget.thermostat.minCool;
        maxValue.value = widget.thermostat.maxCool;
      } else if (widget.thermostat.systemMode == TPThermostatMode.heat) {
        minValue.value = widget.thermostat.minHeat;
        maxValue.value = widget.thermostat.maxHeat;
      } else {
        minValue.value = 0;
        maxValue.value = 0;
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: _ThermostatSlider(
            thermostat: widget.thermostat,
            height: 300,
            onChangeTempurate: (p0, p1) {
              if (p1 == _TPThermostatDirectionThumb.max) {
                maxValue.value = p0;
              } else if (p1 == _TPThermostatDirectionThumb.min) {
                minValue.value = p0;
              }
            },
            onMinTempurateCompletion: widget.onMinTempurateCompletion,
            onMaxTempurateCompletion: widget.onMaxTempurateCompletion,
          ),
        ),
        Visibility(
          visible: minValue.value != 0 || maxValue.value != 0,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'KEEP BETWEEN',
                  style:
                      CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            color: Colors.orange,
                          ),
                ),
                const SizedBox(height: 6),
                ValueListenableBuilder(
                  valueListenable: minValue,
                  builder: ((context, value, child) {
                    return ValueListenableBuilder(
                      valueListenable: maxValue,
                      builder: ((context, value, child) {
                        return Text(
                          '${minValue.value.toStringAsFixed(1)} - ${maxValue.value.toStringAsFixed(1)}',
                          style: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .copyWith(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                        );
                      }),
                    );
                  }),
                ),
                Text(
                  'Celsius',
                  style:
                      CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
        Center(
          child: SizedBox(
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 120,
                  height: 80,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollEndNotification) {
                        final newModeSelected = TPThermostatMode
                            .values[_scrollController.selectedItem];
                        if (newModeSelected != widget.thermostat.systemMode) {
                          widget.onSelectedMode?.call(newModeSelected);
                        }
                      }

                      return true;
                    },
                    child: CupertinoPicker.builder(
                      scrollController: _scrollController,
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {},
                      selectionOverlay: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withAlpha(
                            (0.2 * 255).toInt(),
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ),
                      itemBuilder: (_, index) {
                        final item = TPThermostatMode.values[index];
                        return Center(
                          child: Text(
                            item.title.toUpperCase(),
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                      childCount: TPThermostatMode.values.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _ThermostatSlider extends LeafRenderObjectWidget {
  const _ThermostatSlider({
    required this.height,
    required this.thermostat,
    this.onChangeTempurate,
    this.onMinTempurateCompletion,
    this.onMaxTempurateCompletion,
  });

  final double height;
  final TPThermostat thermostat;
  final void Function(double)? onMinTempurateCompletion;
  final void Function(double)? onMaxTempurateCompletion;
  final void Function(double, _TPThermostatDirectionThumb?)? onChangeTempurate;

  @override
  _RenderThermostatSliderBox createRenderObject(BuildContext context) {
    return _RenderThermostatSliderBox(
      height: height,
      thermostat: thermostat,
      onChangeTempurate: onChangeTempurate,
      onMinTempurateCompletion: onMinTempurateCompletion,
      onMaxTempurateCompletion: onMaxTempurateCompletion,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderThermostatSliderBox renderObject) {
    renderObject.updateNewThermostat(thermostat);
  }
}

class _RenderThermostatSliderBox extends RenderBox {
  _RenderThermostatSliderBox(
      {required this.height,
      required this.thermostat,
      this.onChangeTempurate,
      this.onMinTempurateCompletion,
      this.onMaxTempurateCompletion}) {
    _initValues();

    _drag = PanGestureRecognizer()
      ..onStart = (DragStartDetails details) {}
      ..onUpdate = (DragUpdateDetails details) {
        _updateThumbPosition(details.localPosition);
      }
      ..onEnd = (DragEndDetails details) {
        if (_direction == _TPThermostatDirectionThumb.min) {
          onMinTempurateCompletion?.call(_currentMin!.temperatureRound());
        } else if (_direction == _TPThermostatDirectionThumb.max) {
          onMaxTempurateCompletion?.call(_currentMax!.temperatureRound());
        }

        _direction = null;

        markNeedsPaint();
        markNeedsSemanticsUpdate();
      };
  }

  final double height;
  final void Function(double)? onMinTempurateCompletion;
  final void Function(double)? onMaxTempurateCompletion;
  final void Function(double, _TPThermostatDirectionThumb?)? onChangeTempurate;

  TPThermostat thermostat;

  bool _isFirstDraw = false;
  _TPThermostatDirectionThumb? _direction;
  late PanGestureRecognizer _drag;
  late Path _cachingBackgroundPath;
  late Path _cachingStepsPath;
  double _absMin = 10;
  double _absMax = 40;
  double? _currentMin = 10;
  double? _currentMax = 40;
  double? _temperatureLimited = 10;
  double? _currentOccupiedCooling = 10;
  double? _currentOccupiedHeating = 40;

  final _startAngle = 0.75;
  final _sweepAngle = 1.5;
  final _endAngle = 2.25;
  final _thumbSize = 40.0;
  final _stepPadding = 10.0;
  final coldColors = [Colors.blue[900]!, Colors.blue, Colors.blue[100]!];
  final hotColors = [Colors.orange[100]!, Colors.orange, Colors.orange[900]!];
  List<Color> get _thumbColors {
    switch (thermostat.systemMode) {
      case TPThermostatMode.cool:
        return coldColors;
      case TPThermostatMode.heat:
        return hotColors;
      default:
        return [];
    }
  }

  double get _tempurateSteps => (_absMax - _absMin);
  double get _angleSteps => (_endAngle - _startAngle);
  double get _steps => _angleSteps / _tempurateSteps;
  double get _r => height / 2;
  double get _minTempurateAngle =>
      (max(_currentMin!, _absMin) - _absMin) * _steps + _startAngle;
  double get _maxTempurateAngle =>
      (min(_currentMax!, _absMax) - _absMin) * _steps + _startAngle;
  double get _tempurateLimitedAngle =>
      (min(_temperatureLimited!, _absMax) - _absMin) * _steps + _startAngle;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (_currentMax == null || _currentMin == null) return;

    if (event is PointerDownEvent) {
      final center = size.center(Offset.zero);
      final tmpThumbSize = (_thumbSize / 2);
      final minVector = _minTempurateAngle.convertAngleToVector2D(
          r: (_r - tmpThumbSize), center: center);
      final maxVector = _maxTempurateAngle.convertAngleToVector2D(
          r: (_r - tmpThumbSize), center: center);

      if (event.localPosition.dx > minVector.x - tmpThumbSize &&
          event.localPosition.dx < minVector.x + tmpThumbSize &&
          event.localPosition.dy > minVector.y - tmpThumbSize &&
          event.localPosition.dy < minVector.y + tmpThumbSize) {
        _direction = _TPThermostatDirectionThumb.min;
        _drag.addPointer(event);
      } else if (event.localPosition.dx > maxVector.x - tmpThumbSize &&
          event.localPosition.dx < maxVector.x + tmpThumbSize &&
          event.localPosition.dy > maxVector.y - tmpThumbSize &&
          event.localPosition.dy < maxVector.y + tmpThumbSize) {
        _direction = _TPThermostatDirectionThumb.max;
        _drag.addPointer(event);
      } else {
        _direction = null;
        return;
      }
    }
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.constrain(
      Size(height, height),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final center = size.center(Offset.zero);
    final canvas = context.canvas;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final circleBackgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _thumbSize
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withAlpha((0.4 * 255).toInt());

    final stepsPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = Colors.grey.withAlpha((0.7 * 255).toInt());

    final tmpTempurateSteps = _tempurateSteps * 2;
    final tmpAngleSteps = _angleSteps;
    final tmpSteps = tmpAngleSteps / tmpTempurateSteps;
    if (!_isFirstDraw) {
      _cachingBackgroundPath = Path()
        ..addArc(Rect.fromCircle(center: center, radius: _r - 20),
            _startAngle * pi, _sweepAngle * pi);

      _cachingStepsPath = Path();
      for (var i = 0; i <= tmpTempurateSteps; i++) {
        final radian = (_startAngle + tmpSteps * i);
        final d = radian.convertAngleToVector2D(
            r: (_r - _stepPadding), center: center);
        final d2 = radian.convertAngleToVector2D(
            r: (_r - (_thumbSize - _stepPadding)), center: center);
        _cachingStepsPath.moveTo(d.x, d.y);
        _cachingStepsPath.lineTo(d2.x, d2.y);
      }
    }

    canvas.saveLayer(Offset.zero & size, circleBackgroundPaint);
    canvas.drawPath(_cachingBackgroundPath, circleBackgroundPaint);
    canvas.restore();

    canvas.saveLayer(Offset.zero & size, stepsPaint);
    canvas.drawPath(_cachingStepsPath, stepsPaint);
    canvas.restore();

    if (_currentMin != null && _currentMax != null) {
      final controlPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 40
        ..shader = SweepGradient(
          colors: _thumbColors,
          startAngle: 0.5 * pi,
          endAngle: 2 * pi,
          transform: const GradientRotation(0.3 * pi),
        ).createShader(
          Rect.fromCircle(center: center, radius: _r),
        );

      canvas.drawArc(
          Rect.fromCircle(center: center, radius: _r - 20),
          _minTempurateAngle * pi,
          (_maxTempurateAngle - _minTempurateAngle) * pi,
          false,
          controlPaint);

      final swipePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Colors.white;

      final minD = _minTempurateAngle.convertAngleToVector2D(
          r: (_r - _stepPadding), center: center);
      final minD2 = _minTempurateAngle.convertAngleToVector2D(
          r: (_r - (_thumbSize - _stepPadding)), center: center);

      final maxD = _maxTempurateAngle.convertAngleToVector2D(
          r: (_r - _stepPadding), center: center);
      final maxD2 = _maxTempurateAngle.convertAngleToVector2D(
          r: (_r - (_thumbSize - _stepPadding)), center: center);

      if (_temperatureLimited != null) {
        final temperatureLimitedPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.butt
          ..shader = SweepGradient(
                  colors: (thermostat.systemMode == TPThermostatMode.heat)
                      ? coldColors
                      : hotColors)
              .createShader(
            Rect.fromCircle(center: center, radius: _r),
          );

        canvas.saveLayer(Offset.zero & size, temperatureLimitedPaint);
        final limitD = _tempurateLimitedAngle.convertAngleToVector2D(
            r: (_r), center: center);
        final limitD2 = _tempurateLimitedAngle.convertAngleToVector2D(
            r: (_r - _thumbSize), center: center);
        canvas.drawLine(Offset(limitD.x, limitD.y),
            Offset(limitD2.x, limitD2.y), temperatureLimitedPaint);
        canvas.restore();
      }

      canvas.drawLine(
          Offset(maxD.x, maxD.y), Offset(maxD2.x, maxD2.y), swipePaint);
      canvas.drawLine(
          Offset(minD.x, minD.y), Offset(minD2.x, minD2.y), swipePaint);
    }

    canvas.restore();
    _isFirstDraw = true;
  }

  void _updateThumbPosition(Offset localPosition) {
    final center = size.center(Offset.zero);
    final dx = center.dx - localPosition.dx;
    final dy = center.dy - localPosition.dy;
    double angleValue = atan2(dy, dx) * (180 / pi) + 180;
    if (angleValue >= 0 && angleValue <= 90) {
      angleValue += 360;
    }

    if (_direction == _TPThermostatDirectionThumb.min) {
      _currentMin = (((angleValue / 180) - _startAngle) / _steps) + _absMin;
      _currentMin = min(max(_currentMin!, _absMin), _currentMax! - 1);
      if (_temperatureLimited != null) {
        _currentMin = min(_temperatureLimited!, _currentMin!);
      }

      onChangeTempurate?.call(_currentMin!.temperatureRound(), _direction!);
    } else if (_direction == _TPThermostatDirectionThumb.max) {
      _currentMax = (((angleValue / 180) - _startAngle) / _steps) + _absMin;
      _currentMax = max(min(_currentMax!, _absMax), _currentMin! + 1);
      if (_temperatureLimited != null) {
        _currentMax = max(_temperatureLimited!, _currentMax!);
      }

      onChangeTempurate?.call(_currentMax!.temperatureRound(), _direction!);
    } else {
      return;
    }

    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  void updateNewThermostat(TPThermostat newThermostat) {
    thermostat = newThermostat;
    _initValues();

    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  void _initValues() {
    if (thermostat.systemMode == TPThermostatMode.cool) {
      _absMin =
          max(thermostat.absMinCool, thermostat.minHeat).temperatureRound();
      _absMax = thermostat.absMaxCool.temperatureRound();
      _currentMin = thermostat.minCool.temperatureRound();
      _currentMax = thermostat.maxCool.temperatureRound();
      _temperatureLimited = thermostat.maxHeat.temperatureRound();
    } else if (thermostat.systemMode == TPThermostatMode.heat) {
      _absMin = thermostat.absMinHeat.temperatureRound();
      _absMax =
          min(thermostat.absMaxHeat, thermostat.maxCool).temperatureRound();
      _currentMin = thermostat.minHeat.temperatureRound();
      _currentMax = thermostat.maxHeat.temperatureRound();
      _temperatureLimited = thermostat.minCool.temperatureRound();
    } else if (thermostat.systemMode == TPThermostatMode.auto) {
      _currentOccupiedHeating = thermostat.occupiedHeating;
      _currentOccupiedCooling = thermostat.occupiedCooling;
      _currentMin = null;
      _currentMax = null;
      _temperatureLimited = null;
    } else {
      _currentMin = null;
      _currentMax = null;
      _temperatureLimited = null;
    }
  }
}

extension _DoubleExt on double {
  double temperatureRound() {
    final remain = ((this * 10) % 10).round();
    if (remain == 0 || remain == 5) {
      return this;
    } else if (remain < 5) {
      return floorToDouble() + 0.5;
    } else {
      return roundToDouble();
    }
  }

  vmath.Vector2 convertAngleToVector2D({
    required double r,
    required Offset center,
  }) {
    final maxDx = r * cos(this * pi) + center.dx;
    final maxDy = r * sin(this * pi) + center.dy;
    return vmath.Vector2(maxDx, maxDy);
  }
}
