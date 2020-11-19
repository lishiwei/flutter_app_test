import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

double ourMap(v, start1, stop1, start2, stop2) {
  return (v - start1) / (stop1 - start1) * (stop2 - start2) + start2;
}
class TabEntry{
  String title;
  String mount;

  TabEntry(this.title, this.mount);
}
class MyTabBar extends StatefulWidget {
  List<TabEntry> tabs ;
  List<Widget> pageViews  ;

  MyTabBar(this.tabs, this.pageViews);

  @override
  _MyTabBarState createState() => _MyTabBarState(this.tabs, this.pageViews);
}

class _MyTabBarState extends State<MyTabBar>
    with SingleTickerProviderStateMixin {
  final int initPage = 0;
  PageController _pageController;
  List<TabEntry> tabs ;
  List<Widget> pageViews  ;
  Stream<int> get currentPage$ => _currentPageSubject.stream;
  Sink<int> get currentPageSink => _currentPageSubject.sink;
  BehaviorSubject<int> _currentPageSubject;
  Alignment _dragAlignment;
  AnimationController _controller;
  Animation<Alignment> _animation;
  @override
  void initState() {
    super.initState();
    _currentPageSubject = BehaviorSubject<int>.seeded(initPage);
    _pageController = PageController(initialPage: initPage);
    _dragAlignment = Alignment(ourMap(initPage, 0, tabs.length - 1, -1, 1), 0);

    _controller = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    )..addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });
    });

    currentPage$.listen((int page) {
      _runAnimation(
        _dragAlignment,
        Alignment(ourMap(page, 0, tabs.length - 1, -1, 1), 0),
      );
    });
  }

  @override
  void dispose() {
    _currentPageSubject.close();
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _runAnimation(Alignment oldA, Alignment newA) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: oldA,
        end: newA,
      ),
    );
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return
    Container(child:  Column(

      children: <Widget>[
        SizedBox(height:  20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Container(
            child: Stack(
              children: <Widget>[
                StreamBuilder(
                  stream: currentPage$,
                  builder: (context, AsyncSnapshot<int> snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      return AnimatedAlign(
                        duration: kThemeAnimationDuration,
                        alignment: Alignment(
                            ourMap(snapshot.data, 0, tabs.length - 1, -1, 1),
                            0),
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            double width = constraints.maxWidth;
                            return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Column(
                                children: [
                                  Padding(padding: EdgeInsets.all(20.0)),
                                  Container(
                                    height:2,
                                    width: width / tabs.length,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return SizedBox();
                  },
                ),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: tabs.map((t) {
                      int index = tabs.indexOf(t);
                      return Column(children: [
                        Text(tabs[index].title),
                        Text(tabs[index].mount)
                      ],);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (page) => currentPageSink.add(page),
            children: pageViews,
          ),
        ),
      ],
    ),);

  }

  _MyTabBarState(this.tabs, this.pageViews);
}