import 'package:flutter/material.dart';
import 'package:rando/screens/main_page.dart';
import 'package:rando/screens/profile_page.dart';
import 'package:rando/widgets/main_appbar.dart';
import 'package:rando/widgets/main_navbar.dart';
import 'profile_card.dart';
// import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../dummy_Data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/chat_list.dart';
import '../providers/page_provider.dart';

class MainPageWidget extends ConsumerStatefulWidget {
  // final String chatroomList;
  final String userId;

  const MainPageWidget({
    super.key,
    // required this.chatroomList,
    required this.userId,
  });

  @override
  ConsumerState<MainPageWidget> createState() => _MainPageWidgetState();
}

class _MainPageWidgetState extends ConsumerState<MainPageWidget> {
  final CardSwiperController controller = CardSwiperController();

  Widget MainPageWidget(int page) {
    print('current_user: ${widget.userId}');

    if (page == 0) {
      return Column(
        children: [
          MainAppBar(Colors.white, widget.userId),
          Expanded(
            child: CardSwiper(
              controller: controller,
              cardsCount: profiles.length,
              onSwipe: _onSwipe,
              onUndo: _onUndo,
              backCardOffset: const Offset(40, 40),
              padding: const EdgeInsets.all(24.0),
              cardBuilder: (
                context,
                index,
                horizontalThresholdPercentage,
                verticalThresholdPercentage,
              ) =>
                  ProfileCard(profiles[index], controller),
            ),
          ),
          const MainNavbar()
        ],
      );
    } else if (page == 1) {
      // print(widget.chatroomList);
      return Column(
        children: [
          MainAppBar(Colors.white, widget.userId),
          ChatPageScreen(
            // chatroomList: widget.chatroomList,
            userId: widget.userId,
          ),
          const MainNavbar()
        ],
      );
    } else if (page == 2) {
      return Column(
        children: [
          MainAppBar(Colors.white, widget.userId),
          Expanded(
            child: ProfilePageScreen(userId: widget.userId),
          ),
          const MainNavbar()
        ],
      );
    } else {
      return MainPageScreen(userId: widget.userId);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPageIndex = ref.watch(selectPageProvider);
    return MainPageWidget(selectedPageIndex);
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint(
      'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
    );
    return true;
  }

  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint(
      'The card $currentIndex was undod from the ${direction.name}',
    );
    return true;
  }
}
