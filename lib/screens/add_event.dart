import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AddEventPage extends StatefulWidget {
  final String clubId; // The club that is creating the event

  const AddEventPage({required this.clubId, Key? key}) : super(key: key);

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventVenueController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _chiefGuestController = TextEditingController();
  final TextEditingController _maxParticipantsController = TextEditingController();
  final TextEditingController _prizesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedEventType = "Offline Workshop"; // Default event type

  bool _isLoading = false;
  String? _errorMessage;

  File? _posterImage; // Selected poster image
  final ImagePicker _picker = ImagePicker();

  // Pick an image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _posterImage = File(pickedFile.path);
      });
    }
  }

  // Show date picker
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Show time picker
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null) {
      setState(() {
        _errorMessage = "Please fill in all fields and select date/time.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Format date and time
      final String eventDate = DateFormat("yyyy-MM-dd").format(_selectedDate!);
      final String eventTime = _selectedTime!.format(context);

      // Build event data (without poster image URL)
      Map<String, dynamic> eventData = {
        "eventName": _eventNameController.text.trim(),
        "eventDate": eventDate,
        "eventTime": eventTime,
        "eventVenue": _eventVenueController.text.trim(),
        "eventDescription": _eventDescriptionController.text.trim(),
        "chiefGuest": _chiefGuestController.text.trim(),
        "clubId": widget.clubId,
        "eventType": _selectedEventType,
        "maxParticipants": int.tryParse(_maxParticipantsController.text.trim()) ?? 0,
        "prizes": _prizesController.text.trim(),
        "updates": [],
        "queries": [],
        "registeredUsers": [],
        "eventAdmins": []
      };

      // Call API service to create event (if _posterImage is provided, it will be uploaded)
      String responseMessage = await ApiService.createEvent(eventData, posterImage: _posterImage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseMessage)),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventVenueController.dispose();
    _eventDescriptionController.dispose();
    _chiefGuestController.dispose();
    _maxParticipantsController.dispose();
    _prizesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Event"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Name
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(labelText: "Event Name"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Event name is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Date Picker
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? "Select Date"
                          : "Date: ${DateFormat("yyyy-MM-dd").format(_selectedDate!)}",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text("Pick Date"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Time Picker
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedTime == null
                          ? "Select Time"
                          : "Time: ${_selectedTime!.format(context)}",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickTime,
                    child: const Text("Pick Time"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Venue
              TextFormField(
                controller: _eventVenueController,
                decoration: const InputDecoration(labelText: "Event Venue"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Event venue is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Event Description
              TextFormField(
                controller: _eventDescriptionController,
                decoration: const InputDecoration(labelText: "Event Description"),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Event description is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Chief Guest (optional)
              TextFormField(
                controller: _chiefGuestController,
                decoration: const InputDecoration(labelText: "Chief Guest (Optional)"),
              ),
              const SizedBox(height: 16),
              // Button to pick poster image
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Select Event Poster Image"),
              ),
              const SizedBox(height: 16),
              // Show selected image preview
              if (_posterImage != null)
                Center(
                  child: Image.file(
                    _posterImage!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              // Event Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedEventType,
                decoration: const InputDecoration(labelText: "Event Type"),
                items: <String>["Online", "Offline Workshop", "Hybrid"]
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEventType = value ?? _selectedEventType;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Max Participants
              TextFormField(
                controller: _maxParticipantsController,
                decoration: const InputDecoration(labelText: "Max Participants"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Prizes
              TextFormField(
                controller: _prizesController,
                decoration: const InputDecoration(labelText: "Prize Money (Optional)"),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 8),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: ElevatedButton(
                        onPressed: _submitEvent,
                        child: const Text("Create Event"),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
