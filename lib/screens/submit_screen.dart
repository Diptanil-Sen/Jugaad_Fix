import 'package:flutter/material.dart';

import 'package:jugaad_fix/data/sample_data.dart';
import 'package:jugaad_fix/models/jugaad_model.dart';

/// Form screen for submitting a new Jugaad.
class SubmitScreen extends StatefulWidget {
  const SubmitScreen({
    super.key,
  });

  @override
  State<SubmitScreen> createState() => _SubmitScreenState();
}

class _SubmitScreenState extends State<SubmitScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedCategoryKey = JugaadCategories.categories.first['key']!;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack);
    // Animate the submit button in when the screen opens.
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apna Jugaad Bhejo'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apna desi hack share karo 👇',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Jugaad ka naam... (short & catchy)',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title toh zaroori hai 🙂';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryKey,
                  items: JugaadCategories.categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c['key'],
                          child: Text('${c['emoji']}  ${c['label']}'),
                        ),
                      )
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategoryKey = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Full Description',
                    alignLabelWithHint: true,
                    hintText:
                        'Apna jugaad likho yahan... step by step batao ki kaise kaam karta hai, kya chahiye, kya dhyaan rakhna hai, sab Hinglish mein bhi chalega 🙂',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Thoda detail mein batao na 🙂';
                    }
                    if (value.trim().length < 30) {
                      return 'Thoda aur likho, taaki dusre ko samajh aaye.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name (optional)',
                    hintText: 'Naam likhoge toh credit milega 😄',
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handleSubmit,
                        icon: const Icon(Icons.send_rounded),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text('Jugaad Publish Karo'),
                        ),
                      ),
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

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final category = JugaadCategories.byKey(_selectedCategoryKey);
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final name = _nameController.text.trim().isEmpty
        ? null
        : _nameController.text.trim();

    final jugaad = Jugaad(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      categoryKey: category['key']!,
      categoryEmoji: category['emoji']!,
      categoryLabel: category['label']!,
      shortDescription: description.length > 90
          ? '${description.substring(0, 90)}...'
          : description,
      description: description,
      authorName: name,
      isUserCreated: true,
      upvotes: 0,
      isBookmarked: false,
    );

    await _animationController.forward();
    // Return the created Jugaad to the caller so home can update immediately.
    if (mounted) {
      Navigator.of(context).pop<Jugaad>(jugaad);
    }
  }
}
