import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Comment {
  final int commentId;
  final int productId;
  final String productName;
  final String commentt;
  final int customerId;
  final String customerName;
  final int point;
  final DateTime createdDate;

  Comment({
    required this.commentId,
    required this.productId,
    required this.productName,
    required this.commentt,
    required this.customerId,
    required this.customerName,
    required this.point,
    required this.createdDate,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['commentId'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      commentt: json['commentt'] ?? '',
      customerId: json['customerId'] ?? 0,
      customerName: json['customerName'] ?? '',
      point: json['point'] ?? 0,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate']) : DateTime.now(),
    );
  }
}

class CommentListScreen extends StatefulWidget {
  @override
  _CommentListScreenState createState() => _CommentListScreenState();
}

class _CommentListScreenState extends State<CommentListScreen> {
  late List<Comment> comments = [];

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      // Handle token not found error
      return;
    }

    final response = await http.get(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Customer/GetCommentForCustomer'),
      headers: {
        'Authorization': 'Bearer $token',
        'accept': 'text/plain',
      },
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> commentsJson = jsonDecode(response.body)['comments'];
        setState(() {
          comments = commentsJson.map((json) => Comment.fromJson(json)).toList();
        });
      } catch (e) {
        print('Error parsing JSON: $e');
      }
    } else {
      print('Failed to fetch comments: ${response.statusCode}');
    }
  }

  Future<void> deleteComment(int commentId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      // Handle token not found error
      return;
    }

    final response = await http.put(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Customer/DeleteComment'),
      headers: {
        'Authorization': 'Bearer $token',
        'accept': 'text/plain',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'commentId': commentId}),
    );

    if (response.statusCode == 200) {
      // Yorum listesini güncelleme veya tekrar API'yi çağırma gibi işlemler yapılabilir
      setState(() {
        comments.removeWhere((comment) => comment.commentId == commentId);
      });
      print('Comment deleted');
    } else {
      print('Failed to delete comment: ${response.statusCode}');
    }
  }

  Future<void> updateComment(Comment comment) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      // Handle token not found error
      return;
    }

    final response = await http.put(
      Uri.parse('http://fruitmanagement.softsense.com.tr/api/Customer/UpdateCommentToProduct'),
      headers: {
        'Authorization': 'Bearer $token',
        'accept': 'text/plain',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'commentId': comment.commentId,
        'comment': comment.commentt,
        'point': comment.point,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        final index = comments.indexWhere((c) => c.commentId == comment.commentId);
        if (index != -1) {
          comments[index] = comment;
        }
      });
      print('Comment updated');
    } else {
      print('Failed to update comment: ${response.statusCode}');
    }
  }

  void showEditDialog(Comment comment) {
    TextEditingController commentController = TextEditingController(text: comment.commentt);
    TextEditingController pointController = TextEditingController(text: comment.point.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yorumu Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: commentController,
                decoration: InputDecoration(labelText: 'Yorum'),
              ),
              TextField(
                controller: pointController,
                decoration: InputDecoration(labelText: 'Puan'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Kaydet'),
              onPressed: () {
                final updatedComment = Comment(
                  commentId: comment.commentId,
                  productId: comment.productId,
                  productName: comment.productName,
                  commentt: commentController.text,
                  customerId: comment.customerId,
                  customerName: comment.customerName,
                  point: int.parse(pointController.text),
                  createdDate: comment.createdDate,
                );
                updateComment(updatedComment);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yorumlarım'),
      ),
      body: comments.isNotEmpty
          ? ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.grey[200],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.productName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(comment.commentt),
                            SizedBox(height: 8.0),
                            Text(
                              'Puan: ${comment.point}',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showEditDialog(comment);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteComment(comment.commentId);
                        },
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
