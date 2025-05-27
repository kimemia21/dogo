import 'dart:convert';

import 'package:dogo/core/constants/initializer.dart';
import 'package:dogo/core/theme/AppColors.dart';
import 'package:dogo/data/models/Pod.dart';
import 'package:dogo/data/services/FetchGlobals.dart';
import 'package:dogo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';

class PodSelectionForm extends StatefulWidget {
  const PodSelectionForm({
    Key? key,
  }) : super(key: key);

  @override
  State<PodSelectionForm> createState() => _PodSelectionFormState();
}

class _PodSelectionFormState extends State<PodSelectionForm>
    with TickerProviderStateMixin {
  Pod? selectedPod;
  late Future<List<Pod>> podsFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  void fetchPods() {
    podsFuture = fetchGlobal<Pod>(
      getRequests: (endpoint) => comms.getRequests(endpoint: endpoint),
      fromJson: (json) => Pod.fromJson(json),
      endpoint: 'pods',
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    fetchPods();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _refreshPods() {
    setState(() {
      fetchPods();
      selectedPod = null;
    });
    _animationController.reset();
    _animationController.forward();
  }

  bool get _isWeb => MediaQuery.of(context).size.width > 768;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: _isWeb ? 24 : 16,
                vertical: _isWeb ? 40 : 24,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: _isWeb ? 600 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    SizedBox(height: 32),
                    _buildPodSelection(context),
                    SizedBox(height: 32),
                    _buildActionButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.workspaces_outline,
            color: Colors.white,
            size: 40,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Select Your POD',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Choose from our premium work pods available across the city',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPodSelection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FutureBuilder<List<Pod>>(
          future: podsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState(context);
            } else if (snapshot.hasError) {
              return _buildErrorState(context);
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState(context);
            } else {
              return _buildPodList(context, snapshot.data!);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(48),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Finding available pods...',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Please wait while we load PODs',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: Colors.red[400],
          ),
          SizedBox(height: 16),
          Text(
            'Connection Issue',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red[600],
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Unable to load PODs. Please try again.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          TextButton.icon(
            onPressed: _refreshPods,
            icon: Icon(Icons.refresh),
            label: Text('Try Again'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(
            Icons.domain_disabled_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No Pods Available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'All PODs are occupied. Check back soon!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          TextButton.icon(
            onPressed: _refreshPods,
            icon: Icon(Icons.refresh),
            label: Text('Check Again'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodList(BuildContext context, List<Pod> pods) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: _isWeb ? 400 : 300,
      ),
      child: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: pods.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppColors.border,
        ),
        itemBuilder: (context, index) {
          return _buildPodTile(context, pods[index]);
        },
      ),
    );
  }

  Widget _buildPodTile(BuildContext context, Pod pod) {
    final isSelected = selectedPod?.id == pod.id;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.workspace_premium,
            color: isSelected ? Colors.white : Colors.grey[600],
            size: 24,
          ),
        ),
        title: Text(
          pod.stationName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    pod.location,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2),
            Text(
              'ID: ${pod.id}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: isSelected
              ? Container(
                  key: ValueKey('selected'),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                )
              : Container(
                  key: ValueKey('unselected'),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[400]!,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
        ),
        onTap: () {
          setState(() {
            if (selectedPod?.id == pod.id) {
              selectedPod = null; // Deselect if already selected
            } else {
              selectedPod = pod; // Select the tapped pod
            }
           
        // 
          });
        },
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return CustomButton(
      text: selectedPod != null ? 'CONFIRM SELECTION' : 'SELECT A POD',
      onPressed: selectedPod != null ? () {
        // Handle confirmation
      } : null,
    );
  }
}