import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tp_flutter_matter_package/channels/devices/tp_device_control_manager.dart';
import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/models/tp_device_lightbulb_dimmer.dart';
import 'package:tp_flutter_matter_package_example/managers/tp_device_manager.dart';

enum LightActionType { brightness, temperatureColor, hueColor }

class TPLightbulbDimmerWidget extends StatefulWidget {
  const TPLightbulbDimmerWidget({super.key, required this.device});

  final ValueNotifier<TPDevice> device;

  @override
  State<TPLightbulbDimmerWidget> createState() => _TPLightbulbDimmerWidget();
}

class _TPLightbulbDimmerWidget extends State<TPLightbulbDimmerWidget> {
  final _level = ValueNotifier<double>(0);
  final _actionTypeSelected = ValueNotifier(LightActionType.brightness);

  TPLightbulbDimmer get dimmerDevice {
    return widget.device.value as TPLightbulbDimmer;
  }

  @override
  void initState() {
    _level.value = dimmerDevice.level.toDouble();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.device,
        builder: (_, device, __) {
          return ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height / 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                CupertinoButton(
                  child: Column(
                    children: [
                      Image(
                        image: dimmerDevice.getIcon(),
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dimmerDevice.getStatusText(),
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    final response = await dimmerDevice.toggle();
                    if (response is TPDeviceControlSuccess) {
                      await TPDeviceManager().updateDevice(device);
                    }
                  },
                ),
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    height: 250,
                    // child: _tempurateColorSlider(dimmerDevice),
                    child: ValueListenableBuilder(
                      valueListenable: _actionTypeSelected,
                      builder: (_, type, __) {
                        switch (type) {
                          case LightActionType.brightness:
                            return _brightnessSlider(dimmerDevice);
                          case LightActionType.temperatureColor:
                            return _tempurateColorSliderWidget(dimmerDevice);
                          case LightActionType.hueColor:
                            return _hueColorSliderWidget(dimmerDevice);
                          default:
                            return Container();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (dimmerDevice.isSupportedColorControl)
                  SizedBox(
                    height: 50,
                    child: ValueListenableBuilder(
                      valueListenable: _actionTypeSelected,
                      builder: (_, type, __) {
                        return CupertinoSlidingSegmentedControl<
                            LightActionType>(
                          groupValue: type,
                          backgroundColor: CupertinoColors.systemGrey2,
                          children: {
                            LightActionType.brightness: Text(
                              'Brightness',
                              style: Theme.of(context).textTheme.button,
                            ),
                            LightActionType.temperatureColor: Text(
                              'Temperature',
                              style: Theme.of(context).textTheme.button,
                            ),
                            LightActionType.hueColor: Text(
                              'Colors',
                              style: Theme.of(context).textTheme.button,
                            ),
                          },
                          onValueChanged: (value) {
                            _actionTypeSelected.value = value!;
                          },
                        );
                      },
                    ),
                  ),
                if (dimmerDevice.isSupportedColorControl)
                  const SizedBox(height: 8),
              ],
            ),
          );
        });
  }

  Widget _brightnessSlider(TPLightbulbDimmer device) {
    return RotatedBox(
      quarterTurns: -45,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 100,
          overlayShape: SliderComponentShape.noOverlay,
          thumbShape: SliderComponentShape.noThumb,
          trackShape: const _RoundedRectSliderTrackShape(),
        ),
        child: ValueListenableBuilder(
          valueListenable: _level,
          builder: (context, value, child) {
            return Slider(
              min: 0,
              max: 100,
              value: value,
              onChanged: (value) {
                _level.value = value;
              },
              onChangeEnd: (value) async {
                final response = await dimmerDevice.controlLevel(value.toInt());
                if (response is TPDeviceControlError) {
                  _level.value = device.level.toDouble();
                  return;
                }

                await TPDeviceManager().updateDevice(device);
              },
              inactiveColor: Colors.black45,
              activeColor: Colors.white,
            );
          },
        ),
      ),
    );
  }

  Widget _tempurateColorSliderWidget(TPLightbulbDimmer device) {
    return _TempurateColorSlider(
      height: 250,
      temperatureColor: device.temperatureColor.toDouble(),
      endDrag: (p0) async {
        final response = await dimmerDevice.controlTemperatureColor(p0.toInt());
        if (response is TPDeviceControlError) {}

        await TPDeviceManager().updateDevice(device);
      },
    );
  }

  Widget _hueColorSliderWidget(TPLightbulbDimmer device) {
    return _HUEColorSlider(
      height: 250,
      hsvColor: HSVColor.fromAHSV(
          1, device.hue.toDouble(), device.saturation.toDouble(), 1),
      endDrag: (p0) async {
        final response = dimmerDevice.controlHueAndSaturationColor(
            p0.hue.toInt(), p0.saturation.toInt());
        if (response is TPDeviceControlSuccess) {
          await TPDeviceManager().updateDevice(device);
        }
      },
    );
  }
}

