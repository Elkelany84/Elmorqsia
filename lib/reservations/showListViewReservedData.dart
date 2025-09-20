import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservationsList extends StatefulWidget {
  const ReservationsList({super.key});

  @override
  State<ReservationsList> createState() => _ReservationsListState();
}

class _ReservationsListState extends State<ReservationsList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  List<QueryDocumentSnapshot> _reservations = [];
  List<QueryDocumentSnapshot> _filteredReservations = [];

  // Filter variables
  String _searchQuery = '';
  String? _filterDate;
  String? _filterInfo;
  String? _filterPeriod;

  // Options for filters
  Set<String> _dateOptions = {};
  Set<String> _infoOptions = {};
  Set<String> _periodOptions = {};

  bool _isLoading = true;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadReservations();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadReservations() async {
    try {
      final querySnapshot = await _firestore
          .collection('reservations')
          .orderBy('date', descending: true)
          .get();

      setState(() {
        _reservations = querySnapshot.docs;
        _filteredReservations = _reservations;
        _extractFilterOptions();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reservations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _extractFilterOptions() {
    final dates = <String>{};
    final infoOptions = <String>{};
    final periodOptions = <String>{};

    for (final doc in _reservations) {
      final data = doc.data() as Map<String, dynamic>;

      if (data['date'] != null) dates.add(data['date']);
      if (data['type'] != null) infoOptions.add(data['type']);
      if (data['period'] != null) periodOptions.add(data['period']);
    }

    setState(() {
      _dateOptions = dates;
      _infoOptions = infoOptions;
      _periodOptions = periodOptions;
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<QueryDocumentSnapshot> filtered = _reservations;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _matchesSearch(data, _searchQuery);
      }).toList();
    }

    // Apply date filter
    if (_filterDate != null) {
      filtered = filtered.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['date'] == _filterDate;
      }).toList();
    }

    // Apply info filter
    if (_filterInfo != null) {
      filtered = filtered.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['type'] == _filterInfo;
      }).toList();
    }

    // Apply period filter
    if (_filterPeriod != null) {
      filtered = filtered.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['period'] == _filterPeriod;
      }).toList();
    }

    setState(() {
      _filteredReservations = filtered;
    });
  }

  bool _matchesSearch(Map<String, dynamic> data, String query) {
    return data.values.any((value) {
      if (value is String) {
        return value.toLowerCase().contains(query);
      } else if (value is Timestamp) {
        final date = DateFormat('yyyy-MM-dd HH:mm').format(value.toDate());
        return date.toLowerCase().contains(query);
      }
      return false;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _filterDate = null;
      _filterInfo = null;
      _filterPeriod = null;
      _filteredReservations = _reservations;
    });
  }

  Widget _buildFilterChip(
      String label, String? currentValue, ValueChanged<String?> onSelected) {
    return FilterChip(
      label: Text(label),
      selected: currentValue == label,
      onSelected: (selected) {
        onSelected(selected ? label : null);
        _applyFilters();
      },
    );
  }

  Widget _buildFiltersPanel() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الفلترة:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Date Filter
            if (_dateOptions.isNotEmpty) ...[
              const Text('التاريخ:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _dateOptions.map((date) {
                  return _buildFilterChip(date, _filterDate, (value) {
                    setState(() => _filterDate = value);
                  });
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Info Filter
            if (_infoOptions.isNotEmpty) ...[
              const Text('النوع:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _infoOptions.map((info) {
                  return _buildFilterChip(info, _filterInfo, (value) {
                    setState(() => _filterInfo = value);
                  });
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Period Filter
            if (_periodOptions.isNotEmpty) ...[
              const Text('الفترة:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _periodOptions.map((period) {
                  return _buildFilterChip(period, _filterPeriod, (value) {
                    setState(() => _filterPeriod = value);
                  });
                }).toList(),
              ),
            ],

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearFilters,
              child: const Text('مسح جميع الفلاتر'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        contentPadding:
            EdgeInsets.symmetric(horizontal: 5.00), // Remove default padding
        title: Text(
          data['toWhom'] ?? 'No text',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('التاريخ: ${data['date']}'),
            Row(
              children: [
                Text('${data['period']}'),
                if (data['periodDetails'] != null)
                  Text(' ${data['periodDetails']}'),
              ],
            ),
            Text('إسم الطالب: ${data['studentName']}'),
            Text('كود الطالب: ${data['studentCode']}'),
            Text('الرقم القومى للطالب: ${data['studentID']}'),
            Text('الموبايل: ${data['mobile']}'),
            Text('النوع: ${data['type']}'),
            Text('إسم المدرسة: ${data['schoolName']}'),
            Text('الصف الدراسى: ${data['classStage']}'),
            Text('العام الدراسى: ${data['academicYear']}'),
            Text('مكان الجهة: ${data['insideOutside']}'),
            Text('اللغة المطلوبة: ${data['language']}'),
            // if (data['periodDetails'] != null)
            //   Text('Time: ${data['periodDetails']}'),
            if (data['createdAt'] != null)
              Text(
                'Created: ${DateFormat('yyyy-MM-dd HH:mm').format((data['createdAt'] as Timestamp).toDate())}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteReservation(doc.id),
        ),
      ),
    );
  }

  Future<void> _deleteReservation(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الحجز؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('reservations').doc(docId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الحذف بنجاح')),
        );
        _loadReservations(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting reservation: $e')),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _loadReservations();
  }

  void _toggleFilters() {
    // Hide keyboard before toggling filters
    FocusScope.of(context).unfocus();

    setState(() {
      _showFilters = !_showFilters;
    });
  }

  final FocusNode _searchFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الحجوزات'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt_off : Icons.filter_alt),
            onPressed: _toggleFilters,
            // onPressed: () {
            //   _toggleFilters;
            //   setState(() => _showFilters = !_showFilters);
            // },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Hide keyboard when tapping anywhere on the screen
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            // Search Box
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  labelText: 'البحث عن حجز معين...',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Filters Panel
            if (_showFilters) _buildFiltersPanel(),

            // Results Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'عرض ${_filteredReservations.length} من ${_reservations.length} الحجوزات ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_filterDate != null ||
                      _filterInfo != null ||
                      _filterPeriod != null)
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('مسح جميع الفلاتر'),
                    ),
                ],
              ),
            ),

            // Reservations List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _refreshData,
                      child: _filteredReservations.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.search_off,
                                      size: 64, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  Text(
                                    _reservations.isEmpty
                                        ? 'لا توجد حجوزات'
                                        : 'لا توجد حجوزات مطابقة',
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
                                  if (_reservations.isNotEmpty)
                                    TextButton(
                                      onPressed: _clearFilters,
                                      child: const Text('مسح جميع الفلاتر'),
                                    ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredReservations.length,
                              itemBuilder: (context, index) {
                                return _buildReservationCard(
                                    _filteredReservations[index]);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
