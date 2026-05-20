import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/domain/models/navigation_model.dart';
import 'package:ride_sharing_user_app/features/home/screens/home_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/notification/screens/notification_screen.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/screens/welcome%20to%20carpool.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageStorageBucket bucket = PageStorageBucket();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<NavigationModel> item = [
      NavigationModel(
        name: 'home'.tr,
        activeIcon: Images.homeActive,
        inactiveIcon: Images.homeOutline,
        screen: const HomeScreen(),
      ),
      NavigationModel(
          name: "carpool".tr,
          activeIcon: Images.peopleIcon,
  inactiveIcon: Images.peopleoutlineIcon,
          screen: const CarpoolScreen()),
      NavigationModel(
        name: 'activity'.tr,
        activeIcon: Images.activityActive,
        inactiveIcon: Images.activityOutline,
        screen:
            // WelcomePoolScreen()

            const TripScreen(fromProfile: false),
      ),
      NavigationModel(
        name: 'notification'.tr,
        activeIcon: Images.notificationActive,
        inactiveIcon: Images.notificationOutline,
        screen: const NotificationScreen(),
      ),
      NavigationModel(
        name: 'profile'.tr,
        activeIcon: Images.profileActive,
        inactiveIcon: Images.profileOutline,
        screen: const ProfileScreen(),
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, val) async {
        if (Get.find<BottomMenuController>().currentTab != 0) {
          Get.find<BottomMenuController>().setTabIndex(0);
          return;
        } else {
          Get.find<BottomMenuController>().exitApp();
        }
        return;
      },
      child: GetBuilder<BottomMenuController>(builder: (menuController) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(children: [
            PageStorage(
                bucket: bucket, child: item[menuController.currentTab].screen),
            ValueListenableBuilder<bool>(
              valueListenable:
                  Get.find<LocationController>().bottomNavVisibility,
              builder: (context, showBottomNav, child) {
                // Only show the bottom navigation bar if:
                // 1. locationController.bottomNavVisibility is true, OR
                // 2. we're not on the home screen (currentTab != 0)
                bool shouldShowBottomBar =
                    showBottomNav || menuController.currentTab != 0;

                return shouldShowBottomBar
                    ? Positioned(
                        child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault),
                          child: Container(
                            height: 65,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Theme.of(context).primaryColor,
                              boxShadow: [
                                BoxShadow(
                                    offset: const Offset(0, 4),
                                    blurRadius: 3,
                                    color: Colors.black.withOpacity(0.3))
                              ],
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: generateBottomNavigationItems(
                                    menuController, item)),
                          ),
                        ),
                      ))
                    : const SizedBox.shrink();
              },
            ),
          ]),
        );
      }),
    );
  }

  List<Widget> generateBottomNavigationItems(
      BottomMenuController menuController, List<NavigationModel> item) {
    List<Widget> items = [];
    for (int index = 0; index < item.length; index++) {
      items.add(Expanded(
          child: CustomMenuItem(
        isSelected: menuController.currentTab == index,
        name: item[index].name,
        activeIcon: item[index].activeIcon,
        inActiveIcon: item[index].inactiveIcon,
        onTap: () => menuController.setTabIndex(index),
      )));
    }
    return items;
  }
}

class CustomMenuItem extends StatelessWidget {
  final bool isSelected;
  final String name;
  final String activeIcon;
  final String inActiveIcon;
  final VoidCallback onTap;

  const CustomMenuItem({
    super.key,
    required this.isSelected,
    required this.name,
    required this.activeIcon,
    required this.inActiveIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
            width: isSelected ? 90 : 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  isSelected ? activeIcon : inActiveIcon,
                  color: activeIcon == Images.carTripeIcon && !isSelected
                      ? Colors.white.withOpacity(0.5)
                      : isSelected
                          ? Colors.white
                          : null,
                  width: Dimensions.menuIconSize,
                  height: Dimensions.menuIconSize,
                ),
                isSelected
                    ? Text(name.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textRegular.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeExtraSmall))
                    : const SizedBox(),
              ],
            )),
      ),
    );
  }
}
