import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/pages/chat_page.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListingSelectionPage extends StatefulWidget {
  final List<String> locations;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const ListingSelectionPage({
    super.key,
    required this.locations,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<ListingSelectionPage> createState() => _ListingSelectionPageState();
}

class _ListingSelectionPageState extends State<ListingSelectionPage> {
  // instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Listings")),
      body: _buildUserList(),
    );
  }

  // build a list of users except for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('listings').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading..');
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  // build individual user list items
  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> listing = document.data()! as Map<String, dynamic>;
    final TimeOfDay listingStartTime = Listing.minutesToTOD(
      listing['timeStart'],
    );
    final TimeOfDay listingEndTime = Listing.minutesToTOD(listing['timeEnd']);

    // display all listings with a selection location
    // TODO: add PaymentType filtering here
    // TODO: add a date selector and only display the listings on that date
    // TODO: add a filter to stop people from seeing their own posts (compare uid of current user to listing sellerID)
    if (widget.locations.contains(listing['diningHall'])) {
      return ListTile(
        // change this from a listTile to a custom componenent that will take arguments and spit out smth beautiful
        // need to add ratings somehow, probably easiest to do it through the listing itself with another content field
        // TODO: find overlap% between the buyer and possible sellers
        title: Text(
          "${listingStartTime.hour}:${listingStartTime.minute.toString().padLeft(2, '0')} to ${listingEndTime.hour}:${listingEndTime.minute.toString().padLeft(2, '0')} @ ${listing['diningHall']}",
        ),
        onTap: () {
          // open a confimation screen
          print("Selected this one woo");
        },
      );
    } else {
      return Container();
    }
  }
}
