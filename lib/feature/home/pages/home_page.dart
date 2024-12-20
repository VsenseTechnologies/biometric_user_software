import 'package:application/feature/home/bloc/home_bloc.dart';
import 'package:application/feature/home/widgets/custom_machine_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<HomeBloc>(context).add(HomeFetchMachinesEvent());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyR) {
      // Trigger the refresh event
      BlocProvider.of<HomeBloc>(context).add(HomeFetchMachinesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true, // Ensures the widget automatically listens to key events
      onKey: _handleKeyPress,
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          title: Text(
            "Home",
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.grey.shade900,
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 30,
          ),
          actions: [
            Tooltip(
              message: "Refresh", // Tooltip text
              child: Padding(
                padding: const EdgeInsets.all(9.0),
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  color: Colors.white,
                  onPressed: () {
                    BlocProvider.of<HomeBloc>(context)
                        .add(HomeFetchMachinesEvent());
                  },
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              DrawerHeader(
                child: Image.asset("assets/logo.png"),
              ),
              Text(
                "VSENSE",
                style: GoogleFonts.lato(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, "/register");
                },
                leading: const Icon(
                  Icons.people,
                  color: Colors.black,
                  size: 28,
                ),
                title: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Register",
                    style: GoogleFonts.nunito(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                style: ListTileStyle.drawer,
              ),
              const SizedBox(height: 10),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, "/download");
                },
                leading: const Icon(
                  Icons.file_download_outlined,
                  color: Colors.black,
                  size: 28,
                ),
                title: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Download",
                    style: GoogleFonts.nunito(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                style: ListTileStyle.drawer,
              ),
              const SizedBox(height: 10),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, "/settime");
                },
                leading: const Icon(
                  Icons.more_time_sharp,
                  color: Colors.black,
                  size: 28,
                ),
                title: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Set Time",
                    style: GoogleFonts.nunito(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                style: ListTileStyle.drawer,
              ),
              const SizedBox(height: 10),
              ListTile(
                onTap: () {
                  BlocProvider.of<HomeBloc>(context).add(HomeLogoutEvent());
                  Navigator.pushReplacementNamed(context, "/login");
                },
                leading: const Icon(
                  Icons.logout,
                  color: Colors.black,
                  size: 28,
                ),
                title: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Logout",
                    style: GoogleFonts.nunito(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                style: ListTileStyle.drawer,
              ),
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(40),
          margin: const EdgeInsets.only(top: 2),
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeMachinesFetchSuccessState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Machines",
                      style: GoogleFonts.nunito(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 1600
                                  ? 7
                                  : MediaQuery.of(context).size.width < 950
                                      ? 2
                                      : 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          return CustomMachineCard(
                            machineID: state.getMachines[index]["unit_id"],
                            status: state.getMachines[index]["online"],
                            onPressed: () {
                              Navigator.pushNamed(context, '/details',
                                  arguments: DetailsArguments(
                                      unitId: state.getMachines[index]
                                          ['unit_id']));
                            },
                          );
                        },
                        itemCount: state.getMachines.length,
                      ),
                    ),
                  ],
                );
              } else if (state is HomeMachinesFetchFailureState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 100,
                      ),
                      Text(
                        state.err,
                        style: GoogleFonts.nunito(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<HomeBloc>(context).add(
                            HomeFetchMachinesEvent(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                10,
                              ),
                            ),
                          ),
                        ),
                        child: Text(
                          "Retry",
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class DetailsArguments {
  final String unitId;
  DetailsArguments({required this.unitId});
}
