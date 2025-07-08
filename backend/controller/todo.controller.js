const TodoService = require('../services/todo.services');

exports.createTodo = async (req, res, next) => {
  try {
    const { userId, title, desc } = req.body;
    const todo = await TodoService.createTodo(userId, title, desc);

    res.status(201).json({
      status: true,
      success: todo,
    });
  } catch (error) {
    next(error);
  }
};

exports.getUserTodo = async (req, res, next) => {
  try {
    const { userId } = req.body;
    const todo = await TodoService.getTododata(userId);

    res.status(200).json({
      status: true,
      success: todo,
    });
  } catch (error) {
    next(error);
  }
};

// exports.deleteTodo = async (req, res, next) => {
//   try {
//     const { todoId, userId } = req.body;
//     await TodoService.deleteTodo(todoId, userId);

//     res.status(200).json({
//       status: true,
//       message: "Todo deleted successfully",
//     });
//   } catch (error) {
//     next(error);
//   }
// };

module.exports = {
  createTodo: exports.createTodo,
  getUserTodo: exports.getUserTodo,
  //deleteTodo: exports.deleteTodo,
};
