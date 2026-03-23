import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../logic/app_state.dart';

class SnapshotsModule extends StatefulWidget {
  const SnapshotsModule({super.key});

  @override
  State<SnapshotsModule> createState() => _SnapshotsModuleState();
}

class _SnapshotsModuleState extends State<SnapshotsModule> {
  static const Color darkSlate = Color(0xFF313B4D); // The dark slate color used in the buttons

  void _showCreateSnapshotDialog() {
    final titleCtrl = TextEditingController();
    
    // Check if there are active routes to save
    if (AppState.instance.activeRoutes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'No active routes to save. Please route something in Operate first.', 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.grey.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundLight,
        title: const Text('Save Snapshot', style: TextStyle(color: AppTheme.accentWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Save your current Operate Matrix configuration so you can recall it later instantly.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl, 
              style: const TextStyle(color: Colors.white), 
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Snapshot Name', 
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accentWhite)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('Cancel', style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentWhite, foregroundColor: Colors.black),
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                // Clone the active routes map to freeze the state
                final frozenMatrix = Map<String, String?>.from(AppState.instance.activeRoutes);
                
                final now = DateTime.now();
                final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

                final newSnapshot = {
                  'title': titleCtrl.text,
                  'date': dateStr,
                  'routes': frozenMatrix.length,
                  'matrix': frozenMatrix,
                };

                AppState.instance.savedSnapshots.insert(0, newSnapshot);
                AppState.instance.notifyListeners();
                Navigator.pop(ctx);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Snapshot saved: ${titleCtrl.text}'),
                    backgroundColor: Colors.greenAccent.shade400,
                  )
                );
              }
            },
            child: const Text('Save Matrix'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppState.instance.stateVersionNotifier,
      builder: (context, _, child) {
        final snapshots = AppState.instance.savedSnapshots;
        final isMobile = MediaQuery.of(context).size.width < 700;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 12.0 : 16.0), // Densified layout
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Routing Snapshots',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textMain,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Save and recall complete routing configurations',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showCreateSnapshotDialog,
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Create Snapshot'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentWhite,
                      foregroundColor: AppTheme.backgroundLight,
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 14 : 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Slightly less rounded for density
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              snapshots.isEmpty 
               ? Center(
                   child: Container(
                     padding: const EdgeInsets.all(40),
                     child: Column(
                       children: [
                         Icon(Icons.camera_enhance_outlined, size: 60, color: Colors.grey.shade700),
                         const SizedBox(height: 16),
                         const Text('No Snapshots Saved', style: TextStyle(color: Colors.white, fontSize: 16)),
                         const SizedBox(height: 8),
                         const Text('Route your destinations in the Operate panel, then save them here.', style: TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
                       ],
                     ),
                   ),
                 )
               : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    crossAxisSpacing: isMobile ? 12.0 : 16.0,
                    mainAxisSpacing: isMobile ? 12.0 : 16.0,
                    mainAxisExtent: 180, // Dense box height
                  ),
                  itemCount: snapshots.length,
                  itemBuilder: (context, index) {
                    final snapshot = snapshots[index];
                    return AvCard(
                      padding: const EdgeInsets.all(16.0), // Reduced internal padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundLight,
                                  borderRadius: BorderRadius.circular(10), // Tighter radius
                                  border: Border.all(color: Colors.grey.shade800),
                                ),
                                child: const Icon(Icons.apps_rounded, color: AppTheme.accentWhite, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  snapshot['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textMain,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                snapshot['date'],
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${snapshot['routes']} routes saved',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 38,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final dynamic matrixData = snapshot['matrix'];
                                      if (matrixData != null && matrixData is Map) {
                                        final typedMatrix = Map<String, String?>.from(matrixData);
                                        AppState.instance.loadSnapshotRoutes(typedMatrix);
                                      }
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(Icons.check_circle_outline, color: Colors.black, size: 20),
                                              const SizedBox(width: 10),
                                              Expanded(child: Text('Snapshot Active: ${snapshot['title']}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                            ],
                                          ),
                                          backgroundColor: Colors.greenAccent.shade400,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.play_arrow_outlined, size: 18),
                                    label: const Text('Recall'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.accentWhite,
                                      foregroundColor: AppTheme.backgroundLight,
                                      elevation: 0,
                                      shape: const StadiumBorder(),
                                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 38,
                                width: 38,
                                child: OutlinedButton(
                                  onPressed: () {
                                    // Remove the snapshot and notify structure
                                    AppState.instance.savedSnapshots.removeAt(index);
                                    AppState.instance.notifyListeners();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    side: BorderSide(color: Colors.grey.shade800),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }
    );
  }
}
