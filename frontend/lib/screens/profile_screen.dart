import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/l10n/app_localizations.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/route_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/role_provider.dart';
import '../models/profile_models.dart';
import '../widgets/grade_statistics_chart.dart';
import '../widgets/performance_summary_card.dart';
import '../widgets/ticks_list.dart';
import '../widgets/likes_list.dart';
import '../widgets/projects_list.dart';
import '../widgets/language_selector.dart';
import '../widgets/custom_app_bar.dart';
import 'user_management_screen.dart';
import 'role_management_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh profile data when app becomes active again
      _refreshProfileData();
    }
  }

  void _refreshProfileData() {
    if (mounted) {
      context.read<ProfileProvider>().refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
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

    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          // Refresh data when the screen gains focus (returns from navigation)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _refreshProfileData();
          });
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: l10n.profileTitle,
          actions: [
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
              Tab(
                icon: const Icon(Icons.settings),
                text: l10n.settingsTab,
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
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
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

            return TabBarView(
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
                  child: RoutesTab(
                    onRouteReturn: () => _refreshProfileData(),
                  ),
                ),
                // Settings Tab
                RefreshIndicator(
                  onRefresh: () => profileProvider.refresh(),
                  child: SettingsTab(
                    onEditNickname: () => _promptEditNickname(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
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
  final VoidCallback? onRouteReturn;

  const RoutesTab({
    super.key,
    this.onRouteReturn,
  });

  @override
  State<RoutesTab> createState() => _RoutesTabState();
}

class _RoutesTabState extends State<RoutesTab> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSegmentTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Modern segmented control
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSegmentButton(
                  context: context,
                  index: 0,
                  icon: Icons.check_circle,
                  label: l10n.ticksTab,
                  isSelected: _selectedIndex == 0,
                ),
              ),
              Expanded(
                child: _buildSegmentButton(
                  context: context,
                  index: 1,
                  icon: Icons.favorite,
                  label: l10n.likesTab,
                  isSelected: _selectedIndex == 1,
                ),
              ),
              Expanded(
                child: _buildSegmentButton(
                  context: context,
                  index: 2,
                  icon: Icons.flag,
                  label: l10n.projectsTab,
                  isSelected: _selectedIndex == 2,
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: [
              // Ticks
              _buildTicksContent(),
              // Likes
              _buildLikesContent(),
              // Projects
              _buildProjectsContent(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentButton({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onSegmentTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.surface
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicksContent() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final l10n = AppLocalizations.of(context);
        final ticks = profileProvider.filteredTicks;

        if (ticks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.check_circle_outline,
            title: l10n.noTicksFound,
            description: l10n.noTicksDescription,
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats summary card
              _buildStatsCard(
                title: '${ticks.length} ${l10n.ticksTab}',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              // List
              Expanded(
                child: TicksList(
                  ticks: ticks,
                  gradeColors: context.read<RouteProvider>().gradeColors,
                  onRouteSelected: widget.onRouteReturn,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLikesContent() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final l10n = AppLocalizations.of(context);
        final likes = profileProvider.filteredLikes;

        if (likes.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_outline,
            title: l10n.noLikesFound,
            description: l10n.noLikesDescription,
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats summary card
              _buildStatsCard(
                title: '${likes.length} ${l10n.likesTab}',
                icon: Icons.favorite,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              // List
              Expanded(
                child: LikesList(
                  likes: likes,
                  gradeColors: context.read<RouteProvider>().gradeColors,
                  onRouteSelected: widget.onRouteReturn,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectsContent() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final l10n = AppLocalizations.of(context);
        final projects = profileProvider.filteredProjects;

        if (projects.isEmpty) {
          return _buildEmptyState(
            icon: Icons.flag_outlined,
            title: l10n.noProjectsFound,
            description: l10n.noProjectsDescription,
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats summary card
              _buildStatsCard(
                title: '${projects.length} ${l10n.projectsTab}',
                icon: Icons.flag,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              // List
              Expanded(
                child: ProjectsList(
                  projects: projects,
                  gradeColors: context.read<RouteProvider>().gradeColors,
                  onRouteSelected: widget.onRouteReturn,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  final VoidCallback onEditNickname;

  const SettingsTab({
    super.key,
    required this.onEditNickname,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
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
                                      l10n.unknown,
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
                                onPressed: onEditNickname,
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
                                authProvider.currentUser?.createdAt, l10n)),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Settings Section
              Text(
                l10n.appSettings,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Dark Mode Setting
              Card(
                child: ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: Text(l10n.darkMode),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Language Setting
              const Card(
                child: LanguageListTile(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date, AppLocalizations l10n) {
    if (date == null) return l10n.unknown;
    return '${date.day}/${date.month}/${date.year}';
  }
}