class _RoundedRectSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  const _RoundedRectSliderTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting  can be a no-op.
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    final double trackHeight = sliderTheme.trackHeight ?? 0;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    const Radius trackRadius = Radius.circular(25);

    context.canvas.clipRRect(
      RRect.fromLTRBR(trackRect.left, trackRect.top, trackRect.right,
          trackRect.bottom, trackRadius),
    );

    // Active/Inactive tracks
    context.canvas.drawRRect(
      RRect.fromLTRBR(
        trackRect.left,
        trackRect.top - (additionalActiveTrackHeight / 2),
        thumbCenter.dx,
        trackRect.bottom + (additionalActiveTrackHeight / 2),
        Radius.zero,
      ),
      activePaint,
    );

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          thumbCenter.dx - 10,
          thumbCenter.dy -
              (trackHeight / 2) +
              ((trackHeight - (trackHeight / 3)) / 2),
          5,
          trackHeight / 3,
        ),
        const Radius.circular(5.0),
      ),
      inactivePaint,
    );

    context.canvas.drawRRect(
      RRect.fromLTRBR(
        thumbCenter.dx,
        trackRect.top,
        trackRect.right,
        trackRect.bottom,
        Radius.zero,
      ),
      inactivePaint,
    );
  }
}

//TempurateColorSlider

class _TempurateColorSlider extends LeafRenderObjectWidget {
  const _TempurateColorSlider({
    required this.height,
    required this.temperatureColor,
    this.endDrag,
  });

  final double height;
  final double temperatureColor;
  final void Function(double)? endDrag;

  @override
  _RenderTempurateColorSliderBox createRenderObject(BuildContext context) {
    return _RenderTempurateColorSliderBox(
      height: height,
      temperatureColor: temperatureColor,
      endDrag: endDrag,
    );
  }

  @override
  void updateRenderObject(BuildContext context,
      covariant _RenderTempurateColorSliderBox renderObject) {
    renderObject.updateNewTemperatureColor(temperatureColor);
  }
}

class _RenderTempurateColorSliderBox extends RenderBox {
  _RenderTempurateColorSliderBox({
    required this.height,
    required this.temperatureColor,
    this.endDrag,
  }) {
    _tempValue = max(temperatureColor, mink);
    _drag = PanGestureRecognizer()
      ..onStart = (DragStartDetails details) {}
      ..onUpdate = (DragUpdateDetails details) {
        _updateThumbPosition(details.localPosition);
      }
      ..onEnd = (DragEndDetails details) {
        endDrag?.call(_tempValue);
      };
  }

  static const mink = 2000.0;
  static const maxk = 10000.0;
  static const step = ((maxk - mink) / 180);
  static const paddingCircleCenter = 80.0;
  static const thumbSize = 20.0;

  final double height;
  double temperatureColor;
  final void Function(double)? endDrag;

  late PanGestureRecognizer _drag;

