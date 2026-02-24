import 'dart:math' as math;
import '../math/math.dart';
import '../core/node.dart';
import '../core/puppet.dart';
import '../components/simple_physics.dart';
import '../params/param_ctx.dart';
import 'pendulum.dart';

/// Physics simulation state for a node
class PhysicsState {
  final PuppetNodeUuid nodeId;
  final SimplePhysics config;
  final Pendulum pendulum;

  PhysicsState({
    required this.nodeId,
    required this.config,
    required this.pendulum,
  });
}

/// Physics context for managing physics simulation
class PhysicsCtx {
  final PuppetPhysics globalPhysics;
  final List<PhysicsState> _states = [];
  double _elapsedTime = 0;

  static const double _maxFrameTime = 10.0; // Max 10 seconds per frame
  static const double _timestep = 0.01; // 10ms timestep for stability

  PhysicsCtx(this.globalPhysics, PuppetNodeTree nodes) {
    _initialize(nodes);
  }

  void _initialize(PuppetNodeTree nodes) {
    for (final treeNode in nodes.preOrder()) {
      final node = treeNode.data;
      final components = node.components;
      if (components == null || components.simplePhysics == null) continue;

      final config = components.simplePhysics!;
      final anchor = Vec2(
        node.transOffset.translation.x,
        node.transOffset.translation.y,
      );

      Pendulum pendulum;
      if (config.model == PhysicsModel.rigidPendulum) {
        pendulum = RigidPendulum(
          anchor: anchor,
          length: config.length,
          frequency: config.angleFrequency,
          dampingRatio: config.angleDampingRatio,
        );
      } else {
        pendulum = SpringPendulum(
          anchor: anchor,
          length: config.length,
          frequencyX: config.frequency,
          frequencyY: config.frequency,
          dampingRatioX: config.dampingRatio,
          dampingRatioY: config.dampingRatio,
        );
      }

      _states.add(PhysicsState(
        nodeId: node.uuid,
        config: config,
        pendulum: pendulum,
      ));
    }
  }

  /// Update physics simulation
  void update(double dt, ParamCtx? paramCtx) {
    if (dt < 0) {
      throw ArgumentError('Delta time cannot be negative');
    }

    // Always update anchors from input parameters, even when dt=0.
    // This ensures physics state stays in sync with programmatic
    // parameter changes (e.g., MCP set_param).
    _updateAnchorsFromInputParams(paramCtx);

    // Clamp frame time
    dt = math.min(dt, _maxFrameTime);
    _elapsedTime += dt;

    // Fixed timestep integration
    while (dt >= _timestep) {
      _tick(_timestep);
      dt -= _timestep;
    }

    // Handle remaining time
    if (dt > 0) {
      _tick(dt);
    }

    // Always write output params (even at dt=0) so the pendulum's
    // current position is reflected in the parameter values.
    _writeOutputParams(paramCtx);
  }

  /// Read input parameters and update pendulum anchors.
  void _updateAnchorsFromInputParams(ParamCtx? paramCtx) {
    if (paramCtx == null) return;
    for (final state in _states) {
      final config = state.config;
      if (config.inputParamId == null) continue;

      // Get normalized [-1..1] value regardless of the param's native range.
      final normalized = paramCtx.getNormalized(config.inputParamId!);
      if (normalized == null) continue;

      // Displace anchor by normalized input scaled by pendulum length.
      state.pendulum.anchor = Vec2(
        normalized.x * config.length,
        normalized.y * config.length,
      );
    }
  }

  /// Write pendulum output to mapped parameters.
  void _writeOutputParams(ParamCtx? paramCtx) {
    if (paramCtx == null) return;
    for (final state in _states) {
      final config = state.config;
      if (config.mapParamId == null) continue;

      final gravity = config.localGravity ?? globalPhysics.gravity;
      final output = state.pendulum.calcOutput(gravity);
      final scaled = output * config.outputScale;
      paramCtx.setValue(config.mapParamId!, scaled);
    }
  }

  void _tick(double dt) {
    for (final state in _states) {
      final config = state.config;
      final gravity = config.localGravity ?? globalPhysics.gravity;
      state.pendulum.tick(dt, gravity);
    }
  }

  /// Reset all physics states
  void reset() {
    for (final state in _states) {
      state.pendulum.reset();
    }
    _elapsedTime = 0;
  }

  /// Get elapsed simulation time
  double get elapsedTime => _elapsedTime;
}
