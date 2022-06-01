import 'package:flutter/cupertino.dart';
import 'package:mynotes/views/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context){
  return showGenericDialog<bool>(
    context: context, 
    title: 'Delete', 
    content: 'Are you sure you want to delete?', 
    optionBuilder: () =>{
      'Yes': true,
      'No': false,
    }
    ).then((value) => value ?? false);
}