  final List<Color> _colorTemps = [];
  double _tempValue = 9000;
  double _angleValue = 0;
  bool _isFirstDraw = false;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      final center = size.center(Offset.zero);
      final r = height / 2;
      if (event.localPosition.dx < center.dx - r ||
          event.localPosition.dx > center.dx + r ||
          event.localPosition.dy < center.dy - r ||
          event.localPosition.dy > center.dy + r) {
        return;
      }

      _drag.addPointer(event);
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
    final canvas = context.canvas;
    final r = height / 2;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    if (_colorTemps.isEmpty) {
      for (var i = 0; i <= 360; i++) {
        double colorTemp = mink.toDouble();
        if (i <= 180) {
          colorTemp = maxk - (i * step);
        } else {
          colorTemp = maxk - ((360 - i) * step);
        }

        _colorTemps.add(ColorExt.colorTempToRGB(colorTemp));
      }
    }

    Paint tempCirclePaint = Paint();
    tempCirclePaint.shader = SweepGradient(
      colors: _colorTemps,
      startAngle: 0,
      endAngle: pi * 2,
    ).createShader(
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: r,
        height: r,
      ),
    );

    final circlePath = Path()
      ..fillType = PathFillType.evenOdd
      ..addArc(
          Rect.fromCenter(
              center: size.center(Offset.zero), width: height, height: height),
          0,
          2 * pi)
      ..addArc(
          Rect.fromCenter(
              center: size.center(Offset.zero),
              width: height - paddingCircleCenter * 2,
              height: height - paddingCircleCenter * 2),
          0,
          2 * pi);
    canvas.drawPath(circlePath, tempCirclePaint);

    //caculate current temp
    if (!_isFirstDraw) {
      _angleValue = (_tempValue - mink) / step + 180;
    } else {
      if (_angleValue <= 180) {
        _tempValue = maxk - (_angleValue * step);
      } else {
        _tempValue = maxk - ((360 - _angleValue) * step);
      }
    }

    Paint thumbPaint = Paint()..color = ColorExt.colorTempToRGB(_tempValue);
    final center = size.center(Offset.zero);
    final currentRadian = _angleValue * (pi / 180);
    final dx = (r - paddingCircleCenter / 2) * cos(currentRadian) + center.dx;
    final dy = (r - paddingCircleCenter / 2) * sin(currentRadian) + center.dy;

    canvas.drawShadow(
        Path()
          ..addArc(Rect.fromCircle(center: Offset(dx, dy), radius: thumbSize),
              0, pi * 2),
        Colors.black,
        6.0,
        false);
    canvas.drawCircle(Offset(dx, dy), thumbSize, thumbPaint);
    canvas.restore();

    _isFirstDraw = true;
  }

  void _updateThumbPosition(Offset localPosition) {
    final center = size.center(Offset.zero);
    final dx = center.dx - localPosition.dx;
    final dy = center.dy - localPosition.dy;
    _angleValue = atan2(dy, dx) * (180 / pi) + 180;

    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  void updateNewTemperatureColor(double temperatureColor) {
    this.temperatureColor = temperatureColor;
    _tempValue = max(temperatureColor, mink);
    _isFirstDraw = false;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }
}

//HUEColorSlider

class _HUEColorSlider extends LeafRenderObjectWidget {
  const _HUEColorSlider({
    required this.height,
    required this.hsvColor,
    this.endDrag,
  });

  final double height;
  final HSVColor hsvColor;
  final void Function(HSVColor)? endDrag;

  @override
  _RenderHUEColorSliderBox createRenderObject(BuildContext context) {
    return _RenderHUEColorSliderBox(
      height: height,
      hsvColor: hsvColor,
      endDrag: endDrag,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderHUEColorSliderBox renderObject) {
    renderObject.updateNewHVSColor(hsvColor);
  }
}

class _RenderHUEColorSliderBox extends RenderBox {
  _RenderHUEColorSliderBox({
    required this.height,
    required this.hsvColor,
    this.endDrag,
  }) {
    _drag = PanGestureRecognizer()
      ..onStart = (DragStartDetails details) {}
      ..onUpdate = (DragUpdateDetails details) {
        _updateThumbPosition(details.localPosition);
      }
      ..onEnd = (DragEndDetails details) {
        endDrag?.call(HSVColor.fromAHSV(1, _angleValue, 1, 1));
      };
  }

