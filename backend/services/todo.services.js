const TodoModel = require("../model/todo.model");

class TodoServices {
  static async createTodo(userId, title, desc) {
    const createTodo = new TodoModel({ userId, title, desc });
    return await createTodo.save();
  }

  static async getTododata(userId) {
    const userdata = await TodoModel.find({ userId });
    return userdata;
  }

  // static async deleteTodo(todoId, userId) {
  //   return await TodoModel.deleteOne({ _id: todoId, userId });
  // }
}

module.exports = TodoServices;
