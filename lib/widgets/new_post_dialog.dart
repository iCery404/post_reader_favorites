import 'package:flutter/material.dart';

import 'cozy_widgets.dart';

/// Values entered in the "new post" dialog.
class NewPostData {
  const NewPostData({required this.title, required this.body});

  final String title;
  final String body;
}

/// Dialog with title and body fields. Neither field may be empty.
/// Returns [NewPostData] when the user taps Send, otherwise null.
class NewPostDialog extends StatefulWidget {
  const NewPostDialog({super.key});

  static Future<NewPostData?> show(BuildContext context) {
    return showDialog<NewPostData>(
      context: context,
      builder: (BuildContext context) => const NewPostDialog(),
    );
  }

  @override
  State<NewPostDialog> createState() => _NewPostDialogState();
}

class _NewPostDialogState extends State<NewPostDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  String? _required(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field cannot be empty';
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(
        NewPostData(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CozyDialogFrame(
      title: 'New Post',
      actions: <Widget>[
        CozyButton(
          label: 'Cancel',
          style: CozyButtonStyle.cream,
          onPressed: () => Navigator.of(context).pop(),
        ),
        CozyButton(
          label: 'Send',
          icon: Icons.send_rounded,
          onPressed: _submit,
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (String? v) => _required(v, 'Title'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _bodyController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Body'),
              validator: (String? v) => _required(v, 'Body'),
            ),
          ],
        ),
      ),
    );
  }
}
