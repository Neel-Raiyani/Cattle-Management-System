import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cattle_bloc.dart';
import '../bloc/cattle_event.dart';
import '../bloc/cattle_state.dart';
import '../../../../presentation/widgets/state_widgets.dart';
import '../../../../core/theme/app_theme.dart';

/// Cattle List Screen
class CattleListScreen extends StatelessWidget {
  const CattleListScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cattle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to search screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => CattleBloc()..add(const LoadCattleList()),
        child: BlocBuilder<CattleBloc, CattleState>(
          builder: (context, state) {
            // Using StreamBuilder pattern - state changes trigger rebuilds
            if (state is CattleLoading) {
              return const LoadingIndicator(
                message: 'Loading cattle...',
              );
            } else if (state is CattleListLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<CattleBloc>().add(
                        const LoadCattleList(forceRefresh: true),
                      );
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.cattleList.length,
                  itemBuilder: (context, index) {
                    final cattle = state.cattleList[index];
                    return _CattleCard(
                      tagNumber: cattle.tagNumber,
                      name: cattle.name,
                      breed: cattle.breed,
                      age: cattle.displayAge,
                      status: cattle.status,
                      imageUrl: cattle.imageUrl,
                      onTap: () {
                        // TODO: Navigate to cattle detail screen
                      },
                    );
                  },
                ),
              );
            } else if (state is CattleEmpty) {
              return EmptyState(
                message: state.message,
                icon: Icons.pets,
                actionLabel: 'Add Cattle',
                onAction: () {
                  // TODO: Navigate to add cattle screen
                },
              );
            } else if (state is CattleError) {
              return ErrorDisplay(
                message: state.message,
                onRetry: () {
                  context.read<CattleBloc>().add(const LoadCattleList());
                },
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add cattle screen
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Cattle'),
      ),
    );
  }
}

/// Cattle Card Widget
class _CattleCard extends StatelessWidget {
  final String tagNumber;
  final String name;
  final String breed;
  final String age;
  final String status;
  final String? imageUrl;
  final VoidCallback onTap;
  
  const _CattleCard({
    required this.tagNumber,
    required this.name,
    required this.breed,
    required this.age,
    required this.status,
    this.imageUrl,
    required this.onTap,
  });
  
  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'healthy':
        return AppTheme.healthyColor;
      case 'sick':
        return AppTheme.sickColor;
      case 'pregnant':
        return AppTheme.pregnantColor;
      case 'dry':
        return AppTheme.dryColor;
      default:
        return AppTheme.textSecondary;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Cattle Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl == null
                    ? const Icon(
                        Icons.pets,
                        size: 40,
                        color: AppTheme.primaryColor,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              
              // Cattle Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tag: $tagNumber',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          breed,
                          style:
                              Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.cake,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          age,
                          style:
                              Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow Icon
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
