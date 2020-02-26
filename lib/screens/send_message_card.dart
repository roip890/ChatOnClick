import 'dart:math';

import 'package:contacts_service/contacts_service.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complete_guide/bloc/deeplink/DeepLinkBloc.dart';
import 'package:provider/provider.dart';
import '../bloc/bloc.dart';
import '../bloc/contact/contact_state.dart';
import '../models/message.dart';
import '../models/phone_number.dart';
import 'package:libphonenumber/libphonenumber.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_number/phone_number.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../helpers/permissions.dart';
import '../bloc/contact/contact_bloc.dart';

class MessageCard extends StatefulWidget {

  const MessageCard({
    Key key,
  }) : super(key: key);

  @override
  _MessageCardState createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard>
    with SingleTickerProviderStateMixin {

  PermissionStatus _contactsPermissionStatus = PermissionStatus.unknown;

  final GlobalKey<FormState> _formKey = GlobalKey();
  Map<String, dynamic> _messageData = {
    'contact': null,
    'prefix': 'IL',
    'number': '',
    'message': '',
  };
  var _withMessage = false;
  var _isLoading = false;
  final _numberController = TextEditingController();
  final _messageController = TextEditingController();
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;
  ContactBloc _contactBloc;
  MessageBloc _messageBloc;
  List<Contact> _contacts;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    // _heightAnimation.addListener(() => setState(() {}));

    _checkContactsPermissionStatus();
    _contactBloc = BlocProvider.of<ContactBloc>(context);
    _messageBloc = BlocProvider.of<MessageBloc>(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
    _numberController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _requestContactsPermission();
  }

  void _checkContactsPermissionStatus() {
    final Future<PermissionStatus> statusFuture =
    PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);

    statusFuture.then((PermissionStatus status) {
      setState(() {
        _contactsPermissionStatus = status;
      });
    });
  }

