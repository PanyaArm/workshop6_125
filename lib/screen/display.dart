import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  final _firestore = FirebaseFirestore.instance;

  // ==================== ลบข้อมูล ====================
  Future<void> deleteStudent(String documentId) async {
    await _firestore.collection('student').doc(documentId).delete();
  }

  Future<void> showDeleteConfirmation(String documentId) async {
    return await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('ยืนยันการลบข้อมูล'),
          content: const Text('คุณต้องการลบข้อมูลจริงๆ ใช่ไหมครับ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                await deleteStudent(documentId);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('ลบ'),
            ),
          ],
        );
      },
    );
  }

  // ==================== แก้ไขข้อมูล (งานเพิ่มเติม) ====================
  Future<void> updateStudent(String documentId, Map<String, dynamic> data) async {
    await _firestore.collection('student').doc(documentId).update(data);
  }

  Future<void> showEditDialog(QueryDocumentSnapshot document) async {
    final editKey = GlobalKey<FormState>();
    // ใส่ข้อมูลเดิมลงในช่องกรอก
    final fnameCtrl = TextEditingController(text: document["fname"]);
    final lnameCtrl = TextEditingController(text: document["lname"]);
    final emailCtrl = TextEditingController(text: document["email"]);
    final scoreCtrl = TextEditingController(text: document["score"]);

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('แก้ไขข้อมูลนักเรียน'),
          content: Form(
            key: editKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: fnameCtrl,
                    decoration: const InputDecoration(labelText: 'ชื่อ'),
                    validator: RequiredValidator(errorText: "กรุณาป้อนชื่อด้วยครับ").call,
                  ),
                  TextFormField(
                    controller: lnameCtrl,
                    decoration: const InputDecoration(labelText: 'นามสกุล'),
                    validator: RequiredValidator(errorText: "กรุณาป้อนนามสกุลด้วยครับ").call,
                  ),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'อีเมล์'),
                    keyboardType: TextInputType.emailAddress,
                    validator: MultiValidator([
                      EmailValidator(errorText: "รูปแบบอีเมล์ไม่ถูกต้อง"),
                      RequiredValidator(errorText: "กรุณาป้อนอีเมล์ด้วยครับ"),
                    ]).call,
                  ),
                  TextFormField(
                    controller: scoreCtrl,
                    decoration: const InputDecoration(labelText: 'คะแนน'),
                    keyboardType: TextInputType.number,
                    validator: RequiredValidator(errorText: "กรุณาป้อนคะแนนสอบด้วยครับ").call,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                if (editKey.currentState!.validate()) {
                  await updateStudent(document.id, {
                    "fname": fnameCtrl.text,
                    "lname": lnameCtrl.text,
                    "email": emailCtrl.text,
                    "score": scoreCtrl.text,
                  });
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                }
              },
              child: const Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }

  // ==================== หน้าแสดงรายการ ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายงานคะแนนสอบ"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 138, 224, 174),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("student").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final document = snapshot.data!.docs[index];
              return Container(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    child: FittedBox(child: Text(document["score"])),
                  ),
                  title: Text(document["fname"] + " " + document["lname"]),
                  subtitle: Text(document["email"]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ปุ่มแก้ไข (งานเพิ่มเติม)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await showEditDialog(document);
                        },
                      ),
                      // ปุ่มลบ
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await showDeleteConfirmation(document.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}