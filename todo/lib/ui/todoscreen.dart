import 'package:flutter/material.dart';
import 'package:todo/model/todo_item.dart';
import 'package:todo/util/database_client.dart';
import 'package:todo/util/dateformatter.dart';
class TodoScreen extends StatefulWidget {
  const TodoScreen({Key key}) : super(key: key);

  @override
  _TodoScreenState createState() =>new _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _textEditingController= new TextEditingController();
  var db= new DatabaseHelper();
  final List<TodoItem> _itemlist= <TodoItem>[];


  @override
  void initState() {
    super.initState();
    _readTodoList();
  }

  void _handleSubmitted(String text) async{
    _textEditingController.clear();
    TodoItem todoItem= new TodoItem(text, dateFormatted());
    int savedItem= await db.saveItem(todoItem);
    TodoItem addedItem= await db.getItem(savedItem);


    setState(() {
      _itemlist.insert(0, addedItem);

    });

    print("Item saved id: $savedItem");
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: <Widget>[
          new Flexible(
            child: new ListView.builder(
              padding: new EdgeInsets.all(8.0),
              reverse: false,
              itemCount: _itemlist.length,
              itemBuilder: (_, int index){
                return new Card(
                  color: Colors.white10,
                  child: new ListTile(
                    title: _itemlist[index],
                    onLongPress: ()=>_updateItem(_itemlist[index], index),
                    trailing: new Listener(
                      key: new Key(_itemlist[index].itemName),
                      child: new Icon(Icons.remove_circle, color: Colors.redAccent,),
                      onPointerDown: (pointerEver)=>
                      _deleteTodo(_itemlist[index].id, index ),
                    ),
                  ),
                );
              },
            ),
          ),
          new Divider(
            height: 1.0,
          )
        ],
      ),


      floatingActionButton: new FloatingActionButton(
        tooltip: "Add Item",
          backgroundColor: Colors.redAccent,
          child: new ListTile(
            title: new Icon(Icons.add),
          ),
          onPressed: _showFormDialog),

    );
  }

  void _showFormDialog() {
    var alert= new AlertDialog(
      content: new Row(
        children: <Widget>[
          new Expanded(
            child: new Expanded(
              child: new TextField(
                controller: _textEditingController,
              autofocus: true,
              decoration: new InputDecoration(
                labelText: "Item",
                hintText: "e.g. Don't buy stuff",
                icon: new Icon(Icons.note_add)
              ),),
            ),
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: (){

              _handleSubmitted(_textEditingController.text);
              _textEditingController.clear();
              Navigator.pop(context);
            },
            child: Text("Save")
        ),
        new FlatButton(onPressed: ()=> Navigator.pop(context), child: Text("Cancel"))
      ],
    );
    showDialog(context: context, builder: (_){
      return alert;
    });
  }
  _readTodoList() async{
    List items= await db.getItems();
    items.forEach((item){
      //TodoItem todoItem= TodoItem.map(item );
      setState(() {
        _itemlist.add(TodoItem.map(item));
      });
      //print("Do items: ${todoItem.itemName}");
    }

    );
  }

  _deleteTodo(int id, int index)async {
    debugPrint("Deleted Item!");
    await db.deleteItem(id);
    setState(() {
      _itemlist.removeAt(index);
    });


  }

  _updateItem(TodoItem item, int index) {
    var alert= new AlertDialog(
      title: new Text("Update Item"),
      content: new Row(
        children: <Widget>[
          new Expanded(
            child:  new TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: new InputDecoration(
                labelText: "Item",
                hintText: "e.g. Don't buy stuff",
                icon: new Icon(Icons.update)
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(onPressed: () async{
          TodoItem newItemUpdated= TodoItem.fromMap(
            {
              "itemName": _textEditingController.text,
              "dateCreated": dateFormatted(),
              "id": item.id
            }
          );
          _handleSubmittedUpdate(index, item);
          await db.updateItem(newItemUpdated);
          setState(() {
            _readTodoList();
          });
          Navigator.pop(context);
        },
            child: new Text("Update")),
        new FlatButton(onPressed: ()=>Navigator.pop(context),
            child: new Text("Cancle"))
      ],
    );
    showDialog(context: context, builder: (_){
      return alert;
    });
  }

  void _handleSubmittedUpdate(int index, TodoItem item) {
    setState(() {
      _itemlist.removeWhere((element) {
        _itemlist[index].itemName== item.itemName;
      });
    });
  }
}