  static const paddingCircleCenter = 80.0;
  static const thumbSize = 20.0;

  final double height;
  final void Function(HSVColor)? endDrag;

  HSVColor hsvColor;

  late PanGestureRecognizer _drag;

  final List<Color> _colorTemps = [];
  double _angleValue = 0;
  bool _isFirstDraw = false;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      final center = size.center(Offset.zero);
      final r = height / 2;
      if (event.localPosition.dx < center.dx - r ||
          event.localPosition.dx > center.dx + r ||
          event.localPosition.dy < center.dy - r ||
          event.localPosition.dy > center.dy + r) {
        return;
      }

      _drag.addPointer(event);
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
    final canvas = context.canvas;
    final r = height / 2;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    if (_colorTemps.isEmpty) {
      for (var i = 0; i <= 360; i++) {
        _colorTemps.add(
          HSVColor.fromAHSV(1, i.toDouble(), 1, 1).toColor(),
        );
      }
    }

    Paint tempCirclePaint = Paint();
    tempCirclePaint.shader = SweepGradient(
      colors: _colorTemps,
      startAngle: 0,
      endAngle: pi * 2,
    ).createShader(
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: r,
        height: r,
      ),
    );

    final circlePath = Path()
      ..fillType = PathFillType.evenOdd
      ..addArc(
          Rect.fromCenter(
              center: size.center(Offset.zero), width: height, height: height),
          0,
          2 * pi)
      ..addArc(
          Rect.fromCenter(
              center: size.center(Offset.zero),
              width: height - paddingCircleCenter * 2,
              height: height - paddingCircleCenter * 2),
          0,
          2 * pi);
    canvas.drawPath(circlePath, tempCirclePaint);

    //caculate current temp
    if (!_isFirstDraw) {
      _angleValue = hsvColor.hue;
    }

    Paint thumbPaint = Paint()
      ..color = HSVColor.fromAHSV(1, _angleValue, 1, 1).toColor();
    final center = size.center(Offset.zero);
    final currentRadian = _angleValue * (pi / 180);
    final dx = (r - paddingCircleCenter / 2) * cos(currentRadian) + center.dx;
    final dy = (r - paddingCircleCenter / 2) * sin(currentRadian) + center.dy;

    canvas.drawShadow(
        Path()
          ..addArc(Rect.fromCircle(center: Offset(dx, dy), radius: thumbSize),
              0, pi * 2),
        Colors.black,
        6.0,
        false);
    canvas.drawCircle(Offset(dx, dy), thumbSize, thumbPaint);
    canvas.restore();

    _isFirstDraw = true;
  }

  void _updateThumbPosition(Offset localPosition) {
    final center = size.center(Offset.zero);
    final dx = center.dx - localPosition.dx;
    final dy = center.dy - localPosition.dy;
    _angleValue = atan2(dy, dx) * (180 / pi) + 180;

    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  void updateNewHVSColor(HSVColor hsvColor) {
    this.hsvColor = hsvColor;
    _isFirstDraw = false;

    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }
}

extension ColorExt on Color {
  static Color colorTempToRGB(double colorTemp) {
    final temp = colorTemp / 100;

    final red = temp <= 66
        ? 255
        : (pow(temp - 60, -0.1332047592) * 329.698727446).round().clamp(0, 255);

    final green = temp <= 66
        ? (99.4708025861 * log(temp) - 161.1195681661).round().clamp(0, 255)
        : (pow(temp - 60, -0.0755148492) * 288.1221695283)
            .round()
            .clamp(0, 255);

    final blue = temp >= 66
        ? 255
        : temp <= 19
            ? 0
            : (138.5177312231 * log(temp - 10) - 305.0447927307)
                .round()
                .clamp(0, 255);

    return Color.fromARGB(255, red, green, blue);
  }
}
