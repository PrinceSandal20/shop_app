import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlControler = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _edittedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );

  var _inItValues = {
    'title': '',
    'description': '',
    'price': '',
    'imgUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _edittedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _inItValues = {
          'title': _edittedProduct.title,
          'description': _edittedProduct.description,
          'price': _edittedProduct.price.toString(),
          // 'imgUrl': _edittedProduct.imageUrl,
          'imgUrl': '',
        };
        _imageUrlControler.text = _edittedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlControler.text.startsWith('http') &&
              !_imageUrlControler.text.startsWith('https')) ||
          (!_imageUrlControler.text.endsWith('png') &&
              !_imageUrlControler.text.endsWith('jpg') &&
              !_imageUrlControler.text.endsWith('jpeg'))) return;
    }
    setState(() {});
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_edittedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_edittedProduct.id, _edittedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_edittedProduct);
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An Error Occured'),
            content: Text('Something Went wrong.'),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text('Okay'))
            ],
          ),
        );
        // }
        // finally {
        //   setState(() {
        //     _isLoading = false;
        //   });
        //   Navigator.of(context).pop();
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(children: [
                  TextFormField(
                    initialValue: _inItValues['title'],
                    decoration: InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_priceFocusNode);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please Provide a value.';
                      } else
                        return null;
                    },
                    onSaved: (value) {
                      _edittedProduct = Product(
                        title: value,
                        price: _edittedProduct.price,
                        description: _edittedProduct.description,
                        imageUrl: _edittedProduct.imageUrl,
                        id: _edittedProduct.id,
                        isFavorite: _edittedProduct.isFavorite,
                      );
                    },
                  ),
                  TextFormField(
                    initialValue: _inItValues['price'],
                    decoration: InputDecoration(labelText: 'Price'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _priceFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a Price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please Enter a valid Number';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Please Enter A Number Greaer than zero';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _edittedProduct = Product(
                        title: _edittedProduct.title,
                        price: double.parse(value),
                        description: _edittedProduct.description,
                        imageUrl: _edittedProduct.imageUrl,
                        id: _edittedProduct.id,
                        isFavorite: _edittedProduct.isFavorite,
                      );
                    },
                  ),
                  TextFormField(
                    initialValue: _inItValues['description'],
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    focusNode: _descriptionFocusNode,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a Description.';
                      } else if (value.length < 10) {
                        return 'Abe Thoda bade to Karde!!';
                      } else
                        return null;
                    },
                    onSaved: (value) {
                      _edittedProduct = Product(
                        title: _edittedProduct.title,
                        price: _edittedProduct.price,
                        description: value,
                        imageUrl: _edittedProduct.imageUrl,
                        id: _edittedProduct.id,
                        isFavorite: _edittedProduct.isFavorite,
                      );
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: EdgeInsets.only(
                          top: 8,
                          right: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                        ),
                        child: _imageUrlControler.text.isEmpty
                            ? Text('Enter a Url')
                            : FittedBox(
                                child: Image.network(
                                  _imageUrlControler.text,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      Expanded(
                        child: TextFormField(
                          // initialValue: _inItValues['imgUrl'],
                          decoration: InputDecoration(labelText: 'Image URL'),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          controller: _imageUrlControler,
                          focusNode: _imageUrlFocusNode,
                          onFieldSubmitted: (_) {
                            _saveForm();
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Enter A Url';
                            }
                            if (!value.startsWith('http') &&
                                !value.startsWith('https')) {
                              return 'Please Enter Valid Url';
                            }
                            if (!value.endsWith('png') &&
                                !value.endsWith('jpg') &&
                                !value.endsWith('jpeg')) {
                              return 'Please Enter Valid Url';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _edittedProduct = Product(
                              title: _edittedProduct.title,
                              price: _edittedProduct.price,
                              description: _edittedProduct.description,
                              imageUrl: value,
                              id: _edittedProduct.id,
                              isFavorite: _edittedProduct.isFavorite,
                            );
                          },
                          // onEditingComplete: () {
                          //   setState(() {});
                          // },
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
    );
  }
}
