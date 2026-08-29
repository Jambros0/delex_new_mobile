import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RepairsChart extends StatefulWidget {
  final Map<String, dynamic> repairedChartCounts;
  final bool statusZero;
  final Map<String, int> statusCounts;
  const RepairsChart(
      {super.key,
      required this.repairedChartCounts,
      required this.statusZero,
      required this.statusCounts});

  @override
  State<RepairsChart> createState() => _RepairsChartState();
}

class _RepairsChartState extends State<RepairsChart> {
  late String svgString;

  @override
  void initState() {
    super.initState();
    svgString = getDynamicSvg(widget.repairedChartCounts);
  }

  @override
  void didUpdateWidget(covariant RepairsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.repairedChartCounts != oldWidget.repairedChartCounts) {
      setState(() {
        svgString = getDynamicSvg(widget.repairedChartCounts);
      });
    }
  }

  String getDynamicSvg(Map<String, dynamic> repairedChartCounts) {
    int totalRepairs = repairedChartCounts["total"] ?? 0;
    int redToGreen = repairedChartCounts["redToGreen"] ?? 0;
    int yellowToGreen = repairedChartCounts["yellowToGreen"] ?? 0;
    int redToYellow = repairedChartCounts["redToYellow"] ?? 0;

    String redToGreenGradient, yellowToGreenGradient, redToYellowGradient;

    if (totalRepairs > redToGreen) {
      double redToGreenRatio = redToGreen / totalRepairs;
      double redToRedRatio = 1 - redToGreenRatio;
      redToGreenGradient = '''
      <linearGradient id="gradRedToGreen" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="${redToRedRatio * 100}%" style="stop-color:#F44336;stop-opacity:1" />
          <stop offset="${redToGreenRatio * 100}%" style="stop-color:#4CAF50;stop-opacity:1" />
      </linearGradient>
  ''';
    } else if (totalRepairs == 0) {
      redToGreenGradient =
          '<linearGradient id="gradRedToGreen"><stop offset="100%" style="stop-color:#F44336;stop-opacity:1" /></linearGradient>';
    } else {
      redToGreenGradient =
          '<linearGradient id="gradRedToGreen"><stop offset="100%" style="stop-color:#4CAF50;stop-opacity:1" /></linearGradient>';
    }

    if (totalRepairs > yellowToGreen) {
      double yellowToGreenRatio = yellowToGreen / totalRepairs;
      double yellowToYellowRatio = 1 - yellowToGreenRatio;
      yellowToGreenGradient = '''
      <linearGradient id="gradYellowToGreen" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="${yellowToYellowRatio * 100}%" style="stop-color:#FFC107;stop-opacity:1" />
          <stop offset="${yellowToGreenRatio * 100}%" style="stop-color:#4CAF50;stop-opacity:1" />
      </linearGradient>
  ''';
    } else if (totalRepairs == 0) {
      yellowToGreenGradient =
          '<linearGradient id="gradYellowToGreen"><stop offset="100%" style="stop-color:#FFC107;stop-opacity:1" /></linearGradient>';
    } else {
      yellowToGreenGradient =
          '<linearGradient id="gradYellowToGreen"><stop offset="100%" style="stop-color:#4CAF50;stop-opacity:1" /></linearGradient>';
    }

    if (totalRepairs > redToYellow) {
      double redToYellowRatio = redToYellow / totalRepairs;
      double redToRedRatio = 1 - redToYellowRatio;
      redToYellowGradient = '''
      <linearGradient id="gradRedToYellow" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="${redToRedRatio * 100}%" style="stop-color:#F44336;stop-opacity:1" />
          <stop offset="${redToYellowRatio * 100}%" style="stop-color:#FFC107;stop-opacity:1" />
      </linearGradient>
  ''';
    } else if (totalRepairs == 0) {
      redToYellowGradient =
          '<linearGradient id="gradRedToYellow"><stop offset="100%" style="stop-color:#F44336;stop-opacity:1" /></linearGradient>';
    } else {
      redToYellowGradient =
          '<linearGradient id="gradRedToYellow"><stop offset="100%" style="stop-color:#FFC107;stop-opacity:1" /></linearGradient>';
    }

    String countText = '''
  <text x="118.723" y="113.196" text-anchor="middle" dominant-baseline="middle" font-size="14" font-weight="bold" fill="#333">$totalRepairs</text>
  ''';

    return '''
  <svg xmlns="http://www.w3.org/2000/svg" width="239" height="238" viewBox="0 0 239 238" fill="none">
      <defs>
          $redToGreenGradient
          $yellowToGreenGradient
          $redToYellowGradient
      </defs>
      <circle cx="118.723" cy="113.196" r="100" fill="url(#gradRedToGreen)" />
      <circle cx="118.723" cy="113.196" r="90" fill="#FFFFFF" />
      <circle cx="118.723" cy="113.196" r="75" fill="url(#gradYellowToGreen)" />
      <circle cx="118.723" cy="113.196" r="65" fill="#FFFFFF" />
      <circle cx="118.723" cy="113.196" r="50" fill="url(#gradRedToYellow)" />
      <circle cx="118.723" cy="113.196" r="40" fill="#FFFFFF" />
        $countText
  </svg>
  ''';
  }

  @override
  Widget build(BuildContext context) {
    int totalRepairs = widget.repairedChartCounts["total"] ?? 0;
    int redToGreen = widget.repairedChartCounts["redToGreen"] ?? 0;
    int yellowToGreen = widget.repairedChartCounts["yellowToGreen"] ?? 0;
    int redToYellow = widget.repairedChartCounts["redToYellow"] ?? 0;
    double redToGreenPercentage =
        (totalRepairs > 0) ? (redToGreen / totalRepairs) * 100 : 0;
    double yellowToGreenPercentage =
        (totalRepairs > 0) ? (yellowToGreen / totalRepairs) * 100 : 0;
    double redToYellowPercentage =
        (totalRepairs > 0) ? (redToYellow / totalRepairs) * 100 : 0;

    String formattedRedToGreenPercentage =
        redToGreenPercentage.toStringAsFixed(1);
    String formattedYellowToGreenPercentage =
        yellowToGreenPercentage.toStringAsFixed(1);
    String formattedRedToYellowPercentage =
        redToYellowPercentage.toStringAsFixed(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double screenHeight = MediaQuery.of(context).size.height;
        return Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Column(
            children: [
              Column(
                children: [
                  !widget.statusZero
                      ? (widget.statusCounts['partiallyRepaired'] ?? 0) > 0 ||
                              (widget.statusCounts['completelyRepaired'] ?? 0) >
                                  0 ||
                              (widget.statusCounts['pendingRepaired'] ?? 0) > 0
                          ? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SvgPicture.string(
                                  svgString,
                                  width: 213,
                                  height: 213,
                                ),
                                Positioned(
                                  left: -48,
                                  top: 25,
                                  child: SvgPicture.asset(
                                    'lib/src/features/dashboard/assets/svg/yellowToGreenLine.svg',
                                  ),
                                ),
                                Positioned(
                                  left: -85,
                                  top: 20,
                                  child: Column(
                                    children: [
                                      Text("$formattedYellowToGreenPercentage%",
                                          style: TextStyle(
                                              fontSize: screenHeight * 0.015,
                                              fontWeight: FontWeight.w600))
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 10,
                                  child: SvgPicture.asset(
                                    'lib/src/features/dashboard/assets/svg/redToYellowLine.svg',
                                  ),
                                ),
                                Positioned(
                                  right: -30,
                                  top: 4,
                                  child: Column(
                                    children: [
                                      Text("$formattedRedToYellowPercentage%",
                                          style: TextStyle(
                                              fontSize: screenHeight * 0.015,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: -10,
                                  bottom: 15,
                                  child: SvgPicture.asset(
                                    'lib/src/features/dashboard/assets/svg/redToGreenLine.svg',
                                  ),
                                ),
                                Positioned(
                                  right: -45,
                                  bottom: 10,
                                  child: Column(
                                    children: [
                                      Text("$formattedRedToGreenPercentage%",
                                          style: TextStyle(
                                              fontSize: screenHeight * 0.015,
                                              fontWeight: FontWeight.w600))
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              width: screenWidth * 0.3,
                              height: screenHeight * 0.3,
                              child: const Center(
                                child: Text("No Record Found"),
                              ))
                      : SizedBox(
                          width: screenWidth * 0.3,
                          height: screenHeight * 0.3,
                          child: const Center(
                            child: Text("No Record Found"),
                          )),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ToggleWidget(
                    number: widget.repairedChartCounts["redToGreen"] ?? 0,
                    colors: const [Colors.red, Colors.green],
                    firstColor: Colors.red,
                    secondColor: Colors.green,
                    label: 'Red > Green',
                  ),
                  SizedBox(
                    width: screenWidth * 0.016,
                  ),
                  ToggleWidget(
                    number: widget.repairedChartCounts["yellowToGreen"] ?? 0,
                    colors: const [Colors.yellow, Colors.green],
                    firstColor: Colors.yellow,
                    secondColor: Colors.green,
                    label: 'Yellow > Green',
                  ),
                  SizedBox(
                    width: screenWidth * 0.016,
                  ),
                  ToggleWidget(
                    number: widget.repairedChartCounts["redToYellow"] ?? 0,
                    colors: const [Colors.red, Colors.yellow],
                    firstColor: Colors.red,
                    secondColor: Colors.yellow,
                    label: 'Red > Yellow',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ToggleWidget extends StatelessWidget {
  final int number;
  final List<Color> colors;
  final Color firstColor;
  final Color secondColor;
  final String label;

  const ToggleWidget({
    super.key,
    required this.number,
    required this.colors,
    required this.firstColor,
    required this.secondColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: firstColor,
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(15)),
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: secondColor,
                    borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(15)),
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 8,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(width: 8),
                Text(
                  '$number',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}
