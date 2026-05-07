import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iconsax/iconsax.dart';

class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen({
    super.key,
    this.initialAddress,
    this.prefilledRecipientName,
    this.lockRecipientName = false,
    this.lockDefaultForNewAddress = false,
  });

  final AddressItem? initialAddress;
  final String? prefilledRecipientName;
  final bool lockRecipientName;
  final bool lockDefaultForNewAddress;

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _postalController = TextEditingController();

  List<CountryItem> _countries = [];
  List<ProvinceItem> _provinces = [];
  List<CityItem> _cities = [];
  List<BarangayItem> _barangays = [];

  CountryItem? _selectedCountry;
  ProvinceItem? _selectedProvince;
  CityItem? _selectedCity;
  BarangayItem? _selectedBarangay;

  bool _loadingCountries = false;
  bool _loadingProvinces = false;
  bool _loadingCities = false;
  bool _loadingBarangays = false;

  bool _saving = false;
  bool _setAsDefault = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.initialAddress == null && widget.lockDefaultForNewAddress) {
      _setAsDefault = true;
    }

    if (widget.initialAddress == null &&
        (widget.prefilledRecipientName ?? '').trim().isNotEmpty) {
      _nameController.text = widget.prefilledRecipientName!.trim();
    }

    await _loadCountries();

    final initial = widget.initialAddress;
    if (initial == null) return;

    await _loadForEditing(initial);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    setState(() => _loadingCountries = true);
    final res = await ApiMiddleware.location.getCountries();
    if (mounted) {
      setState(() {
        _loadingCountries = false;
        if (res.success) {
          _countries = res.data?.whereType<CountryItem>().toList() ?? [];
        }
      });
    }
  }

  Future<void> _loadForEditing(AddressItem initial) async {
    // Find and set country, then sequentially load province/city/barangay options.
    CountryItem? countryItem;
    for (final c in _countries) {
      if (c.country == initial.country) {
        countryItem = c;
        break;
      }
    }
    if (countryItem == null) return;

    setState(() {
      _setAsDefault = initial.isDefault;
      _nameController.text = initial.recipientName;
      _phoneController.text = initial.mobileNo;
      _streetController.text = initial.streetAddress;
      _postalController.text = initial.postalCode;
      _selectedCountry = countryItem;
    });

    await _loadProvinces(countryItem.country);

    ProvinceItem? provinceItem;
    for (final p in _provinces) {
      if (p.province == initial.province) {
        provinceItem = p;
        break;
      }
    }
    if (provinceItem == null) return;

    setState(() => _selectedProvince = provinceItem);

    await _loadCities(countryItem.country, provinceItem.province);

    CityItem? cityItem;
    for (final c in _cities) {
      if (c.city == initial.city) {
        cityItem = c;
        break;
      }
    }
    if (cityItem == null) return;

    setState(() => _selectedCity = cityItem);

    await _loadBarangays(
      countryItem.country,
      provinceItem.province,
      cityItem.city,
    );

    BarangayItem? barangayItem;
    for (final b in _barangays) {
      if (b.barangay == initial.barangay) {
        barangayItem = b;
        break;
      }
    }
    if (barangayItem == null) return;

    setState(() => _selectedBarangay = barangayItem);
  }

  String _buildCompleteAddress({
    required String streetAddress,
    required String barangay,
    required String city,
    required String province,
    required String country,
    required String postalCode,
  }) {
    final base = '$streetAddress, $barangay, $city, $province, $country';
    return postalCode.trim().isEmpty ? base : '$base, $postalCode';
  }

  Future<void> _saveAddress() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_selectedCountry == null ||
        _selectedProvince == null ||
        _selectedCity == null ||
        _selectedBarangay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please complete the location fields.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[300],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final recipientName = _nameController.text.trim();
      final mobileNo = _phoneController.text.trim();
      final streetAddress = _streetController.text.trim();
      final postalCode = _postalController.text.trim();

      final completeAddress = _buildCompleteAddress(
        streetAddress: streetAddress,
        barangay: _selectedBarangay!.barangay,
        city: _selectedCity!.city,
        province: _selectedProvince!.province,
        country: _selectedCountry!.country,
        postalCode: postalCode,
      );

      // If this is the first saved address and the user did not opt-in,
      // treat it as default to improve checkout usability.
      var isDefaultToSend = _setAsDefault;
      if (widget.initialAddress == null && !_setAsDefault) {
        final existingRes = await ApiMiddleware.address.getAddresses();
        final existing =
            existingRes.data?.whereType<AddressItem>().toList() ?? [];
        if (existing.isEmpty) isDefaultToSend = true;
      }

      if (widget.initialAddress != null) {
        final res = await ApiMiddleware.address.updateAddress(
          autoId: widget.initialAddress!.autoId,
          recipientName: recipientName,
          mobileNo: mobileNo,
          country: _selectedCountry!.country,
          province: _selectedProvince!.province,
          city: _selectedCity!.city,
          barangay: _selectedBarangay!.barangay,
          streetAddress: streetAddress,
          postalCode: postalCode,
          completeAddress: completeAddress,
          isDefault: isDefaultToSend,
        );
        if (!res.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                res.message.isNotEmpty
                    ? res.message
                    : 'Unable to save address.',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red[300],
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
          return;
        }
      } else {
        final res = await ApiMiddleware.address.addAddress(
          recipientName: recipientName,
          mobileNo: mobileNo,
          country: _selectedCountry!.country,
          province: _selectedProvince!.province,
          city: _selectedCity!.city,
          barangay: _selectedBarangay!.barangay,
          streetAddress: streetAddress,
          postalCode: postalCode,
          completeAddress: completeAddress,
          isDefault: isDefaultToSend,
        );

        if (!res.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                res.message.isNotEmpty
                    ? res.message
                    : 'Unable to save address.',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red[300],
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Address saved successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green[300],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _loadProvinces(String country) async {
    setState(() => _loadingProvinces = true);
    final res = await ApiMiddleware.location.getProvinces(country);
    if (mounted) {
      setState(() {
        _loadingProvinces = false;
        if (res.success) {
          _provinces = res.data?.whereType<ProvinceItem>().toList() ?? [];
        }
      });
    }
  }

  Future<void> _loadCities(String country, String province) async {
    setState(() => _loadingCities = true);
    final res = await ApiMiddleware.location.getCities(country, province);
    if (mounted) {
      setState(() {
        _loadingCities = false;
        if (res.success) {
          _cities = res.data?.whereType<CityItem>().toList() ?? [];
        }
      });
    }
  }

  Future<void> _loadBarangays(
    String country,
    String province,
    String city,
  ) async {
    setState(() => _loadingBarangays = true);
    final res = await ApiMiddleware.location.getBarangays(
      country,
      province,
      city,
    );
    if (mounted) {
      setState(() {
        _loadingBarangays = false;
        if (res.success) {
          _barangays = res.data?.whereType<BarangayItem>().toList() ?? [];
        }
      });
    }
  }

  void _onCountryChanged(CountryItem? country) {
    setState(() {
      _selectedCountry = country;
      _selectedProvince = null;
      _selectedCity = null;
      _selectedBarangay = null;
      _provinces.clear();
      _cities.clear();
      _barangays.clear();
    });
    if (country != null) {
      _loadProvinces(country.country);
    }
  }

  void _onProvinceChanged(ProvinceItem? province) {
    setState(() {
      _selectedProvince = province;
      _selectedCity = null;
      _selectedBarangay = null;
      _cities.clear();
      _barangays.clear();
    });
    if (province != null && _selectedCountry != null) {
      _loadCities(_selectedCountry!.country, province.province);
    }
  }

  void _onCityChanged(CityItem? city) {
    setState(() {
      _selectedCity = city;
      _selectedBarangay = null;
      _barangays.clear();
    });
    if (city != null && _selectedCountry != null && _selectedProvince != null) {
      _loadBarangays(
        _selectedCountry!.country,
        _selectedProvince!.province,
        city.city,
      );
    }
  }

  void _onBarangayChanged(BarangayItem? barangay) {
    setState(() => _selectedBarangay = barangay);
  }

  @override
  Widget build(BuildContext context) {
    final lockDefaultSwitch =
        widget.initialAddress == null && widget.lockDefaultForNewAddress;
    return Scaffold(
      appBar: const IAMAppBar(
        showBackArrow: true,
        title: Text('Add New Address'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// Name
                TextFormField(
                  controller: _nameController,
                  enabled: !(widget.initialAddress == null &&
                      widget.lockRecipientName),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    labelText: 'Recipient',
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty)
                      return 'Recipient is required.';
                    return null;
                  },
                ),
                const SizedBox(height: IAMSizes.spaceBtwInputFields),

                /// Phone Number
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.mobile),
                    labelText: 'Phone Number',
                  ),
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'Phone number is required.';
                    if (v.length < 7) return 'Phone number looks too short.';
                    return null;
                  },
                ),
                const SizedBox(height: IAMSizes.spaceBtwInputFields),

                /// Country Dropdown
                DropdownButtonFormField<CountryItem>(
                  value: _selectedCountry,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.global),
                    labelText: 'Country',
                  ),
                  items: _countries.map((country) {
                    return DropdownMenuItem(
                      value: country,
                      child: Text(country.country),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) return 'Country is required.';
                    return null;
                  },
                  onChanged: !_loadingCountries ? _onCountryChanged : null,
                  hint: _loadingCountries
                      ? const Text('Loading countries...')
                      : const Text('Select Country'),
                  disabledHint: const Text('Loading countries...'),
                  isExpanded: true,
                ),
                const SizedBox(height: IAMSizes.spaceBtwInputFields),

                /// Province Dropdown
                DropdownButtonFormField<ProvinceItem>(
                  value: _selectedProvince,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.map),
                    labelText: 'Province',
                  ),
                  items: _provinces.map((province) {
                    return DropdownMenuItem(
                      value: province,
                      child: Text(province.province),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) return 'Province is required.';
                    return null;
                  },
                  onChanged: _selectedCountry != null && !_loadingProvinces
                      ? _onProvinceChanged
                      : null,
                  hint: _loadingProvinces
                      ? const Text('Loading provinces...')
                      : const Text('Select Province'),
                  disabledHint: _selectedCountry == null
                      ? const Text('Select a country first')
                      : const Text('Loading provinces...'),
                  isExpanded: true,
                ),
                const SizedBox(height: IAMSizes.spaceBtwInputFields),

                /// City Dropdown
                DropdownButtonFormField<CityItem>(
                  value: _selectedCity,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.building),
                    labelText: 'City',
                  ),
                  items: _cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city.city),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) return 'City is required.';
                    return null;
                  },
                  onChanged: _selectedProvince != null && !_loadingCities
                      ? _onCityChanged
                      : null,
                  hint: _loadingCities
                      ? const Text('Loading cities...')
                      : const Text('Select City'),
                  disabledHint: _selectedProvince == null
                      ? const Text('Select a province first')
                      : const Text('Loading cities...'),
                  isExpanded: true,
                ),
                const SizedBox(height: IAMSizes.spaceBtwInputFields),

                /// Barangay Dropdown
                DropdownButtonFormField<BarangayItem>(
                  value: _selectedBarangay,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.location),
                    labelText: 'Barangay',
                  ),
                  items: _barangays.map((barangay) {
                    return DropdownMenuItem(
                      value: barangay,
                      child: Text(barangay.barangay),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) return 'Barangay is required.';
                    return null;
                  },
                  onChanged: _selectedCity != null && !_loadingBarangays
                      ? _onBarangayChanged
                      : null,
                  hint: _loadingBarangays
                      ? const Text('Loading barangays...')
                      : const Text('Select Barangay'),
                  disabledHint: _selectedCity == null
                      ? const Text('Select a city first')
                      : const Text('Loading barangays...'),
                  isExpanded: true,
                ),
                const SizedBox(height: IAMSizes.defaultSpace),

                /// Street + Postal Code Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _streetController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.building_3),
                          labelText: 'Street',
                        ),
                        validator: (value) {
                          final v = (value ?? '').trim();
                          if (v.isEmpty) return 'Street address is required.';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: IAMSizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        controller: _postalController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.code),
                          labelText: 'Postal Code',
                        ),
                        validator: (value) {
                          final v = (value ?? '').trim();
                          if (v.isEmpty) return 'Postal code is required.';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: IAMSizes.spaceBtwInputFields),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Set as default address'),
                  value: _setAsDefault,
                  onChanged: lockDefaultSwitch
                      ? null
                      : (v) => setState(() => _setAsDefault = v),
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveAddress,
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            widget.initialAddress == null
                                ? 'Save Address'
                                : 'Update Address',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
