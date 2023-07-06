import 'package:flutter/material.dart';
import 'package:rando/widgets/main_appbar.dart';
import 'package:rando/widgets/main_navbar.dart';
import '../widgets/profile_card.dart';
// import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../dummy_Data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_list.dart';
import '../providers/page_provider.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  final CardSwiperController controller = CardSwiperController();

  Widget mainPage(int page) {
    if (page == 0) {
      return Column(
        children: [
          MainAppBar(Colors.white),
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
          MainNavbar()
        ],
      );
    } else if (page == 1) {
      return Column(
        children: [MainAppBar(Colors.white), ChatPageScreen(), MainNavbar()],
      );
    } else if (page == 2) {
      return Column(
        children: [Expanded(child: Text('test')), MainNavbar()],
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width * 0.86,
        height: MediaQuery.of(context).size.height * 0.7,
      );
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
    return mainPage(selectedPageIndex);
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
