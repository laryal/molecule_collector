import 'package:flutter/material.dart';
import 'molecule_data.dart';
import 'package:flutter/services.dart';
import 'package:google_wallet/google_wallet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';



class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtain screen size
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: screenHeight, // Set the container height to the screen height
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/menu_background.png"), // Replace with your image path
            fit: BoxFit.cover, // Cover the entire screen
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Start alignment for vertical
          children: <Widget>[
            SizedBox(height: screenHeight * 0.25), // Adjust the size for the logo's position
            Image.asset('assets/images/game_logo.png', width: 200), // Include your logo asset and adjust the width as needed
            SizedBox(height: screenHeight * 0.2), // Adjust space before buttons, based on your logo size and desired spacing
            Center( // Center the button horizontally
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/game');
                },
                child: Text('Start Game'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded Rectangle Shape
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // Space between buttons
            Center( // Center the button horizontally
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/periodicTable');
                },
                child: Text('ChemiDex'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded Rectangle Shape
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MoleculeTableScreen extends StatefulWidget {
  @override
  _MoleculeTableScreenState createState() => _MoleculeTableScreenState();
}

class _MoleculeTableScreenState extends State<MoleculeTableScreen> {
  Future<List<MoleculeData>>? moleculesFuture;

  @override
  void initState() {
    super.initState();
    moleculesFuture = MoleculeData.fromJsonAsset('assets/molecule_data.json');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ChemiDex')),
      body: FutureBuilder<List<MoleculeData>>(
        future: moleculesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            // Separate molecules into natural and pollutants based on molecule number
            List<MoleculeData> naturalMolecules = snapshot.data!.where((m) => m.number % 2 == 0).toList();
            List<MoleculeData> pollutantMolecules = snapshot.data!.where((m) => m.number % 2 != 0).toList();

            return SingleChildScrollView(
              child: Column(
                children: [
                  buildMoleculesTable(naturalMolecules, 'Natural Molecules'),
                  buildMoleculesTable(pollutantMolecules, 'Pollutant Molecules'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget buildMoleculesTable(List<MoleculeData> molecules, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        GridView.count(
          shrinkWrap: true,
          //physics: NeverScrollableScrollPhysics(), // to disable GridView's scrolling
          crossAxisCount: 2,
          children: List.generate(molecules.length, (index) {
            MoleculeData molecule = molecules[index];
            return ElevatedButton(
              onPressed: () => _showMoleculeImage(molecule),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: molecule.playerOwns
                        ? Image.asset('assets/images/${molecule.png}')
                        : Image.asset('assets/images/mystery.png'),
                  ),
                  SizedBox(height: 4), // Add some spacing between the image and text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4), // Add horizontal padding
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        molecule.symbol,
                        style: TextStyle(fontSize: 14), // Increase the font size
                      ),
                    ),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero, // Remove the default padding
              ),
            );
          }),
        ),
      ],
    );
  }
  void _showMoleculeImage(MoleculeData molecule) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20), // Add space above the image
            Image.asset('assets/images/${molecule.playerOwns ? molecule.png : "mystery.png"}'),
            SizedBox(height: 20),
            if (molecule.playerOwns && molecule.number % 2 == 0) // Check if the molecule is natural
              if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS))
                GoogleWalletButton(
                  style: GoogleWalletButtonStyle.condensed,
                  height: 90,
                  onPressed: () {
                    Navigator.of(context).pop();
                    _saveMoleculePassToWallet(molecule.jwt);
                  },
                )
              else // For platforms other than iOS or Android, and not web
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    _savePassBrowser(molecule.jwt); // Attempt to save to wallet through browser
                  },
                  child: Text('Add to Wallet'),
                ),
          ],
        ),
      ),
    );
  }


  void _saveMoleculePassToWallet(String jwt) async {
    final googleWallet = GoogleWallet();
    try {
      final bool? saved = await googleWallet.savePassesJwt(jwt);
      if (saved == true) {
        _showFeedback(context, "Added to wallet successfully");
      } else {
        print("Failed to add molecule pass to Google Wallet.");
        _savePassBrowser(jwt);
      }
    } catch (e) {
      print("Error saving pass to Google Wallet: '${e.toString()}'.");
      _savePassBrowser(jwt);
    }
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _savePassBrowser(String jwt) async {
    String url = "https://pay.google.com/gp/v/save/$jwt";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('Could not open Google Wallet via web.');
    }
  }
}
