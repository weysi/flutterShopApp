import 'package:flutter/material.dart';
import 'package:flutter_shop_app/screens/orders_screen.dart';
import './screens/splash_screen.dart';
import 'package:provider/provider.dart';
import '../screens/cart_screen.dart';
import '../providers/cart.dart';

import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/auth.dart';
import './providers/orders.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './helpers/custome_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => Auth(),
      builder: (ctx, _) => MultiProvider(
        providers: [
          ChangeNotifierProxyProvider<Auth, Products>(
              create: (_) => Products(
                    Provider.of<Auth>(ctx, listen: false).token,
                    Provider.of<Auth>(ctx, listen: false).userId,
                    [],
                  ),
              // lazy: false,
              update: (ctx, auth, productList) => Products(
                    auth.token,
                    Provider.of<Auth>(ctx, listen: false).userId,
                    productList == null ? [] : productList.items,
                  )),
          ChangeNotifierProvider.value(
            value: Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (_) => Orders(Provider.of<Auth>(ctx, listen: false).token,
                Provider.of<Auth>(ctx, listen: false).userId, []),
            // lazy: false,
            update: (ctx, auth, previousOrder) => Orders(
              auth.token,
              auth.userId,
              previousOrder == null ? [] : previousOrder.orders,
            ),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MyShop',
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
            theme: ThemeData(
                colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: Colors.purple,
                  accentColor: Colors.deepOrange,
                ).copyWith(secondary: Colors.deepOrange),
                fontFamily: 'Lato',
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android: CustomPageTransitionBuilder(),
                  TargetPlatform.iOS: CustomPageTransitionBuilder()
                })),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
            },
          ),
        ),
      ),
    );
  }
}
