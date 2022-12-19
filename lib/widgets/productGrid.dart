import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/product_item.dart';
import '../providers/products.dart';

class ProductGrid extends StatelessWidget {
  final bool showFav;
  ProductGrid(this.showFav);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = showFav ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: products[i],
        child: ProductItem(
            // id: products[i].id,
            // imageUrl: products[i].imageUrl,
            // title: products[i].title,
            ),
      ),
    );
  }
}
