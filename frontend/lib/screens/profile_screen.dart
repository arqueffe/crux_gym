import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/l10n/app_localizations.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/route_provider.dart';
import '../providers/theme_provider.dart';
import '../models/profile_models.dart';
import '../widgets/grade_statistics_chart.dart';
import '../widgets/performance_summary_card.dart';
import '../widgets/ticks_list.dart';
import '../widgets/likes_list.dart';
import '../widgets/projects_list.dart';
import '../widgets/language_selector.dart';
import '../widgets/custom_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _promptEditNickname(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.read<AuthProvider>();
    final controller = TextEditingController(
      text: authProvider.currentUser?.nickname ?? '',
    );
    String? errorText;

    bool validate(String value) {
      if (value.trim().isEmpty) {
        errorText = l10n.pleaseEnterNickname;
        return false;
      }
      if (value.length < 3 || value.length > 20) {
        errorText = l10n.nicknameLength;
        return false;
      }
      final regex = RegExp(r'^[A-Za-z0-9_]+$');
      if (!regex.hasMatch(value)) {
        errorText = l10n.nicknameFormat;
        return false;
      }
      errorText = null;
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            title: Text(l10n.editNickname),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: l10n.nickname,
                    prefixIcon: const Icon(Icons.person_outline),
                    errorText: errorText,
                  ),
                  onChanged: (v) => setState(() {
                    validate(v);
                  }),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  final value = controller.text.trim();
                  if (!validate(value)) {
                    setState(() {});
                    return;
                  }
                  final ok = await authProvider.updateNickname(value);
                  if (!ctx.mounted) return;
                  if (ok) {
                    Navigator.of(ctx).pop(true);
                  } else {
                    setState(() {
                      errorText =
                          authProvider.errorMessage ?? l10n.updateFailed;
                    });
                  }
                },
                child: Text(l10n.save),
              ),
            ],
          );
        });
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.nicknameUpdated)),
      );
      // No need to refresh profile data here; changing nickname doesn't affect stats/ticks/likes
      // and calling refresh immediately after provider rebuild can target a disposed instance.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.profileTitle,
        actions: [
          // Language selector
          const LanguageSelector(),
          // Time filter dropdown
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: DropdownButton<ProfileTimeFilter>(
                  value: profileProvider.timeFilter,
                  underline: Container(),
                  items: ProfileTimeFilter.values.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(
                        _getTimeFilterDisplayName(filter, l10n),
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (filter) {
                    if (filter != null) {
                      profileProvider.setTimeFilter(filter);
                    }
                  },
                ),
              );
            },
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logout,
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.logoutConfirmTitle),
                  content: Text(l10n.logoutConfirmMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(l10n.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.read<AuthProvider>().logout();
                      },
                      child: Text(l10n.logout),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.analytics),
              text: l10n.performanceTab,
            ),
            Tab(
              icon: const Icon(Icons.map),
              text: l10n.routesTab,
            ),
          ],
        ),
      ),
      body: Consumer2<ProfileProvider, AuthProvider>(
        builder: (context, profileProvider, authProvider, child) {
          final l10n = AppLocalizations.of(context);

          if (profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    '${l10n.error}: ${profileProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => profileProvider.loadProfile(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // User Info Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        (authProvider.currentUser?.nickname ?? 'U')[0]
                            .toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  authProvider.currentUser?.nickname ??
                                      'Unknown',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.editNicknameTooltip,
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _promptEditNickname(context),
                              ),
                            ],
                          ),
                          Text(
                            authProvider.currentUser?.email ?? '',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.memberSince(_formatDate(
                                authProvider.currentUser?.createdAt)),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Dark mode toggle and Language settings
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.brightness_6,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer
                                            .withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.darkMode,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Switch(
                                        value: themeProvider.isDarkMode,
                                        onChanged: (value) {
                                          themeProvider.toggleTheme();
                                        },
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Language settings tile
                                  const LanguageListTile(),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Performance Tab
                    RefreshIndicator(
                      onRefresh: () => profileProvider.refresh(),
                      child: const PerformanceTab(),
                    ),
                    // Routes Tab
                    RefreshIndicator(
                      onRefresh: () => profileProvider.refresh(),
                      child: const RoutesTab(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getTimeFilterDisplayName(
      ProfileTimeFilter filter, AppLocalizations l10n) {
    switch (filter) {
      case ProfileTimeFilter.all:
        return l10n.filterAll;
      case ProfileTimeFilter.lastWeek:
        return l10n.filterThisWeek;
      case ProfileTimeFilter.lastMonth:
        return l10n.filterThisMonth;
      case ProfileTimeFilter.last3Months:
        return l10n.filterLast3Months;
      case ProfileTimeFilter.lastYear:
        return l10n.filterThisYear;
    }
  }
}

class PerformanceTab extends StatelessWidget {
  const PerformanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Performance Summary
              PerformanceSummaryCard(
                stats: profileProvider.profileStats,
                filteredTicks: profileProvider.filteredTicks,
                timeFilter: profileProvider.timeFilter,
                gradeDefinitions:
                    context.read<RouteProvider>().gradeDefinitions,
              ),
              const SizedBox(height: 16),

              // Grade Statistics Chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.gradeBreakdown,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      GradeStatisticsChart(
                        gradeStats: profileProvider.filteredGradeStats,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RoutesTab extends StatefulWidget {
  const RoutesTab({super.key});

  @override
  State<RoutesTab> createState() => _RoutesTabState();
}

class _RoutesTabState extends State<RoutesTab>
    with SingleTickerProviderStateMixin {
  late TabController _routesTabController;

  @override
  void initState() {
    super.initState();
    _routesTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _routesTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Sub-tabs for Routes
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _routesTabController,
            tabs: [
              Tab(
                icon: const Icon(Icons.check_circle),
                text: l10n.ticksTab,
              ),
              Tab(
                icon: const Icon(Icons.favorite),
                text: l10n.likesTab,
              ),
              Tab(
                icon: const Icon(Icons.flag),
                text: l10n.projectsTab,
              ),
            ],
          ),
        ),
        // Sub-tab content
        Expanded(
          child: TabBarView(
            controller: _routesTabController,
            children: [
              // Ticks
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  final l10n = AppLocalizations.of(context);
                  final ticks = profileProvider.filteredTicks;

                  if (ticks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noTicksFound,
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.noTicksDescription,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return TicksList(
                    ticks: ticks,
                    gradeColors: context.read<RouteProvider>().gradeColors,
                  );
                },
              ),
              // Likes
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  final l10n = AppLocalizations.of(context);
                  final likes = profileProvider.filteredLikes;

                  if (likes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_outline,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noLikesFound,
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.noLikesDescription,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return LikesList(
                    likes: likes,
                    gradeColors: context.read<RouteProvider>().gradeColors,
                  );
                },
              ),
              // Projects
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  final l10n = AppLocalizations.of(context);
                  final projects = profileProvider.filteredProjects;

                  if (projects.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flag_outlined,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noProjectsFound,
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.noProjectsDescription,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ProjectsList(
                    projects: projects,
                    gradeColors: context.read<RouteProvider>().gradeColors,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
