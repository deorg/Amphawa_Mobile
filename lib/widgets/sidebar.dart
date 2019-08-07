import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SideBar extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    const List _drawerMenu = [
      {
        'id': '02',
        "image": "assets/images/drawer/earning.jpg",
        "url": "/catalog"
      },
      {
        'id': '03',
        "image": "assets/images/drawer/order.jpeg",
        "url": "/catalog"
      },
      {
        'id': '04',
        "image": "assets/images/drawer/installment.png",
        "url": "/catalog"
      },
      {
        'id': '05',
        "image": "assets/images/drawer/preference.png",
        "url": "/catalog"
      },
      {
        'id': '06',
        "image": "assets/images/drawer/about.png",
        "url": "/catalog"
      }
    ];
    // AnimationController _controller;
    // _controller = AnimationController(
    //   duration: const Duration(milliseconds: 200),
    // );
    // Animation<double> _drawerContentsOpacity;
    // _drawerContentsOpacity = CurvedAnimation(
    //   parent: ReverseAnimation(_controller),
    //   curve: Curves.fastOutSlowIn,
    // );
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: const Text('สาย ณัฏฐพัชร'),
            accountEmail: const Text('สาขา 12'),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage(
                'assets/images/profile/48.jpg',
                // package: _kGalleryAssetsPackage,
              ),
            ),
            otherAccountsPictures: <Widget>[
              GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                onTap: () {
                  // _onOtherAccountsTap(context);
                },
                child: Semantics(
                  label: 'Switch to Account B',
                  child: const CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/images/profile/48.jpg',
                      // package: _kGalleryAssetsPackage,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                dragStartBehavior: DragStartBehavior.down,
                onTap: () {
                  // _onOtherAccountsTap(context);
                },
                child: Semantics(
                  label: 'Switch to Account C',
                  child: const CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/images/profile/48.jpg',
                      // package: _kGalleryAssetsPackage,
                    ),
                  ),
                ),
              ),
            ],
            margin: EdgeInsets.zero,
            onDetailsPressed: () {
              // _showDrawerContents = !_showDrawerContents;
              // if (_showDrawerContents)
              //   _controller.reverse();
              // else
              //   _controller.forward();
            },
          ),
          MediaQuery.removePadding(
            context: context,
            // DrawerHeader consumes top MediaQuery padding.
            removeTop: true,
            child: Expanded(
              child: ListView(
                dragStartBehavior: DragStartBehavior.down,
                padding: const EdgeInsets.only(top: 8.0),
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _drawerMenu.map<Widget>((menu) {
                          return ListTile(
                            // leading: CircleAvatar(backgroundImage: AssetImage(menu['image']),),
                            title: Text(menu['id']),
                            onTap: (){},
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}