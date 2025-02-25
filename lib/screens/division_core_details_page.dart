import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DivisionCoreDetailsPage extends StatefulWidget {
  final String divisionId; // Using division ObjectId

  const DivisionCoreDetailsPage({required this.divisionId, Key? key}) : super(key: key);

  @override
  State<DivisionCoreDetailsPage> createState() => _DivisionCoreDetailsPageState();
}

class _DivisionCoreDetailsPageState extends State<DivisionCoreDetailsPage> {
  late Future<Map<String, dynamic>> _divisionDetails;

  @override
  void initState() {
    super.initState();
    _divisionDetails = ApiService.fetchDivisionCoreDetails(widget.divisionId);
  }

  // Build a team member widget.
  Widget _buildTeamMember(String displayRole, Map<String, dynamic> member) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: member['profile'] != null &&
                  member['profile']['avatar'] != null &&
                  (member['profile']['avatar'] as String).isNotEmpty
              ? NetworkImage(member['profile']['avatar'])
              : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
        ),
        const SizedBox(height: 8),
        Text(
          member['profile'] != null && member['profile']['fullName'] != null
              ? member['profile']['fullName']
              : 'Unknown',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          displayRole,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _divisionDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Division Core"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Division Core"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            body: Center(
                child: Text("Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.white))),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Division Core"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            body: const Center(
                child: Text("No division details found.",
                    style: TextStyle(color: Colors.white))),
          );
        } else {
          final division = snapshot.data!;
          // Assume divisionTeam is stored as an object with keys matching roles.
          final team = division['divisionTeam'] as Map<String, dynamic>;

          // Map role keys to display names.
          final Map<String, String> roleDisplayNames = {
            "president": "President",
            "vicePresidentEvent": "Vice President (Events)",
            "vicePresidentTechLead": "Vice President (Tech Lead)",
            "vicePresidentViceTechLead": "Vice President (Vice Tech Lead)",
            "vicePresidentClubIncharge": "Vice President (Club Incharge)",
            "vicePresidentOutreach": "Vice President (Outreach)",
            "vicePresidentMarketing": "Vice President (Marketing)",
            "vicePresidentTreasurer": "Vice President (Treasurer)"
          };

          // Build list of team member widgets.
          List<Widget> presidentWidget = [];
          List<Widget> otherWidgets = [];

          // President goes in its own row.
          if (team['president'] != null) {
            presidentWidget.add(_buildTeamMember(
                roleDisplayNames['president']!, team['president']));
          }

          // Other team members.
          roleDisplayNames.forEach((roleKey, displayName) {
            if (roleKey != 'president' && team[roleKey] != null) {
              otherWidgets.add(_buildTeamMember(displayName, team[roleKey]));
            }
          });

          return Scaffold(
            appBar: AppBar(
              title: Text(division['name'] ?? "Division Core"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            backgroundColor: Colors.white,
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg.png'),
                  fit: BoxFit.cover,
                  // Optionally apply a color filter for better contrast:
                  colorFilter:
                      ColorFilter.mode(Colors.black45, BlendMode.darken),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // President widget (full width)
                    if (presidentWidget.isNotEmpty) ...[
                      presidentWidget.first,
                      const SizedBox(height: 16),
                    ],
                    // Other team members in a grid (2 per row)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 14,
                      children: otherWidgets,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
