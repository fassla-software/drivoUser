import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/screens/set_destination_carpool_screen.dart';

class CarpoolScreen extends StatefulWidget {
  const CarpoolScreen({super.key});

  @override
  State<CarpoolScreen> createState() => _CarpoolScreenState();
}

class _CarpoolScreenState extends State<CarpoolScreen> {
  bool isEditing = false;
  bool _showTripScreen = false;
  String _selectedCarpoolType = 'trip';

  List<String> titles = ["One Trip", "Travel", "Routine", "North Coast"];
  List<String> subtitles = [
    "Book a ride instantly",
    "Travel from and to anywhere in Egypt",
    "Weekly and Monthly rides",
    "Summer trips inside north coast"
  ];

  void goToNext(String type) {
    setState(() {
      _selectedCarpoolType = type;
      _showTripScreen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showTripScreen) {
      return SetDestinationCarPoolScreen(
        fromDashboard: true,
        carpoolType: _selectedCarpoolType,
        onBackToWelcome: () => setState(() => _showTripScreen = false),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),

      // ================= APP BAR =================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 16),
        child: Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: const AppBarTheme(
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
          ),
          child: AppBarWidget(
            title: 'Welcome to Carpool',
            showBackButton: true,
            centerTitle: true,
            isShowIcon: true,
            height: kToolbarHeight + 16,
            toolbarHeight: kToolbarHeight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ================= BODY (OVERLAP DESIGN) =================
      body: Stack(
        children: [
          Container(color: const Color.fromARGB(255, 0, 0, 0)),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: Container(
                color: const Color(0xFFF4F5F7),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // ================= OPTIONS =================
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Column(
                        children: List.generate(
                          titles.length,
                          (index) => OptionTile(
                            icon: [
                              Icons.directions_car,
                              Icons.flight_takeoff,
                              Icons.repeat,
                              Icons.beach_access
                            ][index],
                            title: titles[index],
                            subtitle: subtitles[index],
                            color: [
                              Colors.teal,
                              Colors.blue,
                              Colors.orange,
                              Colors.purple
                            ][index],
                            isEditing: isEditing,
                            onTitleChanged: (value) =>
                                setState(() => titles[index] = value),
                            onSubtitleChanged: (value) =>
                                setState(() => subtitles[index] = value),
                            onTap: () => goToNext(
                              [
                                'trip',
                                'travel',
                                'routine',
                                'north_coast'
                              ][index],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 200),

                    // ================= BADGES =================
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: InfoBadge(
                              icon: Icons.account_balance_wallet,
                              title: "Save Money",
                              subtitle: "Split rides cost",
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: InfoBadge(
                              icon: Icons.people,
                              title: "Meet People",
                              subtitle: "Connect easily",
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: InfoBadge(
                              icon: Icons.eco,
                              title: "Eco Friendly",
                              subtitle: "Reduce CO₂",
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => setState(() => isEditing = !isEditing),
      //   child: Icon(isEditing ? Icons.check : Icons.edit),
      // ),
    );
  }
}

// ================= OPTION TILE =================
class OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;
  final bool isEditing;
  final ValueChanged<String>? onTitleChanged;
  final ValueChanged<String>? onSubtitleChanged;

  const OptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
    this.isEditing = false,
    this.onTitleChanged,
    this.onSubtitleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: isEditing ? null : onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: isEditing
          ? TextField(
              controller: TextEditingController(text: title),
              onChanged: onTitleChanged,
              decoration: const InputDecoration(border: InputBorder.none),
            )
          : Text(title),
      subtitle: isEditing
          ? TextField(
              controller: TextEditingController(text: subtitle),
              onChanged: onSubtitleChanged,
              decoration: const InputDecoration(border: InputBorder.none),
            )
          : Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }
}

// ================= BADGE =================
class InfoBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const InfoBadge({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 6),
        Text(title, textAlign: TextAlign.center),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
