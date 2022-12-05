import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CreditCardForm extends StatefulWidget {
  const CreditCardForm({
    Key? key,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
    this.obscureCvv = false,
    this.obscureNumber = false,
    required this.onCreditCardModelChange,
    required this.themeColor,
    this.textColor = Colors.black,
    this.cursorColor,
    this.cardHolderDecoration = const InputDecoration(
      labelText: 'Card holder',
    ),
    this.cardNumberDecoration = const InputDecoration(
      labelText: 'Card number',
      hintText: 'XXXX XXXX XXXX XXXX',
    ),
    this.expiryDateDecoration = const InputDecoration(
      labelText: 'Expired Date',
      hintText: 'MM/YY',
    ),
    this.cvvCodeDecoration = const InputDecoration(
      labelText: 'CVV',
      hintText: 'XXX',
    ),
    required this.formKey,
    this.cardNumberKey,
    this.cardHolderKey,
    this.expiryDateKey,
    this.cvvCodeKey,
    this.cvvValidationMessage = 'Please input a valid CVV',
    this.dateValidationMessage = 'Please input a valid date',
    this.numberValidationMessage = 'Please input a valid number',
    this.isHolderNameVisible = true,
    this.isCardNumberVisible = true,
    this.isExpiryDateVisible = true,
    this.autovalidateMode,
    this.cardNumberValidator,
    this.expiryDateValidator,
    this.cvvValidator,
    this.cardHolderValidator,
    this.onFormComplete,
  }) : super(key: key);

  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final String cvvValidationMessage;
  final String dateValidationMessage;
  final String numberValidationMessage;
  final void Function(CreditCardModel) onCreditCardModelChange;
  final Color themeColor;
  final Color textColor;
  final Color? cursorColor;
  final bool obscureCvv;
  final bool obscureNumber;
  final bool isHolderNameVisible;
  final bool isCardNumberVisible;
  final bool isExpiryDateVisible;
  final GlobalKey<FormState> formKey;
  final Function? onFormComplete;

  final GlobalKey<FormFieldState<String>>? cardNumberKey;
  final GlobalKey<FormFieldState<String>>? cardHolderKey;
  final GlobalKey<FormFieldState<String>>? expiryDateKey;
  final GlobalKey<FormFieldState<String>>? cvvCodeKey;

  final InputDecoration cardNumberDecoration;
  final InputDecoration cardHolderDecoration;
  final InputDecoration expiryDateDecoration;
  final InputDecoration cvvCodeDecoration;
  final AutovalidateMode? autovalidateMode;

  final String? Function(String?)? cardNumberValidator;
  final String? Function(String?)? expiryDateValidator;
  final String? Function(String?)? cvvValidator;
  final String? Function(String?)? cardHolderValidator;

  @override
  _CreditCardFormState createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  late String cardNumber;
  late String expiryDate;
  late String cardHolderName;
  late String cvvCode;
  bool isCvvFocused = false;
  late Color themeColor;

  late void Function(CreditCardModel) onCreditCardModelChange;
  late CreditCardModel creditCardModel;
  FocusNode focusNode = FocusNode();
  String statusCardNumber = 'initial';
  bool isValidCardNumber = true;
  String statusExpiryDate = 'initial';
  bool isValidExpiryDate = true;
  String statusCvv = 'initial';
  bool isValidCvv = true;

  final MaskedTextController _cardNumberController =
      MaskedTextController(mask: '0000 0000 0000 0000');
  final TextEditingController _expiryDateController =
      MaskedTextController(mask: '00/00');
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final TextEditingController _cvvCodeController =
      MaskedTextController(mask: '0000');

  FocusNode cvvFocusNode = FocusNode();
  FocusNode expiryDateNode = FocusNode();
  FocusNode cardHolderNode = FocusNode();

  void textFieldFocusDidChange() {
    creditCardModel.isCvvFocused = cvvFocusNode.hasFocus;
    onCreditCardModelChange(creditCardModel);
  }

  void createCreditCardModel() {
    cardNumber = widget.cardNumber;
    expiryDate = widget.expiryDate;
    cardHolderName = widget.cardHolderName;
    cvvCode = widget.cvvCode;

    creditCardModel = CreditCardModel(
      cardNumber,
      expiryDate,
      cardHolderName,
      cvvCode,
      isCvvFocused,
    );
  }

  void focusListener() {
    focusNode.addListener(() async {
      if (!focusNode.hasFocus) {
        setState(() {
          statusCardNumber = 'unFocus';
          checkCardNumber();
        });
      }
    });
  }

  void checkCardNumber() {
    if (_cardNumberController.text.isEmpty ||
        _cardNumberController.text.length < 16) {
      isValidCardNumber = false;
    } else {
      isValidCardNumber = true;
    }
  }

  void focusListenerExpiry() {
    expiryDateNode.addListener(() async {
      if (!expiryDateNode.hasFocus) {
        setState(() {
          statusExpiryDate = 'unFocus';
          checkExpiryDate();
        });
      }
    });
  }

  void checkExpiryDate() {
    if (_expiryDateController.text.isEmpty) {
      setState(() {
        isValidExpiryDate = false;
      });
    }

    final DateTime now = DateTime.now();
    final List<String> date = _expiryDateController.text.split(RegExp(r'/'));
    final int month = int.parse(date.first);
    final int year = int.parse('20${date.last}');
    final int lastDayOfMonth = month < 12
        ? DateTime(year, month + 1, 0).day
        : DateTime(year + 1, 1, 0).day;
    final DateTime cardDate =
        DateTime(year, month, lastDayOfMonth, 23, 59, 59, 999);

    if (cardDate.isBefore(now) || month > 12 || month == 0) {
      setState(() {
        isValidExpiryDate = false;
      });
    } else {
      setState(() {
        isValidExpiryDate = true;
      });
    }
  }

  void focusListenerCvv() {
    cvvFocusNode.addListener(() async {
      if (!cvvFocusNode.hasFocus) {
        setState(() {
          statusCvv = 'unFocus';
          checkCvv();
        });
      }
    });
  }

  void checkCvv() {
    if (_cvvCodeController.text.isEmpty || _cvvCodeController.text.length < 3) {
      setState(() {
        isValidCvv = false;
      });
    } else {
      setState(() {
        isValidCvv = true;
      });
    }
  }

  void _onTapNormalCvv() {
    setState(() {
      statusCvv = 'focus';
      focusListenerCvv();
    });
  }

  void _onTapNormalInput() {
    setState(() {
      statusCardNumber = 'focus';
      focusListener();
    });
  }

  void _onTapNormalInputExpiryDate() {
    setState(() {
      statusExpiryDate = 'focus';
      focusListenerExpiry();
    });
  }

  @override
  void initState() {
    super.initState();
    createCreditCardModel();

    _cardNumberController.text = widget.cardNumber;
    _expiryDateController.text = widget.expiryDate;
    _cardHolderNameController.text = widget.cardHolderName;
    _cvvCodeController.text = widget.cvvCode;

    onCreditCardModelChange = widget.onCreditCardModelChange;

    cvvFocusNode.addListener(textFieldFocusDidChange);
  }

  @override
  void dispose() {
    cardHolderNode.dispose();
    cvvFocusNode.dispose();
    expiryDateNode.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    themeColor = widget.themeColor;
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant CreditCardForm oldWidget) {
    if (widget.cardNumber.isNotEmpty && _cardNumberController.text.isEmpty) {
      _cardNumberController.text = widget.cardNumber;
    }

    if (widget.expiryDate.isNotEmpty && _expiryDateController.text.isEmpty) {
      _expiryDateController.text = widget.expiryDate;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: themeColor.withOpacity(0.8),
        primaryColorDark: themeColor,
      ),
      child: Form(
        key: widget.formKey,
        child: Column(
          children: <Widget>[
            Visibility(
              visible: widget.isCardNumberVisible,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Card number',
                      style: TextStyle(
                          fontFamily: 'gt',
                          fontWeight: FontWeight.w400,
                          color: Color(0xff242626)),
                    ),
                    const SizedBox(height: 8),
                    Neumorphic(
                      padding: EdgeInsets.only(
                        top: statusCardNumber == 'focus' ? 6 : 0,
                      ),
                      style: NeumorphicStyle(
                        depth: statusCardNumber == 'focus' ? -30 : 0,
                        lightSource: const LightSource(0, 0),
                        shape: NeumorphicShape.concave,
                        color: statusCardNumber == 'focus'
                            ? const Color(0xffEDEDED)
                            : const Color(0xffFFFFFF),
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(8),
                        ),
                        border: statusCardNumber == 'focus'
                            ? NeumorphicBorder(
                                color: isValidCardNumber
                                    ? const Color(0xff145041)
                                    : const Color(0xffDF514B),
                                width: 2,
                              )
                            : NeumorphicBorder(
                                color: isValidCardNumber
                                    ? const Color(0xffBBBCBC)
                                    : const Color(0xffDF514B),
                                width: 1,
                              ),
                      ),
                      child: TextFormField(
                        key: widget.cardNumberKey,
                        focusNode: focusNode,
                        obscureText: widget.obscureNumber,
                        controller: _cardNumberController,
                        onChanged: (String value) {
                          setState(() {
                            cardNumber = _cardNumberController.text;
                            creditCardModel.cardNumber = cardNumber;
                            onCreditCardModelChange(creditCardModel);
                          });
                        },
                        cursorColor: widget.cursorColor ?? themeColor,
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(expiryDateNode);
                        },
                        style: TextStyle(
                          color: widget.textColor,
                        ),
                        onTap: () {
                          if (statusCardNumber != 'focus') {
                            _onTapNormalInput();
                          }
                        },
                        decoration: InputDecoration(
                          fillColor: const Color(0xffFFFFFF),
                          filled: true,
                          hintText: _cardNumberController.mask,
                          contentPadding: statusCardNumber == 'focus'
                              ? const EdgeInsets.fromLTRB(12, 20, 12, 14)
                              : const EdgeInsets.fromLTRB(12, 24, 12, 16),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textInputAction: TextInputAction.next,
                        autovalidateMode: widget.autovalidateMode,
                        validator: widget.cardNumberValidator ??
                            (String? value) {
                              // Validate less that 13 digits +3 white spaces
                              if (value!.isEmpty || value.length < 16) {
                                return widget.numberValidationMessage;
                              }
                              return null;
                            },
                      ),
                    ),
                    if (!isValidCardNumber) ...<Widget>[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const <Widget>[
                          FaIcon(
                            FontAwesomeIcons.xmark,
                            color: Color(0xffDF514B),
                            size: 7.5,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Please enter a valid credit card',
                            style: TextStyle(
                                fontFamily: 'GT',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xffDF514B)),
                          )
                        ],
                      )
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Visibility(
                  visible: widget.isExpiryDateVisible,
                  child: Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Expired date',
                            style: TextStyle(
                                fontFamily: 'gt',
                                fontWeight: FontWeight.w400,
                                color: Color(0xff242626)),
                          ),
                          const SizedBox(height: 8),
                          Neumorphic(
                            padding: EdgeInsets.only(
                              top: statusExpiryDate == 'focus' ? 6 : 0,
                            ),
                            style: NeumorphicStyle(
                              depth: statusExpiryDate == 'focus' ? -30 : 0,
                              lightSource: const LightSource(0, 0),
                              shape: NeumorphicShape.concave,
                              color: statusExpiryDate == 'focus'
                                  ? const Color(0xffEDEDED)
                                  : const Color(0xffFFFFFF),
                              boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(8),
                              ),
                              border: statusExpiryDate == 'focus'
                                  ? NeumorphicBorder(
                                      color: isValidExpiryDate
                                          ? const Color(0xff145041)
                                          : const Color(0xffDF514B),
                                      width: 2,
                                    )
                                  : NeumorphicBorder(
                                      color: isValidExpiryDate
                                          ? const Color(0xffBBBCBC)
                                          : const Color(0xffDF514B),
                                      width: 1,
                                    ),
                            ),
                            child: TextFormField(
                              key: widget.expiryDateKey,
                              controller: _expiryDateController,
                              onChanged: (String value) {
                                if (_expiryDateController.text
                                    .startsWith(RegExp('[2-9]'))) {
                                  _expiryDateController.text =
                                      '0' + _expiryDateController.text;
                                }
                                setState(() {
                                  expiryDate = _expiryDateController.text;
                                  creditCardModel.expiryDate = expiryDate;
                                  onCreditCardModelChange(creditCardModel);
                                });
                              },
                              cursorColor: widget.cursorColor ?? themeColor,
                              focusNode: expiryDateNode,
                              onTap: () {
                                if (statusExpiryDate != 'focus') {
                                  _onTapNormalInputExpiryDate();
                                }
                              },
                              onEditingComplete: () {
                                FocusScope.of(context)
                                    .requestFocus(cvvFocusNode);
                              },
                              style: TextStyle(
                                color: widget.textColor,
                              ),
                              decoration: InputDecoration(
                                fillColor: const Color(0xffFFFFFF),
                                filled: true,
                                hintText: '12/22',
                                contentPadding: statusExpiryDate == 'focus'
                                    ? const EdgeInsets.fromLTRB(12, 20, 12, 14)
                                    : const EdgeInsets.fromLTRB(12, 24, 12, 16),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: widget.expiryDateValidator ??
                                  (String? value) {
                                    if (value!.isEmpty) {
                                      return widget.dateValidationMessage;
                                    }
                                    final DateTime now = DateTime.now();
                                    final List<String> date =
                                        value.split(RegExp(r'/'));
                                    final int month = int.parse(date.first);
                                    final int year =
                                        int.parse('20${date.last}');
                                    final int lastDayOfMonth = month < 12
                                        ? DateTime(year, month + 1, 0).day
                                        : DateTime(year + 1, 1, 0).day;
                                    final DateTime cardDate = DateTime(year,
                                        month, lastDayOfMonth, 23, 59, 59, 999);

                                    if (cardDate.isBefore(now) ||
                                        month > 12 ||
                                        month == 0) {
                                      return widget.dateValidationMessage;
                                    }
                                    return null;
                                  },
                            ),
                          ),
                          if (!isValidExpiryDate) ...<Widget>[
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const <Widget>[
                                FaIcon(
                                  FontAwesomeIcons.xmark,
                                  color: Color(0xffDF514B),
                                  size: 7.5,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Invalid expiration date',
                                  style: TextStyle(
                                      fontFamily: 'GT',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xffDF514B)),
                                )
                              ],
                            )
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'CVV',
                          style: TextStyle(
                              fontFamily: 'gt',
                              fontWeight: FontWeight.w400,
                              color: Color(0xff242626)),
                        ),
                        const SizedBox(height: 8),
                        Neumorphic(
                          padding: EdgeInsets.only(
                            top: statusCvv == 'focus' ? 6 : 0,
                          ),
                          style: NeumorphicStyle(
                            depth: statusCvv == 'focus' ? -30 : 0,
                            lightSource: const LightSource(0, 0),
                            shape: NeumorphicShape.concave,
                            color: statusCvv == 'focus'
                                ? const Color(0xffEDEDED)
                                : const Color(0xffFFFFFF),
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(8),
                            ),
                            border: statusCvv == 'focus'
                                ? NeumorphicBorder(
                                    color: isValidCvv
                                        ? const Color(0xff145041)
                                        : const Color(0xffDF514B),
                                    width: 2,
                                  )
                                : NeumorphicBorder(
                                    color: isValidCvv
                                        ? const Color(0xffBBBCBC)
                                        : const Color(0xffDF514B),
                                    width: 1,
                                  ),
                          ),
                          child: TextFormField(
                            key: widget.cvvCodeKey,
                            obscureText: widget.obscureCvv,
                            focusNode: cvvFocusNode,
                            controller: _cvvCodeController,
                            cursorColor: widget.cursorColor ?? themeColor,
                            onTap: () {
                              if (statusCvv != 'focus') {
                                _onTapNormalCvv();
                              }
                            },
                            onEditingComplete: () {
                              if (widget.isHolderNameVisible)
                                FocusScope.of(context)
                                    .requestFocus(cardHolderNode);
                              else {
                                FocusScope.of(context).unfocus();
                                onCreditCardModelChange(creditCardModel);
                                if (widget.onFormComplete != null) {
                                  widget.onFormComplete!();
                                }
                              }
                            },
                            style: TextStyle(
                              color: widget.textColor,
                            ),
                            decoration: InputDecoration(
                              fillColor: const Color(0xffFFFFFF),
                              filled: true,
                              hintText: '123',
                              contentPadding: statusCvv == 'focus'
                                  ? const EdgeInsets.fromLTRB(12, 20, 12, 14)
                                  : const EdgeInsets.fromLTRB(12, 24, 12, 16),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: widget.isHolderNameVisible
                                ? TextInputAction.next
                                : TextInputAction.done,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (String text) {
                              setState(() {
                                cvvCode = text;
                                creditCardModel.cvvCode = cvvCode;
                                onCreditCardModelChange(creditCardModel);
                              });
                            },
                            validator: widget.cvvValidator ??
                                (String? value) {
                                  if (value!.isEmpty || value.length < 3) {
                                    return widget.cvvValidationMessage;
                                  }
                                  return null;
                                },
                          ),
                        ),
                        if (!isValidCvv) ...<Widget>[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const <Widget>[
                              FaIcon(
                                FontAwesomeIcons.xmark,
                                color: Color(0xffDF514B),
                                size: 7.5,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Invalid cvv',
                                style: TextStyle(
                                    fontFamily: 'GT',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xffDF514B)),
                              )
                            ],
                          )
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: widget.isHolderNameVisible,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                child: TextFormField(
                  key: widget.cardHolderKey,
                  controller: _cardHolderNameController,
                  onChanged: (String value) {
                    setState(() {
                      cardHolderName = _cardHolderNameController.text;
                      creditCardModel.cardHolderName = cardHolderName;
                      onCreditCardModelChange(creditCardModel);
                    });
                  },
                  cursorColor: widget.cursorColor ?? themeColor,
                  focusNode: cardHolderNode,
                  style: TextStyle(
                    color: widget.textColor,
                  ),
                  decoration: widget.cardHolderDecoration,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  autofillHints: const <String>[AutofillHints.creditCardName],
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                    onCreditCardModelChange(creditCardModel);
                    if (widget.onFormComplete != null) {
                      widget.onFormComplete!();
                    }
                  },
                  validator: widget.cardHolderValidator,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
