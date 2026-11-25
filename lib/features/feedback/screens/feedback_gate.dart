import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/state/app_scope.dart';
import '../data/feedback_api.dart';

/// Blocks booking tabs while completed services still need a rating.
class FeedbackGate extends StatefulWidget {
  const FeedbackGate({
    super.key,
    required this.child,
    this.loadPending,
    this.submitFeedback,
  });

  final Widget child;
  final Future<List<PendingFeedback>> Function(String token)? loadPending;
  final Future<void> Function(String token, PendingFeedback item, int rating, String comment)? submitFeedback;

  @override
  State<FeedbackGate> createState() => _FeedbackGateState();
}

class _FeedbackGateState extends State<FeedbackGate> with WidgetsBindingObserver {
  List<PendingFeedback> _pending = [];
  String? _error;
  String? _submitError;
  String? _savedMessage;
  bool _loading = false;
  bool _submitting = false;
  bool _checked = false;
  int _rating = 5;
  final _comment = TextEditingController();
  String? _seenToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _comment.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final token = AppScope.of(context).signedIn?.accessToken;
    if (token == _seenToken) return;
    _seenToken = token;
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    final app = AppScope.of(context);
    final token = app.signedIn?.accessToken;
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          _pending = [];
          _error = null;
          _submitError = null;
          _savedMessage = null;
          _checked = false;
          _loading = false;
        });
      }
      return;
    }
    setState(() => _loading = true);
    try {
      final rows = widget.loadPending == null
          ? await FeedbackApi(ApiClient(), token).pending()
          : await widget.loadPending!(token);
      if (!mounted) return;
      setState(() {
        _pending = rows;
        _error = null;
        _loading = false;
        _checked = true;
        if (rows.isNotEmpty) _rating = 5;
      });
    } catch (error) {
      if (!mounted) return;
      if (error is ApiException && error.statusCode == 401) {
        AppScope.of(context).signOut();
        return;
      }
      setState(() {
        _error = error is ApiException ? error.message : 'Feedback could not be checked. Try again.';
        _loading = false;
        _checked = true;
      });
    }
  }

  Future<void> _submit() async {
    if (_submitting || _pending.isEmpty) return;
    final app = AppScope.of(context);
    final token = app.signedIn?.accessToken;
    final item = _pending.first;
    if (token == null || token.isEmpty) return;
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final comment = _comment.text.trim();
      if (widget.submitFeedback == null) {
        await FeedbackApi(ApiClient(), token).submit(
          appointmentServiceId: item.appointmentServiceId,
          rating: _rating,
          comment: comment,
        );
      } else {
        await widget.submitFeedback!(token, item, _rating, comment);
      }
      if (!mounted) return;
      _comment.clear();
      setState(() => _savedMessage = 'Feedback saved.');
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _submitError = error.message);
      if (error.statusCode == 409) await _load();
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitError = 'Feedback could not be saved. You can try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final signedIn = app.signedIn != null;
    final awayFromAccount = app.tabIndex != 3;
    final waiting = signedIn && !_checked;
    final savedAndClear = _savedMessage != null && _pending.isEmpty && _error == null && _checked;
    final blocked = signedIn &&
        awayFromAccount &&
        (waiting || _loading || _pending.isNotEmpty || _error != null || savedAndClear);
    if (!blocked) return widget.child;
    final item = _pending.isEmpty ? null : _pending.first;
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback required')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _loading || waiting
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_savedMessage != null) Text(_savedMessage!),
                      Text(_error!),
                      TextButton(onPressed: _load, child: const Text('Retry')),
                      TextButton(onPressed: () => app.setTab(3), child: const Text('Account')),
                    ],
                  )
                : savedAndClear
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_savedMessage!),
                          const SizedBox(height: 12),
                          const Text('You can use Home, Explore, and Bookings again.'),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => setState(() => _savedMessage = null),
                            child: const Text('Continue'),
                          ),
                          TextButton(onPressed: () => app.setTab(3), child: const Text('Account')),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_savedMessage != null) Text(_savedMessage!),
                          Text('${_pending.length} completed service${_pending.length == 1 ? '' : 's'} need a rating before you continue.'),
                          const SizedBox(height: 16),
                          Text('${item!.serviceName} with ${item.stylistName}'),
                          Text(item.appointmentDate),
                          const SizedBox(height: 12),
                          DropdownButton<int>(
                            value: _rating,
                            items: [for (var star = 1; star <= 5; star++) DropdownMenuItem(value: star, child: Text('$star star${star == 1 ? '' : 's'}'))],
                            onChanged: _submitting ? null : (value) => setState(() => _rating = value ?? 5),
                          ),
                          TextField(
                            controller: _comment,
                            decoration: const InputDecoration(labelText: 'Comment (optional)'),
                          ),
                          if (_submitError != null) ...[
                            const SizedBox(height: 8),
                            Text(_submitError!),
                          ],
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _submitting ? null : _submit,
                            child: Text(_submitting ? 'Saving' : 'Submit feedback'),
                          ),
                          TextButton(onPressed: () => app.setTab(3), child: const Text('Account')),
                        ],
                      ),
      ),
    );
  }
}
