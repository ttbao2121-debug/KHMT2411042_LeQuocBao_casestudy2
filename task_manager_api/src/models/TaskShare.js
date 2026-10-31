const mongoose = require('mongoose');

const taskShareSchema = new mongoose.Schema(
  {
    taskId: { type: mongoose.Schema.Types.ObjectId, ref: 'Task', required: true },
    sharedWithUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    permission: { type: String, enum: ['readOnly', 'edit'], default: 'readOnly' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('TaskShare', taskShareSchema);
