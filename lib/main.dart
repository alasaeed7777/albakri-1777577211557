```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ø­Ø§Ø³Ø¨Ø©',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1E88E5),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF1E88E5),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double _firstOperand = 0;
  String _operator = '';
  bool _waitingForSecondOperand = false;
  String _memory = '';
  bool _isRadians = true;

  void _onDigitPressed(String digit) {
    setState(() {
      if (_waitingForSecondOperand) {
        _display = digit;
        _waitingForSecondOperand = false;
      } else {
        _display = _display == '0' ? digit : _display + digit;
      }
    });
  }

  void _onDecimalPressed() {
    setState(() {
      if (_waitingForSecondOperand) {
        _display = '0.';
        _waitingForSecondOperand = false;
        return;
      }
      if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _onOperatorPressed(String operator) {
    setState(() {
      if (_operator.isNotEmpty && !_waitingForSecondOperand) {
        _calculate();
      }
      _firstOperand = double.parse(_display);
      _operator = operator;
      _waitingForSecondOperand = true;
      _expression = '$_firstOperand $operator';
    });
  }

  void _onUnaryOperatorPressed(String operator) {
    setState(() {
      final value = double.parse(_display);
      double result;
      switch (operator) {
        case 'â':
          result = sqrt(value);
          break;
        case 'xÂ²':
          result = value * value;
          break;
        case 'xÂ³':
          result = value * value * value;
          break;
        case '1/x':
          result = 1 / value;
          break;
        case 'sin':
          result = _isRadians ? sin(value) : sin(value * pi / 180);
          break;
        case 'cos':
          result = _isRadians ? cos(value) : cos(value * pi / 180);
          break;
        case 'tan':
          result = _isRadians ? tan(value) : tan(value * pi / 180);
          break;
        case 'log':
          result = log10(value);
          break;
        case 'ln':
          result = log(value);
          break;
        case '10^x':
          result = pow(10, value).toDouble();
          break;
        case 'e^x':
          result = exp(value);
          break;
        case 'x!':
          result = _factorial(value);
          break;
        case 'Â±':
          result = -value;
          break;
        default:
          result = value;
      }
      _display = _formatResult(result);
      _expression = '$operator($value) =';
    });
  }

  double _factorial(double n) {
    if (n < 0 || n != n.floor()) return double.nan;
    int num = n.toInt();
    if (num == 0 || num == 1) return 1;
    double result = 1;
    for (int i = 2; i <= num; i++) {
      result *= i;
    }
    return result;
  }

  void _calculate() {
    if (_operator.isEmpty) return;
    final secondOperand = double.parse(_display);
    double result;
    switch (_operator) {
      case '+':
        result = _firstOperand + secondOperand;
        break;
      case '-':
        result = _firstOperand - secondOperand;
        break;
      case 'Ã':
        result = _firstOperand * secondOperand;
        break;
      case 'Ã·':
        result = secondOperand != 0 ? _firstOperand / secondOperand : double.nan;
        break;
      case '%':
        result = _firstOperand * (secondOperand / 100);
        break;
      case '^':
        result = pow(_firstOperand, secondOperand).toDouble();
        break;
      default:
        result = secondOperand;
    }
    _display = _formatResult(result);
    _expression = '$_firstOperand $_operator $secondOperand =';
    _operator = '';
    _waitingForSecondOperand = true;
  }

  String _formatResult(double result) {
    if (result.isNaN || result.isInfinite) {
      return 'Error';
    }
    if (result == result.floor() && result.abs() < 1e15) {
      return result.toInt().toString();
    }
    return result.toStringAsFixed(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _onEqualsPressed() {
    setState(() {
      _calculate();
    });
  }

  void _onClearPressed() {
    setState(() {
      _display = '0';
      _expression = '';
      _firstOperand = 0;
      _operator = '';
      _waitingForSecondOperand = false;
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  void _onMemoryPressed(String action) {
    setState(() {
      switch (action) {
        case 'MC':
          _memory = '';
          break;
        case 'MR':
          if (_memory.isNotEmpty) {
            _display = _memory;
            _waitingForSecondOperand = false;
          }
          break;
        case 'M+':
          _memory = _display;
          break;
        case 'M-':
          _memory = _display;
          break;
      }
    });
  }

  void _toggleAngleMode() {
    setState(() {
      _isRadians = !_isRadians;
    });
  }

  void _onPiPressed() {
    setState(() {
      _display = pi.toStringAsFixed(10);
      _waitingForSecondOperand = false;
    });
  }

  void _onEPressed() {
    setState(() {
      _display = e.toStringAsFixed(10);
      _waitingForSecondOperand = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ø­Ø§Ø³Ø¨Ø©'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isRadians ? Icons.radar : Icons.rotate_90_degrees_ccw),
            tooltip: _isRadians ? 'RAD' : 'DEG',
            onPressed: _toggleAngleMode,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _expression,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _display,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          _buildButtonPanel(theme),
        ],
      ),
    );
  }

  Widget _buildButtonPanel(ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _buildMemoryRow(theme),
            const SizedBox(height: 8),
            _buildScientificRow(theme),
            const SizedBox(height: 8),
            _buildAdvancedRow(theme),
            const SizedBox(height: 8),
            _buildMainRow1(theme),
            const SizedBox(height: 8),
            _buildMainRow2(theme),
            const SizedBox(height: 8),
            _buildMainRow3(theme),
            const SizedBox(height: 8),
            _buildMainRow4(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryRow(ThemeData theme) {
    return Row(
      children: [
        _calcButton('MC', theme, onPressed: () => _onMemoryPressed('MC')),
        const SizedBox(width: 8),
        _calcButton('MR', theme, onPressed: () => _onMemoryPressed('MR')),
        const SizedBox(width: 8),
        _calcButton('M+', theme, onPressed: () => _onMemoryPressed('M+')),
        const SizedBox(width: 8),
        _calcButton('M-', theme, onPressed: () => _onMemoryPressed('M-')),
      ],
    );
  }

  Widget _buildScientificRow(ThemeData theme) {
    return Row(
      children: [
        _calcButton('sin', theme, onPressed: () => _onUnaryOperatorPressed('sin')),
        const SizedBox(width: 8),
        _calcButton('cos', theme, onPressed: () => _onUnaryOperatorPressed('cos')),
        const SizedBox(width: 8),
        _calcButton('tan', theme, onPressed: () => _onUnaryOperatorPressed('tan')),
        const SizedBox(width: 8),
        _calcButton('Ï', theme, onPressed: _onPiPressed),
        const SizedBox(width: 8),
        _calcButton('e', theme, onPressed: _onEPressed),
      ],
    );
  }

  Widget _buildAdvancedRow(ThemeData theme) {
    return Row(
      children: [
        _calcButton('xÂ²', theme, onPressed: () => _onUnaryOperatorPressed('xÂ²')),
        const SizedBox(width: 8),
        _calcButton('xÂ³', theme, onPressed: () => _onUnaryOperatorPressed('xÂ³')),
        const SizedBox(width: 8),
        _calcButton('â', theme, onPressed: () => _onUnaryOperatorPressed('â')),
        const SizedBox(width: 8),
        _calcButton('1/x', theme, onPressed: () => _onUnaryOperatorPressed('1/x')),
        const SizedBox(width: 8),
        _calcButton('x!', theme, onPressed: () => _onUnaryOperatorPressed('x!')),
      ],
    );
  }

  Widget _buildMainRow1(ThemeData theme) {
    return Row(
      children: [
        _calcButton('log', theme, onPressed: () => _onUnaryOperatorPressed('log')),
        const SizedBox(width: 8),
        _calcButton('ln', theme, onPressed: () => _onUnaryOperatorPressed('ln')),
        const SizedBox(width: 8),
        _calcButton('10^x', theme, onPressed: () => _onUnaryOperatorPressed('10^x')),
        const SizedBox(width: 8),
        _calcButton('e^x', theme, onPressed: () => _onUnaryOperatorPressed('e^x')),
        const SizedBox(width: 8),
        _calcButton('^', theme, isOperator: true, onPressed: () => _onOperatorPressed('^')),
      ],
    );
  }

  Widget _buildMainRow2(ThemeData theme) {
    return Row(
      children: [
        _calcButton('C', theme, isClear: true, onPressed: _onClearPressed),
        const SizedBox(width: 8),
        _calcButton('â«', theme, isClear: true, onPressed: _onDeletePressed),
        const SizedBox(width: 8),
        _calcButton('%', theme, isOperator: true, onPressed: () => _onOperatorPressed('%')),
        const SizedBox(width: 8),
        _calcButton('Ã·', theme, isOperator: true, onPressed: () => _onOperatorPressed('Ã·')),
      ],
    );
  }

  Widget _buildMainRow3(ThemeData theme) {
    return Row(
      children: [
        _calcButton('7', theme, onPressed: () => _onDigitPressed('7')),
        const SizedBox(width: 8),
        _calcButton('8', theme, onPressed: () => _onDigitPressed('8')),
        const SizedBox(width: 8),
        _calcButton('9', theme, onPressed: () => _onDigitPressed('9')),
        const SizedBox(width: 8),
        _calcButton('Ã', theme, isOperator: true, onPressed: () => _onOperatorPressed('Ã')),
      ],
    );
  }

  Widget _buildMainRow4(ThemeData theme) {
    return Row(
      children: [
        _calcButton('4', theme, onPressed: () => _onDigitPressed('4')),
        const SizedBox(width: 8),
        _calcButton('5', theme, onPressed: () => _onDigitPressed('5')),
        const SizedBox(width: 8),
        _calcButton('6', theme, onPressed: () => _onDigitPressed('6')),
        const SizedBox(width: 8),
        _calcButton('-', theme, isOperator: true, onPressed: () => _onOperatorPressed('-')),
      ],
    );
  }

  Widget _buildMainRow5(ThemeData theme) {
    return Row(
      children: [
        _calcButton('1', theme, onPressed: () => _onDigitPressed('1')),
        const SizedBox(width: 8),
        _calcButton('2', theme, onPressed: () => _onDigitPressed('2')),
        const SizedBox(width: 8),
        _calcButton('3', theme, onPressed: () => _onDigitPressed('3')),
        const SizedBox(width: 8),
        _calcButton('+', theme, isOperator: true, onPressed: () => _onOperatorPressed('+')),
      ],
    );
  }

  Widget _buildMainRow6(ThemeData theme) {
    return Row(
      children: [
        _calcButton('Â±', theme, onPressed: () => _onUnaryOperatorPressed('Â±')),
        const SizedBox(width: 8),
        _calcButton('0', theme, onPressed: () => _onDigitPressed('0')),
        const SizedBox(width: 8),
        _calcButton('.', theme, onPressed: _onDecimalPressed),
        const SizedBox(width: 8),
        _calcButton('=', theme, isEquals: true, onPressed: _onEqualsPressed),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ø­Ø§Ø³Ø¨Ø©'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isRadians ? Icons.radar : Icons.rotate_90_degrees_ccw),
            tooltip: _isRadians ? 'RAD' : 'DEG',
            onPressed: _toggleAngleMode,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _expression,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _display,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          _buildButtonPanel(theme),
        ],
      ),
    );
  }

  Widget _buildButtonPanel(ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _buildMemoryRow(theme),
            const SizedBox(height: 8),
            _buildScientificRow(theme),
            const SizedBox(height: 8),
            _buildAdvancedRow(theme),
            const SizedBox(height: 8),
            _buildMainRow1(theme),
            const SizedBox(height: 8),
            _buildMainRow2(theme),
            const SizedBox(height: 8),
            _buildMainRow3(theme),
            const SizedBox(height: 8),
            _buildMainRow4(theme),
            const SizedBox(height: 8),
            _buildMainRow5(theme),
            const SizedBox(height: 8),
            _buildMainRow6(theme),
          ],
        ),
      ),
    );
  }

  Widget _calcButton(
    String text,
    ThemeData theme, {
    bool isOperator = false,
    bool isClear = false,
    bool isEquals = false,
    VoidCallback? onPressed,
  }) {
    Color? backgroundColor;
    Color? foregroundColor;
    if (isOperator) {
      backgroundColor = theme.colorScheme.primaryContainer;
      foregroundColor = theme.colorScheme.onPrimaryContainer;
    } else if (isClear) {
      backgroundColor = theme.colorScheme.errorContainer;
     