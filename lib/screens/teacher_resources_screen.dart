import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TeacherResourcesScreen extends StatefulWidget {
  const TeacherResourcesScreen({super.key});

  @override
  State<TeacherResourcesScreen> createState() => _TeacherResourcesScreenState();
}

class _TeacherResourcesScreenState extends State<TeacherResourcesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<ResourceItem> _allResources = [
    ResourceItem(
      title: 'Introduction to Mathematics',
      type: ResourceType.video,
      size: '24.5 MB',
      description: 'Comprehensive introduction to basic mathematical concepts',
      category: 'Mathematics',
      duration: '45 min',
      thumbnail:
          'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400',
    ),
    ResourceItem(
      title: 'Physics Fundamentals',
      type: ResourceType.video,
      size: '32.1 MB',
      description: 'Core physics principles and applications',
      category: 'Science',
      duration: '60 min',
      thumbnail:
          'https://images.unsplash.com/photo-1636466497217-26a8cbeaf0aa?w=400',
    ),
    ResourceItem(
      title: 'Course Syllabus 2024',
      type: ResourceType.pdf,
      size: '2.1 MB',
      description: 'Complete curriculum overview and learning objectives',
      category: 'Documentation',
      pages: '24 pages',
      thumbnail:
          'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400',
    ),
    ResourceItem(
      title: 'Student Assessment Guide',
      type: ResourceType.pdf,
      size: '3.8 MB',
      description: 'Comprehensive guide for student evaluation methods',
      category: 'Assessment',
      pages: '36 pages',
      thumbnail:
          'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=400',
    ),
    ResourceItem(
      title: 'Lesson Plan Template',
      type: ResourceType.word,
      size: '1.2 MB',
      description: 'Structured template for daily lesson planning',
      category: 'Templates',
      pages: '8 pages',
      thumbnail:
          'https://images.unsplash.com/photo-1586281380349-632531db7ed4?w=400',
    ),
    ResourceItem(
      title: 'Interactive Worksheets',
      type: ResourceType.word,
      size: '2.8 MB',
      description: 'Engaging worksheets for student activities',
      category: 'Activities',
      pages: '15 pages',
      thumbnail:
          'https://images.unsplash.com/photo-1606092195730-5d7b9af1efc5?w=400',
    ),
    ResourceItem(
      title: 'Chemistry Lab Experiments',
      type: ResourceType.video,
      size: '45.2 MB',
      description: 'Safe and effective chemistry laboratory demonstrations',
      category: 'Science',
      duration: '90 min',
      thumbnail:
          'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=400',
    ),
    ResourceItem(
      title: 'Digital Teaching Tools',
      type: ResourceType.pdf,
      size: '5.4 MB',
      description: 'Guide to modern educational technology tools',
      category: 'Technology',
      pages: '42 pages',
      thumbnail:
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400',
    ),
  ];

  List<ResourceItem> get _filteredResources {
    if (_searchQuery.isEmpty) return _allResources;
    return _allResources
        .where((resource) =>
            resource.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            resource.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            resource.category
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<ResourceItem> _getResourcesByType(ResourceType type) {
    return _filteredResources
        .where((resource) => resource.type == type)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[900]!, Colors.indigo[50]!],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllResourcesTab(),
                    _buildResourceTypeTab(ResourceType.video),
                    _buildResourceTypeTab(ResourceType.pdf),
                    _buildResourceTypeTab(ResourceType.word),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadDialog(),
        backgroundColor: Colors.indigo[700],
        icon: const Icon(Icons.cloud_upload),
        label: Text(
          'Upload Resource',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ).animate().scale(delay: 800.ms),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.school,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teacher Resources',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Enhance your teaching experience',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search resources...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.indigo[700]),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        style: GoogleFonts.poppins(),
      ),
    ).animate().fadeIn().slideY(delay: 200.ms);
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.indigo[700],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle:
            GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Videos'),
          Tab(text: 'PDFs'),
          Tab(text: 'Docs'),
        ],
      ),
    ).animate().fadeIn().slideY(delay: 400.ms);
  }

  Widget _buildAllResourcesTab() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: _isGridView
          ? _buildGridView(_filteredResources)
          : _buildListView(_filteredResources),
    );
  }

  Widget _buildResourceTypeTab(ResourceType type) {
    final resources = _getResourcesByType(type);
    return Container(
      margin: const EdgeInsets.all(20),
      child:
          _isGridView ? _buildGridView(resources) : _buildListView(resources),
    );
  }

  Widget _buildGridView(List<ResourceItem> resources) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        return _buildResourceCard(resources[index], index);
      },
    );
  }

  Widget _buildListView(List<ResourceItem> resources) {
    return ListView.builder(
      itemCount: resources.length,
      itemBuilder: (context, index) {
        return _buildResourceListTile(resources[index], index);
      },
    );
  }

  Widget _buildResourceCard(ResourceItem resource, int index) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  image: DecorationImage(
                    image: NetworkImage(resource.thumbnail),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7)
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _getTypeColor(resource.type),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getTypeIcon(resource.type),
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Text(
                          resource.title,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          resource.size,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _downloadResource(resource),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.indigo[700],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.download,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).scale();
  }

  Widget _buildResourceListTile(ResourceItem resource, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(resource.thumbnail),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _getTypeColor(resource.type).withValues(alpha: 0.8),
              ),
              child: Icon(
                _getTypeIcon(resource.type),
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          title: Text(
            resource.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                resource.description,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _getTypeColor(resource.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      resource.category,
                      style: GoogleFonts.poppins(
                        color: _getTypeColor(resource.type),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    resource.size,
                    style: GoogleFonts.poppins(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Container(
            decoration: BoxDecoration(
              color: Colors.indigo[700],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () => _downloadResource(resource),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX();
  }

  Color _getTypeColor(ResourceType type) {
    switch (type) {
      case ResourceType.video:
        return Colors.red[600]!;
      case ResourceType.pdf:
        return Colors.orange[600]!;
      case ResourceType.word:
        return Colors.blue[600]!;
    }
  }

  IconData _getTypeIcon(ResourceType type) {
    switch (type) {
      case ResourceType.video:
        return Icons.play_circle_filled;
      case ResourceType.pdf:
        return Icons.picture_as_pdf;
      case ResourceType.word:
        return Icons.description;
    }
  }

  void _downloadResource(ResourceItem resource) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.download, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Downloading ${resource.title}...',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Upload Resource',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select the type of resource you want to upload',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUploadOption(Icons.videocam, 'Video', Colors.red),
                _buildUploadOption(Icons.picture_as_pdf, 'PDF', Colors.orange),
                _buildUploadOption(Icons.description, 'Document', Colors.blue),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadOption(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Upload $label selected', style: GoogleFonts.poppins()),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

enum ResourceType { video, pdf, word }

class ResourceItem {
  final String title;
  final ResourceType type;
  final String size;
  final String description;
  final String category;
  final String? duration;
  final String? pages;
  final String thumbnail;

  ResourceItem({
    required this.title,
    required this.type,
    required this.size,
    required this.description,
    required this.category,
    required this.thumbnail,
    this.duration,
    this.pages,
  });
}
