import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/cattle/domain/entities/cattle.dart';
import '../../../../features/cattle/presentation/bloc/cattle_bloc.dart';
import '../../../../features/cattle/presentation/bloc/cattle_event.dart';
import '../../../../features/cattle/presentation/bloc/cattle_state.dart';

class EarTagAlertScreen extends StatefulWidget {
  const EarTagAlertScreen({super.key});

  @override
  State<EarTagAlertScreen> createState() => _EarTagAlertScreenState();
}

class _EarTagAlertScreenState extends State<EarTagAlertScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQ = '';

  @override
  void initState() {
    super.initState();
    context.read<CattleBloc>().add(const LoadCattleList());
  }

  List<Cattle> _getNoTagAnimals(List<Cattle> allCattle) {
    var list = allCattle
        .where((a) => a.tagNumber == '-' || a.tagNumber.isEmpty)
        .toList();
    if (_searchQ.isNotEmpty) {
      list = list
          .where((a) => a.name.toLowerCase().contains(_searchQ.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
        ),
        title: Text(
          'Ear Tag No. Alert',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<CattleBloc, CattleState>(
        builder: (context, state) {
          List<Cattle> cattleList = [];
          if (state is CattleListLoaded) {
            cattleList = state.cattleList;
          } else if (state is CattleDetailLoaded) {
            cattleList = [state.cattle];
          }
          final animals = _getNoTagAnimals(cattleList);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 22, color: Colors.grey.shade400),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _searchQ = v),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search here...',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            isDense: true,
                            fillColor: Colors.transparent,
                            filled: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: animals.isEmpty
                    ? _buildNoData()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: animals.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) =>
                            _AnimalTagCard(animal: animals[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoData() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/no_data_found.png',
            width: 200,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.search_off, size: 100, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            'No Data Found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimalTagCard extends StatelessWidget {
  final Cattle animal;
  const _AnimalTagCard({required this.animal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              animal.imageUrl ?? 'assets/icons/cow_and_calf.png',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
                child: const Icon(Icons.pets, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      animal.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      animal.gender == 'Female' ||
                              animal.gender.toLowerCase() == 'cow'
                          ? 'Cow'
                          : 'Bull',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.sell_outlined,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tag No.: ${animal.tagNumber}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'No. : ${animal.serialNumber ?? "0000"}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFA4C639).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Color(0xFFA4C639), size: 20),
          ),
        ],
      ),
    );
  }
}