  Future<void> _requestContactsPermission() async {
    PermissionStatus contactsPermissionResult =
    await Permissions.requestPermission(PermissionGroup.contacts);

    setState(() {
      _contactsPermissionStatus = contactsPermissionResult;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    // save or fetch the contact
    try {
      if (_messageData['contact'] == null
          || (_messageData['contact'] as Contact).phones.toList()[0].value != _messageData['number']) {
        Iterable<Contact> contacts
        = await ContactsService.getContacts(query : _messageData['number'], withThumbnails: false);
        _messageData['contact'] = contacts.toList().firstWhere((Contact contact) =>
        contact.phones.toList().length > 0
            && contact.phones.toList()[0].value == _messageData['number'], orElse: () => null);
      }
    } catch (e) {
      print(e.toString());
    }

    // go to send message
    try {
//      String parsed = await PhoneNumberUtil.normalizePhoneNumber(phoneNumber: _messageData['number'], isoCode: _messageData['prefix']);
      dynamic parsed = await PhoneNumber().parse(_messageData['number'], region: _messageData['prefix']);
      if (parsed != null && parsed['e164'] != null) {
        final url = 'https://api.whatsapp.com/send?phone=${parsed['e164']}'
            + (_withMessage && _messageData['message'].isNotEmpty ? '&text=${_messageData['message']}': '');
        if (await canLaunch(url)) {

          // launch whatsapp
          await launch(url);

          // save message on db
          try {
            if (_messageData['number'] != null && _messageData['number'].toString().isNotEmpty
                && _messageData['message'] != null && _messageData['message'].toString().isNotEmpty) {
              _messageBloc.add(AddMessage(Message(
                phoneNumber: MessagePhoneNumber(
                  prefix: _messageData['prefix'],
                  number: _messageData['number'],
                  formatted: parsed['e164'],
                ),
                content: _messageData['message'],
                timestamp: DateTime.now(),
                contact: _messageData['contact'],
              )));
            }
          } catch (error) {
            print(error);
          }
        } else {
          _showErrorDialog('Failed to send message');
        }
      }


    } catch (error) {
      _showErrorDialog('Failed to send message');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchMessageMode() {
    if (!_withMessage) {
      setState(() {
        _withMessage = !_withMessage;
      });
      _controller.forward();
    } else {
      setState(() {
        _withMessage = !_withMessage;
      });
      _controller.reverse();
    }
  }

  List<Contact> _filterContacts(List<Contact> contacts, String query) {
    if (contacts == null) {
      return List<Contact>();
    }
    return contacts.where((contact) => _filterContact(contact, query)).toList();
  }

  bool _filterContact(Contact contact, String query) {
    if (contact != null && contact.displayName != null  && contact.phones != null
        && (contact.phones.any((phone) => phone.value.contains(query))
            || contact.displayName.contains(query))) {
      return true;
    }
    return false;
  }

  String _cleanNumberLink(String numberLink) {
      if (numberLink != null && numberLink.startsWith('tel:')) {
        return numberLink.substring(4);
      }
      return numberLink;
  }

  @override
  Widget build(BuildContext context) {
    DeepLinkBloc _bloc = Provider.of<DeepLinkBloc>(context);
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _withMessage ? 300 : 240,
        // height: _heightAnimation.value.height,
        constraints:
        BoxConstraints(minHeight: _withMessage ? 300 : 240),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                StreamBuilder<String>(
                  stream: _bloc.state,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      _numberController.text = _cleanNumberLink(snapshot.data);
                      _messageData['number'] = _cleanNumberLink(snapshot.data);
                    }
                    return _buildNumberField();
                  },
                ),
                _buildMessageField(),
                SizedBox(
                  height: 10,
                ),
                _buildSwitchButton(),
                SizedBox(
                  height: 10,
                ),
                _isLoading
                    ? CircularProgressIndicator()
                    : _buildSendButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountryCode() {
    return new CountryCodePicker(
      onChanged: _onCountryChange,
      initialSelection: 'IL',
      favorite: ['+972','IL'],
      showCountryOnly: false,
      showOnlyCountryWhenClosed: false,
      alignLeft: false,
      textStyle: TextStyle(
        fontSize: 16
      ),
    );
  }

  void _onCountryChange(CountryCode countryCode) {
    _messageData['prefix'] = countryCode.code;
  }

  Widget _buildAutocompleteNumberField({bool loadLocal = false}) {
    return  TypeAheadFormField(
      autoFlipDirection: true,
      textFieldConfiguration: TextFieldConfiguration(
          controller: this._numberController,
          decoration: InputDecoration(
              labelText: 'Number'
          )
      ),
      direction: AxisDirection.up,
      suggestionsCallback: (pattern) async {
        Iterable<Contact> filteredContacts = loadLocal
            ? _filterContacts(_contacts, pattern)
            :await ContactsService.getContacts(query : pattern, withThumbnails: false);
        return filteredContacts.toList().sublist(0, min(10, filteredContacts.length));
      },
      itemBuilder: (context, suggestion) {
        Contact contact = suggestion as Contact;
        return ListTile(
          title: Text(contact.displayName != null
              ? contact.displayName
              : contact.phones.toList().length > 0
              ? contact.phones.toList()[0].value
              : 'No Title!'
          ),
          subtitle: Text(contact.phones.toList().length > 0
              ? contact.phones.toList()[0].value
              : 'No Phone Number!'
          ),
        );
      },
      transitionBuilder: (context, suggestionsBox, controller) {
        return suggestionsBox;
      },
      onSuggestionSelected: (suggestion) {
        Contact contact = suggestion as Contact;
        if (contact != null && contact.phones.toList().length > 0) {
          _messageData['contact'] = contact;
          _messageData['number'] = contact.phones.toList()[0].value;
        }
        this._numberController.text = contact.phones.toList().length > 0
            ? contact.phones.toList()[0].value
            : _numberController.text;
      },
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter number!';
        }
        return null;
      },
      onSaved: (value) {
        this._messageData['number'] = value;
      },
    );
  }

  Widget _buildNonAutocompleteNumberField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Number'),
      controller: _numberController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter number!';
        }
        return null;
      },
      onSaved: (value) => this._messageData['number'] = value,
    );
  }

  Widget _buildNumberTextField() {
    return _contactsPermissionStatus == PermissionStatus.granted
        ? BlocBuilder<ContactBloc, ContactState>(
      builder: (context, state) {
        if (state is ContactsLoaded && state.contacts != null) {
          _contacts = state.contacts != null ? state.contacts : List<Contact>();
          return _buildAutocompleteNumberField(loadLocal: true);
        } else if (state is ContactsSnapshotLoaded && state.contacts != null) {
          _contactBloc.add(LoadContacts());
          _contacts = state.contacts != null ? state.contacts : List<Contact>();
          return _buildAutocompleteNumberField(loadLocal: true);
        }
//        return _buildAutocompleteNumberField(loadLocal: false);
        return _buildNonAutocompleteNumberField();
      },
    )
        : _buildNonAutocompleteNumberField();
  }

  Widget _buildNumberField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        _buildCountryCode(),
        SizedBox(
          width: 5,
        ),
        Expanded(
          child: _buildNumberTextField(),
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return AnimatedContainer(
      constraints: BoxConstraints(
        minHeight: _withMessage ? 60 : 0,
        maxHeight: _withMessage ? 120 : 0,
      ),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: TextFormField(
            enabled: _withMessage,
            decoration:
            InputDecoration(labelText: 'Message'),
            controller: _messageController,
            validator: _withMessage
                ? (value) {
              if (value.isEmpty) {
                return 'Please enter a message!';
              }
              return null;
            }
                : null,
            onSaved: (value) {
              _messageData['message'] = value;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return RaisedButton(
      child:
      Text('${_withMessage ? 'Send' : 'Go'}'),
      onPressed: _submit,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding:
      EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
      color: Theme.of(context).primaryColor,
      textColor: Theme.of(context).primaryTextTheme.button.color,
    );
  }

  Widget _buildSwitchButton() {
    return FlatButton.icon(
      icon: Icon(
        _withMessage ? Icons.arrow_drop_up : Icons.arrow_drop_down,
      ),
      label: Text(
          '${_withMessage ? 'Remove Message' : 'Add Message'}'),
      onPressed: _switchMessageMode,
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: Theme.of(context).primaryColor,
    );
  }
}
